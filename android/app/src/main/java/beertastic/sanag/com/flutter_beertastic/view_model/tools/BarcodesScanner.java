package beertastic.sanag.com.flutter_beertastic.view_model.tools;

import android.media.Image;
import android.util.SparseIntArray;
import android.view.Surface;

import androidx.camera.core.ExperimentalGetImage;
import androidx.camera.core.ImageProxy;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.firebase.ml.vision.common.FirebaseVisionImageMetadata;
import com.google.mlkit.vision.barcode.Barcode;
import com.google.mlkit.vision.barcode.BarcodeScanner;
import com.google.mlkit.vision.barcode.BarcodeScannerOptions;
import com.google.mlkit.vision.barcode.BarcodeScanning;
import com.google.mlkit.vision.common.InputImage;

import java.util.List;

public class BarcodesScanner {

    private static final String TAG = "Barcode scanner";
    private static BarcodesScanner instance;

    private static final SparseIntArray ORIENTATIONS = new SparseIntArray();
    static {
        ORIENTATIONS.append(Surface.ROTATION_0, 0);
        ORIENTATIONS.append(Surface.ROTATION_90, 90);
        ORIENTATIONS.append(Surface.ROTATION_180, 180);
        ORIENTATIONS.append(Surface.ROTATION_270, 270);
    }

    private static final SparseIntArray DEGREES_TO_FIREBASE_ORIENTATION = new SparseIntArray();
    static {
        DEGREES_TO_FIREBASE_ORIENTATION.append(0, FirebaseVisionImageMetadata.ROTATION_0);
        DEGREES_TO_FIREBASE_ORIENTATION.append(90, FirebaseVisionImageMetadata.ROTATION_270);
        DEGREES_TO_FIREBASE_ORIENTATION.append(180, FirebaseVisionImageMetadata.ROTATION_180);
        DEGREES_TO_FIREBASE_ORIENTATION.append(270, FirebaseVisionImageMetadata.ROTATION_90);
    }

    private BarcodesScanner(){
        BarcodeScannerOptions options =
                new BarcodeScannerOptions.Builder()
                        .setBarcodeFormats(
                                Barcode.FORMAT_QR_CODE,
                                Barcode.FORMAT_EAN_8,
                                Barcode.FORMAT_EAN_13)
                        .build();

    }

    /**
     * @return the unique instance of barcode scanner
     */
    public static BarcodesScanner getInstance() {
        if(instance==null) instance=new BarcodesScanner();
        return instance;
    }

    @ExperimentalGetImage
    public void scanYUVImage(ImageProxy mediaImage, OnCompleteListener<List<Barcode>> listener){
        if(mediaImage.getImage()!=null){
            InputImage image = InputImage.fromMediaImage(mediaImage.getImage(),mediaImage.getImageInfo().getRotationDegrees());
            BarcodeScanner scanner = BarcodeScanning.getClient();
            scanner.process(image).addOnCompleteListener(listener).addOnCompleteListener((e)->mediaImage.close());
        }
    }
}
