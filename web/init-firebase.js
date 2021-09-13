if (typeof firebase === 'undefined') throw new Error('hosting/init-error: Firebase SDK not detected. You must include it before "init-firebase.js".');

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
var firebaseConfig = {
  apiKey: "AIzaSyDKl1e5UEWKl1j4CrCKENTHhKO8-XWCHfg",
  authDomain: "notesproject-ab12c.firebaseapp.com",
  databaseURL: "https://notesproject-ab12c.firebaseio.com",
  projectId: "notesproject-ab12c",
  storageBucket: "notesproject-ab12c.appspot.com",
  messagingSenderId: "787552385461",
  appId: "1:787552385461:web:900c05d7826287726501fc",
  // measurementId: "G-PZZ7F85GVT"
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);
// firebase.analytics();
firebase.firestore();
