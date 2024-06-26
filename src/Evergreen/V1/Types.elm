module Evergreen.V1.Types exposing (..)

import AssocList
import Browser
import Browser.Navigation
import Dict
import Evergreen.V1.Auth.Common
import Evergreen.V1.LocalUUID
import Evergreen.V1.MagicLink.Types
import Evergreen.V1.Route
import Evergreen.V1.Session
import Evergreen.V1.User
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
    , route : Evergreen.V1.Route.Route
    }


type alias LoadedModel =
    { key : Browser.Navigation.Key
    , now : Time.Posix
    , window :
        { width : Int
        , height : Int
        }
    , route : Evergreen.V1.Route.Route
    , message : String
    , showTooltip : Bool
    , counter : Int
    , users : Dict.Dict Evergreen.V1.User.EmailString Evergreen.V1.User.User
    , magicLinkModel : Evergreen.V1.MagicLink.Types.Model
    }


type FrontendModel
    = Loading LoadingModel
    | Loaded LoadedModel


type alias BackendModel =
    { counter : Int
    , randomAtmosphericNumbers : Maybe (List Int)
    , localUuidData : Maybe Evergreen.V1.LocalUUID.Data
    , time : Time.Posix
    , sessionInfo : Evergreen.V1.Session.SessionInfo
    , pendingAuths : Dict.Dict Lamdera.SessionId Evergreen.V1.Auth.Common.PendingAuth
    , userNameToEmailString : Dict.Dict Evergreen.V1.User.Username Evergreen.V1.User.EmailString
    , pendingEmailAuths : Dict.Dict Lamdera.SessionId Evergreen.V1.Auth.Common.PendingEmailAuth
    , users : Dict.Dict Evergreen.V1.User.EmailString Evergreen.V1.User.User
    , sessions : Dict.Dict Lamdera.SessionId Evergreen.V1.Auth.Common.UserInfo
    , log : Evergreen.V1.MagicLink.Types.Log
    , secretCounter : Int
    , pendingLogins : Evergreen.V1.MagicLink.Types.PendingLogins
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
    | SignInUser Evergreen.V1.User.SignInData
    | AuthFrontendMsg Evergreen.V1.MagicLink.Types.Msg
    | SetRoute_ Evergreen.V1.Route.Route
    | LiftMsg Evergreen.V1.MagicLink.Types.Msg


type ToBackend
    = CounterIncremented
    | CounterDecremented
    | GetUserDictionary
    | RequestSignUp String String String
    | AddUser String String String
    | AuthToBackend Evergreen.V1.Auth.Common.ToBackend


type BackendMsg
    = ClientConnected Lamdera.SessionId Lamdera.ClientId
    | Noop
    | GotAtmosphericRandomNumbers (Result Http.Error String)
    | AuthBackendMsg Evergreen.V1.Auth.Common.BackendMsg
    | AutoLogin Lamdera.SessionId Evergreen.V1.User.SignInData
    | GotFastTick Time.Posix


type BackendDataStatus
    = Sunny
    | LoadedBackendData


type ToFrontend
    = CounterNewValue Int String
    | GotMessage String
    | GotUserDictionary (Dict.Dict Evergreen.V1.User.EmailString Evergreen.V1.User.User)
    | UserRegistered Evergreen.V1.User.User
    | UserSignedIn (Maybe Evergreen.V1.User.User)
    | SignInError String
    | RegistrationError String
    | GetLoginTokenRateLimited
    | CheckSignInResponse (Result BackendDataStatus Evergreen.V1.User.SignInData)
    | UserInfoMsg (Maybe Evergreen.V1.Auth.Common.UserInfo)
    | AuthSuccess Evergreen.V1.Auth.Common.UserInfo
    | AuthToFrontend Evergreen.V1.Auth.Common.ToFrontend
