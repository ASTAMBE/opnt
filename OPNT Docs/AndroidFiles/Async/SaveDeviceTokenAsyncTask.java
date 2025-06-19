package com.opinito.social.Async;

import android.content.Context;
import android.os.AsyncTask;
import android.util.Log;

import com.opinito.social.BuildConfig;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.HttpRequest;
import com.opinito.social.Constants.Progress;
import com.opinito.social.Fragment.FeedFragment;
import com.opinito.social.Interface.CommonInterface;

import org.json.JSONException;
import org.json.JSONObject;

/**
 * Created by bhaskar on 7/22/17.
 */

public class SaveDeviceTokenAsyncTask extends AsyncTask<String, Void, String> {
    Context mContext;
    Progress mprogress;
    Boolean progress;
    String response = "";
    CommonInterface commonInterface;

    public SaveDeviceTokenAsyncTask(Context context, CommonInterface commonInterface) {
        this.commonInterface = commonInterface;
        this.mContext = context;
    }

    @Override
    protected void onPreExecute() {
        super.onPreExecute();
    }

    @Override
    protected String doInBackground(String... params) {
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("device_token", params[0]);
            jsonObject.put("device_uuid",params[1]);
            response = new HttpRequest(mContext).HttpPost(jsonObject, BuildConfig.SERVER_URL + Constants.app_send_token_url);

        } catch (JSONException e) {
            e.printStackTrace();
        }
        return response;
    }

    @Override
    protected void onPostExecute(String s) {
        if (FeedFragment.loadProgress == 0) {
            if(mprogress != null)
                mprogress.ProgressDismiss();
            FeedFragment.loadProgress = 1;
        }
        commonInterface.OnCommonInterface(response);
        super.onPostExecute(s);
    }
}
