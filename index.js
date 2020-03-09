import {
  Elm
} from './Main.elm'
import './main.css'
import gun from "gun"


const app = Elm.Main.init({
  node: document.getElementById('main')
});

let gundb = Gun(['http://localhost:8765/gun']);


function loadGun() {

  var tododata = {}
  gundb.get('tododatag').on(function(todo, id) {

    tododata["newTaskName"] = todo.newTaskName
    tododata["newTaskEstimate"] = todo.newTaskEstimate
    tododata["activeTask"] = todo.activeTask

    var tlist = {}
    gundb.get('tododatag').get('tasklist').map().on(function(task, id) {

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

app.ports.updateTaskState.subscribe(str => {
  updateTaskState(str);
})

function writeNewTask(task) {
  // A Task entry.
  var taskData = JSON.parse(task)
  // var newKey = taskData.id
  // Write the new task's data in the task list
  var tlist = {}
  // var uniqid = Date.now();
  tlist[taskData.id] = taskData
  // var updates = {};
  // updates['/tasklist/'] = taskData;
  console.log(taskData);
  var tl = gundb.get('tododatag').get('tasklist');
  tl.put(tlist);
}



function updateTaskState(newtask_) {
  // A Task entry.
  var tlist = {}

  const newtask = JSON.parse(newtask_)
  console.log("newtask_ = ", newtask)

  gundb.get('tododatag').get('tasklist').map().once((task, id) => {
    if (task.id == newtask.id){
      var data = {
        "id": task.id,
        "actual": newtask.actual,
        "estimate": newtask.estimate,
        "name": task.name,
        "status": newtask.status
      }
      tlist[id] = data
      var tl = gundb.get('tododatag').get('tasklist');
      tl.put(tlist);
      let tododata = {}
      tododata = gundb.get('tododatag').put({ activeTask: task.id })
      // tododata["activeTask"] = task.id
    }
  })
}
