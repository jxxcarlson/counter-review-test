module Evergreen.V6.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Dict
import Evergreen.V6.Auth.Common
import Evergreen.V6.LocalUUID
import Evergreen.V6.MagicLink.Types
import Evergreen.V6.Route
import Evergreen.V6.Session
import Evergreen.V6.User
import Http
import Lamdera
import Time
import Url


type alias LoadingModel =
    { key : Browser.Navigation.Key
    , initUrl : Url.Url
    , now : Time.Posix
    , window :
        Maybe
            { width : Int
            , height : Int
            }
    , route : Evergreen.V6.Route.Route
    }


type alias LoadedModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        { width : Int
        , height : Int
        }
    , route : Evergreen.V6.Route.Route
    , message : String
    , showTooltip : Bool
    , counter : Int
    , users : Dict.Dict Evergreen.V6.User.EmailString Evergreen.V6.User.User
    , magicLinkModel : Evergreen.V6.MagicLink.Types.Model
    }


type FrontendModel
    = Loading LoadingModel
    | Loaded LoadedModel


type alias BackendModel =
    { counter : Int
    , randomAtmosphericNumbers : Maybe (List Int)
    , localUuidData : Maybe Evergreen.V6.LocalUUID.Data
    , sessionInfo : Evergreen.V6.Session.SessionInfo
    , time : Time.Posix
    , userNameToEmailString : Dict.Dict Evergreen.V6.User.Username Evergreen.V6.User.EmailString
    , pendingAuths : Dict.Dict Lamdera.SessionId Evergreen.V6.Auth.Common.PendingAuth
    , users : Dict.Dict Evergreen.V6.User.EmailString Evergreen.V6.User.User
    , pendingEmailAuths : Dict.Dict Lamdera.SessionId Evergreen.V6.Auth.Common.PendingEmailAuth
    , log : Evergreen.V6.MagicLink.Types.Log
    , sessions : Dict.Dict Lamdera.SessionId Evergreen.V6.Auth.Common.UserInfo
    , pendingLogins : Evergreen.V6.MagicLink.Types.PendingLogins
    , secretCounter : Int
    , sessionDict : AssocList.Dict Lamdera.SessionId String
    }


type FrontendMsg
    = Increment
    | Decrement
    | UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | Tick Time.Posix
    | GotWindowSize Int Int
    | MouseDown
    | SetViewport
    | NoOp
    | SignInUser Evergreen.V6.User.SignInData
    | AuthFrontendMsg Evergreen.V6.MagicLink.Types.Msg
    | SetRoute_ Evergreen.V6.Route.Route
    | LiftMsg Evergreen.V6.MagicLink.Types.Msg


type ToBackend
    = CounterIncremented
    | CounterDecremented
    | GetUserDictionary
    | RequestSignUp String String String
    | AddUser String String String
    | AuthToBackend Evergreen.V6.Auth.Common.ToBackend


type BackendMsg
    = ClientConnected Lamdera.SessionId Lamdera.ClientId
    | Noop
    | GotAtmosphericRandomNumbers (Result Http.Error String)
    | AuthBackendMsg Evergreen.V6.Auth.Common.BackendMsg
    | AutoLogin Lamdera.SessionId Evergreen.V6.User.SignInData
    | GotFastTick Time.Posix
    | OnConnected Lamdera.SessionId Lamdera.ClientId


type BackendDataStatus
    = Sunny
    | LoadedBackendData
    | Spell String Int


type ToFrontend
    = CounterNewValue Int String
    | GotMessage String
    | GotUserDictionary (Dict.Dict Evergreen.V6.User.EmailString Evergreen.V6.User.User)
    | UserRegistered Evergreen.V6.User.User
    | UserSignedIn (Maybe Evergreen.V6.User.User)
    | SignInError String
    | RegistrationError String
    | GetLoginTokenRateLimited
    | CheckSignInResponse (Result BackendDataStatus Evergreen.V6.User.SignInData)
    | UserInfoMsg (Maybe Evergreen.V6.Auth.Common.UserInfo)
    | AuthSuccess Evergreen.V6.Auth.Common.UserInfo
    | AuthToFrontend Evergreen.V6.Auth.Common.ToFrontend
