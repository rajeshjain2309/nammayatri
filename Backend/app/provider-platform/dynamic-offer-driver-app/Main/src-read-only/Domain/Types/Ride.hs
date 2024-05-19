{-# LANGUAGE ApplicativeDo #-}
{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Domain.Types.Ride where

import Data.Aeson
import qualified Domain.Types.Booking
import qualified Domain.Types.Client
import qualified Domain.Types.Common
import qualified Domain.Types.Driver.GoHomeFeature.DriverGoHomeRequest
import qualified Domain.Types.FareParameters
import qualified Domain.Types.Location
import qualified Domain.Types.Merchant
import qualified Domain.Types.Merchant.MerchantOperatingCity
import qualified Domain.Types.Person
import qualified IssueManagement.Domain.Types.MediaFile
import qualified Kernel.External.Maps
import Kernel.Prelude
import qualified Kernel.Types.Common
import qualified Kernel.Types.Id
import qualified Kernel.Types.Version
import Kernel.Utils.TH
import qualified Tools.Beam.UtilsTH

data Ride = Ride
  { backendAppVersion :: Kernel.Prelude.Maybe Kernel.Prelude.Text,
    backendConfigVersion :: Kernel.Prelude.Maybe Kernel.Types.Version.Version,
    bookingId :: Kernel.Types.Id.Id Domain.Types.Booking.Booking,
    chargeableDistance :: Kernel.Prelude.Maybe Kernel.Types.Common.Meters,
    clientBundleVersion :: Kernel.Prelude.Maybe Kernel.Types.Version.Version,
    clientConfigVersion :: Kernel.Prelude.Maybe Kernel.Types.Version.Version,
    clientDevice :: Kernel.Prelude.Maybe Kernel.Types.Version.Device,
    clientId :: Kernel.Prelude.Maybe (Kernel.Types.Id.Id Domain.Types.Client.Client),
    clientSdkVersion :: Kernel.Prelude.Maybe Kernel.Types.Version.Version,
    createdAt :: Kernel.Prelude.UTCTime,
    currency :: Kernel.Types.Common.Currency,
    distanceCalculationFailed :: Kernel.Prelude.Maybe Kernel.Prelude.Bool,
    driverArrivalTime :: Kernel.Prelude.Maybe Kernel.Prelude.UTCTime,
    driverDeviatedFromRoute :: Kernel.Prelude.Maybe Kernel.Prelude.Bool,
    driverDeviatedToTollRoute :: Kernel.Prelude.Maybe Kernel.Prelude.Bool,
    driverGoHomeRequestId :: Kernel.Prelude.Maybe (Kernel.Types.Id.Id Domain.Types.Driver.GoHomeFeature.DriverGoHomeRequest.DriverGoHomeRequest),
    driverId :: Kernel.Types.Id.Id Domain.Types.Person.Person,
    enableFrequentLocationUpdates :: Kernel.Prelude.Maybe Kernel.Prelude.Bool,
    endOdometerReading :: Kernel.Prelude.Maybe Domain.Types.Ride.OdometerReading,
    endOtp :: Kernel.Prelude.Maybe Kernel.Prelude.Text,
    estimatedTollCharges :: Kernel.Prelude.Maybe Kernel.Types.Common.HighPrecMoney,
    estimatedTollNames :: Kernel.Prelude.Maybe [Kernel.Prelude.Text],
    fare :: Kernel.Prelude.Maybe Kernel.Types.Common.HighPrecMoney,
    fareParametersId :: Kernel.Prelude.Maybe (Kernel.Types.Id.Id Domain.Types.FareParameters.FareParameters),
    fromLocation :: Domain.Types.Location.Location,
    id :: Kernel.Types.Id.Id Domain.Types.Ride.Ride,
    isAdvanceBooking :: Kernel.Prelude.Bool,
    isFreeRide :: Kernel.Prelude.Maybe Kernel.Prelude.Bool,
    merchantId :: Kernel.Prelude.Maybe (Kernel.Types.Id.Id Domain.Types.Merchant.Merchant),
    merchantOperatingCityId :: Kernel.Types.Id.Id Domain.Types.Merchant.MerchantOperatingCity.MerchantOperatingCity,
    numberOfDeviation :: Kernel.Prelude.Maybe Kernel.Prelude.Bool,
    numberOfOsrmSnapToRoadCalls :: Kernel.Prelude.Maybe Kernel.Prelude.Int,
    numberOfSelfTuned :: Kernel.Prelude.Maybe Kernel.Prelude.Int,
    numberOfSnapToRoadCalls :: Kernel.Prelude.Maybe Kernel.Prelude.Int,
    otp :: Kernel.Prelude.Text,
    pickupDropOutsideOfThreshold :: Kernel.Prelude.Maybe Kernel.Prelude.Bool,
    previousRideTripEndPos :: Kernel.Prelude.Maybe Kernel.External.Maps.LatLong,
    rideEndedBy :: Kernel.Prelude.Maybe Domain.Types.Ride.RideEndedBy,
    safetyAlertTriggered :: Kernel.Prelude.Bool,
    shortId :: Kernel.Types.Id.ShortId Domain.Types.Ride.Ride,
    startOdometerReading :: Kernel.Prelude.Maybe Domain.Types.Ride.OdometerReading,
    status :: Domain.Types.Ride.RideStatus,
    toLocation :: Kernel.Prelude.Maybe Domain.Types.Location.Location,
    tollCharges :: Kernel.Prelude.Maybe Kernel.Types.Common.HighPrecMoney,
    tollConfidence :: Kernel.Prelude.Maybe Domain.Types.Ride.Confidence,
    tollNames :: Kernel.Prelude.Maybe [Kernel.Prelude.Text],
    trackingUrl :: Kernel.Types.Common.BaseUrl,
    traveledDistance :: Kernel.Types.Common.HighPrecMeters,
    tripCategory :: Domain.Types.Common.TripCategory,
    tripEndPos :: Kernel.Prelude.Maybe Kernel.External.Maps.LatLong,
    tripEndTime :: Kernel.Prelude.Maybe Kernel.Prelude.UTCTime,
    tripStartPos :: Kernel.Prelude.Maybe Kernel.External.Maps.LatLong,
    tripStartTime :: Kernel.Prelude.Maybe Kernel.Prelude.UTCTime,
    uiDistanceCalculationWithAccuracy :: Kernel.Prelude.Maybe Kernel.Prelude.Int,
    uiDistanceCalculationWithoutAccuracy :: Kernel.Prelude.Maybe Kernel.Prelude.Int,
    updatedAt :: Kernel.Prelude.UTCTime,
    vehicleServiceTierAirConditioned :: Kernel.Prelude.Maybe Kernel.Prelude.Double,
    vehicleServiceTierSeatingCapacity :: Kernel.Prelude.Maybe Kernel.Prelude.Int
  }
  deriving (Generic, Show)

data Confidence = Sure | Unsure | Neutral deriving (Eq, Ord, Show, Read, Generic, ToJSON, FromJSON, ToSchema, ToParamSchema)

data OdometerReading = OdometerReading {fileId :: Kernel.Prelude.Maybe (Kernel.Types.Id.Id IssueManagement.Domain.Types.MediaFile.MediaFile), value :: Kernel.Types.Common.Centesimal}
  deriving (Generic, Show, ToJSON, FromJSON, ToSchema, Eq)

data RideEndedBy = Driver | Dashboard | CallBased | CronJob deriving (Eq, Ord, Show, Read, Generic, ToJSON, FromJSON, ToSchema)

data RideStatus = NEW | INPROGRESS | COMPLETED | CANCELLED deriving (Eq, Ord, Show, Read, Generic, ToJSON, FromJSON, ToSchema, ToParamSchema)

$(Tools.Beam.UtilsTH.mkBeamInstancesForEnumAndList ''Confidence)

$(mkHttpInstancesForEnum ''Confidence)

$(Tools.Beam.UtilsTH.mkBeamInstancesForEnumAndList ''RideEndedBy)

$(Tools.Beam.UtilsTH.mkBeamInstancesForEnumAndList ''RideStatus)

$(mkHttpInstancesForEnum ''RideStatus)
