{-# OPTIONS_GHC -Wno-orphans #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module API.Action.Dashboard.Revenue
  ( API.Types.ProviderPlatform.Revenue.API,
    handler,
  )
where

import qualified API.Types.ProviderPlatform.Revenue
import qualified Domain.Action.Dashboard.Revenue as Domain.Action.Dashboard.Revenue
import qualified Domain.Types.Merchant
import qualified Environment
import EulerHS.Prelude
import qualified Kernel.Prelude
import qualified Kernel.Types.Beckn.Context
import qualified Kernel.Types.Id
import Kernel.Utils.Common
import Servant
import Tools.Auth

handler :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Environment.FlowServer API.Types.ProviderPlatform.Revenue.API)
handler merchantId city = getRevenueCollectionHistory merchantId city :<|> getRevenueAllFeeHistory merchantId city

getRevenueCollectionHistory :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Kernel.Prelude.Maybe Kernel.Prelude.UTCTime -> Kernel.Prelude.Maybe Kernel.Prelude.Text -> Kernel.Prelude.Maybe Kernel.Prelude.UTCTime -> Kernel.Prelude.Maybe Kernel.Prelude.Text -> Environment.FlowHandler API.Types.ProviderPlatform.Revenue.CollectionList)
getRevenueCollectionHistory a6 a5 a4 a3 a2 a1 = withFlowHandlerAPI $ Domain.Action.Dashboard.Revenue.getRevenueCollectionHistory a6 a5 a4 a3 a2 a1

getRevenueAllFeeHistory :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Kernel.Prelude.Maybe Kernel.Prelude.UTCTime -> Kernel.Prelude.Maybe Kernel.Prelude.UTCTime -> Environment.FlowHandler [API.Types.ProviderPlatform.Revenue.AllFees])
getRevenueAllFeeHistory a4 a3 a2 a1 = withFlowHandlerAPI $ Domain.Action.Dashboard.Revenue.getRevenueAllFeeHistory a4 a3 a2 a1
