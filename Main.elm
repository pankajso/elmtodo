module Main exposing (..)

import Browser
import Html exposing (Html, button)
import Html.Attributes as HA
import Html.Events exposing (onClick)
import List



---- MODEL ----


type alias Model =
    {}


init : ( Model, Cmd Msg )
init =
    ( {}
    , Cmd.none
    )


type Msg
    = None


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    let
        noChange =
            ( model, Cmd.none )
    in
    case message of
        None ->
            noChange



---- VIEW ----


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.text "Hello"
        ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { init = always init
        , update = update
        , subscriptions = always Sub.none
        , view = view
        }
