module Page.Seasons exposing (Model, Msg(..), empty, load, update, view)

import Api
import Cfg
import Html exposing (Html, a, button, div, h1, h2, input, label, span, text)
import Html.Attributes exposing (checked, class, href, placeholder, type_, value)
import Html.Events exposing (onCheck, onClick, onInput)
import Http
import Json.Decode as Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode
import Nav
import Settings
import Token


load : Settings.Model -> Cmd Msg
load settings =
    Api.get (params settings) Loaded (Decode.list seasonDecoder)


post : Model -> Cmd Msg
post model =
    Api.post (postParams model) Posted seasonDecoder


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Loaded result ->
            case result of
                Ok seasons ->
                    ( { model | summaries = seasons }, Cmd.none )

                Err err ->
                    ( model, Cmd.none )

        Posted result ->
            case result of
                Ok season ->
                    ( { model | summaries = season :: model.summaries, submitting = False, formVisible = False }, load model.settings )

                Err err ->
                    ( { model | submitting = False }, Cmd.none )

        Name str ->
            ( { model | name = str }, Cmd.none )

        Status status ->
            ( { model | status = status }, Cmd.none )

        ToggleForm ->
            ( { model | formVisible = not model.formVisible }, Cmd.none )

        CancelForm ->
            ( { model | formVisible = False, name = "", status = False }, Cmd.none )

        SubmitForm ->
            ( { model | submitting = True }, post model )


type alias SeasonSummary =
    { id : String
    , name : String
    , status : SeasonStatus
    }


type SeasonStatus
    = Open
    | Closed


type Msg
    = Loaded (Result Http.Error (List SeasonSummary))
    | Posted (Result Http.Error SeasonSummary)
    | Name String
    | Status Bool
    | ToggleForm
    | SubmitForm
    | CancelForm


type alias Model =
    { summaries : List SeasonSummary
    , name : String --Season Form
    , status : Bool -- Season Form
    , formVisible : Bool
    , settings : Settings.Model
    , submitting : Bool
    }


empty : Settings.Model -> Model
empty stngs =
    { summaries = [], name = "", status = False, formVisible = False, settings = stngs, submitting = False }


params : Settings.Model -> Api.Params
params settings =
    { url = Cfg.url Cfg.SEASONS
    , body = Http.emptyBody
    , token =
        -- ToDo: the record given to this function should NOT have a Maybe Token.
        --       That should have been taken car of much earlier!
        case settings.token of
            Just token ->
                token

            Nothing ->
                Token.fromString ""
    }


postParams : Model -> Api.Params
postParams model =
    let
        base =
            params model.settings

        status =
            if model.status then
                "Open"

            else
                "Closed"

        season =
            Encode.object
                [ ( "name", Encode.string model.name )
                , ( "status", Encode.string status )
                ]
    in
    { base | body = Http.jsonBody season }


seasonDecoder : Decoder SeasonSummary
seasonDecoder =
    Decode.succeed SeasonSummary
        |> required "id" string
        |> required "name" string
        |> required "status" (string |> Decode.andThen decodeStatus)


decodeStatus : String -> Decoder SeasonStatus
decodeStatus s =
    case s of
        "Open" ->
            Decode.succeed Open

        "Closed" ->
            Decode.succeed Closed

        _ ->
            Decode.fail "Neither 'Open' nor 'Closed'"



-- View


viewSummary : SeasonSummary -> Html Msg
viewSummary s =
    div [ class "season" ] [ a [ Nav.href (Nav.Season s.id) ] [ text s.name ] ]


viewSummaryList : String -> List SeasonSummary -> List (Html Msg)
viewSummaryList title list =
    h2 [] [ text title ] :: List.map viewSummary list


viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
    input [ type_ t, placeholder p, value v, onInput toMsg ] []


view : Model -> Html Msg
view model =
    let
        openSeasons =
            List.filter (\s -> s.status == Open) model.summaries

        closedSeasons =
            List.filter (\s -> s.status == Closed) model.summaries

        form =
            [ div [ class "form-button" ] [ button [ class "cancel", onClick ToggleForm ] [ text "Create new Season" ] ]
            , div
                [ class "form modal inverted"
                , if model.formVisible == False then
                    class "hidden"

                  else
                    class "form"
                ]
                [ div []
                    [ label [] [ text "Season Name" ]
                    , viewInput "text" "Name" model.name Name
                    , label [] [ text "Active?" ]
                    , input [ type_ "checkbox", checked model.status, onCheck Status ] []
                    , div [ class "form-buttons" ]
                        [ button [ class "cancel", onClick CancelForm ] [ text "Cancel" ]
                        , button [ onClick SubmitForm ] [ text "Submit" ]
                        ]
                    ]
                ]
            ]
    in
    div [ class "seasons" ] <|
        [ h1 [ class "profile" ] [ text "Seasons" ] ]
            ++ viewSummaryList "Open Seasons" openSeasons
            ++ viewSummaryList "Closed Seasons" closedSeasons
            ++ form
