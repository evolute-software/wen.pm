module Static.Widgets exposing (footerBox, titleBox)

import Html exposing (Html, a, button, div, h1, h2, img, span, text)
import Html.Attributes as Attr exposing (class, href, id, src, style, target)
import Html.Events exposing (onClick)


titleBox : Html msg
titleBox =
    div [ class "event", class "title" ]
        [ h1 [] [ Html.text "Wen.!?" ]
        , div [] [ Html.text "#WenRewards? #WenGoguen!? #WenStuff???" ]
        , div [] [ Html.text "Your one stop shop to Cardano, its roadmap and the Cardano community!" ]
        ]


footerBox : Html msg
footerBox =
    div [ class "event", class "footer" ]
        [ div [] [ Html.text "Made with love by" ]
        , a [ href "https://spectrum-pool.kind.software", target "_new" ] [ img [ src "/assets/images/spec-logo-4-512.jpg" ] [] ]
        ]
