package com.opinito.social.Async;

import android.content.Context;
import android.os.AsyncTask;

import com.opinito.social.BuildConfig;
import com.opinito.social.Constants.HttpRequest;
import com.opinito.social.Interface.CommonInterface;

import org.json.JSONObject;

import java.util.Map;

/**
 * Created by chanti on 8/8/2017.
 */

public class CommonAsync extends AsyncTask<String, Void, String> {
    Context mContext;
    Boolean progress;
    String response = "";
    CommonInterface commonInterface;
    JSONObject jsonObject;


    public CommonAsync(Context context, CommonInterface commonInterface,JSONObject jsonObject) {
        this.mContext = context;
        this.commonInterface = commonInterface;
        this.jsonObject = jsonObject;

    }

    @Override
    protected void onPreExecute() {
        super.onPreExecute();
    }

    @Override
    protected String doInBackground(String... params) {
        try {

            response = new HttpRequest(mContext).HttpPost(jsonObject, BuildConfig.SERVER_URL + params[0]);

        } catch (Exception e) {

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
