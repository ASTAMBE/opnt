package com.opinito.social.Async;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.AsyncTask;

import com.opinito.social.BuildConfig;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.HttpRequest;
import com.opinito.social.Interface.CommonInterface;

import org.json.JSONException;
import org.json.JSONObject;

/**
 * Created by bhaskar on 7/22/17.
 */

public class CheckLinkExistsAsyncTask extends AsyncTask<String, Void, String> {
    @SuppressLint("StaticFieldLeak")
    Context mContext;
    String response = "";
    CommonInterface commonInterface;

    public CheckLinkExistsAsyncTask(Context context, CommonInterface commonInterface) {
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
            jsonObject.put("url", params[0]);
            response = new HttpRequest(mContext).HttpPost(jsonObject, BuildConfig.SERVER_URL + Constants.checkLinkPreviewUrl);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return response;
    }

    @Override
    protected void onPostExecute(String s) {
        commonInterface.OnCommonInterface(response);
        super.onPostExecute(s);
    }

}
