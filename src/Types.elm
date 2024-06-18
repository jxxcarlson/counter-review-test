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



--| AuthFrontendMsg MagicLink.Types.FrontendMsg


type ToBackend
    = CounterIncremented
    | CounterDecremented


type BackendMsg
    = ClientConnected SessionId ClientId
    | Noop


type ToFrontend
    = CounterNewValue Int String
    | UserRegistered User.User


type SignInState
    = SignedOut
    | SignUp
    | SignedIn


type BackendDataStatus
    = Sunny
    | LoadedBackendData


type Foo
    = Bar
