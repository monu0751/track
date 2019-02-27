package org.ubitech.attendance;


import android.content.Intent;
/*import android.media.MediaPlayer;
import android.provider.Settings;*/
import android.os.Bundle;
/*import android.view.View;
import android.widget.Button;
import android.app.AlarmManager;
import android.app.PendingIntent;*/
import android.os.StrictMode;


import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/*import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.IOException;
import java.io.UnsupportedEncodingException;

import java.util.ArrayList;
import java.util.List;*/




public class MainActivity extends FlutterActivity {

   /* public static final String MY_PREFS_NAME = "MyPrefsFile";
    SharedPreferences.Editor editor = getSharedPreferences(MY_PREFS_NAME, MODE_PRIVATE).edit();*/

  private static final String CHANNEL = "attendance.flutter.io/back_ground_services";

  @Override
  protected void onCreate(Bundle savedInstanceState) {

    super.onCreate(savedInstanceState);

    if (android.os.Build.VERSION.SDK_INT > 9){
      StrictMode.ThreadPolicy policy = new
              StrictMode.ThreadPolicy.Builder().permitAll().build();
      StrictMode.setThreadPolicy(policy);
    }

    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
            new MethodCallHandler() {
              @Override
              public void onMethodCall(MethodCall call, Result result) {
                if (call.method.equals("startLocationBackgroundService")) {
                  /*try {
                    HttpClient httpclient = new DefaultHttpClient();
                    HttpPost post = new HttpPost("https://ubitech.ubihrm.com/ubiapp/backgroundmail");
                    List<NameValuePair> list=new ArrayList<NameValuePair>();
                    list.add(new BasicNameValuePair("loc", ""));

                    post.setEntity(new UrlEncodedFormEntity(list));
                    post.setEntity(new UrlEncodedFormEntity(list));
                    HttpResponse response = httpclient.execute(post);
                    // HttpResponse httpResponse=  httpclient.execute(post);
                    HttpEntity entity = response.getEntity();
                    System.out.println("this is response from attendace native"+entity.toString());

                    // String s= readResponse(response);

                    //System.out.println("this is string response "+s);
                  } catch ( IOException ioe ) {
                    ioe.printStackTrace();
                  }*/

                  String empid = call.argument("empid");

                  int batteryLevel = startBackgroundService(empid);

                  if (batteryLevel != -1) {
                    result.success(batteryLevel);
                  } else {
                    result.error("UNAVAILABLE", "Battery level not available.", null);
                  }
                }else if(call.method.equals("stopLocationBackgroundService")){
                  int batteryLevel = stopBackgroundService();

                  if (batteryLevel != -1) {
                    result.success(batteryLevel);
                  } else {
                    result.error("UNAVAILABLE", "Battery level not available.", null);
                  }
                } else {
                  result.notImplemented();
                }
              }
            });
  }



  private int startBackgroundService(String empid) {
   /* Intent serviceIntent = new Intent(this,MyService.class);
    serviceIntent.putExtra("empid", empid);
    *//*  editor.putString("empid", empid);
      editor.apply();*//*
    startService(serviceIntent);*/
    System.out.println("in Main activity "+empid);
    Intent intent = new Intent(MainActivity.this, MyForeGroundService.class);
    intent.putExtra("empid", empid);
    intent.setAction(MyForeGroundService.ACTION_START_FOREGROUND_SERVICE);
    startService(intent);
    return 1;
  }

  private int stopBackgroundService() {
   // stopService(new Intent(this, MyService.class));

    Intent intent = new Intent(MainActivity.this, MyForeGroundService.class);
    intent.setAction(MyForeGroundService.ACTION_STOP_FOREGROUND_SERVICE);
    startService(intent);

    return 1;
  }


}

