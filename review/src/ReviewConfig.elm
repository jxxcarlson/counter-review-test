module ReviewConfig exposing (config)

{-| Do not rename the ReviewConfig module or the config function, because
`elm-review` will look for these.

To add packages that contain rules, add them to this review project using

    `elm install author/packagename`

when inside the directory containing this file.

-}

import Install.Import
import Install.TypeVariant
import Install.FieldInTypeAlias
import Install.Type
import Install.ClauseInCase
import Install.Function
import Review.Rule exposing (Rule)


config : List Rule
config =
    [
     -- TYPES
           Install.Type.makeRule "Types" "SignInState" [ "SignedOut", "SignUp", "SignedIn" ]
     -- TYPES IMPORTS
          , Install.Import.init "Types" "Auth.Common" |>Install.Import.makeRule
          , Install.Import.init "Types" "Url" |>Install.Import.makeRule
          , Install.Import.init "Types" "MagicLink.Types" |>Install.Import.makeRule
          , Install.Import.init "Types" "User" |>Install.Import.makeRule
          , Install.Import.init "Types" "Session" |>Install.Import.makeRule
          , Install.Import.init "Types" "Dict" |> Install.Import.withExposedValues ["Dict"] |>Install.Import.makeRule
          -- Type Frontend, MagicLink
          , Install.FieldInTypeAlias.makeRule "Types" "FrontendModel" "authFlow : Auth.Common.Flow"
          , Install.FieldInTypeAlias.makeRule "Types" "FrontendModel" "authRedirectBaseUrl : Url"
          , Install.FieldInTypeAlias.makeRule "Types" "FrontendModel" "signinForm : MagicLink.Types.SigninForm"
          , Install.FieldInTypeAlias.makeRule "Types" "FrontendModel" "loginErrorMessage : Maybe String"
          , Install.FieldInTypeAlias.makeRule "Types" "FrontendModel" "signInStatus : MagicLink.Types.SignInStatus"
          , Install.FieldInTypeAlias.makeRule "Types" "FrontendModel" "currentUserData : Maybe User.LoginData"
          -- Type Frontend, User
          , Install.FieldInTypeAlias.makeRule "Types" "FrontendModel" "currentUser : Maybe User.User"
          , Install.FieldInTypeAlias.makeRule "Types" "FrontendModel" "signInState : SignInState"
          , Install.FieldInTypeAlias.makeRule "Types" "FrontendModel" "realname : String"
          , Install.FieldInTypeAlias.makeRule "Types" "FrontendModel" "username : String"
          , Install.FieldInTypeAlias.makeRule "Types" "FrontendModel" "email : String"
          -- Type BackendModel
          , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "pendingAuths : Dict Lamdera.SessionId Auth.Common.PendingAuth"
          , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "pendingEmailAuths : Dict Lamdera.SessionId Auth.Common.PendingEmailAuth"
          , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "sessions : Dict SessionId Auth.Common.UserInfo"
          , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "secretCounter : Int"
          , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "sessionDict : AssocList.Dict SessionId String"
          , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "pendingLogins: MagicLink.Types.PendingLogins"
          , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "log : MagicLink.Types.Log"
          , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "users: Dict.Dict User.EmailString User.User"
          , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "userNameToEmailString : Dict.Dict User.Username User.EmailString"
          , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "sessionInfo : Session.SessionInfo"
        -- Type ToBackend
          , Install.TypeVariant.makeRule "Types" "ToBackend" "AuthToBackend Auth.Common.ToBackend"
          , Install.TypeVariant.makeRule "Types" "ToBackend" "AddUser String String String"
          , Install.TypeVariant.makeRule "Types" "ToBackend" "RequestSignup String String String"
        -- Type BackendMsg
          , Install.TypeVariant.makeRule "Types" "BackendMsg" "AuthBackendMsg Auth.Common.BackendMsg"
          , Install.TypeVariant.makeRule "Types" "BackendMsg" "AutoLogin SessionId User.LoginData"
        -- Type ToFrontend
          , Install.TypeVariant.makeRule "Types" "ToFrontend" "AuthToFrontend Auth.Common.ToFrontend"
          , Install.TypeVariant.makeRule "Types" "ToFrontend" "AuthSuccess Auth.Common.UserInfo"
          , Install.TypeVariant.makeRule "Types" "ToFrontend" "UserInfoMsg (Maybe Auth.Common.UserInfo)"
          , Install.TypeVariant.makeRule "Types" "ToFrontend" "CheckSignInResponse (Result BackendDataStatus User.LoginData)"
          , Install.TypeVariant.makeRule "Types" "ToFrontend" "GetLoginTokenRateLimited"
          , Install.TypeVariant.makeRule "Types" "ToFrontend" "RegistrationError String"
          , Install.TypeVariant.makeRule "Types" "ToFrontend" "SignInError String"
          , Install.TypeVariant.makeRule "Types" "ToFrontend" "UserSignedIn (Maybe User.User)"
    ]



{-

    , pendingLogins :
        AssocList.Dict
            SessionId
            { loginAttempts : Int
            , emailAddress : EmailAddress
            , creationTime : Time.Posix
            , loginCode : Int
            }

    , sessionInfo : Session.SessionInfo
    }
-}


{-
type alias BackendModel =
    { randomAtmosphericNumbers : Maybe (List Int)
    , localUuidData : Maybe LocalUUID.Data
    , time : Time.Posix

    -- MAGICLINK
    , pendingAuths : Dict Lamdera.SessionId Auth.Common.PendingAuth
    , pendingEmailAuths : Dict Lamdera.SessionId Auth.Common.PendingEmailAuth
    , sessions : Dict SessionId Auth.Common.UserInfo
    , secretCounter : Int
    , sessionDict : AssocList.Dict SessionId String -- Dict sessionId usernames
    , pendingLogins :
        AssocList.Dict
            SessionId
            { loginAttempts : Int
            , emailAddress : EmailAddress
            , creationTime : Time.Posix
            , loginCode : Int
            }
    , log : MagicLink.Types.Log
    , users : Dict.Dict User.EmailString User.User
    , userNameToEmailString : Dict.Dict User.Username User.EmailString
    , sessionInfo : Session.SessionInfo
    }
-}


configOld : List Rule
configOld =
    [
       Install.TypeVariant.makeRule "Types" "ToBackend" "CounterReset"
     , Install.TypeVariant.makeRule "Types" "FrontendMsg" "Reset"
     , Install.ClauseInCase.init "Frontend" "update" "Reset" "( { model | counter = 0 }, sendToBackend CounterReset )"
        |> Install.ClauseInCase.withInsertAfter "Increment"
        |> Install.ClauseInCase.makeRule
     , Install.ClauseInCase.init "Backend" "updateFromFrontend" "CounterReset" "( { model | counter = 0 }, broadcast (CounterNewValue 0 clientId) )"
        |> Install.ClauseInCase.makeRule
     , Install.Function.init ["Frontend"]"view" viewFunction |>Install.Function.makeRule

    ]

viewFunction = """view model =
    Html.div [ style "padding" "50px" ]
        [ Html.button [ onClick Increment ] [ text "+" ]
        , Html.div [ style "padding" "10px" ] [ Html.text (String.fromInt model.counter) ]
        , Html.button [ onClick Decrement ] [ text "-" ]
        , Html.div [ style "padding-top" "15px", style "padding-bottom" "15px" ] [ Html.text "Click me then refresh me!" ]
        , Html.button [ onClick Reset ] [ text "Reset" ]
        ]"""


viewFunction2 = """view model =
     Html.div [ style "padding" "50px" ]
         [ Html.button [ onClick Increment ] [ text "+" ]
         , Html.div [ style "padding" "10px" ] [ Html.text (String.fromInt model.counter) ]
         , Html.button [ onClick Decrement ] [ text "-" ]
         , Html.div [ style "padding-top" "15px", style "padding-bottom" "15px" ] [ Html.text "Click me then refresh me!" ]
         , Html.button [ onClick Reset ] [ text "Reset" ]
         ]"""

