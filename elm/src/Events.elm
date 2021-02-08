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

goguenUrl =
    Just "https://roadmap.cardano.org/en/goguen/"


events : List Event
events =
    [ Event "Byron" (Just 1596491091) byronUrl Nothing
    , Event "Shelley" (Just 1596491091) shelleyUrl <| Just "The start of the transition from the legacy BFT nodes to community operated PoS nodes."
    , Event "Allegra" (Just 1596491091) mairyUrl <| Just "Timed Token Locking."
    , Event "k=500" (Just 1596491091) Nothing Nothing
    , Event "Rewards" Nothing Nothing <| Just "#WenRewards"
    , Event "Native Assets" (Just 1614635091) mairyUrl <| Just "NFTs and other tokens, natively on the Cardano ledger!"
    , Event "d=0" (Just 1617227091) Nothing <| Just "Full decentralization, the legacy BFT nodes can be taken completely offline, the community assumes complete responsibility for the operation of the mainnet."
    , Event "Goguen" Nothing goguenUrl <| Just "Full Smart Contract functionality, Haskell and formally verified DAOs, ERC-20 importers."
    , Event "Voltaire" Nothing Nothing Nothing
    , Event "Basho" Nothing Nothing Nothing
    , Event "Moon" Nothing Nothing Nothing

    -- ToDo: introduce sum type
    ]
