module Static.Events exposing (milestones, streams)

import Model.Event as ME exposing (Event)


milestones : List Event
milestones =
    [ ME.Milestone <| ME.TheMilestone "Byron" (Just 1596491091) True byronUrl Nothing
    , ME.Milestone <| ME.TheMilestone "Shelley" (Just 1596491092) True shelleyUrl <| Just "The start of the transition from the legacy BFT nodes to community operated PoS nodes."
    , ME.Milestone <| ME.TheMilestone "Allegra" (Just 1596491093) True mairyUrl <| Just "Timed Token Locking."
    , ME.Milestone <| ME.TheMilestone "k=500" (Just 1596491094) True Nothing Nothing
    , ME.Milestone <| ME.TheMilestone "Native Assets" (Just 1614635091) True mairyUrl <| Just "NFTs and other tokens, natively on the Cardano ledger!"
    , ME.Milestone <| ME.TheMilestone "d=0" (Just 1617227091) True Nothing <| Just "Full decentralization, the legacy BFT nodes can be taken completely offline, the community assumes complete responsibility for the operation of the mainnet."
    , ME.Milestone <| ME.TheMilestone "Alonzo Node" (Just 1618523091) True Nothing <| Just "In mid April the functionality for executing smart contracts inside the cardano-node component reaches maturity and can be used in the various testnets that will be following. Now an internal testnet can be launched to prepare for the Alonzo Pioneers era."
    , ME.Milestone <| ME.TheMilestone "Alonzo Internal Testnet" (Just 1619819091) True Nothing <| Just "An IOHK internal testnet for Goguen. The first batch of developers of the IOHK Core Engineering Team take the alonzo node for a spin internally"
    , ME.Milestone <| ME.TheMilestone "Alonzo SPO Testnet" (Just 1622307600) True alonzoSpoNetUrl <| Just "Private testnet for Goguen. Select SPOs and IOHK partners test the first version of the alonzo node."

    --, ME.Milestone <| ME.TheMilestone "Alonzo Pioneers Testnet" (Just ) False Nothing <| Just "The first public testnet for Goguen. The first batch of around 1k external Alonzo pioneers will get access to the Pioneers Testnet where the functionalities of Alonzo will be tested in close collaboration with IOHK."
    --, ME.Milestone <| ME.TheMilestone "Alonzo Feature Freeze" (Just 1625003091) False Nothing <| Just "We lock down the code, this is the big one! After 2+ months of rigorous testing in the private and pioneers testnets the codebase will have been ironed out. Now we freeze the codebase and run stress tests on the networks one more time to ensure everyting is rock sollid because next comes..."
    , ME.Milestone <| ME.TheMilestone "Alonzo White" (Just 1625608800) True goguenUrl <| Just "Invite only testnet to test the Alonzo HFC, Full Smart Contract functionality, continuing the evolution of Alonzo blue"
    , ME.Milestone <| ME.TheMilestone "Alonzo Light Purple" (Just 1625608800) True goguenYtUrl <| Just "Prep for scaling the testnet from 100s to 1000s of SPOs and 1000s of developers"
    , ME.Milestone <| ME.TheMilestone "Alonzo Dark Purple" (Just 1629410399) False goguenYtUrl <| Just "Open the testnet from the 100-300 participants of Light Purple to up to 1000"

    -- Aug 23 Cardano Wallet Update
    -- Sep 1 Testnet HardFork
    , ME.Milestone <| ME.TheMilestone "Cardano Testnet Alonzo HFC" (Just 1630532701) False goguenYtUrl <| Just "The open, long running, cardano Testnet is forked into the Alonzo era. This is the last event before the Goguen mainnet launch"
    , ME.Milestone <| ME.TheMilestone "Goguen" (Just 1631483101) False goguenUrl <| Just "The Alonzo HFC. Full Smart Contract functionality, Haskell and formally verified DAOs, ERC-20 importers on the Cardano mainnet"
    , ME.Milestone <| ME.TheMilestone "Pergamon" Nothing True pergamonUrl <| Just "An experiment about human collaboration and NFTs"
    , ME.Milestone <| ME.TheMilestone "Voltaire" Nothing True Nothing Nothing
    , ME.Milestone <| ME.TheMilestone "Basho" Nothing True Nothing Nothing
    , ME.Milestone <| ME.TheMilestone "Moon" Nothing True Nothing Nothing
    ]



-- Event "Rewards" Nothing Nothing <| Just "#WenRewards"


streams : List Event
streams =
    [ ME.Stream <| ME.TheStream "Charles Hoskinson @ Blockchain Africa" "Charles holds a keynote at this years Blockchain Africa Conference" "en" "https://blockchainafrica.co/programme-2021/" 1616065200 3600
    , ME.Stream <| ME.TheStream "Running Stream" "a running one" "en" "https://do.co" 1616420625 7200
    , ME.Stream <| ME.TheStream "Africa" "Rumors around IOHK and Africa abound. Will we get an announcement soon?" "en" "https://africa.cardano.org/" 1619713800 10200
    ]



--, ME.Stream <| ME.TheStream "Running Stream" "a running one" "en" "https://do.co" 1616172575 7200


goguenYtUrl : Maybe String
goguenYtUrl =
    Just "https://www.youtube.com/watch?v=mnV4eWw37Ts"


alonzoSpoNetUrl : Maybe String
alonzoSpoNetUrl =
    Just "https://youtu.be/5mPC4uLMdEw?t=456"


pergamonUrl : Maybe String
pergamonUrl =
    Just "https://pergamon.app"


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
