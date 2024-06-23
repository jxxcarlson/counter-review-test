module ReviewConfig exposing (config)

{-| Do not rename the ReviewConfig module or the config function, because
`elm-review` will look for these.

To add packages that contain rules, add them to this review project using

    `elm install author/packagename`

when inside the directory containing this file.

-}

import Install.ClauseInCase
import Install.FieldInTypeAlias
import Install.Function.InsertFunction
import Install.Function.ReplaceFunction
import Install.Import
import Install.Initializer
import Install.Type
import Install.TypeVariant
import Review.Rule exposing (Rule)



-- CONFIG, Possibilities: configReset, configUsers


config =
    configMagic

configMagic : List Rule
configMagic =
    [ --TYPES
         Install.Import.initSimple "Types" ["AssocList", "Auth.Common", "LocalUUID", "MagicLink.Types", "Session", "User", "Http"] |> Install.Import.makeRule
       , Install.TypeVariant.makeRule "Types" "ToFrontend"    "OnConnected SessionId ClientId"
       , Install.TypeVariant.makeRule "Types" "BackendMsg"    "GotAtmosphericRandomNumbers (Result Http.Error String)"
       , Install.TypeVariant.makeRule "Types" "BackendMsg"    "AuthBackendMsg Auth.Common.BackendMsg"
       , Install.TypeVariant.makeRule "Types" "BackendMsg"    "AutoLogin SessionId User.SignInData"
       -- BACKEND
     , Install.Import.init "Backend" [{moduleToImport = "MagicLink.Helper", alias_ = Just "Helper",  exposedValues = Nothing}] |> Install.Import.makeRule
     , Install.Import.initSimple "Backend" ["AssocList", "Auth.Common", "Auth.Flow",
       "MagicLink.Auth", "MagicLink.Backend", "Reconnect", "User"] |> Install.Import.makeRule
       -- TO FRONTEND
     , Install.TypeVariant.makeRule "Types" "ToFrontend"    "AuthToFrontend Auth.Common.ToFrontend"
     , Install.TypeVariant.makeRule "Types" "ToFrontend"    "AuthSuccess Auth.Common.UserInfo"
     , Install.TypeVariant.makeRule "Types" "ToFrontend"    "UserInfoMsg (Maybe Auth.Common.UserInfo)"
     , Install.TypeVariant.makeRule "Types" "ToFrontend"    "CheckSignInResponse (Result BackendDataStatus User.SignInData)"
     , Install.TypeVariant.makeRule "Types" "ToFrontend"    "GetLoginTokenRateLimited"
     , Install.TypeVariant.makeRule "Types" "ToFrontend"    "RegistrationError String"
     , Install.TypeVariant.makeRule "Types" "ToFrontend"    "SignInError String"
     , Install.TypeVariant.makeRule "Types" "ToFrontend"    "UserSignedIn (Maybe User.User)"
     , Install.TypeVariant.makeRule "Types" "ToFrontend"    "UserRegistered User.User"
     , Install.TypeVariant.makeRule "Types" "ToFrontend"    "CheckSignInResponse (Result BackendDataStatus User.SignInData)"
     , Install.TypeVariant.makeRule "Types" "ToFrontend"    "CheckSignInResponse (Result BackendDataStatus User.SignInData)"
     , Install.TypeVariant.makeRule "Types" "ToFrontend"    "CheckSignInResponse (Result BackendDataStatus User.SignInData)"
     , Install.TypeVariant.makeRule "Types" "ToFrontend"    "CheckSignInResponse (Result BackendDataStatus User.SignInData)"
     , Install.TypeVariant.makeRule "Types" "ToFrontend"    "CheckSignInResponse (Result BackendDataStatus User.SignInData)"
     , Install.Type.makeRule "Types" "BackendDataStatus" [ "Sunny", "LoadedBackendData", "Spell String Int"]

-- ROUTE
     , Install.TypeVariant.makeRule "Route" "Route" "TermsOfServiceRoute"
     , Install.TypeVariant.makeRule "Route" "Route" "Notes"
     , Install.TypeVariant.makeRule "Route" "Route" "SignInRoute"
     , Install.TypeVariant.makeRule "Route" "Route" "AdminRoute"

    ]

configReset : List Rule
configReset =
    [ Install.TypeVariant.makeRule "Types" "ToBackend" "CounterReset"
    , Install.TypeVariant.makeRule "Types" "FrontendMsg" "Reset"
    , Install.ClauseInCase.init "Frontend" "updateLoaded" "Reset" "( { model | counter = 0 }, sendToBackend CounterReset )"
        |> Install.ClauseInCase.withInsertAfter "Increment"
        |> Install.ClauseInCase.makeRule
    , Install.ClauseInCase.init "Backend" "updateFromFrontend" "CounterReset" "( { model | counter = 0 }, broadcast (CounterNewValue 0 clientId) )" |> Install.ClauseInCase.makeRule
    , Install.Function.ReplaceFunction.init "Pages.Counter" "view" viewFunction |> Install.Function.ReplaceFunction.makeRule
    ]

viewFunction =
    """view model =
    Html.div [ style "padding" "50px" ]
        [ Html.button [ onClick Increment ] [ text "+" ]
        , Html.div [ style "padding" "10px" ] [ Html.text (String.fromInt model.counter) ]
        , Html.button [ onClick Decrement ] [ text "-" ]
        , Html.div [] [Html.button [ onClick Reset, style "margin-top" "10px"] [ text "Reset" ]]
        ] |> Element.html   """
