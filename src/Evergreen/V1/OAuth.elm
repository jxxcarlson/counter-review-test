module Evergreen.V1.OAuth exposing (..)


type Token
    = Bearer String


type ErrorCode
    = InvalidRequest
    | UnauthorizedClient
    | AccessDenied
    | UnsupportedResponseType
    | InvalidScope
    | ServerError
    | TemporarilyUnavailable
    | Custom String
