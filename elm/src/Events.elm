module Events exposing (init, next)

import EventsStatic as ES
import Model.Event as E exposing (Event)
import Time



-- TODO:
-- sum type of Rewards | Milestone title unix url blurb | Stream title unix url blurb duration repetition | Moon


next : Time.Posix -> List Event -> Event
next p es =
    let
        eNext =
            getNextTimed p es
    in
    case eNext of
        Nothing ->
            ES.rewards

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


init : Time.Posix -> List Event
init time =
    let
        ( doneMilestones, _, futureMilestones ) =
            split time ES.milestones

        ( doneStreams, liveStreams, futureStreams ) =
            split time ES.streams

        completed =
            List.sortBy E.comparableTime (doneMilestones ++ doneStreams)

        future =
            List.sortBy E.comparableTime (futureMilestones ++ futureStreams)
    in
    completed ++ [ ES.rewards ] ++ liveStreams ++ future
