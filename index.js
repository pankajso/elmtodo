import { Elm } from './Main.elm'
import './main.css'
import firebase from "firebase"


const app = Elm.Main.init({
  node: document.getElementById('main')
});



function load()
{


    const firebaseConfig = require("./secret/firebase_config.json")
      // Initialize Firebase
      firebase.initializeApp(firebaseConfig);

      const database = firebase.database().ref();
      database.on("value", function(snapshot){
        // console.log(snapshot.val());
        const json = snapshot.val()
        console.log("json: ", json)
        app.ports.loadFirebaseState.send(json)
      });
      // listen(database);
      console.log("aaaaa");
}
load();


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
