import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_beertastic/model/beer.dart';

class UserReviewBloc {
  void createReview(Beer beer, String comment, double rate) async {
    //TODO clear stream
    FirebaseUser fUser = await FirebaseAuth.instance.currentUser();
    DocumentReference userRef =
        Firestore.instance.collection('users').document(fUser.uid);
    DocumentReference beerRef =
        Firestore.instance.collection('beers').document(beer.id);
    beerRef.collection('reviews').add({
      'user': userRef,
      'date': DateTime.now(),
      'rate': rate,
      'comment': comment ?? ''
    });
    Firestore.instance.runTransaction((transaction) {
      return transaction.get(beerRef).then((beerSnap) {
        Beer beer = Beer.fromSnapshot(beerSnap.data);
        Map<String, int> map = Map.from(beer.ratingsByRate
            .map((key, value) => MapEntry(key.toString(), value)));
        map.update(rate.toInt().toString(), (value) => value + 1);
        int newTotalRatings= beer.totalRatings+1;
        double averageRate=0;
        map.entries.forEach((entry) => averageRate+=int.parse(entry.key)*entry.value);
        averageRate=(averageRate/newTotalRatings*10).round()/10;
        transaction.update(beerRef, {'ratings_by_rate': map,'total_ratings':newTotalRatings,'rating':averageRate});
      }).catchError((e) => print(e.toString()));
    });
  }

  void dispose() {}
}
