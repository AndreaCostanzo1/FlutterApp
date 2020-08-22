package beertastic.sanag.com.flutter_beertastic.view;


import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.util.Size;
import android.view.TextureView;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.camera.core.CameraX;
import androidx.camera.core.ImageAnalysis;
import androidx.camera.core.ImageAnalysisConfig;
import androidx.camera.core.ImageProxy;
import androidx.camera.core.Preview;
import androidx.camera.core.PreviewConfig;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.ViewModelProviders;

import com.google.common.primitives.Bytes;

import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

import beertastic.sanag.com.flutter_beertastic.R;
import beertastic.sanag.com.flutter_beertastic.view_model.ScannerViewModel;
import beertastic.sanag.com.flutter_beertastic.view_model.tools.BarcodesScanner;

public class ScannerActivity extends AppCompatActivity {

    private TextureView textureView;
    private ScannerViewModel viewModel;
    private ImageAnalysis imageAnalysis;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.beertastic_activity_camera);
        getComponents();
        checkCameraPermission();
        setUpViewModel();
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        //check if the result code is equal to the one used for camera request
        if (requestCode == getResources().getInteger(R.integer.beertastic_camera_request_code)) {
            if (grantResults[0] != PackageManager.PERMISSION_GRANTED) {
                Toast.makeText(this, "You can't use camera without permission", Toast.LENGTH_SHORT).show();
            } else {
                setUpCameraX();
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
        Executor executor = Executors.newSingleThreadExecutor();
        ImageAnalysisConfig config =
                new ImageAnalysisConfig.Builder()
                        .setTargetResolution(new Size(1280, 720))
                        .setBackgroundExecutor(executor)
                        .setImageReaderMode(ImageAnalysis.ImageReaderMode.ACQUIRE_LATEST_IMAGE)
                        .build();

        int deviceRotation = getWindowManager().getDefaultDisplay().getRotation();
        imageAnalysis = new ImageAnalysis(config);

        imageAnalysis.setAnalyzer(executor,
                (image, rotationDegrees) -> analyzeImage(image,rotationDegrees,deviceRotation));

        PreviewConfig previewConfig = new PreviewConfig.Builder().setTargetResolution(new Size(textureView.getWidth(), textureView.getHeight())).build();
        Preview preview = new Preview(previewConfig);

        preview.setOnPreviewOutputUpdateListener(
                previewOutput -> textureView.setSurfaceTexture(previewOutput.getSurfaceTexture()));

        CameraX.bindToLifecycle(this, imageAnalysis, preview);
    }

    private void analyzeImage(ImageProxy image, int rotationDegrees, int deviceRotation) {
        ImageProxy.PlaneProxy[] proxyList = image.getPlanes();
        byte[] y= new byte[proxyList[0].getBuffer().remaining()];
        proxyList[0].getBuffer().get(y);
        byte[] u= new byte[proxyList[1].getBuffer().remaining()];
        proxyList[1].getBuffer().get(u);
        byte[] v= new byte[proxyList[2].getBuffer().remaining()];
        proxyList[2].getBuffer().get(v);
        byte[] imageByteArray = Bytes.concat(y,u,v);
        BarcodesScanner.getInstance()
                .scanYUVImage(imageByteArray, deviceRotation,
                        (barcodesList)->viewModel.handleScanResult(barcodesList));
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
