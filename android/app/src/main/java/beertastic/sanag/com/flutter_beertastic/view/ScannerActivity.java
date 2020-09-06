package beertastic.sanag.com.flutter_beertastic.view;


import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.util.Log;
import android.util.Size;
import android.view.TextureView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.camera.core.CameraSelector;
import androidx.camera.core.ExperimentalGetImage;
import androidx.camera.core.ImageAnalysis;
import androidx.camera.core.ImageProxy;
import androidx.camera.core.Preview;
import androidx.camera.lifecycle.ProcessCameraProvider;
import androidx.camera.view.PreviewView;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.ViewModelProvider;
import androidx.lifecycle.ViewModelProviders;

import com.google.common.primitives.Bytes;
import com.google.common.util.concurrent.ListenableFuture;

import java.util.concurrent.ExecutionException;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

import beertastic.sanag.com.flutter_beertastic.R;
import beertastic.sanag.com.flutter_beertastic.view_model.ScannerViewModel;
import beertastic.sanag.com.flutter_beertastic.view_model.tools.BarcodesScanner;

public class ScannerActivity extends AppCompatActivity {

    private ScannerViewModel viewModel;
    private PreviewView previewView;

    private ListenableFuture<ProcessCameraProvider> cameraProviderFuture;

    @Override @ExperimentalGetImage
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.beertastic_activity_camera);
        getComponents();
        setUpViewModel();
        checkCameraPermission();
    }

    @Override @ExperimentalGetImage
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        //check if the result code is equal to the one used for camera request
        if (requestCode == getResources().getInteger(R.integer.beertastic_camera_request_code)) {
            if (grantResults[0] != PackageManager.PERMISSION_GRANTED) {
                Toast.makeText(this, "You can't use camera without permission", Toast.LENGTH_SHORT).show();
            } else {
                setUpCamera();
            }
        }
    }

    @ExperimentalGetImage
    private void setUpCamera() {
        cameraProviderFuture = ProcessCameraProvider.getInstance(this);
        cameraProviderFuture.addListener(() -> {
            try {
                ProcessCameraProvider cameraProvider = cameraProviderFuture.get();
                bindPreview(cameraProvider);
            } catch (ExecutionException | InterruptedException e) {
                // No errors need to be handled for this Future.
                // This should never be reached.
            }
        }, ContextCompat.getMainExecutor(this));
    }

    @ExperimentalGetImage
    void bindPreview(@NonNull ProcessCameraProvider cameraProvider) {
        Executor executor = Executors.newSingleThreadExecutor();
        Preview preview = new Preview.Builder()
                .build();

        CameraSelector cameraSelector = new CameraSelector.Builder()
                .requireLensFacing(CameraSelector.LENS_FACING_BACK)
                .build();

        preview.setSurfaceProvider(previewView.createSurfaceProvider());

        ImageAnalysis imageAnalysis =
                new ImageAnalysis.Builder()
                        .setTargetResolution(new Size(1280, 720))
                        .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                        .build();

        imageAnalysis.setAnalyzer(executor, this::analyzeImage);
        cameraProvider.unbindAll();
        cameraProvider.bindToLifecycle((LifecycleOwner) this, cameraSelector, imageAnalysis, preview);
    }

    @ExperimentalGetImage
    private void checkCameraPermission() {
        // Here, thisActivity is the current activity
        if (ContextCompat.checkSelfPermission(this,
                Manifest.permission.CAMERA)
                != PackageManager.PERMISSION_GRANTED) {
            //permission not granted
            handlePermissionRequest();
        } else {
            setUpCamera();
        }
    }

    private void handlePermissionRequest() {
        if (ActivityCompat.shouldShowRequestPermissionRationale(this,
                Manifest.permission.CAMERA)) {
            Toast.makeText(this, "You can't use camera without permission", Toast.LENGTH_SHORT).show(); //fixme: it's ok?
        }
        ActivityCompat.requestPermissions(this,
                new String[]{Manifest.permission.CAMERA},
                getResources().getInteger(R.integer.beertastic_camera_request_code));


    }

    private void getComponents() {
        previewView = findViewById(R.id.beertastic_scanner_preview);
    }


    @ExperimentalGetImage
    private void analyzeImage(ImageProxy image) {
        BarcodesScanner.getInstance()
                .scanYUVImage(image,
                        (barcodesList) -> viewModel.handleScanResult(barcodesList));
    }

    private void setUpViewModel() {
        viewModel = new ViewModelProvider(this).get(ScannerViewModel.class);
        viewModel.getQrData().observe(this, this::setActivityResult);
    }

    private void setActivityResult(String qrData) {
        Intent intent = new Intent();
        intent.putExtra(getResources().getString(R.string.qr_code_data_extra), qrData);
        setResult(RESULT_OK, intent);
        finish();
    }


//    private Bitmap computeImage(ImageProxy image) {
//        ByteArrayOutputStream out = new ByteArrayOutputStream();
//        ByteBuffer byteBuffer = image.getPlanes()[0].getBuffer().asReadOnlyBuffer();
//        byte[] byteArray = new byte[byteBuffer.remaining()];
//        byteBuffer.get(byteArray);
//        Rect section = new Rect(0, image.getHeight() / 3, image.getWidth(), image.getHeight() - image.getHeight() / 3);
//        YuvImage yuvImage = new YuvImage(byteArray, ImageFormat.NV21, image.getWidth(), image.getHeight(), null);
//        yuvImage.compressToJpeg(section, 70, out);
//        byteArray = out.toByteArray();
//        return BitmapFactory.decodeByteArray(byteArray, 0, byteArray.length);
//    }
}
