package beertastic.sanag.com.flutter_beertastic;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.util.SparseArray;

import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.FutureTask;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;
import java.util.function.BiFunction;
import java.util.function.Function;

import beertastic.sanag.com.flutter_beertastic.view.ScannerActivity;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

  private final static String CAMERA_X_CHANNEL= "CAMERA_X";
  private final static String SCAN_METHOD= "SCAN";
  private int qrRequestCode;
  private MethodChannel.Result result;
  private SparseArray<BiFunction<Integer,Intent,Void>> resultHandlers;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    getComponents();
    setUpResultsHandlers();
    new MethodChannel(getFlutterView(),CAMERA_X_CHANNEL).setMethodCallHandler((call, result)->{
      if(call.method.equals(SCAN_METHOD)){
        Intent intent = new Intent(this, ScannerActivity.class);
        this.result=result;
        startActivityForResult(intent,qrRequestCode);
      }
    });
    GeneratedPluginRegistrant.registerWith(this);
  }

  private void getComponents() {
    qrRequestCode=getResources().getInteger(R.integer.beertastic_qr_request_code);
  }


  private void setUpResultsHandlers() {
    resultHandlers=new SparseArray<>();
    resultHandlers.append(qrRequestCode,this::handleQrResult);
  }

  @Override
  protected void onActivityResult(int requestCode, int resultCode, Intent data) {
    super.onActivityResult(requestCode, resultCode, data);
    resultHandlers.get(requestCode).apply(resultCode,data);
  }

  private Void handleQrResult(Integer resultCode, Intent intent) {
    if(resultCode==RESULT_OK){
      String qrData = intent.getStringExtra(getResources().getString(R.string.qr_code_data_extra));
      Log.wtf("HAAHAHHAHAHAH",qrData);
      result.success(qrData);
    }
    return null;
  }
}
