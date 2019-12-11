module Main exposing (..)

import Browser
import Browser.Navigation
import Html exposing (Html, button)
import Html.Attributes as HA
import Html.Events exposing (onClick, onInput)
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)
import List.Extra
import Time



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


type Id
    = TaskId Int


toId : Int -> Id
toId x =
    TaskId x


idToInt : Id -> Int
idToInt (TaskId x) =
    x


type alias MyTask =
    { id : Id
    , status : TaskStatus
    , name : String
    , estimate : Int
    , actual : Int
    }


type alias Model =
    { mytasks : List MyTask
    , activeTask : Maybe Id
    , newTaskName : String
    , newTaskEstimate : Int
    }



--
-- Update name
--   activeTask == Nothing
--     initMyTask ++ mytasks
--   activeTask == Just id
--     mytasks.id == id (\task -> {task|name = name})
--
-- Add name estimate
--   initMyTask ++ mytasks
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


getactiveTaskid : Model -> Id
getactiveTaskid model =
    model.activeTask
        |> Maybe.withDefault (toId 0)



-- let
--     id =
--         case model.activeTask of
--             Maybe.Just a ->
--                 a
--
--             Nothing ->
--                 0
-- in
-- id


toggleTask : TaskStatus -> TaskStatus
toggleTask status =
    case status of
        Pause ->
            Start

        Start ->
            Pause

        Complete ->
            Start


updateStatus :
    a
    -> a
    -> { b | id : a, status : TaskStatus }
    -> { b | id : a, status : TaskStatus }
updateStatus index activetaskId item =
    if index == item.id then
        { item
            | status =
                toggleTask item.status
        }

    else if item.id == activetaskId then
        { item
            | status =
                toggleTask Start
        }

    else
        item



-- Tasks
-- for each task if task id is passed id then toggle task status
-- if active task id is not task id then set active task to this task id
-- if active task id is task id then set active task to none
--
-- NameChange
-- let
--     oldActive =
--         model.activeTask
--
--     newActive =
--         case oldActive of
--             Just a ->
--                 { a | name = name }
--
--             Nothing ->
--                 let
--                     nextid =
--                         getMaxid model
--                 in
--                 { id = nextid + 1, status = Pause, name = name, estimate = 30, actual = 0 }
--
--     newModel =
--         { model | activeTask = Just newActive.id }
-- in
-- ( newModel, Cmd.none )
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
-- getActiveTaskName : Model -> Maybe.Maybe a
-- getActiveTaskName : Model -> Maybe.Maybe Id


getNextid : Model -> Id
getNextid model =
    List.map (\task -> idToInt task.id) model.mytasks
        |> List.maximum
        |> Maybe.withDefault 0
        |> (+) 1
        |> toId


init : ( Model, Cmd Msg )
init =
    let
        newTask =
            { id = toId 1, status = Pause, name = "T1", estimate = 30, actual = 0 }

        newModel =
            { mytasks = newTask :: []
            , newTaskName = ""
            , newTaskEstimate = 30
            , activeTask = Just newTask.id
            }
    in
    ( newModel
    , Cmd.none
    )


type Msg
    = None
    | AddTask
    | OnName String
    | OnEstimate String
    | TaskToggle Int
    | UpdateTask Time.Posix


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
                nextid =
                    -- newid =
                    getNextid model

                -- List.Extra.maximumBy .id model.mytask
                --     |> Maybe.map (\task -> task.id)
                --     |> Maybe.withDefault 1
                -- nextid =
                --     case newid of
                --         Just a ->
                --             a.id
                --
                --         Nothing ->
                --             1
                -- getMaxid .id model.mytask
                newModel =
                    { model
                        | mytasks = model.mytasks ++ [ { id = nextid, status = Pause, name = model.newTaskName, estimate = model.newTaskEstimate, actual = 0 } ]
                        , newTaskName = ""
                        , newTaskEstimate = 30
                        , activeTask = model.activeTask
                    }
            in
            ( newModel, Cmd.none )

        OnName name ->
            let
                newModel =
                    { model
                        | newTaskName = name
                    }
            in
            ( newModel, Cmd.none )

        OnEstimate newEstimate ->
            let
                newModel =
                    { model | newTaskEstimate = String.toInt newEstimate |> Maybe.withDefault 0 }
            in
            ( newModel, Cmd.none )

        TaskToggle id ->
            let
                status =
                    -- updateStaus model id
                    List.map (updateStatus (toId id) (getactiveTaskid model))
                        model.mytasks

                -- status =
                --     List.map (setActiveTaskid id)
                --         model.mytasks
                newModel =
                    { model
                        | mytasks =
                            status
                        , activeTask = Just (toId id)
                    }
            in
            ( newModel, Cmd.none )

        UpdateTask time ->
            let
                increaseActual t =
                    { t
                        | actual =
                            if t.status == Start then
                                t.actual + 1

                            else
                                t.actual
                    }
            in
            ( { model | mytasks = List.map increaseActual model.mytasks }, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.div []
            [ Html.table []
                ([ Html.tr []
                    [ Html.th [] [ Html.text "Number" ]
                    , Html.th [] [ Html.text "Task" ]
                    , Html.th [] [ Html.text "Estimate" ]
                    , Html.th [] [ Html.text "Actual" ]
                    ]
                 ]
                    ++ myTasksView model.mytasks
                )
            ]
        , Html.div []
            [ Html.input
                [ HA.placeholder "Enter taks here"
                , HA.value model.newTaskName
                , onInput OnName
                ]
                []
            , Html.input
                [ HA.value (String.fromInt model.newTaskEstimate)
                , onInput OnEstimate
                ]
                []
            ]
        , Html.div []
            [ Html.text model.newTaskName
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
        [ Html.td [] [ Html.text (String.fromInt (idToInt mytask.id)) ]
        , Html.td [] [ Html.text mytask.name ]
        , Html.td []
            [ Html.button [ onClick (TaskToggle (idToInt mytask.id)) ]
                [ Html.text
                    (if not (mytask.status == Start) then
                        "Start"

                     else
                        "Pause"
                    )
                ]
            ]
        , Html.td [] [ Html.text (String.fromInt mytask.estimate) ]
        , Html.td [] [ Html.text (String.fromInt mytask.actual) ]
        ]


myTasksView : List MyTask -> List (Html Msg)
myTasksView mytasks =
    List.map taskView mytasks


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 600 UpdateTask



-- Sub.none


main : Program () Model Msg
main =
    Browser.element
        { init = always init
        , update = update

        -- , subscriptions = always Sub.none
        , subscriptions = subscriptions
        , view = view
        }
