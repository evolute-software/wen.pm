module Model.Event exposing (Event, comparableTime, getTimed, htmlId, isFuture, isPast)

import Time
import Url exposing (percentEncode)


type alias Event =
    { title : String
    , unix : Maybe Int
    , url : Maybe String
    , blurb : Maybe String
    }


htmlId : Event -> String
htmlId event =
    percentEncode <| String.toLower event.title


comparableTime : Event -> Int
comparableTime e =
    case e.unix of
        Nothing ->
            9999999999

        Just u ->
            u


getTimed : List Event -> List Event
getTimed es =
    List.filter isTimed es


isTimed : Event -> Bool
isTimed e =
    case e.unix of
        Nothing ->
            False

        Just _ ->
            True


isFuture : Time.Posix -> Event -> Bool
isFuture t e =
    not <| isPast t e


isPast : Time.Posix -> Event -> Bool
isPast time e =
    case e.unix of
        Nothing ->
            False

        Just u ->
            toUnix time - u > 0


toUnix : Time.Posix -> Int
toUnix posix =
    round (toFloat (Time.posixToMillis posix) / 1000)
