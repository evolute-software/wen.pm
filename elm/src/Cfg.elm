module Cfg exposing (Path(..), url)

import Url.Builder exposing (crossOrigin)



--- Backend Config and Routing -----------------------------------------------
--- This is the Couterpart to the Nav module. Whereas Nav is concerned with
--- navigation in the SPA itself the Cfg module takes care of the infos
--- required to communicate with the backend


type Path
    = SETTINGS
    | USERS
    | PROFILES
    | SEASONS
    | SEASON String



-- Typed Enpoints for poor people


url : Path -> String
url path =
    case path of
        SETTINGS ->
            genUrl "settings"

        USERS ->
            genUrl "users"

        PROFILES ->
            genUrl "profiles"

        SEASONS ->
            genUrl "seasons"

        SEASON id ->
            genUrl2 "seasons" id


genUrl : String -> String
genUrl path =
    baseUrl [ path ] []


genUrl2 : String -> String -> String
genUrl2 p1 p2 =
    baseUrl [ p1, p2 ] []


baseUrl : List String -> List Url.Builder.QueryParameter -> String
baseUrl =
    protocol ++ "://" ++ host |> crossOrigin


protocol : String
protocol =
    "http"


host : String
host =
    "cianodyne.local:13342"
