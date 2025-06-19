package com.opinito.social.Async;

import android.content.Context;
import android.os.AsyncTask;
import android.util.Log;

import com.opinito.social.BuildConfig;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.HttpRequest;
import com.opinito.social.Constants.Progress;
import com.opinito.social.Interface.CommonInterface;

import org.json.JSONException;
import org.json.JSONObject;

/**
 * Created by bhaskar on 7/22/17.
 */

public class ValidateUserKeyWordAsyncTask extends AsyncTask<String, Void, String> {
    Context mContext;
    Progress mprogress;
    String response = "";
    CommonInterface commonInterface;

    public ValidateUserKeyWordAsyncTask(Context context, CommonInterface commonInterface) {
        this.commonInterface = commonInterface;
        this.mContext = context;

    }

    @Override
    protected void onPreExecute() {
        mprogress = new Progress(mContext);
        super.onPreExecute();
    }

    @Override
    protected String doInBackground(String... params) {
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("userid", params[0]);
            jsonObject.put("topicid", Integer.parseInt(params[1]));
            jsonObject.put("userKW", params[2]);
            response = new HttpRequest(mContext).HttpPost(jsonObject, BuildConfig.SERVER_URL + Constants.checkValidity);

        } catch (JSONException e) {
            e.printStackTrace();
        }
        return response;
    }

    @Override
    protected void onPostExecute(String s) {
        mprogress.ProgressDismiss();
        commonInterface.OnCommonInterface(response);
        super.onPostExecute(s);
    }


}
