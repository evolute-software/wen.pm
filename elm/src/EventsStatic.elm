module EventsStatic exposing (..)

import Model.Event exposing (Event)


milestones : List Event
milestones =
    [ Event "Byron" (Just 1596491091) byronUrl Nothing
    , Event "Shelley" (Just 1596491092) shelleyUrl <| Just "The start of the transition from the legacy BFT nodes to community operated PoS nodes."
    , Event "Allegra" (Just 1596491093) mairyUrl <| Just "Timed Token Locking."
    , Event "k=500" (Just 1596491094) Nothing Nothing
    , Event "Native Assets" (Just 1614635091) mairyUrl <| Just "NFTs and other tokens, natively on the Cardano ledger!"
    , Event "d=0" (Just 1617227091) Nothing <| Just "Full decentralization, the legacy BFT nodes can be taken completely offline, the community assumes complete responsibility for the operation of the mainnet."
    , Event "Goguen" Nothing goguenUrl <| Just "Full Smart Contract functionality, Haskell and formally verified DAOs, ERC-20 importers."
    , Event "Voltaire" Nothing Nothing Nothing
    , Event "Basho" Nothing Nothing Nothing
    , Event "Moon" Nothing Nothing Nothing
    ]


rewards : Event
rewards =
    Event "Rewards" Nothing Nothing <| Just "#WenRewards"


streams : List Event
streams =
    [ Event "Cardano 360 webcast" (Just 1616693400) c360url <| Just "All the freshest news & feature content from across the Cardano ecosystem, delivered by Tim Harrison & Aparna Jue"
    , Event "Lovelace Academy 1st Show" (Just 1614803400) laccUrl <| Just "Tune in to the Lovelace Academy first educational video!"
    ]


byronUrl : Maybe String
byronUrl =
    Just "https://roadmap.cardano.org/en/byron/"


shelleyUrl : Maybe String
shelleyUrl =
    Just "https://roadmap.cardano.org/en/shelley/"


mairyUrl : Maybe String
mairyUrl =
    Just "https://www.youtube.com/watch?v=9mjvXjxTks8"


goguenUrl : Maybe String
goguenUrl =
    Just "https://roadmap.cardano.org/en/goguen/"


c360url : Maybe String
c360url =
    Just "https://www.crowdcast.io/e/hbe6af88"


laccUrl : Maybe String
laccUrl =
    Just "https://lovelace.academy/"
