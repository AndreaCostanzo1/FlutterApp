const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();

exports.updateSearches= functions.https.onCall( async (data,context)=>{
    var reference = db.collection('beers').doc(data.beerId);
    console.log((data));
    try {
        await db.runTransaction(async(trans) => {
            var beerDoc= await reference.get();
            var newSearches= beerDoc.data().searches+1;
            trans.update(reference,{'searches':newSearches});
        })
    } catch (e) {
        console.log(e);
    }
});
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
