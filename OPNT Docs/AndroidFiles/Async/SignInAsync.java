package com.opinito.social.Async;

import android.content.Context;
import android.os.AsyncTask;
import android.text.TextUtils;

import com.opinito.social.BuildConfig;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.HttpRequest;
import com.opinito.social.Constants.Progress;
import com.opinito.social.Interface.CommonInterface;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

/**
 * Created by chanti on 6/14/2017.
 */

public class SignInAsync extends AsyncTask<String, Void, String> {
    Context mContext;
    Progress mprogress;
    Boolean progress;
    String response = "";
    CommonInterface commonInterface;

    public SignInAsync(Context context, CommonInterface commonInterface) {
        this.mContext = context;
        this.commonInterface = commonInterface;
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
            jsonObject.put("username", params[0]);
            jsonObject.put("password", params[1]);
            jsonObject.put("device_serial", getDeviceUniqueId());
            response = new HttpRequest(mContext).HttpPost(jsonObject, BuildConfig.SERVER_URL + Constants.userLogin);

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

    public String getDeviceUniqueId() {
        File folder = mContext.getExternalFilesDir("opinito"); // Folder Name
        File myFile = new File(folder, "data.txt"); // Filename
        String text = getdata(myFile);
        return !TextUtils.isEmpty(text) ? text : "";
    }

    private String getdata(File myfile) {
        FileInputStream fileInputStream = null;
        try {
            fileInputStream = new FileInputStream(myfile);
            int i = -1;
            StringBuffer buffer = new StringBuffer();
            while ((i = fileInputStream.read()) != -1) {
                buffer.append((char) i);
            }
            return buffer.toString();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (fileInputStream != null) {
                try {
                    fileInputStream.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
        return null;
    }
}
