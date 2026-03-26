package com.opinito.social.Async;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.os.AsyncTask;
import android.util.Log;
import android.util.Patterns;

import com.google.gson.JsonObject;
import com.mega4tech.linkpreview.GetLinkPreviewListener;
import com.mega4tech.linkpreview.LinkPreview;
import com.mega4tech.linkpreview.LinkUtil;
import com.opinito.social.Activity.UserPostDetails;
import com.opinito.social.Adapter.UserPostAdapter;
import com.opinito.social.BuildConfig;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.HttpRequest;
import com.opinito.social.Constants.Preference;
import com.opinito.social.Constants.Progress;
import com.opinito.social.Interface.CommonInterface;
import com.opinito.social.Interface.RetrofitNetworkInterface;
import com.opinito.social.Model.WebLoadModel;
import com.opinito.social.RetrofitClient;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.regex.Matcher;

import okhttp3.ResponseBody;
import retrofit2.Call;

import static com.facebook.FacebookSdk.getApplicationContext;

/**
 * Created by 502687702 on 7/17/2017.
 */

public class UserPostDetailsAsync extends AsyncTask<String, Void, String> {
    @SuppressLint("StaticFieldLeak")
    private Activity mContext;
    private Progress mprogress;
    private String response = "";
    private CommonInterface commonInterface;
    private UserPostAdapter userPostAdapter;
    private String topicId, userId, fromIndex, toIndex, type;
    private Call<ResponseBody> call;

    public UserPostDetailsAsync(Activity context, CommonInterface commonInterface, String topicId, String userId,
                                String fromIndex, String toIndex, String type, UserPostAdapter userPostAdapter) {
        this.mContext = context;
        this.commonInterface = commonInterface;
        this.userPostAdapter = userPostAdapter;
        this.topicId = topicId;
        this.userId = userId;
        this.fromIndex = fromIndex;
        this.toIndex = toIndex;
        this.type = type;
    }

    @Override
    protected void onPreExecute() {
        if (UserPostDetails.loadProgress == 0) {
            mprogress = new Progress(mContext);
        }
        super.onPreExecute();
    }

    @Override
    protected String doInBackground(String... params) {
        try {
            RetrofitNetworkInterface retrofitNetworkInterface = RetrofitClient.createService(RetrofitNetworkInterface.class);
            JsonObject jsonObject = new JsonObject();
            jsonObject.addProperty("userid", userId);
            jsonObject.addProperty("topicid", topicId);
            jsonObject.addProperty("from", fromIndex);
            jsonObject.addProperty("to", toIndex);
            Map<String, String> header = new HashMap<>();
            header.put("X-ACCESS-KEY", BuildConfig.APP_ID);
            header.put("Token", new Preference(getApplicationContext()).getPref(Constants.token));
            if (type.equals(Constants.profilePosts))
                call = retrofitNetworkInterface.profilePosts(header ,jsonObject);
            else if (type.equals(Constants.myBookmark))
                call = retrofitNetworkInterface.MyBookmarks(header ,jsonObject);
            else call = retrofitNetworkInterface.commentPosts(header , jsonObject);
            try {
                response = Objects.requireNonNull(call.execute().body()).string();
            } catch (IOException ex) {
                ex.printStackTrace();
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return response;
    }

    @Override
    protected void onPostExecute(String s) {
        if (UserPostDetails.loadProgress == 0) {
            if (mprogress != null) {
                mprogress.ProgressDismiss();
            }
            UserPostDetails.loadProgress = 1;
        }
        commonInterface.OnCommonInterface(response);
        super.onPostExecute(s);
    }
}
