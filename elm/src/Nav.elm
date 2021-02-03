module Nav exposing (Route(..), href, navbar, reqToString, reqValid, toRoute)

import Browser exposing (UrlRequest(..))
import Html exposing (Attribute, Html, a, div, h2, img, input, label, nav, text)
import Html.Attributes as Attr exposing (checked, class, for, id, src, type_)
import Url
import Url.Builder exposing (absolute)
import Url.Parser exposing ((</>), Parser, map, oneOf, parse, s, string, top)


type Route
    = Seasons
    | Profile
    | Season String
    | NotFound


href : Route -> Attribute msg
href r =
    Attr.href (urls r)


urls : Route -> String
urls r =
    case r of
        Seasons ->
            absolute [ "seasons" ] []

        Profile ->
            absolute [ "profile" ] []

        Season str ->
            absolute [ "season", str ] []

        NotFound ->
            absolute [ "404" ] []



-- type Route = Home | Blog Int | NotFound


route : Parser (Route -> a) a
route =
    oneOf
        [ map Seasons top
        , map Season (s "season" </> string)
        , map Profile (s "profile")
        , map Seasons (s "seasons")
        ]


toRoute : String -> Route
toRoute string =
    case Url.fromString string of
        Nothing ->
            NotFound

        Just url ->
            Maybe.withDefault NotFound (parse route url)



-- toRoute "/blog/42"                            ==  NotFound
-- toRoute "https://example.com/"                ==  Home
-- toRoute "https://example.com/blog"            ==  NotFound
-- toRoute "https://example.com/blog/42"         ==  Blog 42
-- toRoute "https://example.com/blog/42/"        ==  Blog 42
-- toRoute "https://example.com/blog/42#wolf"    ==  Blog 42
-- toRoute "https://example.com/blog/42?q=wolf"  ==  Blog 42
-- toRoute "https://example.com/settings"        ==  NotFound


reqValid : UrlRequest -> Bool
reqValid req =
    case req of
        External _ ->
            True

        Internal url ->
            Url.toString url |> toRoute |> (/=) NotFound


reqToString : UrlRequest -> String
reqToString rqst =
    case rqst of
        Internal url ->
            Url.toString url

        External url ->
            url



-- View


navbar : Html msg
navbar =
    nav []
        [ label [ for "navbar" ] [ img [ src "/assets/saturn-2.svg" ] [] ]
        , input [ type_ "checkbox", id "navbar", checked False ] []
        , div []
            [ div [ class "nav-top", class "profile" ] [ a [ href Profile ] [ text "Profile" ] ]
            , div [ class "nav-top", class "seasons" ] [ a [ href Seasons ] [ text "Seasons" ] ]
            ]
        ]
