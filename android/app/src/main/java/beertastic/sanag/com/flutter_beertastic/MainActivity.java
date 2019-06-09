package beertastic.sanag.com.flutter_beertastic;

import android.content.Intent;
import android.os.Bundle;

import beertastic.sanag.com.flutter_beertastic.view.CameraActivity;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

  private final static String CAMERA_X_CHANNEL= "CAMERA_X";
  private final static String SCAN_METHOD= "SCAN";

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    new MethodChannel(getFlutterView(),CAMERA_X_CHANNEL).setMethodCallHandler((call, result)->{
      if(call.method.equals(SCAN_METHOD)){
        Intent intent = new Intent(this, CameraActivity.class);
        startActivity(intent);
      }
    });
    GeneratedPluginRegistrant.registerWith(this);
  }
}
