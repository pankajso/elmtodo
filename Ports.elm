port module Ports exposing (..)

import Json.Decode as Decode


port loadFirebaseState : (Decode.Value -> msg) -> Sub msg


port sendNewTaskState : String -> Cmd msg
