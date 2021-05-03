module Model.Event exposing (Event(..), TheMilestone, TheStream, decodeStream, forceTimestamp, getBlurb, getDone, getTimed, getTitle, getUrl, htmlId, isConfirmed, isDisplayable, isEol, isFuture, isLiveNow, isPast)

import Json.Decode exposing (Decoder, field, int, list, map, map6, string)
import Time
import Url exposing (percentEncode)


type Event
    = Rewards
    | Milestone TheMilestone
    | Stream TheStream


type alias TheMilestone =
    { title : String
    , unix : Maybe Int
    , confirmed : Bool
    , url : Maybe String
    , blurb : Maybe String
    }


type alias TheStream =
    { title : String
    , blurb : String
    , language : String
    , url : String
    , unix : Int
    , duration : Int
    }


decodeStream : Decoder (List Event)
decodeStream =
    map6 TheStream
        (field "title" string)
        (field "blurb" string)
        (field "language" string)
        (field "url" string)
        (field "timestamp" int)
        (field "duration" int)
        |> map Stream
        |> list


htmlId : Event -> String
htmlId e =
    percentEncode <| String.toLower <| getTitle e


forceTimestamp : Event -> Int
forceTimestamp e =
    case e of
        Rewards ->
            9999999999

        Stream s ->
            s.unix

        Milestone m ->
            case m.unix of
                Nothing ->
                    9999999999

                Just t ->
                    t


getTitle : Event -> String
getTitle e =
    case e of
        Rewards ->
            "Rewards"

        Milestone m ->
            m.title

        Stream s ->
            s.title


getDone : Event -> String
getDone e =
    case e of
        Milestone m ->
            if m.confirmed then
                "DONE"

            else
                "Confirming..."

        Stream _ ->
            "DONE"

        _ ->
            "well this was unexpected!"


getBlurb : Event -> String
getBlurb e =
    case e of
        Rewards ->
            "this should never happen"

        Milestone m ->
            case m.blurb of
                Nothing ->
                    ""

                Just b ->
                    b

        Stream s ->
            s.blurb


getUrl : Event -> Maybe String
getUrl e =
    case e of
        Rewards ->
            Nothing

        Milestone m ->
            m.url

        Stream s ->
            Just s.url


getTimed : List Event -> List Event
getTimed es =
    List.filter isTimed es


isConfirmed : Event -> Bool
isConfirmed e =
    case e of
        Milestone m ->
            m.confirmed

        _ ->
            True


isTimed : Event -> Bool
isTimed e =
    case e of
        Rewards ->
            False

        Stream _ ->
            True

        Milestone m ->
            case m.unix of
                Nothing ->
                    False

                Just _ ->
                    True


isFuture : Time.Posix -> Event -> Bool
isFuture t e =
    not <| isPast t e


isPast : Time.Posix -> Event -> Bool
isPast time e =
    case e of
        Rewards ->
            False

        Stream s ->
            toUnix time - s.unix - s.duration > 0

        Milestone m ->
            case m.unix of
                Nothing ->
                    False

                Just u ->
                    toUnix time - u > 0


isLiveNow : Time.Posix -> Event -> Bool
isLiveNow time e =
    case e of
        Stream s ->
            let
                beforeEnd =
                    toUnix time - (s.unix + s.duration) < 0

                afterStart =
                    toUnix time - s.unix > 0
            in
            afterStart && beforeEnd

        _ ->
            False


isDisplayable : Time.Posix -> Event -> Bool
isDisplayable time e =
    not <| isEol time e


isEol : Time.Posix -> Event -> Bool
isEol time e =
    case e of
        Stream s ->
            toUnix time - s.unix - s.duration - streamsStayAroundFor > 0

        _ ->
            False


streamsStayAroundFor : Int
streamsStayAroundFor =
    38 * 60 * 60


toUnix : Time.Posix -> Int
toUnix posix =
    round (toFloat (Time.posixToMillis posix) / 1000)
