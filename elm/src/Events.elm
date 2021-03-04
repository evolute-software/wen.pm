module Events exposing (Event, init, htmlId, next)

import Url exposing (percentEncode)
import Time

-- TODO:
-- sum type of Rewards | Milestone title unix url blurb | Stream title unix url blurb duration repetition | Moon
type alias Event =
    { title : String
    , unix : Maybe Int
    , url : Maybe String
    , blurb : Maybe String
    }

next : Time.Posix -> List Event -> Event
next p es =
    let 
        eNext = nextTimed p es
    in
     case eNext of
         Nothing -> rewards
         Just e -> e

nextTimed : Time.Posix -> List Event -> Maybe Event
nextTimed posix es = 
    let
        timeds = getTimed es
        nexts = List.filter (isFuture posix) timeds
    in
      case nexts of
          [] -> Nothing
          n::ns -> Just n

-- Not necessarily correct but good enough
isFuture : Time.Posix -> Event -> Bool
isFuture t e = not <| isPast t e

getTimed : List Event -> List Event
getTimed es = List.filter isTimed es

isTimed : Event -> Bool
isTimed e = 
    case e.unix of
        Nothing -> False
        Just _ -> True

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

c360url= Just "https://www.crowdcast.io/e/hbe6af88"
laccUrl= Just "https://lovelace.academy/"

milestones : List Event
milestones = 
    [ Event "Byron" (Just 1596491091) byronUrl Nothing
    , Event "Shelley" (Just 1596491092) shelleyUrl <| Just "The start of the transition from the legacy BFT nodes to community operated PoS nodes."
    , Event "Allegra" (Just 1596491093) mairyUrl <| Just "Timed Token Locking."
    , Event "k=500" (Just 1596491094) Nothing Nothing
    , Event "Native Assets" (Just 1614635091) mairyUrl <| Just "NFTs and other tokens, natively on the Cardano ledger!"
    , Event "d=0" (Just 1617227091) Nothing <| Just "Full decentralization, the legacy BFT nodes can be taken completely offline, the community assumes complete responsibility for the operation of the mainnet."
    -- September Update GUI and Appstore
    -- Foundation is helping with metadata server
    , Event "Goguen" Nothing goguenUrl <| Just "Full Smart Contract functionality, Haskell and formally verified DAOs, ERC-20 importers."
    , Event "Voltaire" Nothing Nothing Nothing
    , Event "Basho" Nothing Nothing Nothing
    , Event "Moon" Nothing Nothing Nothing
    ]

streams : List Event
streams =  
    [
    Event "Cardano 360 webcast" (Just 1616693400) c360url <| Just "All the freshest news & feature content from across the Cardano ecosystem, delivered by Tim Harrison & Aparna Jue"
    , Event "Lovelace Academy 1st Show" (Just 1614803400) laccUrl <| Just "Tune in to the Lovelace Academy first educational video!"
    ]

rewards : Event
rewards = Event "Rewards" Nothing Nothing <| Just "#WenRewards"


toUnix : Time.Posix -> Int
toUnix posix =
    round (toFloat (Time.posixToMillis posix) / 1000)

isPast : Time.Posix -> Event -> Bool
isPast time e = 
    case e.unix of
        Nothing -> False 
        Just u -> toUnix time - u > 0


-- ToDo: the running part can only be implemented for events that have duration
split : Time.Posix -> List Event -> (List Event, List Event, List Event)
split time es =
    let
        expired = List.filter (isPast time) es
        running = []
        comming = List.filter (\e -> not <| isPast time e) es
    in
        (expired, running, comming)

-- see: https://package.elm-lang.org/packages/elm/core/latest/List#sortBy
comparableTime : Event -> Int
comparableTime e =
  case e.unix of
        Nothing -> 9999999999
        Just u -> u

init : Time.Posix -> List Event
init time =
    let 
        (doneMilestones, _, futureMilestones) = split time milestones
        (doneStreams, liveStreams, futureStreams) = split time streams
        completed = List.sortBy comparableTime (doneMilestones ++ doneStreams)
        future = List.sortBy comparableTime (futureMilestones ++ futureStreams)

    in
       completed ++ [ rewards ] ++ liveStreams ++ future

-- Old Events list
--    [ Event "Byron" (Just 1596491091) byronUrl Nothing
--    , Event "Shelley" (Just 1596491092) shelleyUrl <| Just "The start of the transition from the legacy BFT nodes to community operated PoS nodes."
--    , Event "Allegra" (Just 1596491093) mairyUrl <| Just "Timed Token Locking."
--    , Event "k=500" (Just 1596491094) Nothing Nothing
--    , Event "Launch of Catalyst Fund4" (Just 1613584800) fund4Url <| Just "The next round in Cardano's community led development!" 
--    , Event "Rewards" Nothing Nothing <| Just "#WenRewards"
--    , Event "Native Assets" (Just 1614635091) mairyUrl <| Just "NFTs and other tokens, natively on the Cardano ledger!"
--    , Event "d=0" (Just 1617227091) Nothing <| Just "Full decentralization, the legacy BFT nodes can be taken completely offline, the community assumes complete responsibility for the operation of the mainnet."
--    , Event "Goguen" Nothing goguenUrl <| Just "Full Smart Contract functionality, Haskell and formally verified DAOs, ERC-20 importers."
--    , Event "Voltaire" Nothing Nothing Nothing
--    , Event "Basho" Nothing Nothing Nothing
--    , Event "Moon" Nothing Nothing Nothing
--
--    -- ToDo: introduce sum type
--    ]
