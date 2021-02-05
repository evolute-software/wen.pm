module Main exposing (main)

import Browser exposing (Document, UrlRequest(..), application)
import Browser.Navigation as BN exposing (Key)
import CardanoProtocol as CP
import Html exposing (Html, a, button, div, h1, h2, span, text)
import Html.Attributes as Attr exposing (class, classList, id, style)
import Html.Events exposing (onClick)
import Json.Decode exposing (Value)
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


events : List Event
events =
    [ Event "Byron" <| Just 1596491091
    , Event "Shelley" <| Just 1596491091
    , Event "k=500" <| Just 1596491091
    , Event "Rewards" Nothing -- ToDo: introduce sum type
    , Event "d=0" <| Just 1617227091
    , Event "Native Assets" <| Just 1617327091
    , Event "Goguen" Nothing
    , Event "Moon" Nothing
    ]



-- MODEL


type alias Event =
    { title : String
    , unix : Maybe Int
    }


type alias Model =
    { zone : Time.Zone
    , time : Time.Posix
    , events : List Event
    , url : Url
    , key : Key
    , start : Int
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
    in
    ( model
    , Cmd.batch
        [ Task.perform AdjustTimeZone Time.here
        , Task.perform Tick Time.now
        ]
    )


type Msg
    = Tick Time.Posix
    | AdjustTimeZone Time.Zone
    | GotUrlReq UrlRequest
    | GotUrlChange Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick newTime ->
            ( updateTime model newTime
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
                Browser.Internal url ->
                    ( model, BN.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, BN.load href )


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
        hour =
            toFloat (Time.toHour model.zone model.time)

        minute =
            toFloat (Time.toMinute model.zone model.time)

        second =
            toFloat (Time.toSecond model.zone model.time)

        title =
            "WEN?!... Moon!"
    in
    Document title <|
        [ div [ class "content" ]
            [ div [ class "events" ] <| titleBox :: getEventBoxes model ++ [ footerBox ]
            ]
        , div [ class "nav" ] [ text "There will be NAV!" ]
        , div [ id "particles-js" ] []
        ]


titleBox : Html msg
titleBox =
    div [ class "event", class "title" ]
        [ h1 [] [ Html.text "Wen.!?" ]
        , div [] [ Html.text "Your one stop shop to Cardano, its roadmap and the Cardano community!" ]
        ]


footerBox : Html msg
footerBox =
    div [ class "event", class "footer" ]
        [ h1 [] [ Html.text "🔴" ]
        ]


titleStyle : Model -> List (Html.Attribute msg)
titleStyle model =
    if toUnix model.time - model.start > 10 then
        [ style "display" "none" ]

    else
        [ class "event", class "title" ]


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
                    [ h2 [] [ Html.text event.title ]
                    , div [ class "qbang" ] [ Html.text "!?" ]
                    , div [ class "countdown" ]
                        [ renderTimeItem "Days" days
                        , renderTimeItem "Hours" hours
                        , renderTimeItem "Minutes" minutes
                        , renderTimeItem "Seconds" seconds
                        ]
                    ]

            else
                div [ class "event", class "done" ]
                    [ h2 [] [ Html.text event.title ]
                    , div [ class "qbang" ] [ Html.text "!?" ]
                    , div [ class "done" ] [ Html.text "DONE!" ]
                    ]

        Nothing ->
            if event.title == "Rewards" then
                renderRewardsTile time event

            else
                renderSoonTile event


renderRewardsTile : Time.Posix -> Event -> Html msg
renderRewardsTile time event =
    div [ class "event", class "rewards" ]
        [ h2 [] [ Html.text event.title ]
        , div [ class "qbang" ] [ Html.text "!?" ]
        , div []
            [ renderEpochTile time event -1
            , renderEpochTile time event 0
            ]
        ]


renderEpochTile : Time.Posix -> Event -> Int -> Html msg
renderEpochTile time event offset =
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


renderSoonTile event =
    div [ class "event" ]
        [ h2 [] [ Html.text event.title ]
        , div [ class "qbang" ] [ Html.text "!?" ]
        , div [] [ Html.text "soon™" ]
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
