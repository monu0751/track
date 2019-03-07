package org.ubitech.attendance;

import android.app.Notification;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.location.Address;
import android.location.Geocoder;
import android.location.LocationManager;
import android.nfc.Tag;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.util.Log;
import android.widget.Toast;
import android.support.v4.app.NotificationCompat;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.graphics.Color;
import android.content.Context;
import android.os.Build;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.Locale;
import java.util.Timer;
import java.util.TimerTask;
/*import android.content.ContentValues.*;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import java.io.UnsupportedEncodingException;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;*/

import android.location.Location;
/*import android.support.v4.content.ContextCompat;
import android.support.v4.app.ActivityCompat;
import android.Manifest;*/




public class MyForeGroundService extends Service {

    public static final String MY_PREFS_NAME = "MyPrefsFile";

    public String empid,shifttimein,shifttimeout;

    private static final int MY_PERMISSION_ACCESS_COARSE_LOCATION = 11;

    public static final int notify = 1000*60*5;  //interval between two services(Here Service run every 5 Minute)

    private Handler mHandler = new Handler();   //run on another Thread to avoid crash

    private Timer mTimer = null;

    private static final String TAG_FOREGROUND_SERVICE = "FOREGROUND_SERVICE";

    public static final String ACTION_START_FOREGROUND_SERVICE = "ACTION_START_FOREGROUND_SERVICE";

    public static final String ACTION_STOP_FOREGROUND_SERVICE = "ACTION_STOP_FOREGROUND_SERVICE";

    public static final String ACTION_PAUSE = "ACTION_PAUSE";

    public static final String ACTION_PLAY = "ACTION_PLAY";

    Location mLastLocation;

    private LocationManager mLocationManager = null;

    private static final int LOCATION_INTERVAL = 1000;

    private static final float LOCATION_DISTANCE = 10f;

    public static final String inputFormat = "HH:mm:ss";

    private Date date;

    private Date dateCompareOne;

    private Date dateCompareTwo;

    private String compareStringOne = "9:45";

    private String compareStringTwo = "1:45";

    SimpleDateFormat inputParser = new SimpleDateFormat(inputFormat);

    public MyForeGroundService() {
    }

    private class LocationListener implements android.location.LocationListener {

        public LocationListener(String provider) {
            //Log.e(io.opencensus.tags.Tag, "LocationListener " + provider);
            mLastLocation = new Location(provider);
        }

        @Override
        public void onLocationChanged(Location location) {
            //Log.e(TAG, "onLocationChanged: " + location);
            mLastLocation.set(location);
            //sendCoordinates(location.toString());


        }

        @Override
        public void onProviderDisabled(String provider) {
           // Log.e(TAG, "onProviderDisabled: " + provider);
            //new AsyncCaller("onProviderDisabled: ").execute();
        }

        @Override
        public void onProviderEnabled(String provider) {
           // Log.e(TAG, "onProviderEnabled: " + provider);
            // new AsyncCaller("onProviderEnabled: ").execute();
        }

        @Override
        public void onStatusChanged(String provider, int status, Bundle extras) {
           // Log.e(TAG, "onStatusChanged: " + provider);
            //new AsyncCaller("onStatusChanged: "+provider).execute();
            //sendCoordinates("onStatusChanged: "+ provider);
        }
    }


    @Override
    public IBinder onBind(Intent intent) {
        // TODO: Return the communication channel to the service.
        throw new UnsupportedOperationException("Not yet implemented");
    }

    @Override
    public void onCreate() {
        super.onCreate();
        Log.d(TAG_FOREGROUND_SERVICE, "My foreground service onCreate().");
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        System.out.println("In onStartCommand");

        Bundle extras = intent.getExtras();
        empid = (String)extras.get("empid");
        shifttimein = (String)extras.get("shifttimein");
        shifttimeout = (String)extras.get("shifttimeout");

        SharedPreferences.Editor editor = getSharedPreferences(MY_PREFS_NAME, MODE_PRIVATE).edit();
        editor.putString("empid", empid);
        editor.putString("shifttimein", shifttimein);
        editor.putString("shifttimeout", shifttimeout);
        editor.apply();



        if (intent != null) {
            String action = intent.getAction();

            switch (action) {
                case ACTION_START_FOREGROUND_SERVICE:
                    startForegroundService();
                    Toast.makeText(getApplicationContext(), "Foreground service is started.", Toast.LENGTH_LONG).show();
                    break;
                case ACTION_STOP_FOREGROUND_SERVICE:
                    stopForegroundService();
                    Toast.makeText(getApplicationContext(), "Foreground service is stopped.", Toast.LENGTH_LONG).show();
                    break;
                case ACTION_PLAY:
                    Toast.makeText(getApplicationContext(), "You click Play button.", Toast.LENGTH_LONG).show();
                    break;
                case ACTION_PAUSE:
                    Toast.makeText(getApplicationContext(), "You click Pause button.", Toast.LENGTH_LONG).show();
                    break;
            }
        }
        return super.onStartCommand(intent, flags, startId);
    }

    private void initializeLocationManager() {
        //Log.e(TAG, "initializeLocationManager");
        if (mLocationManager == null) {
            mLocationManager = (LocationManager) getApplicationContext().getSystemService(Context.LOCATION_SERVICE);
        }
    }

    /* Used to build and start foreground service. */
    private void startForegroundService() {
        Log.d(TAG_FOREGROUND_SERVICE, "Start foreground service.");

        // Create notification default intent.
        Intent intent = new Intent();
        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, intent, 0);

        // Create notification builder.
        NotificationCompat.Builder builder = new NotificationCompat.Builder(this);

        // Make notification show big text.
        NotificationCompat.BigTextStyle bigTextStyle = new NotificationCompat.BigTextStyle();
        bigTextStyle.setBigContentTitle("UbiAttendance is running in background.");
        //bigTextStyle.bigText("Android foreground service is a android service which can run in foreground always, it can be controlled by user via notification.");
        // Set big text style.
        builder.setStyle(bigTextStyle);

        builder.setWhen(System.currentTimeMillis());
        builder.setSmallIcon(R.mipmap.ic_launcher);
        Bitmap largeIconBitmap = BitmapFactory.decodeResource(getResources(), R.drawable.common_google_signin_btn_icon_dark);
        builder.setLargeIcon(largeIconBitmap);
        // Make the notification max priority.
        builder.setPriority(Notification.PRIORITY_MAX);
        // Make head-up notification.
        builder.setFullScreenIntent(pendingIntent, true);

      /*  // Add Play button intent in notification.
        Intent playIntent = new Intent(this, MyForeGroundService.class);
        playIntent.setAction(ACTION_PLAY);
        PendingIntent pendingPlayIntent = PendingIntent.getService(this, 0, playIntent, 0);
        NotificationCompat.Action playAction = new NotificationCompat.Action(android.R.drawable.ic_media_play, "Play", pendingPlayIntent);
        builder.addAction(playAction);

        // Add Pause button intent in notification.
        Intent pauseIntent = new Intent(this, MyForeGroundService.class);
        pauseIntent.setAction(ACTION_PAUSE);
        PendingIntent pendingPrevIntent = PendingIntent.getService(this, 0, pauseIntent, 0);
        NotificationCompat.Action prevAction = new NotificationCompat.Action(android.R.drawable.ic_media_pause, "Pause", pendingPrevIntent);
        builder.addAction(prevAction);*/

        // Build the notification.
        Notification notification = builder.build();
        System.out.println("before start foreground");
        // Start foreground service.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
            startMyOwnForeground();
        else
            startForeground(1, notification);



        System.out.println("timer called");
        if (mTimer != null) // Cancel if already existed
            mTimer.cancel();
        else
            mTimer = new Timer();   //recreate new
        mTimer.scheduleAtFixedRate(new TimeDisplay(), 0, notify);



    }

    class TimeDisplay extends TimerTask {
        @Override
        public void run() {
            // run on another thread
            mHandler.post(new Runnable() {
                @Override
                public void run() {


                    initializeLocationManager();

                    try {
                        mLocationManager.requestLocationUpdates(
                                LocationManager.PASSIVE_PROVIDER,
                                LOCATION_INTERVAL,
                                LOCATION_DISTANCE,
                                mLocationListeners[0]
                        );
                    } catch (java.lang.SecurityException ex) {
                       // Log.i(TAG, "fail to request location update, ignore", ex);
                    } catch (IllegalArgumentException ex) {
                       // Log.d(TAG, "network provider does not exist, " + ex.getMessage());
                    }

       /*
       try {
            mLocationManager.requestLocationUpdates(
                    LocationManager.NETWORK_PROVIDER, LOCATION_INTERVAL, LOCATION_DISTANCE,
                    mLocationListeners[1]);
        } catch (java.lang.SecurityException ex) {
            Log.i(TAG, "fail to request location update, ignore", ex);
        } catch (IllegalArgumentException ex) {
            Log.d(TAG, "network provider does not exist, " + ex.getMessage());
        }
        */

                        try {
                            mLocationManager.requestLocationUpdates(
                                    LocationManager.PASSIVE_PROVIDER, LOCATION_INTERVAL, LOCATION_DISTANCE,
                                    mLocationListeners[0]);
                            Double latitude;
                            Double longitude;
                            if (mLocationManager != null) {
                                mLastLocation = mLocationManager
                                        .getLastKnownLocation(LocationManager.NETWORK_PROVIDER);
                                if (mLastLocation != null) {
                                    latitude = mLastLocation.getLatitude();
                                    longitude = mLastLocation.getLongitude();
                                    Geocoder geocoder = new Geocoder(getApplicationContext(),Locale.getDefault());

                                    List<Address> addresses;


                                    addresses = geocoder.getFromLocation(latitude, longitude, 1); // Here 1 represent max location result to returned, by documents it recommended 1 to 5

                                    String address = addresses.get(0).getAddressLine(0); // If any additional address line present than only, check with max available address lines by getMaxAddressLineIndex()
                                    String city = addresses.get(0).getLocality();
                                    String state = addresses.get(0).getAdminArea();
                                    String country = addresses.get(0).getCountryName();
                                    String postalCode = addresses.get(0).getPostalCode();
                                    String knownName = addresses.get(0).getFeatureName();

                                    if(addresses!=null){
                                        new AsyncCaller(latitude.toString(), longitude.toString(), address).execute();
                                    }
                                }
                            }

                            // Only if available else return NULL
                        } catch (java.lang.SecurityException ex) {
                            //Log.i(TAG, "fail to request location update, ignore", ex);
                        } catch (IllegalArgumentException ex) {
                            //Log.d(TAG, "gps provider does not exist " + ex.getMessage());
                        } catch (IOException e){

                        }


                       // new AsyncCaller("", "", "").execute();

                }
            });
        }
    }

    private class AsyncCaller extends AsyncTask<Void, Void, Void>
    {
        String latitude, longitude, address;

        public AsyncCaller(String lati, String longi, String address) {
            super();
            latitude = lati;
            longitude = longi;
            this.address = address;

            // do stuff
        }

        @Override
        protected void onPreExecute() {
            super.onPreExecute();

            //this method will be running on UI thread

        }
        @Override
        protected Void doInBackground(Void... params) {

            //this method will be running on a background thread so don't update UI from here
            //do your long-running http tasks here, you don't want to pass argument and u can access the parent class' variable url over here
           try {

               System.out.println("Latitude "+latitude);

               System.out.println("Longitude "+longitude);

               System.out.println("Address "+address);

              sendCoordinates(latitude,longitude,address);


           }catch (Exception e){

           }
            System.out.println("this is background1");
            return null;
        }

        @Override
        protected void onPostExecute(Void result) {
            super.onPostExecute(result);
            //onDestroy();
            //this method will be running on UI thread
        }

    }


    private Date parseDate(String date) {

        try {
            return inputParser.parse(date);
        } catch (java.text.ParseException e) {
            return new Date(0);
        }
    }


    public void sendCoordinates(String lati, String longi, String add){
        try {
            /*empid = prefs.getString("empid", "");*/
            Context ctx = getApplicationContext();
            //SharedPreferences prefs = getSharedPreferences(MY_PREFS_NAME, MODE_PRIVATE);
            //empid = prefs.getString("empid", "");
            SharedPreferences prefs = getSharedPreferences(MY_PREFS_NAME, MODE_PRIVATE);
            empid = prefs.getString("empid", "");
            shifttimein = prefs.getString("shifttimein", "");
            shifttimeout = prefs.getString("shifttimeout", "");
            compareStringOne = shifttimein;
            compareStringTwo = shifttimeout;
            System.out.println("in Send Coordinates "+ empid+" shifttimein "+shifttimein+" shifttimeout "+ shifttimeout);

            System.out.println("This is web api called");

            Calendar now = Calendar.getInstance();

            int hour = now.get(Calendar.HOUR_OF_DAY);
            int minute = now.get(Calendar.MINUTE);
            int seconds = now.get(Calendar.SECOND);

            date = parseDate(hour + ":" + minute + ":" +seconds);
            dateCompareOne = parseDate(compareStringOne);
            dateCompareTwo = parseDate(compareStringTwo);
            System.out.println("dateCompareOne "+dateCompareOne);
            System.out.println("dateCompareTwo "+dateCompareTwo);
            System.out.println("Date "+date);

           // if ( dateCompareOne.before( date ) && dateCompareTwo.after(date)) {
                //yada yada
                URL url = new URL("https://sandbox.ubiattendance.com/index.php/Att_services/backgroundLocationService?"+"latitude="+lati+"&longitude="+longi+"&address="+add+"&empid="+empid);
                //URL url = new URL("http://192.168.0.200/ubiattendance/index.php/Att_services/backgroundLocationService?"+"latitude="+lati+"&longitude="+longi+"&address="+add+"&empid="+empid);

                HttpURLConnection httpConn = (HttpURLConnection)url.openConnection();

                httpConn.setRequestMethod("GET");

                InputStream inputStream = httpConn.getInputStream();
                InputStreamReader inputStreamReader = new InputStreamReader(inputStream);
                BufferedReader bufferedReader = new BufferedReader(inputStreamReader);
                String line = bufferedReader.readLine();

                httpConn.disconnect();

                //System.out.println("inside if");

            /*}else{
                System.out.println("inside else");
                stopForegroundService();
           }*/

            //URL url = new URL("http://192.168.0.200/ubiattendance/index.php/Att_services/backgroundLocationService?"+"latitude="+lati+"&longitude="+longi+"&address="+add+"&empid="+empid);


            /*HttpClient httpclient = new DefaultHttpClient();
            HttpPost post = new HttpPost("http://192.168.0.200/ubiattendance/index.php/Att_services/backgroundLocationService");
            //HttpPost post = new HttpPost("https://sandbox.ubiattendance.com/index.php/Att_services/backgroundLocationService");
            List<NameValuePair> list=new ArrayList<NameValuePair>();
            list.add(new BasicNameValuePair("latitude", lati));
            list.add(new BasicNameValuePair("longitude", longi));
            list.add(new BasicNameValuePair("address", add));
            list.add(new BasicNameValuePair("empid", empid));

            post.setEntity(new UrlEncodedFormEntity(list));

            HttpResponse response = httpclient.execute(post);
            // HttpResponse httpResponse=  httpclient.execute(post);

            HttpEntity entity = response.getEntity();
            System.out.println("this is response "+entity.toString());*/
            // String s= readResponse(response);
            //System.out.println("this is string response "+s);
        }catch ( IOException ioe ){
            ioe.printStackTrace();
        }
    }

    LocationListener[] mLocationListeners = new LocationListener[]{
            /* new LocationListener(LocationManager.GPS_PROVIDER),
             new LocationListener(LocationManager.NETWORK_PROVIDER),*/
            new LocationListener(LocationManager.PASSIVE_PROVIDER)
    };

    private void startMyOwnForeground(){
        String NOTIFICATION_CHANNEL_ID = "com.example.mac.forgroundtestingoreo";
        String channelName = "My Background Service";
        NotificationChannel chan = new NotificationChannel(NOTIFICATION_CHANNEL_ID, channelName, NotificationManager.IMPORTANCE_NONE);
        chan.setLightColor(Color.BLUE);
        chan.setLockscreenVisibility(Notification.VISIBILITY_PRIVATE);
        NotificationManager manager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        assert manager != null;
        manager.createNotificationChannel(chan);

        NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID);
        Notification notification = notificationBuilder.setOngoing(true)
                .setSmallIcon(R.drawable.common_google_signin_btn_icon_dark)
                .setContentTitle("UbiAttendance is running in background")
                .setPriority(NotificationManager.IMPORTANCE_MIN)
                .setCategory(Notification.CATEGORY_SERVICE)
                .build();
        startForeground(2, notification);
    }

    private void stopForegroundService() {
        Log.d(TAG_FOREGROUND_SERVICE, "Stop foreground service.");


        if (mLocationManager != null) {
            for (int i = 0; i < mLocationListeners.length; i++) {
                try {
                    mLocationManager.removeUpdates(mLocationListeners[i]);
                } catch (Exception ex) {
                   // Log.i(TAG, "fail to remove location listners, ignore", ex);
                }
            }
        }

        // Stop foreground service and remove the notification.
        stopForeground(true);

        // Stop the foreground service.
        stopSelf();


    }
}