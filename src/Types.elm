module Types exposing (..)

import AssocList
import Auth.Common
import Browser
import Browser.Navigation exposing (Key)
import Http
import Lamdera exposing (ClientId, SessionId)
import LocalUUID
import MagicLink.Types
import Route exposing (Route)
import Session
import Time
import Url exposing (Url)
import User


type alias BackendModel =
    { counter : Int
    }


type FrontendModel
    = Loading LoadingModel
    | Loaded LoadedModel


type alias LoadingModel =
    { key : Key
    , initUrl : Url
    , now : Time.Posix
    , window : Maybe { width : Int, height : Int }
    , route : Route
    }


type alias LoadedModel =
    { key : Key
    , now : Time.Posix
    , window : { width : Int, height : Int }
    , route : Route
    , message : String
    , showTooltip : Bool
    , counter : Int
    }


type FrontendMsg
    = Increment
    | Decrement
    | UrlClicked Browser.UrlRequest
    | UrlChanged Url
    | Tick Time.Posix
    | GotWindowSize Int Int
    | MouseDown
    | SetViewport
    | NoOp


type ToBackend
    = CounterIncremented
    | CounterDecremented


type BackendMsg
    = ClientConnected SessionId ClientId
    | Noop
    | GotAtmosphericRandomNumbers (Result Http.Error String)
    | AuthBackendMsg Auth.Common.BackendMsg
    | AutoLogin SessionId User.SignInData


type ToFrontend
    = CounterNewValue Int String
    | OnConnected SessionId ClientId
    | CheckSignInResponse (Result BackendDataStatus User.SignInData)
    | UserRegistered User.User
    | UserSignedIn (Maybe User.User)
    | SignInError String
    | AuthToFrontend Auth.Common.ToFrontend
    | RegistrationError String
    | AuthSuccess Auth.Common.UserInfo
    | GetLoginTokenRateLimited
    | UserInfoMsg (Maybe Auth.Common.UserInfo)


type BackendDataStatus
    = Sunny
    | LoadedBackendData
    | Spell String Int
