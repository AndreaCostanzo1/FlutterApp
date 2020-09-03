package beertastic.sanag.com.flutter_beertastic;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.util.SparseArray;

import com.google.firebase.storage.FirebaseStorage;

import java.util.function.BiFunction;

import beertastic.sanag.com.flutter_beertastic.view.ScannerActivity;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {

    private final static String IMAGE_PICKER_CHANNEL = "PICKER_CHANNEL";
    private final static String PICK_STORAGE = "STORAGE";
    private String path;
    private int storageRequestCode;

    private final static String CAMERA_X_CHANNEL = "CAMERA_X";
    private final static String SCAN_METHOD = "SCAN";
    private int qrRequestCode;
    private MethodChannel.Result result;
    private SparseArray<BiFunction<Integer, Intent, Void>> resultHandlers;


    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CAMERA_X_CHANNEL).setMethodCallHandler((call, result) -> {
            if (call.method.equals(SCAN_METHOD)) {
                Intent intent = new Intent(this, ScannerActivity.class);
                this.result = result;
                startActivityForResult(intent, qrRequestCode);
            }
        });
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), IMAGE_PICKER_CHANNEL).setMethodCallHandler((call, result) -> {
            if (call.method.equals(PICK_STORAGE)) {
                Intent intent = new Intent();
                intent.setType("image/*");
                this.path = call.argument("path");
                intent.putExtra("path", path);
                intent.setAction(Intent.ACTION_GET_CONTENT);
                this.result = result;
                startActivityForResult(intent, storageRequestCode);
            }
        });
    }


    private void getComponents() {
        qrRequestCode = getResources().getInteger(R.integer.beertastic_qr_request_code);
        storageRequestCode = getResources().getInteger(R.integer.beertastic_storage_request_code);
    }


    private void setUpResultsHandlers() {
        resultHandlers = new SparseArray<>();
        resultHandlers.append(qrRequestCode, this::handleQrResult);
        resultHandlers.append(storageRequestCode, this::handleStorageResult);
    }


    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        BiFunction<Integer, Intent, Void> handler = resultHandlers.get(requestCode);
        if (handler != null) handler.apply(resultCode, data);
        else
            Log.d("onActivityResult", "request number: " + requestCode + " not handled locally. Ignore this if request comes from flutter plugins");
    }

    private Void handleQrResult(Integer resultCode, Intent intent) {
        if (resultCode == RESULT_OK) {
            String qrData = intent.getStringExtra(getResources().getString(R.string.qr_code_data_extra));
            Log.d("qrValue", qrData);
            result.success(qrData);
        }
        return null;
    }


    private Void handleStorageResult(Integer integer, Intent intent) {
        if (integer == RESULT_OK) {
            if (path!=null && intent.getData() != null)
                FirebaseStorage.getInstance().getReference(path)
                        .putFile(intent.getData())
                        .addOnCompleteListener(listener -> result.success(true))
                        .addOnFailureListener(error -> result.error("upload failure", error.getMessage(), ""));
            else result.success(false);
        }
        return null;
    }

    //get single document from collection group
//  FirebaseFirestore.getInstance().collectionGroup(collectionID).getFirestore()
//                .collection(collectionID).document(beer).get()
//                .addOnCompleteListener(snapshotTask-> sendResultBack(snapshotTask, result));
}
