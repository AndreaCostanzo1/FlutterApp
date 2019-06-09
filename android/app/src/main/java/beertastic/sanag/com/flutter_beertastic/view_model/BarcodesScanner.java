package beertastic.sanag.com.flutter_beertastic.view_model;

import android.graphics.Bitmap;
import android.util.Log;
import android.util.SparseIntArray;
import android.view.Surface;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.firebase.ml.vision.FirebaseVision;
import com.google.firebase.ml.vision.barcode.FirebaseVisionBarcode;
import com.google.firebase.ml.vision.barcode.FirebaseVisionBarcodeDetector;
import com.google.firebase.ml.vision.barcode.FirebaseVisionBarcodeDetectorOptions;
import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import com.google.firebase.ml.vision.common.FirebaseVisionImageMetadata;

import java.nio.ByteBuffer;
import java.util.List;

public class BarcodesScanner {

    private static final String TAG = "Barcode scanner";
    private static BarcodesScanner instance;
    private FirebaseVisionBarcodeDetector detector;

    private static final SparseIntArray ORIENTATIONS = new SparseIntArray();
    static {
        ORIENTATIONS.append(Surface.ROTATION_0, FirebaseVisionImageMetadata.ROTATION_0);
        ORIENTATIONS.append(Surface.ROTATION_90, FirebaseVisionImageMetadata.ROTATION_270);
        ORIENTATIONS.append(Surface.ROTATION_180, FirebaseVisionImageMetadata.ROTATION_180);
        ORIENTATIONS.append(Surface.ROTATION_270, FirebaseVisionImageMetadata.ROTATION_90);
    }

    private BarcodesScanner(){
        detector=getDetector();
    }

    /**
     * @return the unique instance of barcode scanner
     */
    public static BarcodesScanner getInstance() {
        if(instance==null) instance=new BarcodesScanner();
        return instance;
    }

    /**
     * @return the barcode detector
     */
    private FirebaseVisionBarcodeDetector getDetector() {
        Log.d(TAG,"Getting detector");
        FirebaseVisionBarcodeDetectorOptions options = new FirebaseVisionBarcodeDetectorOptions.Builder()
                .setBarcodeFormats(
                        //QR CODE
                        FirebaseVisionBarcode.FORMAT_QR_CODE,
                        //EUROPEAN BARCODE
                        FirebaseVisionBarcode.FORMAT_EAN_8,
                        FirebaseVisionBarcode.FORMAT_EAN_13)
                .build();
        return FirebaseVision.getInstance().getVisionBarcodeDetector(options);
    }

    /**
     * This method scans an image and search for barcode
     */
    public void scanOfBitmapImage(@NonNull Bitmap image, OnCompleteListener<List<FirebaseVisionBarcode>> listener){
        Log.d(TAG,"Barcode detect request received");
        //scan the given image
        detector.detectInImage(FirebaseVisionImage.fromBitmap(image))
                //add a listener to handle positive result
                .addOnCompleteListener(listener);

    }

    public void scanYUVImage(ByteBuffer imageBuffer, int surfaceOrientation,  OnCompleteListener<List<FirebaseVisionBarcode>> listener){
        Integer rotation = ORIENTATIONS.get(surfaceOrientation);
        FirebaseVisionImageMetadata metadata = new FirebaseVisionImageMetadata.Builder()
                .setWidth(1280)   // 480x360 is typically sufficient for  image recognition
                .setHeight(720)
                .setFormat(FirebaseVisionImageMetadata.IMAGE_FORMAT_NV21)
                .setRotation(rotation)
                .build();
        detector.detectInImage(FirebaseVisionImage.fromByteBuffer(imageBuffer,metadata))
                //add a listener to handle positive result
                .addOnCompleteListener(listener);
    }
}
