module Main exposing (..)

import Browser
import Browser.Navigation
import Html exposing (Html, button)
import Html.Attributes as HA
import Html.Events exposing (onClick, onInput)
import Json.Decode as Decode exposing (..)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode exposing (..)
import List.Extra
import Ports exposing (..)
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


type alias Error =
    { error : String
    , errorDescription : String
    }


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


getactiveTaskid : Model -> Id
getactiveTaskid model =
    model.activeTask
        |> Maybe.withDefault (toId 0)


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



-- loadFirebaseState : Model
-- loadFirebaseState =
--     let
--         newModel =
--             { mytasks = decodeTasks
--             , newTaskName = ""
--             , newTaskEstimate = 30
--             , activeTask = 1
--             }
--     in
--     newModel


encodeTasks : List MyTask -> Encode.Value
encodeTasks record =
    Encode.list encodeTask record


encodeTask : MyTask -> Encode.Value
encodeTask record =
    Encode.object
        [ ( "actual", Encode.int <| record.actual )
        , ( "estimate", Encode.int <| record.estimate )
        , ( "id", Encode.int (idToInt record.id) )
        , ( "name", Encode.string <| record.name )
        , ( "status", encodeStatus <| record.status )
        ]


decodeTasks : Decoder (List MyTask)
decodeTasks =
    Decode.list decodeTask


decodeTask : Decoder MyTask
decodeTask =
    Decode.succeed MyTask
        |> required "id" (Decode.map toId Decode.int)
        |> required "status" decodeStatus
        |> required "name" Decode.string
        |> required "estimate" Decode.int
        |> required "actual" Decode.int


encodeStatus : TaskStatus -> Encode.Value
encodeStatus v =
    case v of
        Start ->
            Encode.string "Start"

        Pause ->
            Encode.string "Pause"

        Complete ->
            Encode.string "Complete"


decodeStatus : Decoder TaskStatus
decodeStatus =
    Decode.string
        |> Decode.andThen
            (\string ->
                case string of
                    "Start" ->
                        Decode.succeed Start

                    "Pause" ->
                        Decode.succeed Pause

                    "Complete" ->
                        Decode.succeed Complete

                    _ ->
                        Decode.fail "Invalid Status"
            )



-- result : Result String MyTask
-- result =
--     Decode.decodeString
--         decodeTask
--         """
--           {"id" : "1", "name" : "T1", "status" : "Pause", "estimate": 30, "actual": 0}
--         """


type Msg
    = None
    | AddTask
    | OnName String
    | OnEstimate String
    | TaskToggle Int
    | UpdateTask Time.Posix
    | LoadFirebaseState (Result Decode.Error (List MyTask))


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
                    getNextid model

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
                            case t.status of
                                Start ->
                                    t.actual + 1

                                _ ->
                                    t.actual
                    }
            in
            ( { model | mytasks = List.map increaseActual model.mytasks }, Cmd.none )

        LoadFirebaseState list ->
            ( { model
                | mytasks =
                    case list of
                        Ok value ->
                            value

                        Err error ->
                            let
                                _ =
                                    Debug.log "GameStateChanged err" error
                            in
                            model.mytasks
              }
            , Cmd.none
            )



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
    Sub.batch
        [ Time.every 600 UpdateTask
        , loadFirebaseState (LoadFirebaseState << Decode.decodeValue decodeTasks)
        ]



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
