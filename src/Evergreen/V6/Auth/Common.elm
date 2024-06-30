module Evergreen.V6.Auth.Common exposing (..)

import Evergreen.V6.EmailAddress
import Evergreen.V6.OAuth
import Evergreen.V6.OAuth.AuthorizationCode
import Evergreen.V6.Postmark
import Evergreen.V6.User
import Http
import Time
import Url


type alias MethodId =
    String


type alias AuthCode =
    String


type alias UserInfo =
    { email : String
    , name : Maybe String
    , username : Maybe String
    }


type Error
    = ErrStateMismatch
    | ErrAuthorization Evergreen.V6.OAuth.AuthorizationCode.AuthorizationError
    | ErrAuthentication Evergreen.V6.OAuth.AuthorizationCode.AuthenticationError
    | ErrHTTPGetAccessToken
    | ErrHTTPGetUserInfo
    | ErrAuthString String


type Flow
    = Idle
    | Requested MethodId
    | Pending
    | Authorized AuthCode String
    | Authenticated Evergreen.V6.OAuth.Token
    | Done UserInfo
    | Errored Error


type alias SessionId =
    String


type alias PendingAuth =
    { created : Time.Posix
    , sessionId : SessionId
    , state : String
    }


type alias PendingEmailAuth =
    { created : Time.Posix
    , sessionId : SessionId
    , username : String
    , fullname : String
    , token : String
    }


type alias State =
    String


type ToBackend
    = AuthSigninInitiated
        { methodId : MethodId
        , baseUrl : Url.Url
        , username : Maybe String
        }
    | AuthCallbackReceived MethodId Url.Url AuthCode State
    | AuthRenewSessionRequested
    | AuthLogoutRequested
    | AuthCheckLoginRequest
    | AuthSigInWithToken Int


type alias ClientId =
    String


type AuthChallengeReason
    = AuthSessionMissing
    | AuthSessionInvalid
    | AuthSessionExpired
    | AuthSessionLoggedOut


type ToFrontend
    = AuthInitiateSignin Url.Url
    | AuthError Error
    | AuthSessionChallenge AuthChallengeReason
    | AuthSignInWithTokenResponse (Result Int Evergreen.V6.User.SignInData)
    | ReceivedMessage (Result String String)


type alias Token =
    { methodId : MethodId
    , token : Evergreen.V6.OAuth.Token
    , created : Time.Posix
    , expires : Time.Posix
    }


type BackendMsg
    = AuthSigninInitiated_
        { sessionId : SessionId
        , clientId : ClientId
        , methodId : MethodId
        , baseUrl : Url.Url
        , now : Time.Posix
        , username : Maybe String
        }
    | AuthSigninInitiatedDelayed_ SessionId ToFrontend
    | AuthCallbackReceived_ SessionId ClientId MethodId Url.Url String String Time.Posix
    | AuthSuccess SessionId ClientId MethodId Time.Posix (Result Error ( UserInfo, Maybe Token ))
    | AuthRenewSession SessionId ClientId
    | AuthLogout SessionId ClientId
    | AuthSentLoginEmail Time.Posix Evergreen.V6.EmailAddress.EmailAddress (Result Http.Error Evergreen.V6.Postmark.PostmarkSendResponse)
