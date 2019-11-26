module Main exposing (..)

import Browser
import Browser.Navigation
import Html exposing (Html, button)
import Html.Attributes as HA
import Html.Events exposing (onClick, onInput)
import List
import List.Extra
import String exposing (fromInt)



---- MODEL ----
-- status
-- start
-- task
-- estimate
-- actual
-- task, estimate
-- type alias Suspend =
--     status Bool


type TaskStatus
    = Start
    | Pause
    | Complete


type alias MyTask =
    { id : Int
    , status : TaskStatus
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



-- getidList : MyTask -> List Int
-- getidList mytask =
--     let
--         id =
--             mytask.id
--     in
--     id :: idList
-- getMaxid : List MyTask -> List Int -> List Int
-- getMaxid mytask =
--     let
--         emptylist =
--             []
--
--         idList =
--             List.map getidList mytask
--     in
--     List.maximum idList
-- getMaxid : (a -> comparable) -> List a -> Maybe a
-- getMaxid : (a -> comparable) -> Int
-- getMaxid id =
--     let
--         f x acc =
--             case acc of
--                 Nothing ->
--                     Just x
--
--                 Just y ->
--                     if id x > id y then
--                         Just x.id
--
--                     else
--                         Just y.id
--     in
--     List.foldr f Nothing
-- getMaxid : (a -> comparable) -> List a -> Maybe a
-- getMaxid field =
--     List.head << List.reverse << List.sortBy field


updateStatus index item =
    if index == item.id then
        { item
            | status =
                case item.status of
                    Pause ->
                        Start

                    Start ->
                        Pause

                    Complete ->
                        Start
        }

    else
        item



-- updateStatus tasklst =
--     task.id
-- updateStaus model id =
--     if model.id == id then
--         { model
--             | status =
--                 case model.mytask.status of
--                     Pause ->
--                         Start
--
--                     Start ->
--                         Pause
--
--                     Complete ->
--                         Start
--         }
--
--     else
--         model
-- getTask model id =
--     if model.id == id then
--         { task = model.task }
--
--     else
--         model


init : ( Model, Cmd Msg )
init =
    ( { mytask = [ { id = 1, status = Pause, name = "T1", estimate = 30, actual = 0 } ]
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
    | TaskToggle Int


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
                newid =
                    List.Extra.maximumBy .id model.mytask

                nextid =
                    case newid of
                        Just a ->
                            a.id

                        Nothing ->
                            1

                -- getMaxid .id model.mytask
                newModel =
                    { model
                        | mytask = model.mytask ++ [ { id = nextid + 1, status = Pause, name = model.task, estimate = model.estimate, actual = 0 } ]
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

        TaskToggle id ->
            let
                status =
                    -- updateStaus model id
                    List.map (updateStatus id)
                        model.mytask

                newModel =
                    { model
                        | mytask =
                            status
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
        , Html.td []
            [ Html.button [ onClick (TaskToggle mytask.id) ]
                [ Html.text
                    (if not (mytask.status == Start) then
                        "Start"

                     else
                        "Pause"
                    )
                ]
            ]
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
