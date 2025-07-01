package com.opinito.social.Activity;

import android.os.AsyncTask;
import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.FragmentManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.opinito.social.Adapter.UserPostAdapter;
import com.opinito.social.Async.CommonAsync;
import com.opinito.social.Async.UserPostDetailsAsync;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.Preference;
import com.opinito.social.Fragment.ActivityFragment;
import com.opinito.social.Fragment.BlockUserFragment;
import com.opinito.social.Fragment.FeedFragment;
import com.opinito.social.Fragment.ProfileFragment;
import com.opinito.social.Fragment.ReportDialogFragment;
import com.opinito.social.Interface.CommonInterface;
import com.opinito.social.Interface.OnLoadMoreListener;
import com.opinito.social.Model.PostDetailsModel;
import com.opinito.social.Model.WebLoadModel;
import com.opinito.social.PostModelClass;
import com.opinito.social.R;
import com.opinito.social.Utils.Customize;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Objects;

/**
 * Created by 502687702 on 7/17/2017.
 */

public class UserPostDetails extends AppCompatActivity implements ReportDialogFragment.DialogListener, BlockUserFragment.BlockDialogListener {

    ArrayList<PostDetailsModel> userPostDetailsModelArrayList;
    private LayoutInflater mInflater;
    RecyclerView recyclerView;
    TextView noPostTxt;
    UserPostAdapter mAdapter;
    int startrange = 0;
    int endrange = 5;
    int topicid = 0;
    public static int loadProgress = 0;
    private final String TOPICNAME = "topicname";
    private final String TYPE = "type";
    public static ArrayList<WebLoadModel> webLoadModelArrayList = new ArrayList<>();
    android.os.Handler handler;
    private String type = "";
    public static String postIdRemoveUser = "";

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.userpostdetails);
        noPostTxt = findViewById(R.id.tv_noPost);

        String topicName = getIntent().getStringExtra(TOPICNAME);
        type = getIntent().getStringExtra(TYPE);
        if (topicName != null || !topicName.equals("")) {
            if (type.equals(Constants.profilePosts))
                Customize.customSupportBar(this, Objects.requireNonNull(getSupportActionBar()), getString(R.string.my_posts), topicName);
            else  if (type.equals(Constants.myBookmark))
                Customize.customSupportBar(this, Objects.requireNonNull(getSupportActionBar()), getString(R.string.my_bookmarks), topicName);
            else
                Customize.customSupportBar(this, Objects.requireNonNull(getSupportActionBar()), getString(R.string.my_comments), topicName);
        }

        loadProgress = 0;
        userPostDetailsModelArrayList = new ArrayList<>();
        mInflater = LayoutInflater.from(getApplicationContext());
        recyclerView = findViewById(R.id.userpostdetails_recycler_view);
        RecyclerView.LayoutManager mLayoutManager = new LinearLayoutManager(getApplicationContext());
        recyclerView.setLayoutManager(mLayoutManager);
        mAdapter = new UserPostAdapter(userPostDetailsModelArrayList, UserPostDetails.this, recyclerView, this, type);
        recyclerView.setAdapter(mAdapter);
        topicid = new Preference(getApplicationContext()).getIntPref("posttopic");
        mAdapter.setOnLoadMoreListener(new OnLoadMoreListener() {
            @Override
            public void onLoadMore() {
                startrange = startrange + 5;
                endrange = endrange;
                if (userPostDetailsModelArrayList.size() > 0) {
                    userPostDetailsModelArrayList.add(null);
                    mAdapter.notifyItemInserted(userPostDetailsModelArrayList.size() - 1);
                    DisplayPost(topicid, true);
                }else{

                }
            }
        });
        DisplayPost(topicid, false);
    }

    public void DeletePost(String postid) {
        CommonInterface commonInterface = new CommonInterface() {
            @Override
            public void OnCommonInterface(String response) {
                String status = "";
                try {
                    status = new JSONObject(response).getString("status");
                    if (status.equalsIgnoreCase(Constants.SUCCESS)) {
                        startrange = 0;
                        endrange = 5;
                        FeedFragment.load = false;
                        ProfileFragment.reload = true;
                        ActivityFragment.refresh = true;
                        userPostDetailsModelArrayList.clear();
                        UserPostDetails.super.onBackPressed();
                        /*DisplayPost(new Preference(getApplicationContext()).getIntPref("posttopic"),false);*/
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        };
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("userid", new Preference(getApplicationContext()).getPref(Constants.USERID));
            jsonObject.put("postid", postid);
            new CommonAsync(UserPostDetails.this, commonInterface, jsonObject).execute(Constants.deletePost);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void showConfirmation(String postId) {
        AlertDialog.Builder dialogBuilder = new AlertDialog.Builder(this, R.style.MyCustomDialogTheme);
        LayoutInflater inflater = this.getLayoutInflater();
        final View dialogView = inflater.inflate(R.layout.confirm_dialog, null);
        dialogBuilder.setView(dialogView);
        final TextView dialogText = dialogView.findViewById(R.id.top_tv);
        final TextView descText = dialogView.findViewById(R.id.description_tv);
        descText.setVisibility(View.VISIBLE);
        final Button btnYes = dialogView.findViewById(R.id.btnyes);
        btnYes.setText(getString(R.string.ok));
        final Button btnCancel = dialogView.findViewById(R.id.btncancel);
        btnCancel.setText(getString(R.string.cancel));
        final AlertDialog alertDialog = dialogBuilder.create();
        dialogText.setText(getString(R.string.confirmation));
        descText.setText(getString(R.string.deletepost));
        btnYes.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                alertDialog.dismiss();
                DeletePost(postId);
            }
        });
        btnCancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                alertDialog.dismiss();
            }
        });
        alertDialog.setCancelable(false);
        alertDialog.setCanceledOnTouchOutside(false);
        alertDialog.show();
    }

    public void DisplayPost(int topicid, final Boolean loadmore) {

        if (!loadmore) {
            userPostDetailsModelArrayList.clear();
            webLoadModelArrayList.clear();
        }

        CommonInterface commonInterface = new CommonInterface() {
            @Override
            public void OnCommonInterface(String response) {
                if (response.equalsIgnoreCase("[]")) {
                    if(type.equalsIgnoreCase(Constants.myCommentPosts))
                        noPostTxt.setText("No Comment Yet to Show ");
                    if(type.equalsIgnoreCase(Constants.myBookmark))
                        noPostTxt.setText("No Bookmark Yet to Show ");
                    else
                        noPostTxt.setText("No Post Yet to Show ");
                } else {
                    if (loadmore) {
                        userPostDetailsModelArrayList.remove(userPostDetailsModelArrayList.size() - 1);
                        mAdapter.notifyItemRemoved(userPostDetailsModelArrayList.size());
                    }
                    try {
                        JSONArray jsonArray = new JSONArray(response);
                        if (jsonArray.length() > 0) {
                            for (int i = 0; i < jsonArray.length(); i++) {
                                JSONObject postObj = (JSONObject) jsonArray.get(i);
                                PostDetailsModel postDetailsModel;
                                if(type.equals(Constants.myBookmark))
                                {
                                    postDetailsModel = new PostDetailsModel(
                                            postObj.getLong("POST_ID"),
                                            postObj.getInt("TOPICID"),
                                            postObj.getString("POST_DATETIME"),
                                            null,
                                            postObj.getString("POST_BY_USERNAME"),
                                            postObj.getString("MEDIA_CONTENT"),
                                            postObj.getString("MEDIA_FLAG"),
                                            null,
                                            null,
                                            postObj.getString("LCOUNT"),
                                            postObj.getString("HCOUNT"),
                                            null,
                                            null,
                                            postObj.getString("POST_COMMENT_COUNT"),
                                            postObj.getString("POST_CONTENT"),
                                            postObj.getString("BKMK_FLAG"),
                                            PostModelClass.getPostCellModel(postObj.getString("POST_CONTENT")));
                                }else {
                                    postDetailsModel = new PostDetailsModel(
                                            postObj.getLong("POST_ID"),
                                            postObj.getInt("TOPICID"),
                                            postObj.getString("POST_DATETIME"),
                                            null,
                                            postObj.getString("USERNAME"),
                                            postObj.getString("MEDIA_CONTENT"),
                                            postObj.getString("MEDIA_FLAG"),
                                            postObj.getString("DP_URL"),
                                            null,
                                            postObj.getString("LCOUNT"),
                                            postObj.getString("HCOUNT"),
                                            null,
                                            null,
                                            postObj.getString("POST_COMMENT_COUNT"),
                                            postObj.getString("POST_CONTENT"),
                                            "",
                                            PostModelClass.getPostCellModel(postObj.getString("POST_CONTENT")));
                                }
                                userPostDetailsModelArrayList.add(postDetailsModel);
                            }
                            mAdapter.notifyDataSetChanged();
                            recyclerView.invalidate();
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        };
        new UserPostDetailsAsync(UserPostDetails.this, commonInterface, String.valueOf(topicid),
                new Preference(getApplicationContext()).getPref(Constants.USERID),
                String.valueOf(startrange), String.valueOf(endrange), type, mAdapter)
                .executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
    }

    public void showRemoveFrag(String postId) {
        postIdRemoveUser = postId;
        try {
            FragmentManager fm = getSupportFragmentManager();
            ReportDialogFragment reportDialogFragment = new ReportDialogFragment(this);
            ReportDialogFragment.TYPE = getString(R.string.post_type);
            ReportDialogFragment.POSTID = postId;
            reportDialogFragment.show(fm, "ReportDialogFragment");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    @Override
    public void onBlockClicked() {
        FragmentManager fm = getSupportFragmentManager();
        BlockUserFragment reportDialogFragment = new BlockUserFragment(this);
        BlockUserFragment.CONTENTID = postIdRemoveUser;
        BlockUserFragment.TYPE = getString(R.string.post_type);
        reportDialogFragment.show(fm, "BlockUserFragment");
    }

    @Override
    public void onCompleteBlock(String type) {
        DisplayPost(topicid, false);
    }

    @Override
    public void onKickOut() {

    }

    @Override
    public void onNavBackCliked() {
        if (!postIdRemoveUser.equals(".. .."))
            showRemoveFrag(postIdRemoveUser);
    }

    @Override
    public void onCompleteReport(String type) {
        DisplayPost(topicid, false);
    }
}
