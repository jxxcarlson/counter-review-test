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
    , randomAtmosphericNumbers : Maybe (List Int)
    , localUuidData : Maybe LocalUUID.Data
    , time : Time.Posix
    , sessionInfo : Session.SessionInfo
    , pendingAuths : Dict Lamdera.SessionId Auth.Common.PendingAuth
    , userNameToEmailString : Dict.Dict User.Username User.EmailString
    , pendingEmailAuths : Dict Lamdera.SessionId Auth.Common.PendingEmailAuth
    , users : Dict.Dict User.EmailString User.User
    , sessions : Dict SessionId Auth.Common.UserInfo
    , log : MagicLink.Types.Log
    , secretCounter : Int
    , pendingLogins : MagicLink.Types.PendingLogins
    , sessionDict : AssocList.Dict SessionId String
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
    , users : Dict.Dict User.EmailString User.User
    , magicLinkModel : MagicLink.Types.Model
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
    | SignInUser User.SignInData
    | AuthFrontendMsg MagicLink.Types.Msg
    | SetRoute_ Route
    | LiftMsg MagicLink.Types.Msg


type ToBackend
    = CounterIncremented
    | CounterDecremented
    | GetUserDictionary
    | RequestSignUp String String String
    | AddUser String String String
    | AuthToBackend Auth.Common.ToBackend


type BackendMsg
    = ClientConnected SessionId ClientId
    | OnConnected SessionId ClientId
    | Noop
    | GotAtmosphericRandomNumbers (Result Http.Error String)
    | AuthBackendMsg Auth.Common.BackendMsg
    | AutoLogin SessionId User.SignInData
    | GotFastTick Time.Posix


type ToFrontend
    = CounterNewValue Int String
    | GotMessage String
    | GotUserDictionary (Dict.Dict User.EmailString User.User)
    | UserRegistered User.User
    | UserSignedIn (Maybe User.User)
    | SignInError String
    | RegistrationError String
    | GetLoginTokenRateLimited
    | CheckSignInResponse (Result BackendDataStatus User.SignInData)
    | UserInfoMsg (Maybe Auth.Common.UserInfo)
    | AuthSuccess Auth.Common.UserInfo
    | AuthToFrontend Auth.Common.ToFrontend


type BackendDataStatus
    = Sunny
    | LoadedBackendData
