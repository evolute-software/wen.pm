module View.Events exposing (renderBox)

import CardanoProtocol as CP
import Debug
import Html exposing (Html, a, div, h2)
import Html.Attributes exposing (class, href, id, target)
import Model.Event as ME
import Time
import Url exposing (Url)
import Util


renderBox : Time.Posix -> ME.Event -> Html msg
renderBox time event =
    case event of
        ME.Rewards ->
            renderRewardsEvent time event

        ME.Stream s ->
            renderBoxWithTime time s.unix event

        ME.Milestone m ->
            case m.unix of
                Just ts ->
                    renderBoxWithTime time ts event

                Nothing ->
                    renderSoonEvent event



-- REWARDS --------------------------------------------------------------------


renderRewardsEvent : Time.Posix -> ME.Event -> Html msg
renderRewardsEvent time event =
    div [ class "event", class "rewards" ]
        [ h2 [] [ Html.text <| ME.getTitle event ]
        , div [ class "anchor", id <| ME.htmlId event ] []
        , div [ class "qbang" ] [ Html.text "!?" ]
        , div []
            [ renderEpochTile time True
            , renderEpochTile time False
            ]
        ]



-- TIMED ----------------------------------------------------------------------


renderBoxWithTime : Time.Posix -> Int -> ME.Event -> Html msg
renderBoxWithTime time timestamp event =
    let
        isDone =
            ME.isPast time event

        isLive =
            ME.isLiveNow time event
    in
    if isLive then
        renderLiveTile event

    else if isDone then
        renderDoneTile event

    else
        renderCountdown time timestamp event


renderCountdown : Time.Posix -> Int -> ME.Event -> Html msg
renderCountdown time timestamp event =
    let
        secs =
            timestamp - Util.toUnix time

        seconds =
            modBy 60 secs

        minutes =
            modBy 60 <| secs // 60

        hours =
            modBy 24 <| secs // 3600

        days =
            secs // (3600 * 24)
    in
    div [ class "event" ]
        [ h2 [] [ Html.text <| ME.getTitle event ]
        , infoBox event
        , div [ class "anchor", id <| ME.htmlId event ] []
        , div [ class "qbang" ] [ Html.text "!?" ]
        , div [ class "countdown" ]
            [ renderTimeItem "Days" days
            , renderTimeItem "Hours" hours
            , renderTimeItem "Minutes" minutes
            , renderTimeItem "Seconds" seconds
            ]
        ]


renderLiveTile : ME.Event -> Html msg
renderLiveTile event =
    div [ class "event", class "live-now" ]
        [ h2 [] [ Html.text <| ME.getTitle event ]
        , infoBox event
        , div [ class "anchor", id <| ME.htmlId event ] []
        , div [ class "qbang" ] [ Html.text "!!" ]
        , div [ class "live" ] [ Html.text "Live now!" ]
        ]


renderDoneTile : ME.Event -> Html msg
renderDoneTile event =
    div [ class "event", class "done" ]
        [ h2 [] [ Html.text <| ME.getTitle event ]
        , infoBox event
        , div [ class "anchor", id <| ME.htmlId event ] []
        , div [ class "qbang" ] [ Html.text "!" ]
        , div [ class "done" ] [ Html.text "DONE" ]
        ]


renderEpochTile : Time.Posix -> Bool -> Html msg
renderEpochTile time previous =
    let
        offset =
            if previous then
                -1

            else
                0

        epochLabel =
            if previous then
                "Previous Epoch"

            else
                "Current Epoch"

        epoch =
            CP.getEpoch offset time

        payout =
            CP.rewardsPayout epoch

        secsToPayout =
            payout - Util.toUnix time

        minutesToPay =
            modBy 60 <| secsToPayout // 60

        hoursToPay =
            modBy 24 <| secsToPayout // 3600

        daysToPay =
            secsToPayout // (3600 * 24)
    in
    div [ class "epoch" ]
        [ div [ class "epoch-label" ] [ Html.text epochLabel ]
        , div [ class "epoch-number" ] [ Html.text <| "E-" ++ String.fromInt epoch ]
        , renderTimeItem "Days" daysToPay
        , renderTimeItem "Hours" hoursToPay
        , renderTimeItem "Minutes" minutesToPay
        ]


infoBox : ME.Event -> Html msg
infoBox event =
    let
        blurb =
            div [ class "blurb" ] [ Html.text <| ME.getBlurb event ]
    in
    case ME.getUrl event of
        Nothing ->
            div [ class "info-box" ] [ blurb ]

        Just u ->
            let
                link =
                    a [ href u, target "_new" ] [ Html.text <| "Link: " ++ getDomain u ]
            in
            div [ class "info-box" ] [ blurb, link ]


renderTimeItem : String -> Int -> Html msg
renderTimeItem name value =
    div [ class "time-item", class <| String.toLower name ]
        [ div [ class "value" ] [ Html.text <| String.fromInt value ]
        , div [ class "title" ] [ Html.text <| name ]
        ]


renderSoonEvent : ME.Event -> Html msg
renderSoonEvent event =
    div [ class "event" ]
        [ h2 [] [ Html.text <| ME.getTitle event ]
        , div [ class "anchor", id <| ME.htmlId event ] []
        , div [ class "qbang" ] [ Html.text "!?" ]
        , div [] [ Html.text "soon™" ]
        ]


getDomain : String -> String
getDomain str =
    case Url.fromString str of
        Nothing ->
            "bad URL"

        Just url ->
            url.host
