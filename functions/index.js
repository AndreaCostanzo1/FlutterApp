const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();

exports.updateSearches= functions.https.onCall( async (data,context)=>{
    const reference = db.collection('beers').doc(data.beerId);
    console.log((data));
    try {
        await db.runTransaction(async(trans) => {
            const beerDoc= await reference.get();
            const newSearches= beerDoc.data().searches+1;
            trans.update(reference,{'searches':newSearches});
        })
    } catch (e) {
        console.log(e);
    }
});

exports.deleteUserUponDeleteAccount = functions.auth.user().onDelete(async (user) => {
    console.log(('Deleting user\'s '+user.uid+' data from database...'));
    try {
        console.log('Deleting user\'s '+user.uid+' reference from database...');
        const userRef =db.collection('users').doc(user.uid);
        await deleteAffinities(userRef,5);
        await deleteFavourites(userRef,5);
        await userRef.delete();
        console.log('User '+user.uid+' reference deleted successfully');
        await deleteUserReviews(user.uid,5);
        console.log('All User\'s '+user.uid+' data deleted successfully');
    } catch (e) {
        console.log(e);
    }
});


async function deleteUserReviews(uid,batchSize) {
    const beersRef =db.collection('beers');
    const query = beersRef.orderBy('id').limit(batchSize);
    console.log('Starting to delete beers reviews...');
    return new Promise((resolve, reject) => {
        deleteReviews(query, resolve,uid).catch(reject);
    });
}

async function deleteFavourites(userRef, batchSize) {
    const collectionRef = userRef.collection('favourites');
    const query = collectionRef.orderBy('date').limit(batchSize);

    console.log('Starting to delete users favourites...');
    return new Promise((resolve, reject) => {
        deleteQueryBatch(query, resolve).catch(reject);
    });
}
async function deleteAffinities(userRef, batchSize) {
    const collectionRef = userRef.collection('affinities');
    const query = collectionRef.orderBy('affinity').limit(batchSize);

    console.log('Starting to delete users affinities...');
    return new Promise((resolve, reject) => {
        deleteQueryBatch(query, resolve).catch(reject);
    });
}

async function deleteQueryBatch(query, resolve) {
    const snapshot = await query.get();

    const batchSize = snapshot.size;
    if (batchSize === 0) {
        // When there are no documents left, we are done
        console.log('Documents deleted successfully!');
        resolve();
        return;
    }

    // Delete documents in a batch
    const batch = db.batch();
    snapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
    });
    await batch.commit();

    // Recurse on the next process tick, to avoid
    // exploding the stack.
    process.nextTick(() => {
        deleteQueryBatch(query, resolve);
    });
}

async function deleteReviews(query, resolve,uid,lastDocument =null) {
    let snapshot;
    if(lastDocument===null){
        snapshot = await query.get();
    }else {
        snapshot = await query.startAfter(lastDocument).get();
    }

    const batchSize = snapshot.size;
    if (batchSize === 0) {
        // When there are no documents left, we are done
        console.log('Reviews deleted successfully');
        resolve();
        return;
    }

    const lastDocRetrieved = snapshot.docs[snapshot.docs.length-1];

    snapshot.docs.forEach(async (beerDoc) => {
        const beerRef= beerDoc.ref;
        const reviewDoc = await beerRef.collection('reviews').doc(uid).get();
        console.log('Beer '+beerDoc.data().name+'->'+reviewDoc.exists+'/'+uid);
        if(reviewDoc.exists){
            const rate = reviewDoc.data().rate;
            console.log('Updating beer '+beerDoc.id+' ratings...');
            await db.runTransaction(async(trans) => {
                const beerDoc= await beerRef.get();
                let ratings_by_rate =  beerDoc.data().ratings_by_rate;
                ratings_by_rate[rate.toString()]=ratings_by_rate[rate.toString()] - 1;
                const newTotalRatings = beerDoc.data().total_ratings-1;
                let newRating=0;
                if(newTotalRatings!==0){
                    let weightedRates = 0;
                    for (let rating in ratings_by_rate){
                        weightedRates=weightedRates+parseInt(rating)*ratings_by_rate[rating];
                    }
                    newRating =Math.round( weightedRates/newTotalRatings*10)/10;
                }
                trans.update(beerRef,{'ratings_by_rate':ratings_by_rate,'total_ratings':newTotalRatings,'rating':newRating});
            });
            console.log('Updated beer '+beerDoc.id+' ratings');
            reviewDoc.ref.delete();
            console.log('Deleting review '+ reviewDoc.id+' from beer '+ beerDoc.id);
        }
    });

    // Recurse on the next process tick, to avoid
    // exploding the stack.
    process.nextTick(() => {
        deleteReviews(query, resolve,uid,lastDocRetrieved);
    });
}
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
