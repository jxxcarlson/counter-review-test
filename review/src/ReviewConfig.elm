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
import Install.InitializerCmd
import Install.Type
import Install.TypeVariant
import Regex
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


       -- TO FRONTEND

       -- FRONTEND MSG
       , Install.TypeVariant.makeRule "Types" "FrontendMsg" "SignInUser User.SignInData"
       , Install.TypeVariant.makeRule "Types" "FrontendMsg" "AuthFrontendMsg MagicLink.Types.Msg"
       , Install.TypeVariant.makeRule "Types" "FrontendMsg" "SetRoute_ Route"
       , Install.TypeVariant.makeRule "Types" "FrontendMsg" "LiftMsg MagicLink.Types.Msg"

       -- Backend Import
       , Install.Import.init "Backend" [{moduleToImport = "Dict", alias_ = Nothing, exposedValues = Just ["Dict"]}] |> Install.Import.makeRule
       , Install.Import.initSimple "Backend" ["Time"] |> Install.Import.makeRule
       , Install.Import.initSimple "Backend" ["Task"] |> Install.Import.makeRule
       -- Backend update
       , Install.ClauseInCase.init "Backend" "update" "GotAtmosphericRandomNumbers tryRandomAtmosphericNumbers" "Atmospheric.gotNumbers model tryRandomAtmosphericNumbers" |> Install.ClauseInCase.makeRule
       , Install.ClauseInCase.init "Backend" "update" "GotAtmosphericRandomNumbers tryRandomAtmosphericNumbers" "Atmospheric.gotNumbers model tryRandomAtmosphericNumbers" |> Install.ClauseInCase.makeRule
       , Install.ClauseInCase.init "Backend" "update" "GotFastTick time" "( { model | time = time } , Cmd.none )" |> Install.ClauseInCase.makeRule
       , Install.ClauseInCase.init "Backend" "update" "AuthBackendMsg authMsg" "Auth.Flow.backendUpdate (MagicLink.Auth.backendConfig model) authMsg" |> Install.ClauseInCase.makeRule
       , Install.ClauseInCase.init "Backend" "update" "AutoLogin sessionId loginData" "( model, Lamdera.sendToFrontend sessionId (AuthToFrontend <| Auth.Common.AuthSignInWithTokenResponse <| Ok <| loginData) )" |> Install.ClauseInCase.makeRule

       , Install.InitializerCmd.makeRule "Backend" "init" [ "Time.now |> Task.perform GotFastTick", "Helper.getAtmosphericRandomNumbers" ]
       -- BACKEND MSG
       , Install.TypeVariant.makeRule "Types" "BackendMsg" "GotAtmosphericRandomNumbers (Result Http.Error String)"
       , Install.TypeVariant.makeRule "Types" "BackendMsg" "AuthBackendMsg Auth.Common.BackendMsg"
       , Install.TypeVariant.makeRule "Types" "BackendMsg" "AutoLogin SessionId User.SignInData"
       , Install.TypeVariant.makeRule "Types" "BackendMsg" "GotFastTick Time.Posix"

       -- Loaded Model
       , Install.FieldInTypeAlias.makeRule "Types" "LoadedModel" "users : Dict.Dict User.EmailString User.User"
       , Install.FieldInTypeAlias.makeRule "Types" "LoadedModel" "magicLinkModel : MagicLink.Types.Model"

       , Install.Initializer.makeRule "Frontend" "initLoaded" "magicLinkModel" "Pages.SignIn.init loadingModel.initUrl"
       , Install.Initializer.makeRule "Frontend" "initLoaded" "users" "Dict.empty"
       , Install.Function.ReplaceFunction.init "Frontend" "updateFromBackendLoaded" (asOneLine updateFromBackendLoaded) |> Install.Function.ReplaceFunction.makeRule

       -- Install Frontend
       , Install.Import.initSimple "Frontend" ["MagicLink.Frontend", "MagicLink.Auth", "Dict", "Pages.SignIn", "Pages.Home", "Pages.Admin", "Pages.TermsOfService", "Pages.Notes"] |> Install.Import.makeRule
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
       , Install.Import.initSimple "Frontend" ["MagicLink.Types", "Auth.Common"] |> Install.Import.makeRule

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

    , Install.Function.ReplaceFunction.init "View.Main" "headerRow" headerRow |> Install.Function.ReplaceFunction.makeRule
--init : ( BackendModel, Cmd BackendMsg )
--init =
--    ...
--    , Cmd.batch
--        [ Time.now |> Task.perform GotFastTick
--        , Helper.getAtmosphericRandomNumbers
--        ]
--    )
       -- UpdateLoaded
     , Install.ClauseInCase.init "Frontend" "updateLoaded" "LiftMsg _" "( model, Cmd.none )" |> Install.ClauseInCase.makeRule
     , Install.ClauseInCase.init "Frontend" "updateLoaded" "SetRoute_ route" "( { model | route = route }, Cmd.none )" |> Install.ClauseInCase.makeRule
     , Install.ClauseInCase.init "Frontend" "updateLoaded" "AuthFrontendMsg authToFrontendMsg" "MagicLink.Auth.update authToFrontendMsg model.magicLinkModel |> Tuple.mapFirst (\\magicLinkModel -> { model | magicLinkModel = magicLinkModel })" |> Install.ClauseInCase.makeRule
     , Install.ClauseInCase.init "Frontend" "updateLoaded" "SignInUser userData" "MagicLink.Frontend.signIn model userData" |> Install.ClauseInCase.makeRule

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
     , Install.TypeVariant.makeRule "Types" "ToFrontend"    "GotMessage String"

     , Install.Type.makeRule "Types" "BackendDataStatus" [ "Sunny", "LoadedBackendData", "Spell String Int"]

-- ROUTE
     , Install.TypeVariant.makeRule "Route" "Route" "TermsOfServiceRoute"
     , Install.TypeVariant.makeRule "Route" "Route" "Notes"
     , Install.TypeVariant.makeRule "Route" "Route" "SignInRoute"
     , Install.TypeVariant.makeRule "Route" "Route" "AdminRoute"
     , Install.Function.ReplaceFunction.init "Route" "decode" decode |> Install.Function.ReplaceFunction.makeRule
     , Install.Function.ReplaceFunction.init "Route" "encode" encode |> Install.Function.ReplaceFunction.makeRule

    ]

headerRow = """headerRow model = [ headerView model model.route { window = model.window, isCompact = True }, Pages.SignIn.headerView model.magicLinkModel model.route { window = model.window, isCompact = True } |> Element.map Types.AuthFrontendMsg ]"""

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

updateFromBackendLoaded = """updateFromBackendLoaded msg model =
    let
        updateMagicLinkModelInModel =
            \\magicLinkModel -> { model | magicLinkModel = magicLinkModel }
    in
    case msg of
        AuthToFrontend authToFrontendMsg ->
            MagicLink.Auth.updateFromBackend authToFrontendMsg model.magicLinkModel |> Tuple.mapFirst updateMagicLinkModelInModel

        GotUserDictionary users ->
            ( { model | users = users }, Cmd.none )

        -- MAGICLINK
        AuthSuccess userInfo ->
            -- TODO (placholder)
            case userInfo.username of
                Just username ->
                    let
                        magicLinkModel_ =
                            model.magicLinkModel

                        magicLinkModel =
                            { magicLinkModel_ | authFlow = Auth.Common.Authorized userInfo.email username }
                    in
                    ( { model | magicLinkModel = magicLinkModel }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        UserInfoMsg _ ->
            -- TODO (placholder)
            ( model, Cmd.none )

        SignInError message ->
            MagicLink.Frontend.handleSignInError model.magicLinkModel message
                |> Tuple.mapFirst updateMagicLinkModelInModel

        RegistrationError str ->
            MagicLink.Frontend.handleRegistrationError model.magicLinkModel str
                |> Tuple.mapFirst updateMagicLinkModelInModel

        CheckSignInResponse _ ->
            ( model, Cmd.none )

        GetLoginTokenRateLimited ->
            ( model, Cmd.none )

        UserRegistered user ->
            MagicLink.Frontend.userRegistered model.magicLinkModel user
                |> Tuple.mapFirst updateMagicLinkModelInModel

        --|> Tuple.mapFirst updateMagicLinkModel
        UserSignedIn maybeUser ->
            let
                magicLinkModel_ =
                    model.magicLinkModel

                magicLinkModel =
                    case maybeUser of
                        Nothing ->
                            { magicLinkModel_ | signInStatus = MagicLink.Types.NotSignedIn } |> Debug.log "USER NOT SIGNED IN (1)"

                        Just _ ->
                            { magicLinkModel_ | signInStatus = MagicLink.Types.SignedIn } |> Debug.log "USER SIGNED IN (2)"
            in
            ( updateMagicLinkModelInModel magicLinkModel, Cmd.none )

        GotMessage message ->
            ( { model | message = message }, Cmd.none )
"""

asOneLine : String -> String
asOneLine str =
    str
      |>String.trim
      |>compressSpaces
      |> String.split "\n"
      |> List.filter (\s -> s /= "")
      |> String.join " "


compressSpaces : String -> String
compressSpaces string =
    userReplace " +" (\_ -> " ") string


userReplace : String -> (Regex.Match -> String) -> String -> String
userReplace userRegex replacer string =
    case Regex.fromString userRegex of
        Nothing ->
            string

        Just regex ->
            Regex.replace regex replacer string

