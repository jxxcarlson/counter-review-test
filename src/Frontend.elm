module Frontend exposing (app)

import Auth.Common
import Browser
import Browser.Dom
import Browser.Events
import Browser.Navigation
import Dict
import Json.Decode
import Lamdera exposing (sendToBackend)
import MagicLink.Auth
import MagicLink.Frontend
import MagicLink.Types
import Pages.Admin
import Pages.Home
import Pages.Notes
import Pages.SignIn
import Pages.TermsOfService
import Route
import Task
import Time
import Types exposing (..)
import Url
import View.Main


{-| Lamdera applications define 'app' instead of 'main'.

Lamdera.frontend is the same as Browser.application with the
additional update function; updateFromBackend.

-}
app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = subscriptions
        , view = View.Main.view
        }


subscriptions : FrontendModel -> Sub FrontendMsg
subscriptions _ =
    Sub.batch
        [ Browser.Events.onResize GotWindowSize
        , Browser.Events.onMouseUp (Json.Decode.succeed MouseDown)
        , Time.every 1000 Tick
        ]


init : Url.Url -> Browser.Navigation.Key -> ( FrontendModel, Cmd FrontendMsg )
init url key =
    let
        route =
            Route.decode url
    in
    ( Loading
        { key = key
        , initUrl = url
        , now = Time.millisToPosix 0
        , window = Nothing
        , route = route
        }
    , Cmd.batch
        [ Browser.Dom.getViewport
            |> Task.perform (\{ viewport } -> GotWindowSize (round viewport.width) (round viewport.height))
        ]
    )


update : FrontendMsg -> FrontendModel -> ( FrontendModel, Cmd FrontendMsg )
update msg model =
    case model of
        Loading loading ->
            case msg of
                GotWindowSize width height ->
                    tryLoading { loading | window = Just { width = width, height = height } }

                _ ->
                    ( model, Cmd.none )

        Loaded loaded ->
            updateLoaded msg loaded |> Tuple.mapFirst Loaded


tryLoading : LoadingModel -> ( FrontendModel, Cmd FrontendMsg )
tryLoading loadingModel =
    Maybe.map
        (\window ->
            case loadingModel.route of
                _ ->
                    let
                        authRedirectBaseUrl =
                            let
                                initUrl =
                                    loadingModel.initUrl
                            in
                            { initUrl | query = Nothing, fragment = Nothing }
                    in
                    ( Loaded
                        { key = loadingModel.key
                        , now = loadingModel.now
                        , counter = 0
                        , window = window
                        , showTooltip = False
                        , magicLinkModel = Pages.SignIn.init authRedirectBaseUrl
                        , route = loadingModel.route
                        , message = "Starting up ..."
                        , users = Dict.empty
                        }
                    , Cmd.none
                    )
        )
        loadingModel.window
        |> Maybe.withDefault ( Loading loadingModel, Cmd.none )


updateLoaded : FrontendMsg -> LoadedModel -> ( LoadedModel, Cmd FrontendMsg )
updateLoaded msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        UrlClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Browser.Navigation.pushUrl model.key (Url.toString url)
                    )

                Browser.External url ->
                    ( model
                    , Browser.Navigation.load url
                    )

        UrlChanged url ->
            ( { model | route = Route.decode url }, scrollToTop )

        Tick now ->
            ( { model | now = now }, Cmd.none )

        GotWindowSize width height ->
            ( { model | window = { width = width, height = height } }, Cmd.none )

        MouseDown ->
            ( { model | showTooltip = False }, Cmd.none )

        SetViewport ->
            ( model, Cmd.none )

        Increment ->
            ( { model | counter = model.counter + 1 }, sendToBackend CounterIncremented )

        Decrement ->
            ( { model | counter = model.counter - 1 }, sendToBackend CounterDecremented )

        LiftMsg _ ->
            ( model, Cmd.none )

        SetRoute_ route ->
            ( { model | route = route }, Cmd.none )

        AuthFrontendMsg authToFrontendMsg ->
            MagicLink.Auth.update authToFrontendMsg model.magicLinkModel |> Tuple.mapFirst (\magicLinkModel -> { model | magicLinkModel = magicLinkModel })

        SignInUser userData ->
            MagicLink.Frontend.signIn model userData


scrollToTop : Cmd FrontendMsg
scrollToTop =
    Browser.Dom.setViewport 0 0 |> Task.perform (\() -> SetViewport)



--update2 : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
--update2 msg model =
--    case msg of
--        Increment ->
--            ( { model | counter = model.counter + 1 }, sendToBackend CounterIncremented )
--
--        Decrement ->
--            ( { model | counter = model.counter - 1 }, sendToBackend CounterDecremented )
--
--        NoOp ->
--            ( model, Cmd.none )


updateFromBackend : ToFrontend -> FrontendModel -> ( FrontendModel, Cmd FrontendMsg )
updateFromBackend msg model =
    case model of
        Loading loading ->
            ( model, Cmd.none )

        Loaded loaded ->
            updateFromBackendLoaded msg loaded |> Tuple.mapFirst Loaded


updateFromBackendLoaded : ToFrontend -> LoadedModel -> ( LoadedModel, Cmd FrontendMsg )
updateFromBackendLoaded msg model =
    case msg of
        AuthToFrontend authToFrontendMsg ->
            MagicLink.Auth.updateFromBackend authToFrontendMsg model.magicLinkModel |> Tuple.mapFirst (\magicLinkModel -> { model | magicLinkModel = magicLinkModel })

        GotUserDictionary users ->
            ( { model | users = users }, Cmd.none )

        UserRegistered user ->
            MagicLink.Frontend.userRegistered model.magicLinkModel user |> Tuple.mapFirst (\magicLinkModel -> { model | magicLinkModel = magicLinkModel })

        GotMessage message ->
            ( { model | message = message }, Cmd.none )

        _ ->
            ( model, Cmd.none )
