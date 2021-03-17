module Nav exposing (Model, Msg(..), init, navbar, update)

import Browser exposing (UrlRequest(..))
import Html exposing (Html, a, button, div, nav, text)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Model.Event as ME exposing (Event)


type alias Model =
    { open : Bool
    }


init : Model
init =
    Model False


type Msg
    = ToggleNav
    | UrlReq String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleNav ->
            ( { model | open = not model.open }, Cmd.none )

        UrlReq _ ->
            ( { model | open = False }, Cmd.none )



-- View


navbar : List Event -> Model -> Html Msg
navbar events model =
    div [ class "nav", getDisplay model ]
        [ button [ onClick ToggleNav ] [ Html.text "🔴" ]
        , nav []
            [ -- input [ type_ "checkbox", id "navbar", checked model.open, ] []
              div [ class "list" ]
                (List.map
                    createNav
                    events
                )
            ]
        ]


getDisplay : Model -> Html.Attribute Msg
getDisplay model =
    if model.open then
        class "open"

    else
        class "closed"


createNav : Event -> Html Msg
createNav event =
    let
        anchor =
            "#" ++ ME.htmlId event
    in
    div [ class "item", class "nav-top" ] [ a [ href anchor, onClick <| UrlReq anchor ] [ text <| ME.getTitle event ] ]
