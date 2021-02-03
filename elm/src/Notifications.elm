module Notifications exposing (Model, Msg(..), update, view)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)


type alias Model =
    List String


type Msg
    = Notify String
    | Delete String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Delete str ->
            ( List.filter (\n -> n /= str) model, Cmd.none )

        Notify str ->
            ( str :: model, Cmd.none )


view : List String -> List (Html Msg)
view notices =
    [ div [ class "notices" ] <|
        List.map
            (\notice -> div [] [ text notice ])
            notices
    ]
