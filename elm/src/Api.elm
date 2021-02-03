module Api exposing (Params, delete, get, post, put)

import Http
import Json.Decode as D
import Token exposing (Token)


type Status a
    = NotInitialized
    | Loading
    | Loaded a
    | Error String
    | Unauthorized


type MyError
    = MyError Int String
    | ElmError Http.Error


type Verb
    = GET
    | POST
    | PUT
    | DELETE


verbToString : Verb -> String
verbToString verb =
    case verb of
        GET ->
            "GET"

        POST ->
            "POST"

        PUT ->
            "PUT"

        DELETE ->
            "DELETE"


type alias Request msg =
    { method : String
    , headers : List Http.Header
    , url : String
    , body : Http.Body
    , expect : Http.Expect msg
    , timeout : Maybe Float
    , tracker : Maybe String
    }


type alias Params =
    { url : String
    , body : Http.Body
    , token : Token
    }


req : Verb -> Params -> (Result Http.Error a -> msg) -> D.Decoder a -> Request msg
req verb params resulter decoder =
    { method = verbToString verb
    , headers = authHeader params.token
    , url = params.url
    , body = params.body
    , expect = Http.expectJson resulter decoder
    , timeout = Just 42000
    , tracker = Nothing
    }


authHeader : Token -> List Http.Header
authHeader token =
    [ Http.header "Authorization" ("Bearer " ++ Token.toString token) ]


getFromStatus : Status a -> Maybe a
getFromStatus status =
    case status of
        Loaded a ->
            Just a

        otherwise ->
            Nothing


get : Params -> (Result Http.Error a -> msg) -> D.Decoder a -> Cmd msg
get params msg decoder =
    req GET params msg decoder |> Http.request


put : Params -> (Result Http.Error a -> msg) -> D.Decoder a -> Cmd msg
put params msg decoder =
    req PUT params msg decoder |> Http.request


post : Params -> (Result Http.Error a -> msg) -> D.Decoder a -> Cmd msg
post params msg decoder =
    req POST params msg decoder |> Http.request


delete : Params -> (Result Http.Error a -> msg) -> D.Decoder a -> Cmd msg
delete params msg decoder =
    req DELETE params msg decoder |> Http.request



-- ToDo: Let's see if we need these ------------------------------------------


expectResponse : (Result MyError a -> msg) -> D.Decoder a -> Http.Expect msg
expectResponse toMsg decoder =
    Http.expectStringResponse toMsg <|
        \response ->
            case response of
                Http.BadUrl_ url ->
                    Err (MyError 404 ("Bad Url." ++ url))

                Http.Timeout_ ->
                    Err (MyError 999 "The Server timed out...")

                Http.NetworkError_ ->
                    Err (MyError 999 "NetworkError")

                Http.BadStatus_ metadata body ->
                    Err (MyError metadata.statusCode (metadata.statusText ++ "\n" ++ body))

                Http.GoodStatus_ metadata body ->
                    case D.decodeString decoder body of
                        Ok value ->
                            Ok value

                        Err err ->
                            Err (MyError 998 (D.errorToString err))


expectResponseString : (Result MyError String -> msg) -> Http.Expect msg
expectResponseString toMsg =
    Http.expectStringResponse toMsg <|
        \response ->
            case response of
                Http.BadUrl_ url ->
                    Err (MyError 404 ("Bad Url." ++ url))

                Http.Timeout_ ->
                    Err (MyError 999 "The Server timed out...")

                Http.NetworkError_ ->
                    Err (MyError 999 "NetworkError")

                Http.BadStatus_ metadata body ->
                    Err (MyError metadata.statusCode (metadata.statusText ++ "\n" ++ body))

                Http.GoodStatus_ metadata body ->
                    Ok body


httpErrorToString : Http.Error -> String
httpErrorToString err =
    case err of
        Http.BadUrl st ->
            "BadUrl : " ++ st

        Http.Timeout ->
            "Timeout"

        Http.NetworkError ->
            "NetworkError"

        Http.BadStatus int ->
            case int of
                401 ->
                    "Unauthorized, please refresh the page to login or contact an admin to obtain the permission to perform this action"

                500 ->
                    "Bad Status! The server failed to process this request and responded with following Error : "

                _ ->
                    "Bad status! The server responded with a status code : " ++ String.fromInt int

        Http.BadBody s ->
            "BadBody : " ++ s


apiErrorToString : MyError -> String
apiErrorToString err =
    case err of
        MyError int st ->
            "Error status Code = " ++ String.fromInt int ++ "\nInfo = " ++ st ++ "\n"

        ElmError er ->
            httpErrorToString er
