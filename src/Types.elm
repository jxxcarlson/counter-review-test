module Types exposing (..)

import AssocList
import Auth.Common
import Browser
import Browser.Navigation exposing (Key)
import Dict exposing (Dict)
import Http
import Lamdera exposing (ClientId, SessionId)
import MagicLink.Types
import Route exposing (Route)
import Session
import Time
import Url exposing (Url)
import User


type alias BackendModel =
    { counter : Int
    , pendingAuths : Dict Lamdera.SessionId Auth.Common.PendingAuth
    , pendingEmailAuths : Dict Lamdera.SessionId Auth.Common.PendingEmailAuth
    , sessions : Dict SessionId Auth.Common.UserInfo
    , secretCounter : Int
    , sessionDict : AssocList.Dict SessionId String
    , pendingLogins : MagicLink.Types.PendingLogins
    , log : MagicLink.Types.Log
    , users : Dict.Dict User.EmailString User.User
    , userNameToEmailString : Dict.Dict User.Username User.EmailString
    , sessionInfo : Session.SessionInfo
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
    | AuthFrontendMsg MagicLink.Types.FrontendMsg


type ToBackend
    = CounterIncremented
    | CounterDecremented
    | RequestSignup String String String
    | AddUser String String String
    | AuthToBackend Auth.Common.ToBackend


type BackendMsg
    = ClientConnected SessionId ClientId
    | Noop
    | GotAtmosphericRandomNumbers (Result Http.Error String)
    | AutoLogin SessionId User.LoginData
    | AuthBackendMsg Auth.Common.BackendMsg


type ToFrontend
    = CounterNewValue Int String
    | UserSignedIn (Maybe User.User)
    | SignInError String
    | RegistrationError String
    | GetLoginTokenRateLimited
    | CheckSignInResponse (Result BackendDataStatus User.LoginData)
    | UserInfoMsg (Maybe Auth.Common.UserInfo)
    | AuthSuccess Auth.Common.UserInfo
    | AuthToFrontend Auth.Common.ToFrontend


type SignInState
    = SignedOut
    | SignUp
    | SignedIn


type BackendDataStatus
    = Sunny
    | LoadedBackendData


type Foo
    = Bar
