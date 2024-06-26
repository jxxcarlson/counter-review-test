module Evergreen.V1.LocalUUID exposing (..)

import UUID


type alias Data =
    ( UUID.UUID, UUID.Seeds )
