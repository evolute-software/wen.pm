module Events exposing (Event, events, htmlId)

import Url exposing (percentEncode)


type alias Event =
    { title : String
    , unix : Maybe Int
    }


htmlId : Event -> String
htmlId event =
    percentEncode <| String.toLower event.title


events : List Event
events =
    [ Event "Byron" <| Just 1596491091
    , Event "Shelley" <| Just 1596491091
    , Event "Alegra" <| Just 1596491091
    , Event "k=500" <| Just 1596491091
    , Event "Rewards" Nothing -- ToDo: introduce sum type
    , Event "Native Assets" <| Just 1614635091
    , Event "d=0" <| Just 1617227091
    , Event "Goguen" Nothing
    , Event "Voltaire" Nothing
    , Event "Basho" Nothing
    , Event "Moon" Nothing
    ]
