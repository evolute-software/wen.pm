module CardanoProtocol exposing (getEpoch, rewardsPayout)

import Time


e209start =
    1596491091


epochSeconds =
    432000



-- Get the epoch based on the current time and an epoch offset


getEpoch : Int -> Time.Posix -> Int
getEpoch offset time =
    let
        diff =
            toUnix time - e209start

        epochsSince =
            diff // epochSeconds

        -- epochs that concluded since
    in
    209 + epochsSince + offset



-- Unix timestamp the rewards for the Epoch get payed out
-- if stake was active for 208 the rewards of 208 get payed
-- at the start of 210


rewardsPayout : Int -> Int
rewardsPayout epoch =
    let
        epochsToPayout =
            epoch + 2 - 209

        -- how many epochs must conclude since 209 for 'epoch' to be payed out?
        -- for some reason '+2' instead of '+1'
    in
    e209start + epochsToPayout * epochSeconds



-- stolen from main


toUnix : Time.Posix -> Int
toUnix posix =
    round (toFloat (Time.posixToMillis posix) / 1000)
