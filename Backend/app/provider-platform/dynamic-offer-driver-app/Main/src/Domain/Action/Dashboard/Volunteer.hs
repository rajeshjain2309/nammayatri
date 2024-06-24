{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Domain.Action.Dashboard.Volunteer where

import qualified "dashboard-helper-api" Dashboard.Common as Common
import qualified "dashboard-helper-api" Dashboard.ProviderPlatform.Volunteer as Common
import qualified Domain.Action.UI.Ride as DRide
import qualified Domain.Action.UI.Ride.StartRide as RideStart
import qualified Domain.Types.Booking as Domain
import qualified Domain.Types.Location as Domain
import qualified Domain.Types.Merchant as DM
import qualified Domain.Types.ServiceTierType as DVST
import Environment
import Kernel.Beam.Functions
import Kernel.Prelude
import qualified Kernel.Storage.Hedis as Redis
import Kernel.Types.APISuccess (APISuccess (Success))
import qualified Kernel.Types.Beckn.Context as Context
import Kernel.Types.Common (Forkable (fork), MonadTime (getCurrentTime), PriceAPIEntity (..), convertMetersToDistance)
import Kernel.Types.Id
import Kernel.Utils.Common (fromMaybeM)
import SharedLogic.Merchant (findMerchantByShortId)
import SharedLogic.Person (findPerson)
import qualified SharedLogic.Ride as SRide
import qualified Storage.Cac.TransporterConfig as CTC
import qualified Storage.CachedQueries.Merchant.MerchantOperatingCity as CQMOC
import qualified Storage.Queries.Booking as QBooking
import qualified Storage.Queries.Ride as QRide
import Tools.Error
import qualified Tools.SMS as Sms

bookingInfo :: ShortId DM.Merchant -> Context.City -> Text -> Flow Common.BookingInfoResponse
bookingInfo merchantShortId opCity otpCode = do
  merchant <- findMerchantByShortId merchantShortId
  now <- getCurrentTime
  merchantOpCityId <- CQMOC.getMerchantOpCityId Nothing merchant (Just opCity)
  transporterConfig <- CTC.findByMerchantOpCityId merchantOpCityId Nothing >>= fromMaybeM (TransporterConfigNotFound merchantOpCityId.getId)
  booking <- runInReplica $ QBooking.findBookingBySpecialZoneOTP merchantOpCityId.getId otpCode now transporterConfig.specialZoneBookingOtpExpiry >>= fromMaybeM (BookingNotFoundForSpecialZoneOtp otpCode)
  return $ buildMessageInfoResponse booking
  where
    buildMessageInfoResponse Domain.Booking {..} =
      Common.BookingInfoResponse
        { bookingId = cast id,
          fromLocation = buildBookingLocation fromLocation,
          toLocation = buildBookingLocation <$> toLocation,
          estimatedDistance,
          estimatedDistanceWithUnit = convertMetersToDistance distanceUnit <$> estimatedDistance,
          estimatedFare = roundToIntegral estimatedFare,
          estimatedFareWithCurrency = PriceAPIEntity estimatedFare currency,
          estimatedDuration,
          riderName,
          vehicleVariant = convertVehicleVariant vehicleServiceTier
        }

    convertVehicleVariant DVST.SEDAN = Common.SEDAN
    convertVehicleVariant DVST.SUV = Common.SUV
    convertVehicleVariant DVST.HATCHBACK = Common.HATCHBACK
    convertVehicleVariant DVST.AUTO_RICKSHAW = Common.AUTO_RICKSHAW
    convertVehicleVariant DVST.TAXI = Common.TAXI
    convertVehicleVariant DVST.TAXI_PLUS = Common.TAXI_PLUS
    convertVehicleVariant DVST.ECO = Common.HATCHBACK
    convertVehicleVariant DVST.COMFY = Common.SEDAN
    convertVehicleVariant DVST.PREMIUM = Common.SEDAN
    convertVehicleVariant DVST.PREMIUM_SEDAN = Common.PREMIUM_SEDAN
    convertVehicleVariant DVST.BLACK = Common.BLACK
    convertVehicleVariant DVST.BLACK_XL = Common.BLACK_XL
    convertVehicleVariant DVST.BIKE = Common.BIKE
    convertVehicleVariant DVST.AMBULANCE_TAXI = Common.AMBULANCE_TAXI
    convertVehicleVariant DVST.AMBULANCE_TAXI_OXY = Common.AMBULANCE_TAXI_OXY
    convertVehicleVariant DVST.AMBULANCE_AC = Common.AMBULANCE_AC
    convertVehicleVariant DVST.AMBULANCE_AC_OXY = Common.AMBULANCE_AC_OXY
    convertVehicleVariant DVST.AMBULANCE_VENTILATOR = Common.AMBULANCE_VENTILATOR

    buildBookingLocation Domain.Location {..} =
      Common.Location
        { address = buildLocationAddress address,
          id = cast id,
          ..
        }

    buildLocationAddress Domain.LocationAddress {..} =
      Common.LocationAddress
        { ..
        }

assignCreateAndStartOtpRide :: ShortId DM.Merchant -> Context.City -> Common.AssignCreateAndStartOtpRideAPIReq -> Flow APISuccess
assignCreateAndStartOtpRide _ _ Common.AssignCreateAndStartOtpRideAPIReq {..} = do
  requestor <- findPerson (cast driverId)
  booking <- runInReplica $ QBooking.findById (cast bookingId) >>= fromMaybeM (BookingNotFound bookingId.getId)
  rideOtp <- booking.specialZoneOtpCode & fromMaybeM (InternalError "otpCode not found for special zone booking")
  Redis.whenWithLockRedis (SRide.confirmLockKey booking.id) 60 $ do
    ride <- DRide.otpRideCreate requestor rideOtp booking Nothing
    let driverReq = RideStart.DriverStartRideReq {rideOtp, point, requestor, odometer = Nothing}
    fork "sending dashboard sms - start ride" $ do
      mride <- runInReplica $ QRide.findById ride.id >>= fromMaybeM (RideDoesNotExist ride.id.getId)
      Sms.sendDashboardSms booking.providerId booking.merchantOperatingCityId Sms.BOOKING (Just mride) mride.driverId (Just booking) 0
    shandle <- RideStart.buildStartRideHandle requestor.merchantId booking.merchantOperatingCityId
    void $ RideStart.driverStartRide shandle ride.id driverReq
  return Success
