module Backend exposing (app, init)

import AssocList
import Auth.Common
import Auth.Flow
import Dict
import Helper
import Lamdera exposing (ClientId, SessionId, broadcast, sendToFrontend)
import LocalUUID
import MagicLink.Auth
import Process
import Set exposing (Set)
import Task
import Time
import Types exposing (..)
import User


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = subscriptions
        }



--init : ( BackendModel, Cmd BackendMsg )


init =
    ( { counter = 0
      , users = Dict.empty
      , sessions = Dict.empty
      , time = Time.millisToPosix 0
      , log = []
      , randomAtmosphericNumbers = Nothing
      , sessionDict = AssocList.empty
      , localUuidData = Dict.empty
      , pendingEmailAuths = Dict.empty
      , pendingAuths = Nothing
      , secretCounter = 0
      }
    , Cmd.none
    )


update : BackendMsg -> BackendModel -> ( BackendModel, Cmd BackendMsg )
update msg model =
    case msg of
        ClientConnected sessionId clientId ->
            ( model, sendToFrontend clientId <| CounterNewValue model.counter clientId )

        Noop ->
            ( model, Cmd.none )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> BackendModel -> ( BackendModel, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        CounterIncremented ->
            let
                newCounter =
                    model.counter + 1
            in
            ( { model | counter = newCounter }, broadcast (CounterNewValue newCounter clientId) )

        CounterDecremented ->
            let
                newCounter =
                    model.counter - 1
            in
            ( { model | counter = newCounter }, broadcast (CounterNewValue newCounter clientId) )


subscriptions model =
    Sub.batch
        [ Lamdera.onConnect ClientConnected
        ]
