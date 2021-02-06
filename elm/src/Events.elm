module Events exposing (Event, events, htmlId)

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


byronUrl =
    Just "https://roadmap.cardano.org/en/byron/"


shelleyUrl =
    Just "https://roadmap.cardano.org/en/shelley/"


mairyUrl =
    Just "https://www.youtube.com/watch?v=9mjvXjxTks8"


events : List Event
events =
    [ Event "Byron" (Just 1596491091) byronUrl Nothing
    , Event "Shelley" (Just 1596491091) shelleyUrl Nothing
    , Event "Alegra" (Just 1596491091) mairyUrl <| Just "Timed Token Locking"
    , Event "k=500" (Just 1596491091) Nothing Nothing
    , Event "Rewards" Nothing Nothing Nothing
    , Event "Native Assets" (Just 1614635091) mairyUrl <| Just "NFTs and other tokens, natively on the Cardano ledger!"
    , Event "d=0" (Just 1617227091) Nothing Nothing
    , Event "Goguen" Nothing Nothing Nothing
    , Event "Voltaire" Nothing Nothing Nothing
    , Event "Basho" Nothing Nothing Nothing
    , Event "Moon" Nothing Nothing Nothing

    -- ToDo: introduce sum type
    ]
