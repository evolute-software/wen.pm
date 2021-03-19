module Main exposing (main)

import Browser exposing (Document, UrlRequest(..), application)
import Browser.Navigation as BN exposing (Key)
import Events
import Html exposing (Html, div)
import Html.Attributes exposing (class, href, id)
import Json.Decode exposing (Value)
import Model.Event as ME
import Nav
import Process
import Static.Widgets as SW
import Task
import Time
import Url exposing (Url)
import Util
import View.Events as VE



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
    , events : Events.Model
    , url : Url
    , key : Key
    , start : Int
    , nav : Nav.Model
    }


init : flags -> Url -> Key -> ( Model, Cmd Msg )
init _ url key =
    let
        model =
            Model
                Time.utc
                (Time.millisToPosix 0)
                Events.init
                url
                key
                0
                (Nav.Model False)
    in
    ( model
    , Cmd.batch
        [ Task.perform AdjustTimeZone Time.here
        , Task.perform Tick Time.now
        , Task.perform EventsMsg <| Task.succeed Events.LoadStreams
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
    | EventsMsg Events.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadStart ->
            case model.url.fragment of
                Nothing ->
                    ( model, BN.load <| "#" ++ (ME.htmlId <| Events.next model.time <| Events.getEvents model.events model.time) )

                Just _ ->
                    ( model, Cmd.none )

        Tick newTime ->
            let
                updatedModel =
                    updateTime newTime model
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

        EventsMsg m ->
            let
                ( eModel, eCmd ) =
                    Events.update m model.events
            in
            ( { model | events = eModel }, Cmd.map EventsMsg eCmd )


updateTime : Time.Posix -> Model -> Model
updateTime newTime model =
    let
        newStart =
            if model.start == 0 then
                Util.toUnix newTime

            else
                model.start
    in
    { model | time = newTime, start = newStart }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every 1000 Tick



-- VIEW


view : Model -> Document Msg
view model =
    let
        title =
            "WEN?!... Moon!"

        boxes =
            SW.titleBox :: getEventBoxes model ++ [ SW.footerBox ]
    in
    Document title <|
        [ div [ class "content" ]
            [ div [ class "events" ] boxes
            ]
        , getNavBar model
        , div [ id "particles-js" ] []
        ]


getNavBar : Model -> Html Msg
getNavBar model =
    Html.map NavBar <|
        Nav.navbar (Events.getEvents model.events model.time) model.nav


getEventBoxes : Model -> List (Html msg)
getEventBoxes model =
    List.map (VE.renderBox model.time) <| Events.getEvents model.events model.time
