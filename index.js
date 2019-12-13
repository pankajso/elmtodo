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

      const database = firebase.database().ref('tasklist/');
      database.on("value", function(snapshot){
        // console.log(snapshot.val());
        const json = snapshot.val()
        console.log("json: ", json)
        app.ports.loadFirebaseState.send(json)
      });
      console.log("aaaaa");
}
load();
