{-# OPTIONS_GHC -Wno-dodgy-exports #-}
{-# OPTIONS_GHC -Wno-orphans #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Storage.Queries.SearchRequest (module Storage.Queries.SearchRequest, module ReExport) where

import qualified Domain.Types.Person
import qualified Domain.Types.SearchRequest
import Kernel.Beam.Functions
import Kernel.External.Encryption
import Kernel.Prelude
import qualified Kernel.Prelude
import Kernel.Types.Error
import qualified Kernel.Types.Id
import Kernel.Utils.Common (CacheFlow, EsqDBFlow, MonadFlow, fromMaybeM, getCurrentTime)
import qualified Sequelize as Se
import qualified Storage.Beam.SearchRequest as Beam
import Storage.Queries.SearchRequestExtra as ReExport

updateAdvancedBookingEnabled :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => (Kernel.Prelude.Maybe Kernel.Prelude.Bool -> Kernel.Types.Id.Id Domain.Types.SearchRequest.SearchRequest -> m ())
updateAdvancedBookingEnabled isAdvanceBookingEnabled id = do updateOneWithKV [Se.Set Beam.isAdvanceBookingEnabled isAdvanceBookingEnabled] [Se.Is Beam.id $ Se.Eq (Kernel.Types.Id.getId id)]

updateTotalRidesCount ::
  (EsqDBFlow m r, MonadFlow m, CacheFlow m r) =>
  (Kernel.Types.Id.Id Domain.Types.SearchRequest.SearchRequest -> Kernel.Prelude.Maybe Kernel.Prelude.Int -> Kernel.Types.Id.Id Domain.Types.Person.Person -> m ())
updateTotalRidesCount id totalRidesCount riderId = do
  updateOneWithKV
    [ Se.Set Beam.id (Kernel.Types.Id.getId id),
      Se.Set Beam.totalRidesCount totalRidesCount
    ]
    [Se.Is Beam.riderId $ Se.Eq (Kernel.Types.Id.getId riderId)]
