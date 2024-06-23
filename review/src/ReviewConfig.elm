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
       , Install.TypeVariant.makeRule "Types" "ToFrontend" "OnConnected SessionId ClientId"

       -- FRONTEND MSG
       , Install.TypeVariant.makeRule "Types" "FrontendMsg" "SignInUser User.SignInData"
       , Install.TypeVariant.makeRule "Types" "FrontendMsg" "AuthFrontendMsg MagicLink.Types.Msg"
       , Install.TypeVariant.makeRule "Types" "FrontendMsg" "SetRoute_ Route"
       , Install.TypeVariant.makeRule "Types" "FrontendMsg" "SetAdminDisplay AdminDisplay"
       , Install.TypeVariant.makeRule "Types" "FrontendMsg" "LiftMsg MagicLink.Types.Msg"

       -- Backend Import
       , Install.Import.init "Backend" [{moduleToImport = "Dict", alias_ = Nothing, exposedValues = Just ["Dict"]}] |> Install.Import.makeRule
       , Install.Import.initSimple "Backend" ["Time"] |> Install.Import.makeRule

       -- Backend update
       , Install.ClauseInCase.init "Backend" "update" "GotAtmosphericRandomNumbers tryRandomAtmosphericNumbers" "Atmospheric.gotNumbers model tryRandomAtmosphericNumbers" |> Install.ClauseInCase.makeRule
       , Install.ClauseInCase.init "Backend" "update" "GotAtmosphericRandomNumbers tryRandomAtmosphericNumbers" "Atmospheric.gotNumbers model tryRandomAtmosphericNumbers" |> Install.ClauseInCase.makeRule
       , Install.ClauseInCase.init "Backend" "update" "GotFastTick time" "( { model | time = time } , Cmd.none )" |> Install.ClauseInCase.makeRule
       , Install.ClauseInCase.init "Backend" "update" "AuthBackendMsg authMsg" "Auth.Flow.backendUpdate (MagicLink.Auth.backendConfig model) authMsg" |> Install.ClauseInCase.makeRule
       , Install.ClauseInCase.init "Backend" "update" "AutoLogin sessionId loginData" "( model, Lamdera.sendToFrontend sessionId (AuthToFrontend <| Auth.Common.AuthSignInWithTokenResponse <| Ok <| loginData) )" |> Install.ClauseInCase.makeRule

       -- BACKEND MSG
       , Install.TypeVariant.makeRule "Types" "BackendMsg" "GotAtmosphericRandomNumbers (Result Http.Error String)"
       , Install.TypeVariant.makeRule "Types" "BackendMsg" "AuthBackendMsg Auth.Common.BackendMsg"
       , Install.TypeVariant.makeRule "Types" "BackendMsg" "AutoLogin SessionId User.SignInData"
       , Install.TypeVariant.makeRule "Types" "BackendMsg" "GotFastTick Time.Posix"

       -- Loaded Model
       , Install.FieldInTypeAlias.makeRule "Types" "LoadedModel" "users : Dict.Dict User.EmailString User.User"
       , Install.FieldInTypeAlias.makeRule "Types" "LoadedModel" "magicLinkModel : MagicLink.Types.Model"


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
        , Install.TypeVariant.makeRule "Types" "ToBackend" "AuthToBackend Auth.Common.ToBackend"
        , Install.TypeVariant.makeRule "Types" "ToBackend" "AddUser String String String"
        , Install.TypeVariant.makeRule "Types" "ToBackend" "RequestSignUp String String String"
        , Install.TypeVariant.makeRule "Types" "ToBackend" "GetUserDictionary"

       -- Import
     , Install.Import.init "Backend" [{moduleToImport = "MagicLink.Helper", alias_ = Just "Helper",  exposedValues = Nothing}] |> Install.Import.makeRule
     , Install.Import.initSimple "Backend" ["Atmospheric", "AssocList", "Auth.Common", "Auth.Flow",
       "MagicLink.Auth", "MagicLink.Backend", "Reconnect", "User"] |> Install.Import.makeRule

      -- Init

     , Install.Initializer.makeRule "Backend" "init" "users" "Dict.empty"

     , Install.Initializer.makeRule "Backend" "init" "userNameToEmailString" "Dict.empty"
     , Install.Initializer.makeRule "Backend" "init" "sessions" "Dict.empty"
     , Install.Initializer.makeRule "Backend" "init" "sessionInfo" "Dict.empty"

     , Install.Initializer.makeRule "Backend" "init" "time" "Time.millisToPosix 0"
     , Install.Initializer.makeRule "Backend" "init" "randomAtmosphericNumbers" "Nothing"
     , Install.Initializer.makeRule "Backend" "init" "pendingAuths" "Dict.empty"
     , Install.Initializer.makeRule "Backend" "init" "localUuidData" "Nothing"

     , Install.Initializer.makeRule "Backend" "init" "pendingEmailAuths" "Dict.empty"
     , Install.Initializer.makeRule "Backend" "init" "secretCounter" "0"
     , Install.Initializer.makeRule "Backend" "init" "sessionDict" "AssocList.empty"
     , Install.Initializer.makeRule "Backend" "init" "pendingLogins" "AssocList.empty"
     , Install.Initializer.makeRule "Backend" "init" "log" "[]"

     -- updateFromFrontend
     , Install.ClauseInCase.init "Backend" "updateFromFrontend" "AuthToBackend authMsg" "Auth.Flow.updateFromFrontend (MagicLink.Auth.backendConfig model) clientId sessionId authMsg model" |> Install.ClauseInCase.makeRule
     , Install.ClauseInCase.init "Backend" "updateFromFrontend" "AddUser realname username email" "MagicLink.Backend.addUser model clientId email realname username" |> Install.ClauseInCase.makeRule
     , Install.ClauseInCase.init "Backend" "updateFromFrontend" "RequestSignUp realname username email" "MagicLink.Backend.requestSignUp model clientId realname username email" |> Install.ClauseInCase.makeRule
     , Install.ClauseInCase.init "Backend" "updateFromFrontend" "GetUserDictionary" "( model, Lamdera.sendToFrontend clientId (GotUserDictionary model.users) )" |> Install.ClauseInCase.makeRule

    -- VIEW.MAIN

    , Install.ClauseInCase.init "View.Main" "loadedView" "AdminRoute" adminRoute |> Install.ClauseInCase.makeRule
     , Install.ClauseInCase.init "View.Main" "loadedView" "TermsOfServiceRoute" "generic model Pages.TermsOfService.view" |> Install.ClauseInCase.makeRule
     , Install.ClauseInCase.init "View.Main" "loadedView" "Notes" "generic model Pages.Notes.view" |> Install.ClauseInCase.makeRule
     , Install.ClauseInCase.init "View.Main" "loadedView" "SignInRoute" "generic model (\\model_ -> Pages.SignIn.view Types.LiftMsg model_.magicLinkModel |> Element.map Types.AuthFrontendMsg)" |> Install.ClauseInCase.makeRule

     , Install.Function.InsertFunction.init "View.Main" "generic" generic |> Install.Function.InsertFunction.makeRule

    --
    , Install.Import.initSimple "View.Main" ["Pages.SignIn", "Pages.Admin", "Pages.TermsOfService", "Pages.Notes"] |> Install.Import.makeRule

--init : ( BackendModel, Cmd BackendMsg )
--init =
--    ...
--    , Cmd.batch
--        [ Time.now |> Task.perform GotFastTick
--        , Helper.getAtmosphericRandomNumbers
--        ]
--    )

       -- To Frontend
     , Install.TypeVariant.makeRule "Types" "ToFrontend"    "AuthToFrontend Auth.Common.ToFrontend"
     , Install.TypeVariant.makeRule "Types" "ToFrontend"    "AuthSuccess Auth.Common.UserInfo"
     , Install.TypeVariant.makeRule "Types" "ToFrontend"    "UserInfoMsg (Maybe Auth.Common.UserInfo)"
     , Install.TypeVariant.makeRule "Types" "ToFrontend"    "CheckSignInResponse (Result BackendDataStatus User.SignInData)"
     , Install.TypeVariant.makeRule "Types" "ToFrontend"    "GetLoginTokenRateLimited"
     , Install.TypeVariant.makeRule "Types" "ToFrontend"    "RegistrationError String"
     , Install.TypeVariant.makeRule "Types" "ToFrontend"    "SignInError String"
     , Install.TypeVariant.makeRule "Types" "ToFrontend"    "UserSignedIn (Maybe User.User)"
     , Install.TypeVariant.makeRule "Types" "ToFrontend"    "UserRegistered User.User"
     , Install.TypeVariant.makeRule "Types" "ToFrontend"    "GotUserDictionary (Dict.Dict User.EmailString User.User)"
     , Install.Type.makeRule "Types" "BackendDataStatus" [ "Sunny", "LoadedBackendData", "Spell String Int"]

-- ROUTE
     , Install.TypeVariant.makeRule "Route" "Route" "TermsOfServiceRoute"
     , Install.TypeVariant.makeRule "Route" "Route" "Notes"
     , Install.TypeVariant.makeRule "Route" "Route" "SignInRoute"
     , Install.TypeVariant.makeRule "Route" "Route" "AdminRoute"
     , Install.Function.ReplaceFunction.init "Route" "decode" decode |> Install.Function.ReplaceFunction.makeRule
     , Install.Function.ReplaceFunction.init "Route" "encode" encode |> Install.Function.ReplaceFunction.makeRule

    ]

adminRoute0 = "foo"

adminRouteA = """
    if User.isAdmin model.magicLinkModel.currentUserData then
        generic model Pages.Admin.view

    else
        generic model Pages.Home.view
"""

adminRoute = "if User.isAdmin model.magicLinkModel.currentUserData then generic model Pages.Admin.view else generic model Pages.Home.view"

adminRoute1 = """if User.isAdmin model.magicLinkModel.currentUserData then
        generic model Pages.Admin.view
    else
        generic model Pages.Home.view
"""

generic = """generic : Types.LoadedModel -> (Types.LoadedModel -> Element Types.FrontendMsg) -> Element Types.FrontendMsg
generic model view_ =
    Element.column
        [ Element.width Element.fill, Element.height Element.fill ]
        [ Element.row [ Element.width (Element.px model.window.width), Element.Background.color View.Color.blue ]
            [ ---
              Pages.SignIn.headerView model.magicLinkModel
                model.route
                { window = model.window, isCompact = True }
                |> Element.map Types.AuthFrontendMsg
            , headerView model model.route { window = model.window, isCompact = True }
            ]
        , Element.column
            (Element.padding 20
                :: Element.scrollbarY
                :: Element.height (Element.px <| model.window.height - 95)
                :: Theme.contentAttributes
            )
            [ view_ model -- |> Element.map Types.AuthFrontendMsg
            ]
        , footer model.route model
        ]
"""


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
        , Url.Parser.s "tos" |> Url.Parser.map TermsOfServiceRoute
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
