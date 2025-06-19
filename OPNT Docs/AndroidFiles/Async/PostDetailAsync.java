package com.opinito.social.Async;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.os.AsyncTask;
import android.util.Patterns;

import com.google.gson.JsonObject;
import com.mega4tech.linkpreview.GetLinkPreviewListener;
import com.mega4tech.linkpreview.LinkPreview;
import com.mega4tech.linkpreview.LinkUtil;
import com.opinito.social.Adapter.PostAdapter;
import com.opinito.social.BuildConfig;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.Preference;
import com.opinito.social.Constants.Progress;
import com.opinito.social.Fragment.FeedFragment;
import com.opinito.social.Interface.CommonInterface;
import com.opinito.social.Interface.RetrofitNetworkInterface;
import com.opinito.social.LinkService;
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
 * Created by 502687702 on 7/6/2017.
 */

public class PostDetailAsync extends AsyncTask<String, Void, String> {
    @SuppressLint("StaticFieldLeak")
    private Activity mContext;
    private String response = "";
    private CommonInterface commonInterface;
    private String topicId, userId, fromIndex, toIndex;
    private PostAdapter postAdapter;
    private Boolean loadMore;

    public PostDetailAsync(Activity context, CommonInterface commonInterface, String topicId, String userId, String fromIndex, String toIndex,
                           PostAdapter postAdapter, Boolean loadMore) {
        this.mContext = context;
        this.commonInterface = commonInterface;
        this.topicId = topicId;
        this.userId = userId;
        this.fromIndex = fromIndex;
        this.toIndex = toIndex;
        this.postAdapter = postAdapter;
        this.loadMore = loadMore;
    }

    @Override
    protected void onPreExecute() {
        super.onPreExecute();
    }

    @Override
    protected String doInBackground(String... params) {
        Call<ResponseBody> call;
        RetrofitNetworkInterface retrofitNetworkInterface = RetrofitClient.createService(RetrofitNetworkInterface.class);
        try {
            JsonObject jsonObject = new JsonObject();
            jsonObject.addProperty("topicid", topicId);
            jsonObject.addProperty("userid", userId);
            jsonObject.addProperty("from", fromIndex);
            jsonObject.addProperty("to", toIndex);
            Map<String, String> header = new HashMap<>();
            header.put("X-ACCESS-KEY", BuildConfig.APP_ID);
            header.put("Token", new Preference(getApplicationContext()).getPref(Constants.token));
            if (new Preference(mContext).getPref(Constants.instream).equals(Constants.instreamNW))
                call = retrofitNetworkInterface.getInstreamNW(header ,jsonObject);
            else
                call = retrofitNetworkInterface.getInstreamAnti(header ,jsonObject);
            try {
                response = Objects.requireNonNull(call.execute().body()).string();
                if (!response.isEmpty()){
                }
            } catch (IOException ex) {
                ex.printStackTrace();
            }
            try {
                JSONArray jsonArray = new JSONArray(response);
                if (jsonArray.length() > 0) {
                    if (!loadMore){
                        FeedFragment.webLoadModelArrayList.clear();
                        FeedFragment.postDetailsModelArrayList.clear();

                    }
                    for (int i = 0; i < jsonArray.length(); i++) {
                        final JSONObject postObj = (JSONObject) jsonArray.get(i);
                        try {
                            if (postObj.getString("POST_CONTENT").contains("/")) {
                                LinkUtil.getInstance().getLinkPreview(mContext, extractLinks(postObj.getString("POST_CONTENT"))[0], new GetLinkPreviewListener() {
                                    @Override
                                    public void onSuccess(final LinkPreview link) {
                                        WebLoadModel webLoadModel = null;
                                        try {
                                            String postContent = postObj.getString("POST_CONTENT");
                                            webLoadModel = new WebLoadModel(link.getTitle(),
                                                    link.getImageLink(), link.getLink(), link.getDescription(),
                                                    postObj.getLong("POST_ID"), postContent.substring(extractLinks(postObj.getString("POST_CONTENT"))[0].length()));
                                        } catch (JSONException e) {
                                            e.printStackTrace();
                                        }
                                        FeedFragment.webLoadModelArrayList.add(webLoadModel);
                                        mContext.runOnUiThread(new Runnable() {
                                            @Override
                                            public void run() {
                                                if (postAdapter != null) {
                                                    postAdapter.notifyDataSetChanged();
                                                }
                                            }
                                        });
                                        checkAndPostLinkPreviewForUrl(link.getLink(), webLoadModel);
                                    }

                                    @Override
                                    public void onFailed(final Exception e) {
                                    }
                                });
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return response;
    }

    private synchronized void checkAndPostLinkPreviewForUrl(String link, WebLoadModel webLoadModel) {
        Intent intent = new Intent(mContext, LinkService.class);
        intent.putExtra("webmodelObj", webLoadModel);
        intent.putExtra("linkPreviewUrl", link);
        mContext.startService(intent);
    }

    @Override
    protected void onPostExecute(String s) {
        if (FeedFragment.loadProgress == 0) {
            FeedFragment.loadProgress = 1;
        }
        commonInterface.OnCommonInterface(response);
        super.onPostExecute(s);
    }

    public static String[] extractLinks(String text) {
        List<String> links = new ArrayList<String>();
        Matcher m = Patterns.WEB_URL.matcher(text);
        while (m.find()) {
            String url = m.group();
            links.add(url);
        }
        return links.toArray(new String[links.size()]);
    }

}

