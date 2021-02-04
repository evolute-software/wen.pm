module Main exposing (main)

import Browser exposing (Document, UrlRequest(..), application)
import Browser.Navigation as BN exposing (Key)
import Html exposing (Html, a, button, div, h1, h2, span, text)
import Html.Attributes as Attr exposing (class, classList, id, style)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Value)
import Nav
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
    [ Event "Shelley" <| Just 1596491091
    , Event "k=500" <| Just 1596491091
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
    div [ class "event" ]
        [ h2 [] [ Html.text event.title ]
        , getBoxContents time event
        ]


getBoxContents : Time.Posix -> Event -> Html msg
getBoxContents time event =
    case event.unix of
        Just ts ->
            let
                secs =
                    ts - toUnix time
            in
            if secs > 0 then
                div [] [ Html.text <| String.fromInt <| secs ]

            else
                div [] [ Html.text "DONE!" ]

        Nothing ->
            div [] [ Html.text "soon™" ]


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
