module Settings exposing (Model, Msg(..), Settings, init, update, updateRoute, view)

import Browser.Navigation as BN exposing (Key, load)
import Cfg exposing (Path(..), url)
import Html exposing (Html, button, div, h1, h2, text)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode exposing (Decoder, Value, float, int, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Token exposing (Token(..))
import Url as U
import Url.Parser as UP
import Url.Parser.Query as UPQ


type alias Model =
    { status : Status
    , auth : Maybe String
    , default : Maybe String
    , token : Maybe Token
    , url : U.Url
    , key : Key
    }


loadingModel : U.Url -> Key -> Maybe Token -> Model
loadingModel url key token =
    Model LOADING Nothing Nothing token (Debug.log "initializing with url" url) key


createLoginUrl : String -> U.Url -> String
createLoginUrl auth redir =
    auth ++ (U.percentEncode <| U.toString redir)


ensureLoggedIn : Model -> Cmd Msg
ensureLoggedIn model =
    case ( model.token, model.auth ) of
        ( _, Nothing ) ->
            Debug.log "no auth URL yet: " model.token
                |> (\_ -> Cmd.none)

        ( Nothing, Just url ) ->
            createLoginUrl url model.url
                |> Debug.log "no token yet, logging in: "
                |> BN.load

        ( Just str, _ ) ->
            Debug.log "Token found: " str
                |> (\_ ->
                        updateRoute model (removeQuery model.url |> defaultPath model)
                            |> Tuple.second
                   )



-- Past we did not eliminate the token string from the url (\_ -> Cmd.none)


defaultPath : Model -> U.Url -> U.Url
defaultPath m u =
    case u.path of
        "/" ->
            case m.default of
                Just str ->
                    { u | path = str }

                Nothing ->
                    u

        _ ->
            u


removeQuery : U.Url -> U.Url
removeQuery u =
    { u | query = Nothing }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RouteRequest url ->
            updateRoute model url

        Loaded result ->
            case result of
                Ok settings ->
                    let
                        updates =
                            { model
                                | status = SUCCESS
                                , auth = Just settings.links.auth
                                , default = Just settings.links.default
                            }
                    in
                    ( updates
                    , ensureLoggedIn updates
                    )

                Err error ->
                    case error of
                        Http.BadStatus int ->
                            ( { model | status = FAIL int "bad status" }, Cmd.none )

                        Http.BadBody string ->
                            ( { model | status = FAIL 200 string }, Cmd.none )

                        _ ->
                            ( { model | status = FAIL 42 "Unhandled Loading Error" }, Cmd.none )

        Reload ->
            load model


updateRoute : Model -> U.Url -> ( Model, Cmd Msg )
updateRoute m u =
    ( { m | url = u }, U.toString u |> BN.pushUrl m.key )


init : U.Url -> Key -> ( Model, Cmd Msg )
init url key =
    let
        token =
            hasToken url

        model =
            loadingModel url key token
    in
    load model


hasToken : U.Url -> Maybe Token
hasToken url =
    -- Hack since the damn parser only looks at queries when I have guessed the paths....
    url.query
        |> Maybe.map (\s -> "http://localhost/?" ++ s)
        |> Maybe.andThen U.fromString
        |> Maybe.map (UPQ.string "token" |> UP.query |> UP.parse)
        |> Debug.log "Query?"
        -- The way I use the parser (and the already wrapped url) produces a tripple Maybed result
        |> Maybe.andThen identity
        |> Maybe.andThen identity
        |> Maybe.map Token


load : Model -> ( Model, Cmd Msg )
load model =
    ( { model | status = LOADING }
    , Http.get
        { url = url SETTINGS
        , expect = Http.expectJson Loaded settingsDecoder
        }
    )


type Msg
    = Loaded (Result Http.Error Settings)
    | Reload
    | RouteRequest U.Url


type Status
    = LOADING
    | SUCCESS
    | FAIL Int String


type alias Settings =
    { links : Links
    }


type alias Links =
    { auth : String
    , default : String
    }


settingsDecoder : Decoder Settings
settingsDecoder =
    Decode.succeed Settings
        |> required "links" linkDecoder


linkDecoder : Decoder Links
linkDecoder =
    Decode.succeed Links
        |> required "auth" string
        |> required "default" string



-- View


loadingClass : Model -> String
loadingClass settings =
    case settings.status of
        LOADING ->
            "loading"

        _ ->
            "hidden"


view : Model -> List (Html Msg)
view settings =
    [ div [ class "settings" ] <|
        [ h1 [] [ text "Saturn Focus App" ]
        , h2 [ class <| loadingClass settings ] [ text "Loading..." ]
        , h2 [] [ text "Auth:" ]
        , div [] [ text <| default settings.auth ]
        , h2 [] [ text "Default Route:" ]
        , div [] [ text <| default settings.default ]
        , h2 [] [ text "Token:" ]
        , div [] [ text <| default <| Maybe.map Token.toString settings.token ]
        , button [ onClick <| Reload ] [ text "Reload?" ]
        ]
    ]


default : Maybe String -> String
default =
    Maybe.withDefault "nothing"
