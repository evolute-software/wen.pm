module Main exposing (main)

import Browser exposing (Document, UrlRequest(..), application)
import Browser.Navigation as BN exposing (Key)
import CardanoProtocol as CP
import Events exposing (Event, events, htmlId)
import Html exposing (Html, a, button, div, h1, h2, img, span, text)
import Html.Attributes as Attr exposing (class, href, id, src, style, target)
import Html.Events exposing (onClick)
import Json.Decode exposing (Value)
import Nav
import Process
import Task
import Time
import Url exposing (Url)



-- MAIN


main : Program Value Model Msg
main =
    application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = GotUrlReq
        , onUrlChange = GotUrlChange
        }



-- MODEL


type alias Model =
    { zone : Time.Zone
    , time : Time.Posix
    , events : List Event
    , url : Url
    , key : Key
    , start : Int
    , nav : Nav.Model
    }


init : flags -> Url -> Key -> ( Model, Cmd Msg )
init flags url key =
    let
        model =
            Model
                Time.utc
                (Time.millisToPosix 0)
                events
                url
                key
                0
                (Nav.Model False)
    in
    ( model
    , Cmd.batch
        [ Task.perform AdjustTimeZone Time.here
        , Task.perform Tick Time.now
        , Task.perform (\_ -> LoadStart) (Process.sleep 700)
        ]
    )


type Msg
    = Tick Time.Posix
    | AdjustTimeZone Time.Zone
    | GotUrlReq UrlRequest
    | GotUrlChange Url
    | NavBar Nav.Msg
    | LoadStart


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadStart ->
            case model.url.fragment of
                Nothing ->
                    ( model, BN.load "#native%20assets" )

                Just _ ->
                    ( model, Cmd.none )

        Tick newTime ->
            let
                updatedModel =
                    updateTime model newTime
            in
            ( updatedModel
            , Cmd.none
            )

        AdjustTimeZone newZone ->
            ( { model | zone = newZone }
            , Cmd.none
            )

        GotUrlChange newUrl ->
            ( { model | url = newUrl }
            , Cmd.none
            )

        GotUrlReq request ->
            case request of
                Browser.Internal newUrl ->
                    let
                        updated =
                            { model | url = newUrl }
                    in
                    ( updated, BN.pushUrl model.key (Url.toString newUrl) )

                Browser.External href ->
                    ( model, BN.load href )

        NavBar navMsg ->
            let
                ( newM, newCmd ) =
                    Nav.update navMsg model.nav

                updatedModel =
                    { model | nav = newM }
            in
            case navMsg of
                Nav.UrlReq href ->
                    ( updatedModel, BN.load href )

                Nav.ToggleNav ->
                    ( updatedModel, Cmd.map NavBar newCmd )


updateTime : Model -> Time.Posix -> Model
updateTime model newTime =
    let
        newStart =
            if model.start == 0 then
                toUnix newTime

            else
                model.start
    in
    { model | time = newTime, start = newStart }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 1000 Tick



-- VIEW


view : Model -> Document Msg
view model =
    let
        title =
            "WEN?!... Moon!"
    in
    Document title <|
        [ div [ class "content" ]
            [ div [ class "events" ] <| titleBox :: getEventBoxes model ++ [ footerBox ]
            ]
        , div [ class "nav" ] [ getNavBar model ]
        , div [ id "particles-js" ] []
        ]


getNavBar : Model -> Html Msg
getNavBar model =
    Nav.navbar model.events model.nav |> Html.map NavBar


titleBox : Html msg
titleBox =
    div [ class "event", class "title" ]
        [ h1 [] [ Html.text "Wen.!?" ]
        , div [] [ Html.text "Your one stop shop to Cardano, its roadmap and the Cardano community!" ]
        ]


footerBox : Html msg
footerBox =
    div [ class "event", class "footer" ]
        [ div [] [ Html.text "Made with love by" ]
        , a [ href "https://spectrum-pool.kind.software", target "_new" ] [ img [ src "/assets/images/spec-logo-4-512.jpg" ] [] ]
        ]


getEventBoxes : Model -> List (Html msg)
getEventBoxes model =
    List.map (renderBox model.time) model.events


renderBox : Time.Posix -> Event -> Html msg
renderBox time event =
    case event.unix of
        Just ts ->
            let
                secs =
                    ts - toUnix time

                seconds =
                    modBy 60 secs

                minutes =
                    modBy 60 <| secs // 60

                hours =
                    modBy 24 <| secs // 3600

                days =
                    secs // (3600 * 24)
            in
            if secs > 0 then
                div [ class "event" ]
                    ([ h2 [] [ Html.text event.title ]
                     , div [ class "blurb" ] [ Html.text <| Maybe.withDefault "" event.blurb ]
                     , div [ class "anchor", id <| htmlId event ] []
                     , div [ class "qbang" ] [ Html.text "!?" ]
                     , div [ class "countdown" ]
                        [ renderTimeItem "Days" days
                        , renderTimeItem "Hours" hours
                        , renderTimeItem "Minutes" minutes
                        , renderTimeItem "Seconds" seconds
                        ]
                     ]
                        ++ infoBox event
                    )

            else
                div [ class "event", class "done" ]
                    [ h2 [] [ Html.text event.title ]
                    , div [ class "blurb" ] [ Html.text <| Maybe.withDefault "" event.blurb ]
                    , div [ class "anchor", id <| htmlId event ] []
                    , div [ class "qbang" ] [ Html.text "!?" ]
                    , div [ class "done" ] [ Html.text "DONE!" ]
                    ]

        Nothing ->
            if event.title == "Rewards" then
                renderRewardsEvent time event

            else
                renderSoonEvent event


infoBox : Event -> List (Html msg)
infoBox event =
    case event.url of
        Nothing ->[]
        Just u -> 
            [ div [class "info-box"] [a [ href u] [Html.text u]]]


renderSoonEvent : Event -> Html msg
renderSoonEvent event =
    div [ class "event" ]
        [ h2 [] [ Html.text event.title ]
        , div [ class "anchor", id <| htmlId event ] []
        , div [ class "qbang" ] [ Html.text "!?" ]
        , div [] [ Html.text "soon™" ]
        ]


renderRewardsEvent : Time.Posix -> Event -> Html msg
renderRewardsEvent time event =
    div [ class "event", class "rewards" ]
        [ h2 [] [ Html.text event.title ]
        , div [ class "anchor", id <| htmlId event ] []
        , div [ class "qbang" ] [ Html.text "!?" ]
        , div []
            [ renderEpochTile time -1
            , renderEpochTile time 0
            ]
        ]


renderEpochTile : Time.Posix -> Int -> Html msg
renderEpochTile time offset =
    let
        epoch =
            CP.getEpoch offset time

        payout =
            CP.rewardsPayout epoch

        secsToPayout =
            payout - toUnix time

        minutesToPay =
            modBy 60 <| secsToPayout // 60

        hoursToPay =
            modBy 24 <| secsToPayout // 3600

        daysToPay =
            secsToPayout // (3600 * 24)
    in
    div [ class "epoch" ]
        [ div [ class "epoch-number" ] [ Html.text <| "E" ++ String.fromInt epoch ]
        , renderTimeItem "Days" daysToPay
        , renderTimeItem "Hours" hoursToPay
        , renderTimeItem "Minutes" minutesToPay
        ]


renderTimeItem : String -> Int -> Html msg
renderTimeItem name value =
    div [ class "time-item", class <| String.toLower name ]
        [ div [ class "value" ] [ Html.text <| String.fromInt value ]
        , div [ class "title" ] [ Html.text <| name ]
        ]


toUnix : Time.Posix -> Int
toUnix posix =
    round (toFloat (Time.posixToMillis posix) / 1000)



-- MAIN
--view : Model -> Document Msg
--view model =
--    let
--        mapBody toMsg body =
--            List.map (Html.map toMsg) body
--
--        notices =
--            Notifications.view model.notices |> List.map (Html.map GotNotify)
--
--        settings =
--            Settings.view model.settings |> mapBody GotSettings
--
--        title =
--            "Saturn Focus"
--
--        content =
--            case model.route of
--                Nav.Seasons ->
--                    Page.Seasons.view model.seasons |> Html.map GotSeasons
--
--                Nav.Profile ->
--                    Page.Profile.view model.settings
--
--                Nav.Season _ ->
--                    h1 [ class "season" ] [ text "Season Details" ]
--
--                Nav.NotFound ->
--                    h1 [ class "error" ] [ text "Not Found!" ]
--    in
--    Document title <|
--        [ div [ class "app" ]
--            [ Nav.navbar
--            , div [ class "application", classList [ ( "hidden", model.instrumentsHidden ) ] ] notices
--            , div [ class "application", classList [ ( "hidden", model.instrumentsHidden ) ] ] settings
--            , div [ class "content" ] [ content ]
--            ]
--        , div [ id "particles-js" ] []
--        ]
