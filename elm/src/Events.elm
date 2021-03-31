module Events exposing (Model, Msg(..), Notifications(..), getEvents, getNextTimed, init, next, split, update)

import Debug
import Http
import Model.Event as E exposing (Event)
import Static.Events as ES
import Time
import Url exposing (Protocol(..))
import Util


type alias Model =
    { streams : List E.Event
    , streamsRemote : List E.Event
    , milestones : List E.Event
    , milestonesRemote : List E.Event
    , rewards : E.Event
    , loadingStreams : HttpReqStatus
    , loadingMilestones : HttpReqStatus
    , notifications : Notifications
    }


type Notifications
    = Disabled
    | Unknown
    | Allowed (List Notif)


type alias Notif =
    { unix : Int
    , title : String
    }


init : Model
init =
    Model
        ES.streams
        []
        ES.milestones
        []
        E.Rewards
        None
        None
        Unknown


type Msg
    = LoadStreams
    | LoadingStreams
    | GotStreams (Result Http.Error (List Event))


type HttpReqStatus
    = None
    | Fetching
    | Complete
    | Error


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadStreams ->
            ( model
            , Http.get
                { url = "https://events.wen.pm/streams.json"
                , expect = Http.expectJson GotStreams E.decodeStream
                }
            )

        LoadingStreams ->
            ( { model | loadingStreams = Fetching }, Cmd.none )

        GotStreams result ->
            case result of
                Ok streams ->
                    ( { model | loadingStreams = Complete, streamsRemote = streams }, Cmd.none )

                Err _ ->
                    ( { model | loadingStreams = Debug.log "JSON deserialization" Error }, Cmd.none )


next : Time.Posix -> List Event -> Event
next p es =
    let
        eNext =
            getNextTimed p es
    in
    case eNext of
        Nothing ->
            E.Rewards

        Just e ->
            e


getNextTimed : Time.Posix -> List Event -> Maybe Event
getNextTimed posix es =
    let
        nexts =
            List.filter (E.isFuture posix) <| E.getTimed es
    in
    case nexts of
        [] ->
            Nothing

        n :: _ ->
            Just n



-- Not necessarily correct but good enough
-- ToDo: the running part can only be implemented for events that have duration


split : Time.Posix -> List Event -> ( List Event, List Event, List Event )
split time es =
    let
        expired =
            List.filter (E.isPast time) es

        running =
            []

        comming =
            List.filter (\e -> not <| E.isPast time e) es
    in
    ( expired, running, comming )



-- see: https://package.elm-lang.org/packages/elm/core/latest/List#sortBy


getEvents : Model -> Time.Posix -> List Event
getEvents model time =
    let
        ( doneMilestones, _, futureMilestones ) =
            model.milestones ++ model.milestonesRemote |> split time

        ( doneStreams, liveStreams, futureStreams ) =
            model.streams ++ model.streamsRemote |> split time

        filteredDoneStreams =
            List.filter (E.isDisplayable time) doneStreams

        completed =
            List.sortBy E.forceTimestamp (doneMilestones ++ filteredDoneStreams)

        future =
            List.sortBy E.forceTimestamp (futureMilestones ++ futureStreams)
    in
    completed ++ (model.rewards :: liveStreams) ++ future
