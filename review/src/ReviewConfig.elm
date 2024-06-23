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

         -- IMPORTS
         Install.Import.initSimple "Types" ["AssocList", "Auth.Common", "LocalUUID", "MagicLink.Types", "Session", "User", "Http"] |> Install.Import.makeRule
       , Install.Import.init "Types" [{moduleToImport = "Dict", alias_ = Nothing, exposedValues = Just ["Dict"]}] |> Install.Import.makeRule

       -- NEW TYPES
         , Install.Type.makeRule "Types" "AdminDisplay" ["ADUser", "ADSession", "ADKeyValues"]

       -- TO FRONTEND
       , Install.TypeVariant.makeRule "Types" "ToFrontend"    "OnConnected SessionId ClientId"

       -- BACKEND MSG
       , Install.TypeVariant.makeRule "Types" "BackendMsg"    "GotAtmosphericRandomNumbers (Result Http.Error String)"
       , Install.TypeVariant.makeRule "Types" "BackendMsg"    "AuthBackendMsg Auth.Common.BackendMsg"
       , Install.TypeVariant.makeRule "Types" "BackendMsg"    "AutoLogin SessionId User.SignInData"

       -- BackendModel
       , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "randomAtmosphericNumbers : Maybe (List Int)"
       , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "localUuidData : Maybe LocalUUID.Data"
       , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "time : Time.Posix"

       , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "pendingAuths : Dict Lamdera.SessionId Auth.Common.PendingAuth"
       , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "pendingEmailAuths : Dict Lamdera.SessionId Auth.Common.PendingEmailAuth"
       , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "sessions : Dict SessionId Auth.Common.UserInfo"

       , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "secretCounter : Int"
       , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "sessionDict : AssocList.Dict SessionId String"
       , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "pendingLogins : MagicLink.Types.PendingLogins"

       , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "log : MagicLink.Types.Log"
       , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "users : Dict.Dict User.EmailString User.User"
       , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "userNameToEmailString : Dict.Dict User.Username User.EmailString"
       , Install.FieldInTypeAlias.makeRule "Types" "BackendModel" "sessionInfo : Session.SessionInfo"

      --  ToBackend
        , Install.TypeVariant.makeRule "Types" "ToBackend" "AutoLogin SessionId"
        , Install.TypeVariant.makeRule "Types" "ToBackend" "AdminInspect (Maybe User.User)"
        , Install.TypeVariant.makeRule "Types" "ToBackend" "AuthToBackend Auth.Common.ToBackend"
        , Install.TypeVariant.makeRule "Types" "ToBackend" "AddUser String String String "
        , Install.TypeVariant.makeRule "Types" "ToBackend" "AutoLogin SessionId AuthToBackend Auth.Common.ToBackend"

       -- Import
     , Install.Import.init "Backend" [{moduleToImport = "MagicLink.Helper", alias_ = Just "Helper",  exposedValues = Nothing}] |> Install.Import.makeRule
     , Install.Import.initSimple "Backend" ["AssocList", "Auth.Common", "Auth.Flow",
       "MagicLink.Auth", "MagicLink.Backend", "Reconnect", "User"] |> Install.Import.makeRule

      -- Init


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
     , Install.Type.makeRule "Types" "BackendDataStatus" [ "Sunny", "LoadedBackendData", "Spell String Int"]

-- ROUTE
     , Install.TypeVariant.makeRule "Route" "Route" "TermsOfServiceRoute"
     , Install.TypeVariant.makeRule "Route" "Route" "Notes"
     , Install.TypeVariant.makeRule "Route" "Route" "SignInRoute"
     , Install.TypeVariant.makeRule "Route" "Route" "AdminRoute"
     , Install.Function.ReplaceFunction.init "Route" "decode" decode |> Install.Function.ReplaceFunction.makeRule
     , Install.Function.ReplaceFunction.init "Route" "encode" encode |> Install.Function.ReplaceFunction.makeRule

    ]

encode = """encode : Route -> String
encode route =
    Url.Builder.absolute
        (case route of
            HomepageRoute ->
                []

            CounterPageRoute ->
                [ "counter" ]

            TermsOfServiceRoute ->
                [ "terms" ]

            Notes ->
                [ "notes" ]

            SignInRoute ->
                [ "signin" ]

            AdminRoute ->
                [ "admin" ]
        )
        (case route of
            HomepageRoute ->
                []

            CounterPageRoute ->
                []

            TermsOfServiceRoute ->
                []

            Notes ->
                []

            SignInRoute ->
                []

            AdminRoute ->
                []
        )
"""
decode = """decode : Url -> Route
decode url =
    Url.Parser.oneOf
        [ Url.Parser.top |> Url.Parser.map HomepageRoute
        , Url.Parser.s "counter" |> Url.Parser.map CounterPageRoute
        , Url.Parser.s "admin" |> Url.Parser.map AdminRoute
        , Url.Parser.s "notes" |> Url.Parser.map Notes
        , Url.Parser.s "signin" |> Url.Parser.map SignInRoute
        ]
        |> (\\a -> Url.Parser.parse a url |> Maybe.withDefault HomepageRoute)
"""

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
