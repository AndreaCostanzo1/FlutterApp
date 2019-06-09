package beertastic.sanag.com.flutter_beertastic.view_model;

import android.util.Log;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.google.android.gms.tasks.Task;
import com.google.firebase.ml.vision.barcode.FirebaseVisionBarcode;

import java.util.List;
import java.util.Optional;

public class ScannerViewModel extends ViewModel {
    private MutableLiveData<String> qrData;

    public ScannerViewModel(){
        qrData=new MutableLiveData<>();
    }

    public LiveData<String> getQrData() {
        return qrData;
    }

    public void handleScanResult(Task<List<FirebaseVisionBarcode>> listener) {
        if (listener.isSuccessful()) {
            Optional.ofNullable(listener.getResult())
                    .ifPresent(result -> {
                                if (result.size() > 0) qrData.postValue(result.get(0).getRawValue());
                            }
                    );
        }
    }
}
