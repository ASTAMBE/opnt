package com.opinito.social.Activity;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;

import com.google.android.gms.common.GooglePlayServicesNotAvailableException;
import com.google.android.gms.common.GooglePlayServicesRepairableException;
import com.google.android.gms.security.ProviderInstaller;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.analytics.FirebaseAnalytics;
import com.google.firebase.dynamiclinks.FirebaseDynamicLinks;
import com.google.firebase.dynamiclinks.PendingDynamicLinkData;
import com.google.firebase.remoteconfig.FirebaseRemoteConfig;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.Preference;
import com.opinito.social.Fragment.ActivityFragment;
import com.opinito.social.Fragment.ListFragment;
import com.opinito.social.Fragment.ProfileFragment;
import com.opinito.social.R;
import com.opinito.social.Utils.UserUtils;
import com.opinito.social.databinding.SplashscreenBinding;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.security.KeyManagementException;
import java.security.NoSuchAlgorithmException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.UUID;

import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLHandshakeException;

/**
 * Created by 502687702 on 7/12/2017.
 */

public class Splashscreen extends Activity {
    /**
     * Duration of wait
     **/
    private final int SPLASH_DISPLAY_LENGTH = 2000;
    private static final String QUERY_USER_ID = "userId";
    private static final String QUERY_TOPIC_ID = "topicId";
    private static final String QUERY_POST_ID = "postId";
    private static final String QUERY_USERNAME = "username";
    private static final String QUERY_COUNTRY_CODE = "countrycode";
    private static final int LONG_DELAY = 7000;
    private Uri deepLink = null;
    private FirebaseRemoteConfig mFirebaseRemoteConfig;
    private String fcmServerId= "";

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        try {
            // Google Play will install latest OpenSSL
            ProviderInstaller.installIfNeeded(getApplicationContext());
            SSLContext sslContext;
            sslContext = SSLContext.getInstance("TLSv1.2");
            sslContext.init(null, null, null);
            sslContext.createSSLEngine();
        } catch (GooglePlayServicesRepairableException | GooglePlayServicesNotAvailableException
                 | NoSuchAlgorithmException | KeyManagementException e) {
            e.printStackTrace();
        }

        if (android.os.Build.VERSION.SDK_INT != Build.VERSION_CODES.O) {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        }

        SplashscreenBinding binding = SplashscreenBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());
//        Log.d("taggy","token->"+new Preference(getApplicationContext()).getPref(Constants.token));
//        Log.d("taggy","userid->"+new Preference(getApplicationContext()).getPref(Constants.USERID));
        ListFragment.load = false;
        ActivityFragment.refresh = true;
        ProfileFragment.load = false;
        mFirebaseRemoteConfig = FirebaseRemoteConfig.getInstance();
        fcmServerId = mFirebaseRemoteConfig.getString("fcm_server_id");
        new Preference(Splashscreen.this).savePref("fcm_server_id",fcmServerId);

        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                /* Create an Intent that will start the Menu-Activity. */
                if (Constants.DATEOFEXPIRATION.isEmpty()) {
                    loginIntent();
                } else {
                    try {
                        if (!getCurrentDate()) {
                            UserUtils.logOutUser(Splashscreen.this);
                            Intent intent = new Intent(Splashscreen.this, WelcomeActivity.class);
                            startActivity(intent);
                        } else {
                            loginIntent();
                        }
                    } catch (ParseException e) {
                        loginIntent();
                        e.printStackTrace();
                    }
                }
            }
        }, SPLASH_DISPLAY_LENGTH);
    }

    private void loginIntent() {
        if (!new Preference(Splashscreen.this).getPref(Constants.REFFERED).equals("true")) {
            if (new Preference(getApplicationContext()).getIntPref(Constants.LOGGEDIN) == 0 &&
                    new Preference(getApplicationContext()).getPref(Constants.USERID).equals("")) {
                Intent intent = new Intent(Splashscreen.this, WelcomeActivity.class);
                startActivity(intent);
            } else {
                Intent intent = new Intent(Splashscreen.this, DashBoard.class);
                startActivity(intent);
            }
            finish();
        } else {
            new Preference(Splashscreen.this).savePref(Constants.REFFERED, "false");
        }
    }

    @Override
    protected void onStart() {
        super.onStart();
        new Preference(Splashscreen.this).savePref(Constants.REFFERED, "false");
        FirebaseAnalytics.getInstance(this);
        FirebaseDynamicLinks.getInstance()
                .getDynamicLink(getIntent())
                .addOnSuccessListener(this, new OnSuccessListener<PendingDynamicLinkData>() {
                    @Override
                    public void onSuccess(PendingDynamicLinkData pendingDynamicLinkData) {
                        // Get deep link from result (may be null if no link is found)
                        if (pendingDynamicLinkData != null) {
                            deepLink = pendingDynamicLinkData.getLink();
                        }
                        if (deepLink != null) {
                            String topicid = deepLink.getQueryParameter(QUERY_TOPIC_ID);
                            String userId = deepLink.getQueryParameter(QUERY_USER_ID);
                            String postId = deepLink.getQueryParameter(QUERY_POST_ID);
                            String username = deepLink.getQueryParameter(QUERY_USERNAME);
                            new Preference(Splashscreen.this).savePref(Constants.REFFERED, "true");
                            new Handler().postDelayed(new Runnable() {
                                @SuppressLint("WrongConstant")
                                @Override
                                public void run() {
                                    if (Constants.DATEOFEXPIRATION.isEmpty()) {
                                        pendingIntent(topicid, userId, postId, username);
                                    } else {
                                        try {
                                            if (!getCurrentDate()) {
                                                UserUtils.logOutUser(Splashscreen.this);
                                                Intent intent = new Intent(Splashscreen.this, WelcomeActivity.class);
                                                startActivity(intent);
                                            } else  {
                                                pendingIntent(topicid, userId, postId, username);
                                            }
                                        } catch (ParseException e) {
                                            pendingIntent(topicid, userId, postId, username);
                                            e.printStackTrace();
                                        }
                                    }
                                    finish();
                                }
                            }, 500);
                        }
                    }
                })
                .addOnFailureListener(this, new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        Log.w("SplashScreen", "getDynamicLink:onFailure", e);
                    }
                });
    }

    private void pendingIntent(String topicid, String userId, String postId, String username) {
        if (new Preference(getApplicationContext()).getIntPref(Constants.LOGGEDIN) == 0 &&
                new Preference(getApplicationContext()).getPref(Constants.USERID).equals("")) {
                new Preference(Splashscreen.this).savePref(Constants.REFFERERUSERID, userId);
            try {
                new Preference(Splashscreen.this).savePref(Constants.DEEPLINKCOUNTRYCODE,
                        deepLink.getQueryParameter(QUERY_COUNTRY_CODE));
                new Preference(Splashscreen.this).saveBooleanPref(Constants.ISDEEPLINK, true);
                new Preference(Splashscreen.this).saveIntPref(Constants.DEEPLINKTOPICID,
                        Integer.parseInt(topicid));
                new Preference(Splashscreen.this).savePref(Constants.DEEPLINKPOSTID,
                        postId);
                new Preference(Splashscreen.this).savePref(Constants.DEEPLINKUSERNAME,
                        username);
            } catch (Exception e) {
                e.printStackTrace();
            }
            Intent intent = new Intent(Splashscreen.this, WelcomeActivity.class);
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
            startActivity(intent);
        } else {
            new Preference(Splashscreen.this).savePref(Constants.REFFERERUSERID, userId);
            new Preference(Splashscreen.this).saveBooleanPref(Constants.ISDEEPLINK, true);
            new Preference(Splashscreen.this).saveIntPref(Constants.DEEPLINKTOPICID,
                    Integer.parseInt(topicid));
            new Preference(Splashscreen.this).savePref(Constants.DEEPLINKPOSTID,
                    postId);
            new Preference(Splashscreen.this).savePref(Constants.DEEPLINKUSERNAME,
                    username);
            Intent intent = new Intent(Splashscreen.this, DashBoard.class);
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
            startActivity(intent);
        }
    }

    private Boolean getCurrentDate() throws ParseException {
        @SuppressLint("SimpleDateFormat") SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
        Date currentDate = sdf.parse(sdf.format(new Date()));
        Date enteredDate = sdf.parse(Constants.DATEOFEXPIRATION);
        assert enteredDate != null;
        return enteredDate.after(currentDate);
    }

}
