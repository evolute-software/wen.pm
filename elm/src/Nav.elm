module Nav exposing (Model, Msg(..), init, navbar, update)

import Browser exposing (UrlRequest(..))
import Events exposing (Event)
import Html exposing (Html, a, div, input, label, nav, text)
import Html.Attributes exposing (checked, class, for, href, id, type_)
import Html.Events exposing (onClick)


type alias Model =
    { open : Bool
    }


init : Model
init =
    Model False


type Msg
    = ToggleNav | UrlReq String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleNav ->
            ( { model | open = not model.open }, Cmd.none )
        UrlReq req ->
            ({ model | open = False }, Cmd.none)


-- View


navbar : List Events.Event -> Model -> Html Msg
navbar events model =
    nav []
        [ label [ for "navbar" ] [ Html.text "🔴" ]
        , input [ type_ "checkbox", id "navbar", checked model.open, onClick ToggleNav ] []
        , div []
            (List.map
                createNav
                events
            )
        ]


createNav : Event -> Html Msg
createNav event =
    let
        anchor =
            "#" ++ Events.htmlId event
    in
    div [ class "nav-top" ] [ a [ href anchor, onClick <| UrlReq anchor ] [ text event.title ] ]
