module Page.Profile exposing (view)

import Html exposing (Html, h1, text)
import Html.Attributes exposing (class)
import Settings


view : Settings.Model -> Html msg
view settings =
    h1 [ class "profile" ] [ text "Profile Page" ]
