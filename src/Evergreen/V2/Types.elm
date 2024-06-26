module Evergreen.V2.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Dict
import Evergreen.V2.Auth.Common
import Evergreen.V2.LocalUUID
import Evergreen.V2.MagicLink.Types
import Evergreen.V2.Route
import Evergreen.V2.Session
import Evergreen.V2.User
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
    , route : Evergreen.V2.Route.Route
    }


type alias LoadedModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        { width : Int
        , height : Int
        }
    , route : Evergreen.V2.Route.Route
    , message : String
    , showTooltip : Bool
    , counter : Int
    , users : Dict.Dict Evergreen.V2.User.EmailString Evergreen.V2.User.User
    , magicLinkModel : Evergreen.V2.MagicLink.Types.Model
    }


type FrontendModel
    = Loading LoadingModel
    | Loaded LoadedModel


type alias BackendModel =
    { counter : Int
    , randomAtmosphericNumbers : Maybe (List Int)
    , localUuidData : Maybe Evergreen.V2.LocalUUID.Data
    , time : Time.Posix
    , sessionInfo : Evergreen.V2.Session.SessionInfo
    , pendingAuths : Dict.Dict Lamdera.SessionId Evergreen.V2.Auth.Common.PendingAuth
    , userNameToEmailString : Dict.Dict Evergreen.V2.User.Username Evergreen.V2.User.EmailString
    , pendingEmailAuths : Dict.Dict Lamdera.SessionId Evergreen.V2.Auth.Common.PendingEmailAuth
    , users : Dict.Dict Evergreen.V2.User.EmailString Evergreen.V2.User.User
    , sessions : Dict.Dict Lamdera.SessionId Evergreen.V2.Auth.Common.UserInfo
    , log : Evergreen.V2.MagicLink.Types.Log
    , secretCounter : Int
    , pendingLogins : Evergreen.V2.MagicLink.Types.PendingLogins
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
    | SignInUser Evergreen.V2.User.SignInData
    | AuthFrontendMsg Evergreen.V2.MagicLink.Types.Msg
    | SetRoute_ Evergreen.V2.Route.Route
    | LiftMsg Evergreen.V2.MagicLink.Types.Msg


type ToBackend
    = CounterIncremented
    | CounterDecremented
    | GetUserDictionary
    | RequestSignUp String String String
    | AddUser String String String
    | AuthToBackend Evergreen.V2.Auth.Common.ToBackend


type BackendMsg
    = ClientConnected Lamdera.SessionId Lamdera.ClientId
    | OnConnected Lamdera.SessionId Lamdera.ClientId
    | Noop
    | GotAtmosphericRandomNumbers (Result Http.Error String)
    | AuthBackendMsg Evergreen.V2.Auth.Common.BackendMsg
    | AutoLogin Lamdera.SessionId Evergreen.V2.User.SignInData
    | GotFastTick Time.Posix


type BackendDataStatus
    = Sunny
    | LoadedBackendData


type ToFrontend
    = CounterNewValue Int String
    | GotMessage String
    | GotUserDictionary (Dict.Dict Evergreen.V2.User.EmailString Evergreen.V2.User.User)
    | UserRegistered Evergreen.V2.User.User
    | UserSignedIn (Maybe Evergreen.V2.User.User)
    | SignInError String
    | RegistrationError String
    | GetLoginTokenRateLimited
    | CheckSignInResponse (Result BackendDataStatus Evergreen.V2.User.SignInData)
    | UserInfoMsg (Maybe Evergreen.V2.Auth.Common.UserInfo)
    | AuthSuccess Evergreen.V2.Auth.Common.UserInfo
    | AuthToFrontend Evergreen.V2.Auth.Common.ToFrontend
