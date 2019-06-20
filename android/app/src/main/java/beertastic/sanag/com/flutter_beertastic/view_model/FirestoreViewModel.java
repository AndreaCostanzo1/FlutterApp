package beertastic.sanag.com.flutter_beertastic.view_model;

import android.util.Log;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.google.android.gms.tasks.Task;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FirebaseFirestore;

import java.util.Map;
import java.util.Optional;

public class FirestoreViewModel extends ViewModel {

    private MutableLiveData<Map<String,Object>> beer;

    public FirestoreViewModel() {
        beer = new MutableLiveData<>();
    }

    public LiveData<Map<String, Object>> getBeer() {
        return beer;
    }

    public void searchBeer(String collectionID,String beer) {
        FirebaseFirestore.getInstance().collectionGroup(collectionID).getFirestore()
                .collection(collectionID).document(beer).get()
                .addOnCompleteListener(this::sendResultBack);

    }

    private void sendResultBack(Task<DocumentSnapshot> snapshotTask) {
        if (snapshotTask.isSuccessful()) {
            Optional.ofNullable(snapshotTask.getResult()).ifPresent(beer-> this.beer.postValue(beer.getData()));
            if(snapshotTask.getResult()==null) Log.wtf("FIRESTORE CHANNEL", "NULL SNAPSHOT");
        } else {
            Log.wtf("FIRESTORE CHANNEL", "ERROR FROM FIRESTORE", snapshotTask.getException());
        }
    }
}
