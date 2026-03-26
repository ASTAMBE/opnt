package com.opinito.social.Utils.CompressVideo;

import android.annotation.TargetApi;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.os.Binder;
import android.os.Build;
import android.os.IBinder;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public class BoundService extends Service {
    private RxBus rxBus;
    float progressBar;
    private final String DESTPATH = "destPath";
    private final String INPUTPATH = "inputDest";
    public BoundService() {
    }
    private final IBinder localBinder = new MyBinder();
    @Override
    public IBinder onBind(Intent intent) {
        return localBinder;
    }
    /**
     * Called when all clients have disconnected from a particular interface
     * published by the service.  The default implementation does nothing and
     * returns false.
     *
     * @param intent The Intent that was used to bind to this service,
     *               as given to {@link Context#bindService
     *               Context.bindService}.  Note that any extras that were included with
     *               the Intent at that point will <em>not</em> be seen here.
     * @return Return true if you would like to have the service's
     * {@link #onRebind} method later called when new clients bind to it.
     */
    @Override
    public boolean onUnbind(Intent intent) {
        return super.onUnbind(intent);
    }
    /**
     * Called when new clients have connected to the service, after it had
     * previously been notified that all had disconnected in its
     * {@link #onUnbind}.  This will only be called if the implementation
     * of {@link #onUnbind} was overridden to return true.
     *
     * @param intent The Intent that was used to bind to this service,
     *               as given to {@link Context#bindService
     *               Context.bindService}.  Note that any extras that were included with
     *               the Intent at that point will <em>not</em> be seen here.
     */
    @Override
    public void onRebind(Intent intent) {
        super.onRebind(intent);
    }
    /**
     * Called by the system to notify a Service that it is no longer used and is being removed.  The
     * service should clean up any resources it holds (threads, registered
     * receivers, etc) at this point.  Upon return, there will be no more calls
     * in to this Service object and it is effectively dead.  Do not call this method directly.
     */
    @Override
    public void onDestroy() {
        super.onDestroy();
    }
    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        rxBus = new RxBus();
        if (intent != null) {
            if (intent.getExtras() != null) {
                String destPath = intent.getStringExtra(DESTPATH);
                String inputDest = intent.getStringExtra(INPUTPATH);
                doSomething(inputDest, destPath);
            }
        }
        return START_REDELIVER_INTENT;
    }
    private void doSomething(String inputDest, String destPath) {

        //sending compression request to the video compressor
        VideoCompress.compressVideoLow(inputDest, destPath, new VideoCompress.CompressListener() {
            @Override
            public void onStart() {
                VideoUtils.writeFile(BoundService.this, "Start at: " + new SimpleDateFormat("HH:mm:ss", getLocale()).format(new Date()) + "\n");
            }
            @Override
            public void onSuccess() {
                VideoUtils.writeFile(BoundService.this, "End at: " + new SimpleDateFormat("HH:mm:ss", getLocale()).format(new Date()) + "\n");
                float end = 0.0f;
                ChangeInProgress changeInProgress = new ChangeInProgress(end, true);
                if (rxBus!=null){
                    rxBus.send(changeInProgress);
                }
            }
            @Override
            public void onFail() {
            }
            @Override
            public void onProgress(float percent) {
                progressBar = percent;
                ChangeInProgress changeInProgress = new ChangeInProgress(percent, false);
                if (rxBus!=null){
                    rxBus.send(changeInProgress);
                }
            }
        });
    }
    public class MyBinder extends Binder {
        public BoundService getService() {
            return BoundService.this;
        }
        public RxBus getRxbus(){
            return rxBus;
        }
    }
    private Locale getLocale() {
        Configuration config = getResources().getConfiguration();
        Locale sysLocale = null;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            sysLocale = getSystemLocale(config);
        } else {
            sysLocale = getSystemLocaleLegacy(config);
        }
        return sysLocale;
    }
    @SuppressWarnings("deprecation")
    public static Locale getSystemLocaleLegacy(Configuration config) {
        return config.locale;
    }
    @TargetApi(Build.VERSION_CODES.N)
    public static Locale getSystemLocale(Configuration config) {
        return config.getLocales().get(0);
    }
}