import {
    Elm
} from './Main.elm'
import './main.css'
import firebase from "firebase"
import gun from "gun"


const app = Elm.Main.init({
    node: document.getElementById('main')
});



// function load()
// {
//
//
//     const firebaseConfig = require("./secret/firebase_config.json")
//       // Initialize Firebase
//       firebase.initializeApp(firebaseConfig);
//
//       const database = firebase.database().ref();
//       database.on("value", function(snapshot){
//         // console.log(snapshot.val());
//         const json = snapshot.val()
//         console.log("json: ", json)
//         app.ports.loadFirebaseState.send(json)
//       });
//       // listen(database);
//       console.log("aaaaa");
// }
// load();

function loadGun() {
    var gun = Gun(['http://localhost:8765/gun']);
    // const json = gun.get('tododataa').get("tasklist");
    // const json2 = JSON.stringify(json);
    // var j2 = JSON.parse(json);
    var tododata = {}
    gun.get('tododataa').once(function(todo, id) {
        // console.log(todo.newTaskEstimate);
        // console.log(todo.newTaskName);
        // console.log(todo.activeTask);

        tododata["newTaskName"] = todo.newTaskName
        tododata["newTaskEstimate"] = todo.newTaskEstimate
        tododata["activeTask"] = todo.activeTask

        // console.log(todo.tasklist);
        // todo.tasklist.map().on(function (task, id) {
        //    console.log(task.name)
        //    console.log(task.id)
        //    console.log(task.estimate)
        //    console.log(task.actual)
        // })

        ////////
        var tlist = {}
        gun.get('tododataa').get('tasklist').map().on(function(task, id) {

            // console.log(task)
            // console.log("task id ", id)
            var data = {
                "id": task.id,
                "actual": task.actual,
                "estimate": task.estimate,
                "name": task.name,
                "status": task.status
            }
            // tlist[id] = data
            tlist[id] = data
            tododata["tasklist"] = tlist
            const json = JSON.stringify(tododata);

            console.log("json: ", json);

            // console.log("data = ", tlist);
            // if (task) {
            //
            // } else {
            //
            // }
        })
        //////
        // console.log("Todo data =",tododata)
    })


    // const json = JSON.parse(tododata);
    // const json = tododata;
    // var data =
    // {
    //   "newTaskName":"",
    //   "newTaskEstimate":30,
    //   "activeTask":0,
    //   "tasklist":
    //     {"Lwe":
    //       {
    //         "id": 1,
    //         "actual":0,
    //         "estimate":30,
    //         "name":"aa",
    //         "status":"Pause"
    //       },
    //       "Lwf":
    //       {
    //         "id": 2,
    //         "actual":0,
    //         "estimate":30,
    //         "name":"bb",
    //         "status":"Pause"
    //       },
    //       "Lwg":
    //       {
    //         "id": 3,
    //         "actual":0,
    //         "estimate":30,
    //         "name":"cc",
    //         "status":"Pause"
    //       },
    //       "Lwh":
    //       {
    //         "id": 4,
    //         "actual":0,
    //         "estimate":30,
    //         "name":"dd",
    //         "status":"Pause"
    //       },
    //       "Lwi":
    //       {
    //         "id": 5,
    //         "actual":0,
    //         "estimate":30,
    //         "name":"ee",
    //         "status":"Pause"
    //       }
    //     }
    //   }


    // console.log("json: ", j2);
    app.ports.loadFirebaseState.send(json);
}

loadGun();
app.ports.sendNewTaskState.subscribe(str => {
    writeNewTask(str);
})

function writeNewTask(task) {
    // A Task entry.
    var taskData = JSON.parse(task)
    var newKey = taskData.id
    // Write the new task's data in the task list
    var updates = {};
    updates['/tasklist/'] = taskData;
    return firebase.database().ref().child('tasklist').push(taskData);
}
