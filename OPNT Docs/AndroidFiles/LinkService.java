package com.opinito.social;

import android.app.IntentService;
import android.content.Intent;
import android.os.IBinder;
import androidx.annotation.Nullable;
import android.util.Log;

import com.opinito.social.Async.CheckLinkExistsAsyncTask;
import com.opinito.social.Async.PostLinkPreviewAsyncTask;
import com.opinito.social.Interface.CommonInterface;
import com.opinito.social.Model.WebLoadModel;

import org.json.JSONObject;

public class LinkService extends IntentService {


    private String url;
    private WebLoadModel webLoadModel;
    private String TAG_NAME = this.getClass().getName();

    public LinkService() {
        super("linkPreviewService");
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    protected void onHandleIntent(@Nullable Intent intent) {
        url = intent.getStringExtra("linkPreviewUrl");
        webLoadModel = (WebLoadModel) intent.getSerializableExtra("webmodelObj");
        checkAndPostLinkPreview();
    }

    @Override
    public void onCreate() {
        super.onCreate();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }


    private void checkAndPostLinkPreview() {
        CommonInterface commonInterface = new CommonInterface() {
            @Override
            public void OnCommonInterface(String response) {
                String status = "";
                try {
                    if (response.contains("status")) {
                        status = new JSONObject(response).getString("status");
                        if ("not found".equalsIgnoreCase(status)) {
                            Log.d(TAG_NAME, "Link Not found on the server");
                            postPreviewToServer(webLoadModel);
                        }
                    } else {
                        Log.d(TAG_NAME, "Link found on the server");
                    }

                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        };
        new CheckLinkExistsAsyncTask(getApplicationContext(), commonInterface).execute(url);
    }

    private void postPreviewToServer(WebLoadModel webLoadModel) {
        CommonInterface commonInterface = new CommonInterface() {
            @Override
            public void OnCommonInterface(String response) {
                String status = "";
                Log.d(TAG_NAME, "com.opinito.social.Model.Data posted to server");
                try {
                    // status = new JSONArray(response).getJSONObject(0).getString("status");

                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        };
        new PostLinkPreviewAsyncTask(getApplicationContext(), commonInterface).execute(webLoadModel.getUrl(), webLoadModel.getTitle(), webLoadModel.getRemaining_Description(), webLoadModel.getLead_image_url());
    }
}
