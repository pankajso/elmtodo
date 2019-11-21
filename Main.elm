module Main exposing (..)

import Browser
import Html exposing (Html, button)
import Html.Attributes as HA
import Html.Events exposing (onClick, onInput)
import List
import String exposing (fromInt)



---- MODEL ----
-- status
-- start
-- task
-- estimate
-- actual
-- task, estimate


type alias MyTask =
    { id : Int
    , name : String
    , estimate : Int
    , actual : Int
    }


type alias MyTaskList =
    List MyTask


type alias Model =
    { mytask : MyTaskList
    , task : String
    , estimate : Int
    }


init : ( Model, Cmd Msg )
init =
    ( { mytask = [ { id = 1, name = "T1", estimate = 30, actual = 0 } ]
      , task = ""
      , estimate = 30
      }
    , Cmd.none
    )


type Msg
    = None
    | AddTask
    | ChangeTask String
    | ChangeEstimate String


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    let
        noChange =
            ( model, Cmd.none )
    in
    case message of
        None ->
            noChange

        -- [id = 2, name = model.task, estimate = model.estimate, actual = 0]
        AddTask ->
            let
                -- taks =
                newModel =
                    { model
                        | mytask = model.mytask ++ [ { id = 2, name = model.task, estimate = model.estimate, actual = 0 } ]
                        , task = ""
                        , estimate = 30
                    }
            in
            ( newModel, Cmd.none )

        ChangeTask newTask ->
            let
                newModel =
                    { model
                        | task = newTask
                    }
            in
            ( newModel, Cmd.none )

        ChangeEstimate newEstimate ->
            let
                newModel =
                    { model
                        | estimate = Maybe.withDefault 0 (String.toInt newEstimate)
                    }
            in
            ( newModel, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.div []
            [ Html.table [] []
            , Html.th [] [ Html.text "Number" ]
            , Html.th [] [ Html.text "Task" ]
            , Html.th [] [ Html.text "Estimate" ]
            , myTasksView model.mytask
            ]
        , Html.div []
            [ Html.input
                [ HA.placeholder "Enter taks here"
                , HA.value model.task
                , onInput ChangeTask
                ]
                []
            , Html.input
                [ HA.value (String.fromInt model.estimate)
                , onInput ChangeEstimate
                ]
                []
            ]
        , Html.div []
            [ Html.text model.task
            ]
        , Html.div []
            [ button [ onClick AddTask ] [ Html.text "Add Task" ]
            ]
        ]



-- myTaskView lst ->
--   ""
---- PROGRAM ----


taskView : MyTask -> Html Msg
taskView mytask =
    Html.tr []
        [ Html.td [] [ Html.text (String.fromInt mytask.id) ]
        , Html.td [] [ Html.text mytask.name ]
        , Html.td [] [ Html.text (String.fromInt mytask.estimate) ]
        ]


myTasksView : List MyTask -> Html Msg
myTasksView mytasks =
    Html.div []
        [ Html.div [] (List.map taskView mytasks)
        ]


main : Program () Model Msg
main =
    Browser.element
        { init = always init
        , update = update
        , subscriptions = always Sub.none
        , view = view
        }
