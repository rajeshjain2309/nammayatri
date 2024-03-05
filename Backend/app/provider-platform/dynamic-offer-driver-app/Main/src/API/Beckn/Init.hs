{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module API.Beckn.Init (API, handler) where

import qualified Beckn.ACL.Init as ACL
import qualified Beckn.ACL.OnInit as ACL
import qualified Beckn.OnDemand.Utils.Callback as Callback
import qualified Beckn.OnDemand.Utils.Common as Utils
import qualified Beckn.Types.Core.Taxi.API.Init as Init
import Beckn.Types.Core.Taxi.API.OnInit as OnInit
import qualified BecknV2.OnDemand.Types as Spec
import qualified BecknV2.OnDemand.Utils.Context as ContextV2
import BecknV2.Utils
import qualified Domain.Action.Beckn.Init as DInit
import qualified Domain.Types.Merchant as DM
import Environment
import Kernel.Prelude hiding (init)
import qualified Kernel.Storage.Hedis as Redis
import Kernel.Types.Beckn.Ack
import qualified Kernel.Types.Beckn.Context as Context
import qualified Kernel.Types.Beckn.Domain as Domain
import Kernel.Types.Error
import Kernel.Types.Id
import Kernel.Types.TimeRFC339 (convertRFC3339ToUTC)
import Kernel.Utils.Common
import Kernel.Utils.Error.BaseError.HTTPError.BecknAPIError
import Kernel.Utils.Servant.SignatureAuth
import Servant hiding (throwError)
import qualified SharedLogic.Booking as SBooking
import qualified SharedLogic.FarePolicy as SFP
import Storage.Beam.SystemConfigs ()
import qualified Storage.CachedQueries.BecknConfig as QBC

type API =
  Capture "merchantId" (Id DM.Merchant)
    :> SignatureAuth 'Domain.MOBILITY "Authorization"
    :> Init.InitAPIV2

handler :: FlowServer API
handler = init

init ::
  Id DM.Merchant ->
  SignatureAuthResult ->
  Init.InitReqV2 ->
  FlowHandler AckResponse
init transporterId (SignatureAuthResult _ subscriber) reqV2 = withFlowHandlerBecknAPI $ do
  transactionId <- Utils.getTransactionId reqV2.initReqContext
  Utils.withTransactionIdLogTag transactionId $ do
    logTagInfo "Init APIV2 Flow" "Reached"
    (dInitReq, bapUri, bapId, msgId, city, country, bppId, bppUri) <- do
      dInitReq <- ACL.buildInitReqV2 subscriber reqV2
      let context = reqV2.initReqContext
      callbackUrl <- Utils.getContextBapUri context
      bppUri <- Utils.getContextBppUri context
      messageId <- Utils.getMessageId context
      bapId <- Utils.getContextBapId context
      city <- Utils.getContextCity context
      country <- Utils.getContextCountry context
      pure (dInitReq, callbackUrl, bapId, messageId, city, country, context.contextBppId, bppUri)

    let txnId = Just transactionId
        initFulfillmentId =
          case dInitReq.fulfillmentId of
            DInit.DriverQuoteId (Id fId) -> fId
            DInit.QuoteId (Id fId) -> fId
    now <- getCurrentTime
    initTtl <- reqV2.initReqContext.contextTtl & fromMaybeM (InvalidRequest "Missing ttl")
    timestamp <- reqV2.initReqContext.contextTimestamp >>= Just . convertRFC3339ToUTC & fromMaybeM (InvalidRequest "Missing timestamp")
    let validTill = addDurationToUTCTime timestamp (fromJust (parseISO8601Duration initTtl))
    when (validTill < now) $ throwError $ InvalidRequest "Init request has expired"
    Redis.whenWithLockRedis (initLockKey initFulfillmentId) 60 $ do
      validatedRes <- DInit.validateRequest transporterId dInitReq
      fork "init request processing" $ do
        Redis.whenWithLockRedis (initProcessingLockKey initFulfillmentId) 60 $ do
          dInitRes <- DInit.handler transporterId dInitReq validatedRes
          internalEndPointHashMap <- asks (.internalEndPointHashMap)
          let vehicleCategory = Utils.mapVariantToVehicle dInitRes.booking.vehicleVariant
          bppConfig <- QBC.findByMerchantIdDomainAndVehicle dInitRes.transporter.id (show Context.MOBILITY) vehicleCategory >>= fromMaybeM (InternalError "Beckn Config not found")
          ttlInInt <- bppConfig.onInitTTLSec & fromMaybeM (InternalError "Invalid ttl")
          let ttlToNominalDiffTime = intToNominalDiffTime ttlInInt
              ttlToISO8601Duration = formatTimeDifference ttlToNominalDiffTime
          context <- ContextV2.buildContextV2 Context.ON_INIT Context.MOBILITY msgId txnId bapId bapUri bppId bppUri city country (Just ttlToISO8601Duration)
          void . handle (errHandler dInitRes.booking dInitRes.transporter) $
            Callback.withCallback dInitRes.transporter "INIT" OnInit.onInitAPIV2 bapUri internalEndPointHashMap (errHandlerV2 context) $ do
              mbFarePolicy <- SFP.getFarePolicyByEstOrQuoteIdWithoutFallback dInitRes.booking.quoteId
              let onInitMessage = ACL.mkOnInitMessageV2 dInitRes bppConfig mbFarePolicy
              pure $
                Spec.OnInitReq
                  { onInitReqContext = context,
                    onInitReqError = Nothing,
                    onInitReqMessage = Just onInitMessage
                  }
    pure Ack
  where
    errHandler booking transporter exc
      | Just BecknAPICallError {} <- fromException @BecknAPICallError exc = SBooking.cancelBooking booking Nothing transporter >> pure Ack
      | Just ExternalAPICallError {} <- fromException @ExternalAPICallError exc = SBooking.cancelBooking booking Nothing transporter >> pure Ack
      | otherwise = throwM exc

initLockKey :: Text -> Text
initLockKey id = "Driver:Init:DriverQuoteId-" <> id

initProcessingLockKey :: Text -> Text
initProcessingLockKey id = "Driver:Init:Processing:DriverQuoteId-" <> id

errHandlerV2 :: Spec.Context -> BecknAPIError -> Spec.OnInitReq
errHandlerV2 context (BecknAPIError err) =
  Spec.OnInitReq
    { onInitReqContext = context,
      onInitReqError = Just err',
      onInitReqMessage = Nothing
    }
  where
    err' =
      Spec.Error
        { errorCode = Just err.code,
          errorMessage = err.message >>= \m -> Just $ encodeToText err._type <> " " <> m,
          errorPaths = err.path
        }
