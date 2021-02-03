module Main exposing (main)

import Browser exposing (Document, UrlRequest(..), application)
import Browser.Navigation as BN exposing (Key)
import Html exposing (Html, a, button, div, h1, h2, span, text)
import Html.Attributes exposing (class, classList, id)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Value)
import Nav
import Notifications
import Page.Profile
import Page.Seasons
import Settings
import Url exposing (Url)



-- MAIN
-- Browser.sandbox { init = init, update = update, view = view }


main : Program Value Model Msg
main =
    application
        { init = init
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = GotUrlReq
        , onUrlChange = GotUrlChange
        , view = view
        }


rqstUrl : UrlRequest -> Maybe Url
rqstUrl rqst =
    case rqst of
        Internal url ->
            Just url

        External str ->
            Nothing



-- Model


type alias Model =
    { notices : Notifications.Model
    , settings : Settings.Model
    , seasons : Page.Seasons.Model
    , route : Nav.Route
    , instrumentsHidden : Bool
    }


init : flags -> Url -> Key -> ( Model, Cmd Msg )
init flags url key =
    let
        ( stngs, cmd ) =
            Settings.init url key
    in
    ( { notices = []
      , settings = stngs
      , seasons = Page.Seasons.empty stngs
      , route = Nav.toRoute <| Url.toString url
      , instrumentsHidden = True
      }
    , Cmd.map GotSettings cmd
    )



-- UPDATE


type Msg
    = GotNotify Notifications.Msg
    | DoNotify String
    | GotUrlReq UrlRequest
    | GotUrlChange Url
    | GotSettings Settings.Msg
    | GotSeasons Page.Seasons.Msg
    | GotRoute Nav.Route


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotRoute r ->
            let
                m =
                    { model | route = r }

                cmd =
                    case r of
                        Nav.Seasons ->
                            Cmd.map GotSeasons <| Page.Seasons.load m.settings

                        _ ->
                            Cmd.none
            in
            ( m, cmd )

        GotSettings subMsg ->
            Settings.update subMsg model.settings
                |> updateWith (\ss -> { model | settings = ss }) GotSettings model

        GotUrlReq request ->
            if Nav.reqValid request then
                case request of
                    Browser.Internal url ->
                        ( model, BN.pushUrl model.settings.key (Url.toString url) )

                    Browser.External href ->
                        ( model, BN.load href )

            else
                update (DoNotify <| "Request invalid: " ++ Nav.reqToString request) model

        GotUrlChange url ->
            let
                notify =
                    DoNotify <| "Url Changed: " ++ Url.toString url

                route =
                    Nav.toRoute <| Url.toString url

                u1 =
                    update notify model

                u2 =
                    update (GotRoute route) (Tuple.first u1)
            in
            u2

        DoNotify str ->
            update (GotNotify <| Notifications.Notify str) model

        GotNotify n ->
            Notifications.update n model.notices
                |> updateWith (\subM -> { model | notices = subM }) GotNotify model

        GotSeasons m ->
            let
                seasonModel =
                    model.seasons

                ( newModel, cmd ) =
                    Page.Seasons.update m { seasonModel | settings = model.settings }
            in
            ( { model | seasons = newModel }, Cmd.map GotSeasons cmd )


updateWith : (subModel -> Model) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg model ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )



-- TODO: when do I really need subscriptions?


subscriptions : Model -> Sub msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Document Msg
view model =
    let
        mapBody toMsg body =
            List.map (Html.map toMsg) body

        notices =
            Notifications.view model.notices |> List.map (Html.map GotNotify)

        settings =
            Settings.view model.settings |> mapBody GotSettings

        title =
            "Saturn Focus"

        content =
            case model.route of
                Nav.Seasons ->
                    Page.Seasons.view model.seasons |> Html.map GotSeasons

                Nav.Profile ->
                    Page.Profile.view model.settings

                Nav.Season _ ->
                    h1 [ class "season" ] [ text "Season Details" ]

                Nav.NotFound ->
                    h1 [ class "error" ] [ text "Not Found!" ]
    in
    Document title <|
        [ div [ class "app" ]
            [ Nav.navbar
            , div [ class "application", classList [ ( "hidden", model.instrumentsHidden ) ] ] notices
            , div [ class "application", classList [ ( "hidden", model.instrumentsHidden ) ] ] settings
            , div [ class "content" ] [ content ]
            ]
        , div [ id "particles-js" ] []
        ]
