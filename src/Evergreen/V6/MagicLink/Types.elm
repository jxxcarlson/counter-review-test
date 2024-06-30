module Evergreen.V6.MagicLink.Types exposing (..)

import AssocList
import Dict
import Evergreen.V6.Auth.Common
import Evergreen.V6.EmailAddress
import Evergreen.V6.Route
import Evergreen.V6.User
import Lamdera
import Time
import Url


type SignInStatus
    = NotSignedIn
    | ErrorNotRegistered String
    | SuccessfulRegistration String String
    | SigningUp
    | SignedIn


type alias EnterEmail_ =
    { email : String
    , pressedSubmitEmail : Bool
    , rateLimited : Bool
    }


type LoginCodeStatus
    = Checking
    | NotValid


type alias EnterLoginCode_ =
    { sentTo : Evergreen.V6.EmailAddress.EmailAddress
    , loginCode : String
    , attempts : Dict.Dict Int LoginCodeStatus
    }


type SigninFormState
    = EnterEmail EnterEmail_
    | EnterSigninCode EnterLoginCode_


type SignInState
    = SisSignedOut
    | SisSignUp
    | SisSignedIn


type alias Model =
    { count : Int
    , signInStatus : SignInStatus
    , currentUser : Maybe Evergreen.V6.User.User
    , currentUserData : Maybe Evergreen.V6.User.SignInData
    , signInForm : SigninFormState
    , signInState : SignInState
    , loginErrorMessage : Maybe String
    , realname : String
    , username : String
    , email : String
    , message : String
    , authFlow : Evergreen.V6.Auth.Common.Flow
    , authRedirectBaseUrl : Url.Url
    }


type LogItem
    = LoginsRateLimited Evergreen.V6.User.Id
    | FailedToCreateLoginCode Int


type alias Log =
    List ( Time.Posix, LogItem )


type alias PendingLogins =
    AssocList.Dict
        Lamdera.SessionId
        { loginAttempts : Int
        , emailAddress : Evergreen.V6.EmailAddress.EmailAddress
        , creationTime : Time.Posix
        , loginCode : Int
        }


type Msg
    = SubmitEmailForSignIn
    | AuthSigninRequested
        { methodId : Evergreen.V6.Auth.Common.MethodId
        , email : Maybe String
        }
    | ReceivedSigninCode String
    | CancelSignIn
    | CancelSignUp
    | OpenSignUp
    | TypedEmailInSignInForm String
    | SubmitSignUp
    | SignOut
    | InputRealname String
    | InputUsername String
    | InputEmail String
    | SetRoute Evergreen.V6.Route.Route
