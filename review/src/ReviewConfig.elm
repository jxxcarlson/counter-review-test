module ReviewConfig exposing (config)

{-| Do not rename the ReviewConfig module or the config function, because
`elm-review` will look for these.

To add packages that contain rules, add them to this review project using

    `elm install author/packagename`

when inside the directory containing this file.

-}

import Install.ClauseInCase
import Install.FieldInTypeAlias
import Install.Function
import Install.Import
import Install.Initializer
import Install.Type
import Install.TypeVariant
import Review.Rule exposing (Rule)



-- CONFIG, Possibilities: configReset, configUsers


config =
    configUsers


-- CONFIG RESET

configReset : List Rule
configReset =
    [ Install.TypeVariant.makeRule "Types" "ToBackend" "CounterReset"
    , Install.TypeVariant.makeRule "Types" "FrontendMsg" "Reset"
    , Install.ClauseInCase.init "Frontend" "updateLoaded" "Reset" "( { model | counter = 0 }, sendToBackend CounterReset )"
        |> Install.ClauseInCase.withInsertAfter "Increment"
        |> Install.ClauseInCase.makeRule
    , Install.ClauseInCase.init "Backend" "updateFromFrontend" "CounterReset" "( { model | counter = 0 }, broadcast (CounterNewValue 0 clientId) )" |> Install.ClauseInCase.makeRule
    , Install.Function.init "Pages.Counter" "view" viewFunction |> Install.Function.makeRule
    ]
 --AuthToBackend authMsg ->
 --           Auth.Flow.updateFromFrontend (MagicLink.Auth.backendConfig model) clientId sessionId authMsg model
 --
 --       AddUser realname username email ->
 --           MagicLink.Backend.addUser model clientId email realname username
 --
 --       RequestSignup realname username email ->
 --           MagicLink.Backend.requestSignUp model clientId realname username email

viewFunction =
    """view model =
    Html.div [ style "padding" "50px" ]
        [ Html.button [ onClick Increment ] [ text "+" ]
        , Html.div [ style "padding" "10px" ] [ Html.text (String.fromInt model.counter) ]
        , Html.button [ onClick Decrement ] [ text "-" ]
        , Html.div [] [Html.button [ onClick Reset, style "margin-top" "10px"] [ text "Reset" ]]
        ] |> Element.html   """

-- CONFIG USERS
--
--RequestSignup _ _ _
--    AddUser _ _ _
--    AuthToBackend _

configUsers : List Rule
configUsers =
    [ -- TYPES
      Install.Type.makeRule "Types" "SignInState" [ "SignedOut", "SignUp", "SignedIn" ]

          , Install.Type.makeRule "Types" "BackendDataStatus" [ "Sunny", "LoadedBackendData" ]
     , Install.TypeVariant.makeRule "Types" "ToFrontend" "CheckSignInResponse (Result BackendDataStatus User.LoginData)"

    -- TYPES IMPORTS
    , Install.Import.initSimple "Types" ["Session", "AssocList", "Auth.Common", "User", "Dict", "Http", "LocalUUID", "MagicLink.Types" ] |> Install.Import.makeRule
    , Install.Import.init "Types" [ { moduleToImport = "Dict", alias_ = Nothing, exposedValues = Just [ "Dict" ] } ] |> Install.Import.makeRule

    -- Type Frontend, User
    , Install.FieldInTypeAlias.makeRule "Types" "LoadedModel" "currentUser : Maybe User.User"
    , Install.FieldInTypeAlias.makeRule "Types" "LoadedModel" "signInState : SignInState"
    , Install.FieldInTypeAlias.makeRule "Types" "LoadedModel" "realname : String"
    , Install.FieldInTypeAlias.makeRule "Types" "LoadedModel" "username : String"
    , Install.FieldInTypeAlias.makeRule "Types" "LoadedModel" "email : String"
--
    --
    , Install.ClauseInCase.init "Backend" "updateFromFrontend" "AuthToBackend authMsg" "Auth.Flow.updateFromFrontend (MagicLink.Auth.backendConfig model) clientId sessionId authMsg model" |> Install.ClauseInCase.makeRule
    , Install.ClauseInCase.init "Backend" "updateFromFrontend" "AddUser realname username email" "MagicLink.Backend.addUser model clientId email realname username" |> Install.ClauseInCase.makeRule
    , Install.ClauseInCase.init "Backend" "updateFromFrontend" "RequestSignup realname username email" "MagicLink.Backend.requestSignUp model clientId realname username email" |> Install.ClauseInCase.makeRule

    -- Type ToBackend
    , Install.TypeVariant.makeRule "Types" "ToBackend" "AddUser String String String"
    , Install.TypeVariant.makeRule "Types" "ToBackend" "RequestSignup String String String"

    -- Type ToFrontend
    , Install.TypeVariant.makeRule "Types" "ToFrontend" "RegistrationError String"
    , Install.TypeVariant.makeRule "Types" "ToFrontend" "UserSignedIn (Maybe User.User)"
    , Install.TypeVariant.makeRule "Types" "ToFrontend" "UserRegistered (User.User)"
        , Install.TypeVariant.makeRule "Types" "ToFrontend" "AuthToFrontend Auth.Common.ToFrontend"
        , Install.TypeVariant.makeRule "Types" "ToFrontend" "AuthSuccess Auth.Common.UserInfo"
        , Install.TypeVariant.makeRule "Types" "ToFrontend" "UserInfoMsg (Maybe Auth.Common.UserInfo)"
        , Install.TypeVariant.makeRule "Types" "ToFrontend" "GetLoginTokenRateLimited"
               , Install.TypeVariant.makeRule "Types" "ToFrontend" "SignInError String"
             , Install.TypeVariant.makeRule "Types" "ToFrontend" "AuthToFrontend Auth.Common.ToFrontend"


    , Install.TypeVariant.makeRule "Types" "AuthFrontendMsg" "MagicLink.Types.FrontendMsg"


    -- Route
    , Install.TypeVariant.makeRule "Route" "Route" "TermsOfServicePageRoute"
    -- Frontend, install
    , Install.Import.initSimple "Frontend" [ "Auth.Common", "MagicLink.Types", "MagicLink.LoginForm" ] |> Install.Import.makeRule

    -- Backend init
    , Install.Initializer.makeRule "Backend" "init" "users" "Dict.empty"
    , Install.Initializer.makeRule "Backend" "init" "time" "Time.millisToPosix 0"
    , Install.Initializer.makeRule "Backend" "init" "randomAtmosphericNumbers" "Nothing"
    , Install.Initializer.makeRule "Backend" "init" "localUuidData" "Nothing"
    , Install.Initializer.makeRule "Backend" "init" "userNameToEmailString" "Dict.empty"
    , Install.Initializer.makeRule "Backend" "init" "counter" "AssocList.empty"

    , Install.Initializer.makeRule "Backend" "init" "pendingAuths" "Dict.empty"
    , Install.Initializer.makeRule "Backend" "init" "pendingEmailAuths" "Dict.empty"
    , Install.Initializer.makeRule "Backend" "init" "pendingLogins" "AssocList.empty"
    , Install.Initializer.makeRule "Backend" "init" "secretCounter" "0"
    , Install.Initializer.makeRule "Backend" "init" "sessionDict" "AssocList.empty"
    , Install.Initializer.makeRule "Backend" "init" "sessionInfo" "AssocList.empty"
    , Install.Initializer.makeRule "Backend" "init" "sessions" "AssocList.empty"
    , Install.Initializer.makeRule "Backend" "init" "log" "[]"

    -- Type BackendModel

    , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "sessions : Dict.Dict SessionId Auth.Common.UserInfo"
    , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "secretCounter : Int"
    , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "sessionDict : AssocList.Dict SessionId String"
    , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "pendingLogins: MagicLink.Types.PendingLogins"
    , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "pendingAuths : Dict.Dict Lamdera.SessionId Auth.Common.PendingAuth"
    , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "pendingEmailAuths : Dict.Dict Lamdera.SessionId Auth.Common.PendingEmailAuth"
    , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "pendingLogins : AssocList.empty"
    , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "log : MagicLink.Types.Log"
    , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "users: Dict.Dict User.EmailString User.User"
    , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "userNameToEmailString : Dict.Dict User.Username User.EmailString"
    , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "sessionInfo : Session.SessionInfo"
    , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "localUuidData : Maybe LocalUUID.Data"
    , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "time: Time.Posix"
    , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "randomAtmosphericNumbers: Maybe (List Int)"

    -- Backend import
    , Install.Import.initSimple "Backend" [ "Auth.Flow", "MagicLink.Backend","MagicLink.Auth", "Dict", "Helper", "LocalUUID", "Task", "Time", "User", "AssocList" ] |> Install.Import.makeRule
    , Install.Import.init "Backend" [ { moduleToImport = "Lamdera", alias_ = Nothing, exposedValues = Just [ "ClientId", "SessionId" ] } ] |> Install.Import.makeRule


    --
    , Install.TypeVariant.makeRule "Types" "FrontendMsg" "AuthFrontendMsg MagicLink.Types.FrontendMsg"
    , Install.ClauseInCase.init "Frontend" "updateLoaded" "AuthFrontendMsg authFrontendMsg" "MagicLink.Auth.updateFrontend authFrontendMsg model"
        |> Install.ClauseInCase.makeRule
    , Install.Import.initSimple "Frontend" [ "MagicLink.Auth" ] |> Install.Import.makeRule

    -- Type BackendMsg
    , Install.TypeVariant.makeRule "Types" "BackendMsg" "GotAtmosphericRandomNumbers (Result Http.Error String)"
     , Install.TypeVariant.makeRule "Types" "BackendMsg" "AuthBackendMsg Auth.Common.BackendMsg"
        , Install.TypeVariant.makeRule "Types" "BackendMsg" "AutoLogin SessionId User.LoginData"
        , Install.TypeVariant.makeRule "Types" "BackendMsg" "GotAtmosphericRandomNumbers (Result Http.Error String)"

    -- ToBackend
    , Install.TypeVariant.makeRule "Types" "ToBackend" "AuthToBackend Auth.Common.ToBackend"
    , Install.TypeVariant.makeRule "Types" "ToBackend" "AddUser String String String"
    , Install.TypeVariant.makeRule "Types" "ToBackend" "RequestSignup String String String"

    -- Type Frontend, User
    , Install.FieldInTypeAlias.makeRule "Types" "LoadedModel" "currentUser : Maybe User.User"
    , Install.FieldInTypeAlias.makeRule "Types" "LoadedModel" "signInState : SignInState"
    , Install.FieldInTypeAlias.makeRule "Types" "LoadedModel" "realname : String"
    , Install.FieldInTypeAlias.makeRule "Types" "LoadedModel" "username : String"
    , Install.FieldInTypeAlias.makeRule "Types" "LoadedModel" "email : String"
    , Install.FieldInTypeAlias.makeRule "Types" "LoadedModel" "signinForm : MagicLink.Types.SigninForm"
    --
     , Install.FieldInTypeAlias.makeRule "Types" "LoadedModel" "authFlow : Auth.Common.Flow"
        , Install.FieldInTypeAlias.makeRule "Types" "LoadedModel" "authRedirectBaseUrl : Url"
                , Install.FieldInTypeAlias.makeRule "Types" "LoadedModel" "loginErrorMessage : Maybe String"
        , Install.FieldInTypeAlias.makeRule "Types" "LoadedModel" "signInStatus : MagicLink.Types.SignInStatus"
        , Install.FieldInTypeAlias.makeRule "Types" "LoadedModel" "currentUserData : Maybe User.LoginData"

    --
    , Install.Function.init "Frontend" "tryLoading" tryLoading |> Install.Function.makeRule
    , Install.Function.init "Route" "encode" encodeRoutes_ |> Install.Function.makeRule

    --
    , Install.ClauseInCase.init "View.Main" "loadedView" "TermsOfServicePageRoute"  "Pages.Parts.generic model Pages.TermsOfService.view" |> Install.ClauseInCase.makeRule
    , Install.Import.initSimple "View.Main" ["Pages.TermsOfService"] |> Install.Import.makeRule
    --
    ]

encodeRoutes_ = """encode : Route -> String
encode route =
    Url.Builder.absolute
        (case route of
            HomepageRoute ->
                []

            TermsOfServicePageRoute ->
                [ "tos" ]

            CounterPageRoute ->
                [ "counter" ]
        )
        (case route of
            HomepageRoute ->
                []

            TermsOfServicePageRoute ->
                []

            CounterPageRoute ->
                []
        )"""
tryLoading =
    """tryLoading : LoadingModel -> ( FrontendModel, Cmd FrontendMsg )
tryLoading loadingModel =
    Maybe.map
        (\\window ->
            case loadingModel.route of
                _ ->
                    ( Loaded
                        { key = loadingModel.key
                        , now = loadingModel.now
                        , window = window
                        , showTooltip = False

                        -- MAGICLINK
                        , authFlow = Auth.Common.Idle
                        , authRedirectBaseUrl =
                            let
                                initUrl =
                                    loadingModel.initUrl
                            in
                            { initUrl | query = Nothing, fragment = Nothing }
                        , signinForm = MagicLink.LoginForm.init
                        , loginErrorMessage = Nothing
                        , signInStatus = MagicLink.Types.NotSignedIn

                        -- USER
                        , currentUserData = Nothing
                        , currentUser = Nothing
                        , realname = ""
                        , username = ""
                        , email = ""
                        , signInState = SignedOut
                        --
                        , route = loadingModel.route
                        , backendModel = Nothing
                        , message = "Starting up ..."
                        }
                    , Cmd.none
                    )
        )
        loadingModel.window
        |> Maybe.withDefault ( Loading loadingModel, Cmd.none )
"""



--
--config2 : List Rule
--config2 =
--    [ -- TYPES

--    , Install.Type.makeRule "Types" "Foo" [ "Bar" ]
--
--    -- TYPES IMPORTS
--    , Install.Import.init "Types" "Auth.Common" |> Install.Import.makeRule
--    , Install.Import.init "Types" "Url" |> Install.Import.withExposedValues [ "Url" ] |> Install.Import.makeRule
--    , Install.Import.init "Types" "MagicLink.Types" |> Install.Import.makeRule
--    , Install.Import.init "Types" "User" |> Install.Import.makeRule
--    , Install.Import.init "Types" "Session" |> Install.Import.makeRule
--    , Install.Import.init "Types" "Dict" |> Install.Import.withExposedValues [ "Dict" ] |> Install.Import.makeRule
--    , Install.Import.init "Types" "AssocList" |> Install.Import.makeRule
--    , Install.Import.init "Types" "Http" |> Install.Import.makeRule
--    , Install.Import.init "Types" "LocalUUID" |> Install.Import.makeRule
--
--    -- Type Frontend, MagicLink

--    -- Type Frontend, User
--    , Install.FieldInTypeAlias.makeRule "Types" "LoadedModel" "currentUser : Maybe User.User"
--    , Install.FieldInTypeAlias.makeRule "Types" "LoadedModel" "signInState : SignInState"
--    , Install.FieldInTypeAlias.makeRule "Types" "LoadedModel" "realname : String"
--    , Install.FieldInTypeAlias.makeRule "Types" "LoadedModel" "username : String"
--    , Install.FieldInTypeAlias.makeRule "Types" "LoadedModel" "email : String"
--
--    -- Type ToBackend
--    , Install.TypeVariant.makeRule "Types" "ToBackend" "AuthToBackend Auth.Common.ToBackend"
--    , Install.TypeVariant.makeRule "Types" "ToBackend" "AddUser String String String"
--    , Install.TypeVariant.makeRule "Types" "ToBackend" "RequestSignup String String String"
--
--    -- Type ToFrontend

--
--    -- Backend init
--    -- Looks like fields pendingLogins√, sessionInfo√, and userNameToEmailString
--    , Install.Initializer.makeRule "Backend" "init" "users" "Dict.empty"
--    , Install.Initializer.makeRule "Backend" "init" "sessions" "Dict.empty"
--    , Install.Initializer.makeRule "Backend" "init" "time" "Time.millisToPosix 0"
--    , Install.Initializer.makeRule "Backend" "init" "randomAtmosphericNumbers" "Nothing"
--    , Install.Initializer.makeRule "Backend" "init" "localUuidData" "Nothing"
--    , Install.Initializer.makeRule "Backend" "init" "pendingAuths" "Dict.empty"
--    , Install.Initializer.makeRule "Backend" "init" "secretCounter" "0"
--    , Install.Initializer.makeRule "Backend" "init" "pendingEmailAuths" "Dict.empty"
--    , Install.Initializer.makeRule "Backend" "init" "pendingLogins" "AssocList.empty"
--    , Install.Initializer.makeRule "Backend" "init" "pendingLogins" "AssocList.empty"
--    , Install.Initializer.makeRule "Backend" "init" "userNameToEmailString" "AssocList.empty"
--    , Install.Initializer.makeRule "Backend" "init" "sessionInfo" "Dict.empty"
--    , Install.Initializer.makeRule "Backend" "init" "sessionDict" "AssocList.empty"
--    , Install.Initializer.makeRule "Backend" "init" "log" "[]"
--
--    -- Type BackendModel
--    -- Looks like fields pendingLogins√, sessionInfo√, and userNameToEmailString√

--    -- Backend import
--    , Install.Import.init "Backend" "Auth.Common" |> Install.Import.makeRule
--    , Install.Import.init "Backend" "AssocList" |> Install.Import.makeRule
--    , Install.Import.init "Backend" "Auth.Flow" |> Install.Import.makeRule
--    , Install.Import.init "Backend" "Dict" |> Install.Import.makeRule
--    , Install.Import.init "Backend" "Helper" |> Install.Import.makeRule
--    , Install.Import.init "Backend" "Lamdera" |> Install.Import.withExposedValues [ "ClientId", "SessionId" ] |> Install.Import.makeRule
--    , Install.Import.init "Backend" "LocalUUID" |> Install.Import.makeRule
--    , Install.Import.init "Backend" "MagicLink.Auth" |> Install.Import.makeRule
--    , Install.Import.init "Backend" "Process" |> Install.Import.makeRule
--    , Install.Import.init "Backend" "Task" |> Install.Import.makeRule
--    , Install.Import.init "Backend" "Time" |> Install.Import.makeRule
--    , Install.Import.init "Backend" "User" |> Install.Import.makeRule
--
--    -- Type BackendMsg

--
--    --
--    , Install.ClauseInCase.init
--        "Frontend"
--        "updateFromBacked"
--        "AuthToFrontend authToFrontendMsg"
--        "MagicLink.Auth.updateFromBackend authToFrontendMsg model"
--        |> Install.ClauseInCase.makeRule
--
--    --
--    , Install.TypeVariant.makeRule "Types" "FrontendMsg" "AuthFrontendMsg MagicLink.Types.FrontendMsg"
--    , Install.ClauseInCase.init "Frontend" "updateLoaded" "AuthFrontendMsg authFrontendMsg" "MagicLink.Auth.updateFrontend authFrontendMsg model"
--        |> Install.ClauseInCase.makeRule
--    , Install.Import.init "Frontend" "MagicLink.Auth" |> Install.Import.makeRule
--    ]
{-

-}
