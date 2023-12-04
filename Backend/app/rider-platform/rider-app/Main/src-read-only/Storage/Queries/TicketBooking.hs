{-# OPTIONS_GHC -Wno-orphans #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Storage.Queries.TicketBooking where

import qualified Data.Time.Calendar
import qualified Domain.Types.Merchant.MerchantOperatingCity
import qualified Domain.Types.Person
import qualified Domain.Types.TicketBooking
import qualified Domain.Types.TicketPlace
import Kernel.Beam.Functions
import Kernel.Prelude
import qualified Kernel.Prelude
import qualified Kernel.Types.Common
import qualified Kernel.Types.Id
import Kernel.Utils.Common (CacheFlow, EsqDBFlow, MonadFlow)
import qualified Sequelize as Se
import qualified Storage.Beam.TicketBooking as Beam

create :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => Domain.Types.TicketBooking.TicketBooking -> m ()
create = createWithKV

createMany :: (EsqDBFlow m r, MonadFlow m, CacheFlow m r) => [Domain.Types.TicketBooking.TicketBooking] -> m ()
createMany = traverse_ createWithKV

findById :: (MonadFlow m, CacheFlow m r, EsqDBFlow m r) => Kernel.Types.Id.Id Domain.Types.TicketBooking.TicketBooking -> m (Maybe (Domain.Types.TicketBooking.TicketBooking))
findById (Kernel.Types.Id.Id id) = do
  findOneWithKV
    [ Se.Is Beam.id $ Se.Eq id
    ]

findByShortId :: (MonadFlow m, CacheFlow m r, EsqDBFlow m r) => Kernel.Types.Id.ShortId Domain.Types.TicketBooking.TicketBooking -> m (Maybe (Domain.Types.TicketBooking.TicketBooking))
findByShortId (Kernel.Types.Id.ShortId shortId) = do
  findOneWithKV
    [ Se.Is Beam.shortId $ Se.Eq shortId
    ]

getAllBookingsByPersonId :: (MonadFlow m, CacheFlow m r, EsqDBFlow m r) => Maybe Int -> Maybe Int -> Kernel.Types.Id.Id Domain.Types.Person.Person -> Kernel.Types.Id.Id Domain.Types.Merchant.MerchantOperatingCity.MerchantOperatingCity -> Domain.Types.TicketBooking.BookingStatus -> m ([Domain.Types.TicketBooking.TicketBooking])
getAllBookingsByPersonId limit offset (Kernel.Types.Id.Id personId) (Kernel.Types.Id.Id merchantOperatingCityId) status = do
  findAllWithOptionsKV
    [ Se.And
        [ Se.Is Beam.personId $ Se.Eq personId,
          Se.Is Beam.merchantOperatingCityId $ Se.Eq merchantOperatingCityId,
          Se.Is Beam.status $ Se.Eq status
        ]
    ]
    (Se.Desc Beam.createdAt)
    limit
    offset

updateStatusByShortId :: (MonadFlow m, CacheFlow m r, EsqDBFlow m r) => Domain.Types.TicketBooking.BookingStatus -> Kernel.Prelude.UTCTime -> Kernel.Types.Id.ShortId Domain.Types.TicketBooking.TicketBooking -> m ()
updateStatusByShortId status updatedAt (Kernel.Types.Id.ShortId shortId) = do
  updateWithKV
    [ Se.Set Beam.status status,
      Se.Set Beam.updatedAt updatedAt
    ]
    [ Se.Is Beam.shortId $ Se.Eq shortId
    ]

findByPrimaryKey :: (MonadFlow m, CacheFlow m r, EsqDBFlow m r) => Kernel.Types.Id.Id Domain.Types.TicketBooking.TicketBooking -> m (Maybe (Domain.Types.TicketBooking.TicketBooking))
findByPrimaryKey (Kernel.Types.Id.Id id) = do
  findOneWithKV
    [ Se.And
        [ Se.Is Beam.id $ Se.Eq id
        ]
    ]

updateByPrimaryKey :: (MonadFlow m, CacheFlow m r, EsqDBFlow m r) => Kernel.Types.Common.HighPrecMoney -> Kernel.Prelude.UTCTime -> Kernel.Types.Id.Id Domain.Types.Merchant.MerchantOperatingCity.MerchantOperatingCity -> Kernel.Types.Id.Id Domain.Types.Person.Person -> Kernel.Types.Id.ShortId Domain.Types.TicketBooking.TicketBooking -> Domain.Types.TicketBooking.BookingStatus -> Kernel.Types.Id.Id Domain.Types.TicketPlace.TicketPlace -> Kernel.Prelude.UTCTime -> Data.Time.Calendar.Day -> Kernel.Types.Id.Id Domain.Types.TicketBooking.TicketBooking -> m ()
updateByPrimaryKey amount createdAt (Kernel.Types.Id.Id merchantOperatingCityId) (Kernel.Types.Id.Id personId) (Kernel.Types.Id.ShortId shortId) status (Kernel.Types.Id.Id ticketPlaceId) updatedAt visitDate (Kernel.Types.Id.Id id) = do
  updateWithKV
    [ Se.Set Beam.amount amount,
      Se.Set Beam.createdAt createdAt,
      Se.Set Beam.merchantOperatingCityId merchantOperatingCityId,
      Se.Set Beam.personId personId,
      Se.Set Beam.shortId shortId,
      Se.Set Beam.status status,
      Se.Set Beam.ticketPlaceId ticketPlaceId,
      Se.Set Beam.updatedAt updatedAt,
      Se.Set Beam.visitDate visitDate
    ]
    [ Se.And
        [ Se.Is Beam.id $ Se.Eq id
        ]
    ]

instance FromTType' Beam.TicketBooking Domain.Types.TicketBooking.TicketBooking where
  fromTType' Beam.TicketBookingT {..} = do
    pure $
      Just
        Domain.Types.TicketBooking.TicketBooking
          { amount = amount,
            createdAt = createdAt,
            id = Kernel.Types.Id.Id id,
            merchantOperatingCityId = Kernel.Types.Id.Id merchantOperatingCityId,
            personId = Kernel.Types.Id.Id personId,
            shortId = Kernel.Types.Id.ShortId shortId,
            status = status,
            ticketPlaceId = Kernel.Types.Id.Id ticketPlaceId,
            updatedAt = updatedAt,
            visitDate = visitDate
          }

instance ToTType' Beam.TicketBooking Domain.Types.TicketBooking.TicketBooking where
  toTType' Domain.Types.TicketBooking.TicketBooking {..} = do
    Beam.TicketBookingT
      { Beam.amount = amount,
        Beam.createdAt = createdAt,
        Beam.id = Kernel.Types.Id.getId id,
        Beam.merchantOperatingCityId = Kernel.Types.Id.getId merchantOperatingCityId,
        Beam.personId = Kernel.Types.Id.getId personId,
        Beam.shortId = Kernel.Types.Id.getShortId shortId,
        Beam.status = status,
        Beam.ticketPlaceId = Kernel.Types.Id.getId ticketPlaceId,
        Beam.updatedAt = updatedAt,
        Beam.visitDate = visitDate
      }