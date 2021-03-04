module Main exposing (main)

import Browser exposing (Document, UrlRequest(..), application)
import Browser.Navigation as BN exposing (Key)
import CardanoProtocol as CP
import Events
import Model.Event exposing (Event, htmlId)
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
                []
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
                    ( model, BN.load <| "#" ++ ( htmlId <| Events.next model.time model.events))

                Just _ ->
                    ( model, Cmd.none )

        Tick newTime ->
            let
                updatedModel =
                    updateTime newTime model |> initEvents newTime
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


updateTime : Time.Posix -> Model -> Model
updateTime newTime model =
    let
        newStart =
            if model.start == 0 then
                toUnix newTime

            else
                model.start
    in
    { model | time = newTime, start = newStart }

initEvents : Time.Posix -> Model -> Model
initEvents newTime model = 
    case model.events of
        [] -> {model | events = Events.init newTime}
        _ -> model



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
        ,  getNavBar model
        , div [ id "particles-js" ] []
        ]


getNavBar : Model -> Html Msg
getNavBar model =
    Html.map NavBar <|
        Nav.navbar model.events model.nav


titleBox : Html msg
titleBox =
    div [ class "event", class "title" ]
        [ h1 [] [ Html.text "Wen.!?" ]
        , div [] [ Html.text "#WenRewards? #WenGoguen!? #WenStuff???" ]
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
                     , infoBox event
                     , div [ class "anchor", id <| htmlId event ] []
                     , div [ class "qbang" ] [ Html.text "!?" ]
                     , div [ class "countdown" ]
                        [ renderTimeItem "Days" days
                        , renderTimeItem "Hours" hours
                        , renderTimeItem "Minutes" minutes
                        , renderTimeItem "Seconds" seconds
                        ]
                     ]
                    )

            else
                div [ class "event", class "done" ]
                    ( [h2 [] [ Html.text event.title ]
                     , infoBox event
                     , div [ class "anchor", id <| htmlId event ] []
                     , div [ class "qbang" ] [ Html.text "!?" ]
                     , div [ class "done" ] [ Html.text "DONE!" ]
                     ]
                    )

        Nothing ->
            if event.title == "Rewards" then
                renderRewardsEvent time event

            else
                renderSoonEvent event


infoBox : Event -> Html msg
infoBox event =
    let
        blurb =  div [ class "blurb" ] [ Html.text <| Maybe.withDefault "" event.blurb ]
    in
    case event.url of
        Nothing ->
          div [ class "info-box" ]  [ blurb ]

        Just u ->
            let
                link =  a [ href u, target "_new" ] [ Html.text <| "Link: " ++ getDomain u ]
            in
                div [ class "info-box" ]  [ blurb, link ]  

getDomain : String -> String
getDomain str = 
    case Url.fromString str of
        Nothing -> "bad URL"
        Just url ->
            url.host

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
            [ renderEpochTile time True
            , renderEpochTile time False
            ]
        ]


renderEpochTile : Time.Posix -> Bool -> Html msg
renderEpochTile time previous =
    let
        offset = if previous then -1 else 0
        epochLabel = if previous then "Previous Epoch" else "Current Epoch"
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
        [ 
         div [ class "epoch-label" ] [ Html.text epochLabel ]
        ,    div [ class "epoch-number" ] [ Html.text <| "E-" ++ String.fromInt epoch ]

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

