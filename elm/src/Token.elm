module Token exposing (Token(..), fromString, toString)


type Token
    = Token String


fromString : String -> Token
fromString str =
    Token str


toString : Token -> String
toString (Token str) =
    str
