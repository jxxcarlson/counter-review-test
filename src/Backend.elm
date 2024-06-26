module Backend exposing (app, init)

import AssocList
import Atmospheric
import Auth.Common
import Auth.Flow
import Dict exposing (Dict)
import Lamdera exposing (ClientId, SessionId, broadcast, sendToFrontend)
import MagicLink.Auth
import MagicLink.Backend
import MagicLink.Helper as Helper
import Reconnect
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


init : ( BackendModel, Cmd BackendMsg )
init =
    ( { counter = 0
      , users = Dict.empty
      , userNameToEmailString = Dict.empty
      , sessions = Dict.empty
      , sessionInfo = Dict.empty
      , time = Time.millisToPosix 0
      , randomAtmosphericNumbers = Nothing
      , pendingAuths = Dict.empty
      , localUuidData = Nothing
      , pendingEmailAuths = Dict.empty
      , log = []
      , secretCounter = 0
      , pendingLogins = AssocList.empty
      , sessionDict = AssocList.empty
      }
    , Cmd.batch [ Time.now |> Task.perform GotFastTick, Helper.getAtmosphericRandomNumbers ]
    )


update : BackendMsg -> BackendModel -> ( BackendModel, Cmd BackendMsg )
update msg model =
    case msg of
        ClientConnected sessionId clientId ->
            ( model, sendToFrontend clientId <| CounterNewValue model.counter clientId )

        Noop ->
            ( model, Cmd.none )

        GotAtmosphericRandomNumbers tryRandomAtmosphericNumbers ->
            Atmospheric.gotNumbers model tryRandomAtmosphericNumbers

        GotFastTick time ->
            ( { model | time = time }, Cmd.none )

        AuthBackendMsg authMsg ->
            Auth.Flow.backendUpdate (MagicLink.Auth.backendConfig model) authMsg

        OnConnected sessionId clientId ->
            Reconnect.connect model sessionId clientId

        AutoLogin sessionId loginData ->
            ( model, Lamdera.sendToFrontend sessionId (AuthToFrontend <| Auth.Common.AuthSignInWithTokenResponse <| Ok <| loginData) )


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

        GetUserDictionary ->
            ( model, Lamdera.sendToFrontend clientId (GotUserDictionary model.users) )

        RequestSignUp realname username email ->
            MagicLink.Backend.requestSignUp model clientId realname username email

        AddUser realname username email ->
            MagicLink.Backend.addUser model clientId email realname username

        AuthToBackend authMsg ->
            Auth.Flow.updateFromFrontend (MagicLink.Auth.backendConfig model) clientId sessionId authMsg model


subscriptions model =
    Sub.batch
        [ Lamdera.onConnect ClientConnected
        , Lamdera.onConnect OnConnected
        ]
