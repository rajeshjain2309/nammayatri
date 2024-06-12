{-# OPTIONS_GHC -Wno-orphans #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Storage.Queries.PartnerOrgConfigExtra where

import Domain.Types.PartnerOrgConfig
import Domain.Types.PartnerOrganization
import Kernel.Beam.Functions
import Kernel.External.Encryption
import Kernel.Prelude
import Kernel.Types.Error
import Kernel.Types.Id
import Kernel.Utils.Common (CacheFlow, EsqDBFlow, MonadFlow, fromMaybeM, getCurrentTime)
import qualified Sequelize as Se
import qualified Storage.Beam.PartnerOrgConfig as Beam
import Storage.Queries.OrphanInstances.PartnerOrgConfig

-- Extra code goes here --

findByPartnerOrgIdAndConfigType :: (MonadFlow m, EsqDBFlow m r, CacheFlow m r) => Id PartnerOrganization -> ConfigType -> m (Maybe PartnerOrgConfig)
findByPartnerOrgIdAndConfigType (Id partnerOrgId) configType = do
  findOneWithKV
    [ Se.And
        [ Se.Is Beam.partnerOrgId $ Se.Eq partnerOrgId,
          Se.Is Beam.configType $ Se.Eq configType
        ]
    ]
