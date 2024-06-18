module Types exposing (..)

import AssocList
import Auth.Common
import Browser
import Browser.Navigation exposing (Key)
import Dict exposing (Dict)
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
    , authFlow : Auth.Common.Flow
    , authRedirectBaseUrl : Url
    , signinForm : MagicLink.Types.SigninForm
    , loginErrorMessage : Maybe String
    , signInStatus : MagicLink.Types.SignInStatus
    , currentUserData : Maybe User.LoginData
    , currentUser : Maybe User.User
    , signInState : SignInState
    , realname : String
    , username : String
    , email : String
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



--| AuthFrontendMsg MagicLink.Types.FrontendMsg


type ToBackend
    = CounterIncremented
    | CounterDecremented
    | AuthToBackend Auth.Common.ToBackend
    | AddUser String String String
    | RequestSignup String String String


type BackendMsg
    = ClientConnected SessionId ClientId
    | Noop
    | GotAtmosphericRandomNumbers (Result Http.Error String)
    | AutoLogin SessionId User.LoginData
    | AuthBackendMsg Auth.Common.BackendMsg


type ToFrontend
    = CounterNewValue Int String
    | UserRegistered User.User
    | AuthToFrontend Auth.Common.ToFrontend
    | UserSignedIn (Maybe User.User)
    | AuthSuccess Auth.Common.UserInfo
    | SignInError String
    | UserInfoMsg (Maybe Auth.Common.UserInfo)
    | RegistrationError String
    | CheckSignInResponse (Result BackendDataStatus User.LoginData)
    | GetLoginTokenRateLimited


type SignInState
    = SignedOut
    | SignUp
    | SignedIn


type BackendDataStatus
    = Sunny
    | LoadedBackendData


type Foo
    = Bar
