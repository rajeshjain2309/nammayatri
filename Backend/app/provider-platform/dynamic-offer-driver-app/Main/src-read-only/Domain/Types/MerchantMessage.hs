{-# LANGUAGE ApplicativeDo #-}
{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -Wno-dodgy-exports #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Domain.Types.MerchantMessage (module Domain.Types.MerchantMessage, module ReExport) where

import Data.Aeson
import Domain.Types.Common (UsageSafety (..))
import Domain.Types.Extra.MerchantMessage as ReExport
import qualified Domain.Types.Extra.MerchantMessage
import qualified Domain.Types.Merchant
import qualified Domain.Types.MerchantOperatingCity
import Kernel.Prelude
import qualified Kernel.Types.Id
import qualified Tools.Beam.UtilsTH

data MerchantMessageD (s :: UsageSafety) = MerchantMessage
  { containsUrlButton :: Kernel.Prelude.Bool,
    createdAt :: Kernel.Prelude.UTCTime,
    jsonData :: Domain.Types.Extra.MerchantMessage.MerchantMessageDefaultDataJSON,
    merchantId :: Kernel.Types.Id.Id Domain.Types.Merchant.Merchant,
    merchantOperatingCityId :: Kernel.Types.Id.Id Domain.Types.MerchantOperatingCity.MerchantOperatingCity,
    message :: Kernel.Prelude.Text,
    messageKey :: Domain.Types.MerchantMessage.MessageKey,
    templateId :: Kernel.Prelude.Text,
    updatedAt :: Kernel.Prelude.UTCTime
  }
  deriving (Generic, Show)

data MediaChannel = SMS | WHATSAPP | OVERLAY | ALERT deriving (Eq, Ord, Show, Read, Generic, ToJSON, FromJSON, ToSchema)

data MessageKey
  = SEND_OTP
  | WELCOME_TO_PLATFORM
  | ALTERNATE_NUMBER_OTP
  | ONBOARD_SUPPORT_SMS_TEMPLATE
  | END_RIDE_MESSAGE
  | ONBOARDING_YATRI_MESSAGE
  | BOOKING_MESSAGE
  | CASH_COLLECTED_MESSAGE
  | SEND_PAYMENT_LINK
  | WHATSAPP_CLEAR_DUES_CALL_MISSED_MESSAGE
  | WHATSAPP_CLEAR_DUES_MESSAGE
  | WHATSAPP_CLEAR_DUES_MESSAGE_TO_BLOCKED_DRIVERS
  | WHATSAPP_SETUP_AUTOPAY_MESSAGE
  | WHATSAPP_SWITCH_PLAN_MESSAGE
  | WHATSAPP_HOW_IT_WORKS_MESSAGE
  | SMS_CLEAR_DUES_CALL_MISSED_MESSAGE
  | SMS_CLEAR_DUES_MESSAGE
  | SMS_CLEAR_DUES_MESSAGE_TO_BLOCKED_DRIVERS
  | SMS_SETUP_AUTOPAY_MESSAGE
  | SMS_SWITCH_PLAN_MESSAGE
  | SMS_HOW_IT_WORKS_MESSAGE
  | WHATSAPP_SETUP_MANDATE_MESSAGE
  | WHATSAPP_VEHICLE_UNLINKED_MESSAGE
  | WHATSAPP_VEHICLE_LINKED_MESSAGE
  | YATRI_RENTAL_PAUSE
  | YATRI_RENTAL_RESUME
  | WHATSAPP_SEND_MANUAL_PAYMENT_LINK
  deriving (Eq, Ord, Show, Read, Generic, ToJSON, FromJSON, ToSchema)

type MerchantMessage = MerchantMessageD 'Safe

instance FromJSON (MerchantMessageD 'Unsafe)

instance ToJSON (MerchantMessageD 'Unsafe)

instance FromJSON (MerchantMessageD 'Safe)

instance ToJSON (MerchantMessageD 'Safe)

$(Tools.Beam.UtilsTH.mkBeamInstancesForEnumAndList ''MediaChannel)

$(Tools.Beam.UtilsTH.mkBeamInstancesForEnumAndList ''MessageKey)