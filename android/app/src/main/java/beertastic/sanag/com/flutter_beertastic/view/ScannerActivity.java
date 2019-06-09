package beertastic.sanag.com.flutter_beertastic.view;


import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.HandlerThread;
import android.util.Log;
import android.util.Size;
import android.view.TextureView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.camera.core.CameraX;
import androidx.camera.core.ImageAnalysis;
import androidx.camera.core.ImageAnalysisConfig;
import androidx.camera.core.Preview;
import androidx.camera.core.PreviewConfig;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.LifecycleRegistry;
import androidx.lifecycle.ViewModel;
import androidx.lifecycle.ViewModelProviders;

import com.google.android.gms.tasks.Task;
import com.google.firebase.ml.vision.barcode.FirebaseVisionBarcode;

import java.util.List;
import java.util.Optional;

import beertastic.sanag.com.flutter_beertastic.R;
import beertastic.sanag.com.flutter_beertastic.view_model.ScannerViewModel;
import beertastic.sanag.com.flutter_beertastic.view_model.tools.BarcodesScanner;

public class ScannerActivity extends AppCompatActivity implements LifecycleOwner {

    private TextureView textureView;
    private LifecycleRegistry lifecycleRegistry;
    private ScannerViewModel viewModel;
    private ImageAnalysis imageAnalysis;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.beertastic_activity_camera);
        lifecycleRegistry = new LifecycleRegistry(this);
        getComponents();
        checkCameraPermission();
        setUpViewModel();
        lifecycleRegistry.markState(Lifecycle.State.CREATED);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        lifecycleRegistry.markState(Lifecycle.State.DESTROYED);
    }

    @Override
    protected void onPause() {
        super.onPause();
        lifecycleRegistry.markState(Lifecycle.State.CREATED);
    }

    @Override
    protected void onStart() {
        super.onStart();
        lifecycleRegistry.markState(Lifecycle.State.STARTED);
    }

    @Override
    protected void onResume() {
        super.onResume();
        lifecycleRegistry.markState(Lifecycle.State.RESUMED);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        //check if the result code is equal to the one used for camera request
        if (requestCode == getResources().getInteger(R.integer.beertastic_camera_request_code)) {
            if (grantResults[0] != PackageManager.PERMISSION_GRANTED) {
                Toast.makeText(this, "You can't use camera without permission", Toast.LENGTH_SHORT).show();
            }
        }
    }

    private void checkCameraPermission() {
        // Here, thisActivity is the current activity
        if (ContextCompat.checkSelfPermission(this,
                Manifest.permission.CAMERA)
                != PackageManager.PERMISSION_GRANTED) {
            //permission not granted
            handlePermissionRequest();
        } else {
            setUpCameraX();
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
        textureView = findViewById(R.id.beertastic_scanner_preview);
    }

    private void setUpCameraX() {
        CameraX.unbindAll();
        HandlerThread thread = new HandlerThread("CameraX");
        thread.start();
        ImageAnalysisConfig config =
                new ImageAnalysisConfig.Builder()
                        .setTargetResolution(new Size(textureView.getWidth(), textureView.getHeight()))
                        .setCallbackHandler(new Handler(thread.getLooper()))
                        .setImageReaderMode(ImageAnalysis.ImageReaderMode.ACQUIRE_LATEST_IMAGE)
                        .build();

        int deviceRotation = getWindowManager().getDefaultDisplay().getRotation();
        imageAnalysis = new ImageAnalysis(config);

        imageAnalysis.setAnalyzer(
                (image, rotationDegrees) -> BarcodesScanner.getInstance()
                        .scanYUVImage(image.getPlanes()[0].getBuffer(), deviceRotation,
                                (barcodesList)->viewModel.handleScanResult(barcodesList)));

        PreviewConfig previewConfig = new PreviewConfig.Builder().setTargetResolution(new Size(textureView.getWidth()/2, textureView.getHeight()/2)).build();
        Preview preview = new Preview(previewConfig);


        preview.setOnPreviewOutputUpdateListener(
                previewOutput -> textureView.setSurfaceTexture(previewOutput.getSurfaceTexture()));

        CameraX.bindToLifecycle(this, imageAnalysis, preview);
    }




    @NonNull
    @Override
    public Lifecycle getLifecycle() {
        return lifecycleRegistry;
    }

    private void setUpViewModel() {
        viewModel = ViewModelProviders.of(this).get(ScannerViewModel.class);
        viewModel.getQrData().observe(this, this::setActivityResult);
    }

    private void setActivityResult(String qrData) {
        CameraX.unbind(imageAnalysis);
        Intent intent = new Intent();
        intent.putExtra(getResources().getString(R.string.qr_code_data_extra),qrData);
        setResult(RESULT_OK,intent);
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