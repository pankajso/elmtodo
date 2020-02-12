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
    var tododata = {}
    gun.get('tododatab').on(function(todo, id) {

        tododata["newTaskName"] = todo.newTaskName
        tododata["newTaskEstimate"] = todo.newTaskEstimate
        tododata["activeTask"] = todo.activeTask

        var tlist = {}
        gun.get('tododatab').get('tasklist').map().on(function(task, id) {

            var data = {
                "id": task.id,
                "actual": task.actual,
                "estimate": task.estimate,
                "name": task.name,
                "status": task.status
            }
            tlist[id] = data
            tododata["tasklist"] = tlist
            app.ports.loadFirebaseState.send(tododata);
        })
    })

}

loadGun();

app.ports.sendNewTaskState.subscribe(str => {
    writeNewTask(str);
})

function writeNewTask(task) {
    // A Task entry.
    var gun = Gun(['http://localhost:8765/gun']);
    var taskData = JSON.parse(task)
    var newKey = taskData.id
    // Write the new task's data in the task list
    var tlist = {}
    var uniqid = Date.now();
    tlist[uniqid] = taskData
    // var updates = {};
    // updates['/tasklist/'] = taskData;
    console.log(taskData);
    var tl = gun.get('tododatab').get('tasklist');
    tl.put(tlist);
    // return firebase.database().ref().child('tasklist').push(taskData);
}
