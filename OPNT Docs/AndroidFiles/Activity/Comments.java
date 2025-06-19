package com.opinito.social.Activity;

import static com.opinito.social.Fragment.FeedFragment.commentedPostPosition;
import static com.opinito.social.Fragment.FeedFragment.postDetailsModelArrayList;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.ComponentName;
import android.content.Intent;
import android.content.ServiceConnection;
import android.content.res.ColorStateList;
import android.graphics.drawable.GradientDrawable;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.IBinder;
import android.text.Editable;
import android.text.Html;
import android.text.TextWatcher;
import android.text.method.LinkMovementMethod;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.browser.customtabs.CustomTabsIntent;
import androidx.core.content.ContextCompat;
import androidx.core.text.HtmlCompat;
import androidx.fragment.app.FragmentManager;
import androidx.recyclerview.widget.DefaultItemAnimator;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.bitmap.CircleCrop;
import com.bumptech.glide.load.resource.bitmap.RoundedCorners;
import com.google.android.material.appbar.AppBarLayout;
import com.google.gson.JsonObject;
import com.opinito.social.Adapter.CommentsAdapter;
import com.opinito.social.Adapter.FeedPostImagesAdapter;
import com.opinito.social.Adapter.SendImagesAdapter;
import com.opinito.social.Async.CommonAsync;
import com.opinito.social.BuildConfig;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.Preference;
import com.opinito.social.Constants.TextViewClickMovement;
import com.opinito.social.Fragment.ActivityFragment;
import com.opinito.social.Fragment.BlockUserFragment;
import com.opinito.social.Fragment.FeedFragment;
import com.opinito.social.Fragment.LoveHateUsersListFragment;
import com.opinito.social.Fragment.ReportDialogFragment;
import com.opinito.social.Interface.CommentsInterface;
import com.opinito.social.Interface.CommonInterface;
import com.opinito.social.Interface.ImageInterface;
import com.opinito.social.Interface.RetrofitNetworkInterface;
import com.opinito.social.Model.BaseResponse;
import com.opinito.social.Model.CommentCountModel;
import com.opinito.social.Model.CommentModel;
import com.opinito.social.Model.GetPostModelNew;
import com.opinito.social.Model.PostDetailsModel;
import com.opinito.social.PostModelClass;
import com.opinito.social.R;
import com.opinito.social.RetrofitClient;
import com.opinito.social.Utils.ColorChange;
import com.opinito.social.Utils.CompressVideo.BoundService;
import com.opinito.social.Utils.CompressVideo.ChangeInProgress;
import com.opinito.social.Utils.CompressVideo.RxBus;
import com.opinito.social.Utils.Compressor;
import com.opinito.social.Utils.Customize;
import com.opinito.social.Utils.DynamicLinksUtil;
import com.opinito.social.Utils.EmbeddedContent;
import com.opinito.social.Utils.ExtractWebURLPreview;
import com.opinito.social.Utils.FileUtil;
import com.opinito.social.Utils.LinePagerIndicatorDecoration;
import com.opinito.social.Utils.RecyclerUtils;
import com.opinito.social.Utils.SoftKeypad;
import com.opinito.social.Utils.TextViewResizable;
import com.opinito.social.Utils.TimeUtils;
import com.opinito.social.Utils.UserUtils;
import com.opinito.social.databinding.ActivityCommentBinding;

import org.json.JSONObject;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.CompositeDisposable;
import io.reactivex.functions.Consumer;
import io.reactivex.schedulers.Schedulers;
import okhttp3.MediaType;
import okhttp3.MultipartBody;
import okhttp3.RequestBody;
import okhttp3.ResponseBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

/**
 * Created by 502687702 on 8/8/2017.
 */

public class Comments extends AppCompatActivity
implements ImageInterface, View.OnTouchListener, CommentsInterface, View.OnClickListener,
TextViewClickMovement.OnTextViewClickMovementListener, SwipeRefreshLayout.OnRefreshListener,
ReportDialogFragment.DialogListener, BlockUserFragment.BlockDialogListener {
    private CommentsAdapter mAdapter;
    public static Boolean isEdit = false;
    public static String commentId = "";
    public static PostDetailsModel postDetail = null;
    private int howManyComments = 0;
    private static final String POSTCONTENT = "postcontent";
    public Boolean lorh = false;
    private static final String POSTID = "postid";
    public ActivityCommentBinding binding;
    private static final String ONE = "1";
    private static final String ZERO = "0";
    private int REQUEST_MULTIPLE_FILES = 1;
    private String destPath = "";
    private SendImagesAdapter sendImagesAdapter;
    private Dialog mBottomSheetDialog;

    private List<Uri> imagesUri = new ArrayList<>();
    private List<File> fileList = new ArrayList<>();
    private List<CommentModel.Data> commentsList = new ArrayList<>();
    private View view;
    private CommentsInterface commentsInterface;
    private String commentsType = "Like-Minded - %s";
    private Call<CommentModel> call;
    private Call<BaseResponse> commentCall;
    private static final int REQUEST_FOR_VIDEO_FILE = 1000;
    private RxBus rxBus;
    private BoundService boundService;
    private CompositeDisposable disposables;
    private final String DESTPATH = "destPath";
    private final String INPUTPATH = "inputDest";
    private String IMAGELIST = "imageslist";
    private String IMAGEPOSITION = "imagePosition";
    private final String TOPICID = "topicid";
    private final String USERNAME = "username";
    private final String PROFILEIMAGE = "profileimage";
    private Boolean isBound = false;
    public static String postIdRemoveUser = "";
    public static String KOType = "";
    private int currentSize = 0;
    private int nextLimit = 1;
    private boolean isLoading = true;
    public static String postid = "";
    public static boolean isComment = true;
    private AlertDialog.Builder alertDialog;
    private AlertDialog alert;
    private int count = 0;
    private int popupCount = 0;


    String position = "";

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityCommentBinding.inflate(getLayoutInflater());
        View view = binding.getRoot();
        setContentView(view);
        alertDialog = new AlertDialog.Builder(this);
        //FeedFragment.refresh = false;
        commentsInterface = this;
        position = getIntent().getStringExtra(POSTCONTENT);
        lorh = getIntent().getExtras().getBoolean("L_or_H");
        Customize.customSupportBar(this, Objects.requireNonNull(getSupportActionBar()),
            getString(R.string.discussion), null);
        try {
            postDetail = (PostDetailsModel) getIntent().getSerializableExtra(POSTCONTENT);
            init();
            binding.mainLayout.setVisibility(View.VISIBLE);
        } catch (Exception e) {
            binding.errorText.setOnClickListener(this);
            getPostDetail();
        }
    }

    private void getPostDetail() {
        try {
            Bundle bundle = getIntent().getExtras();
            if (bundle != null) {
                try {
                    postid = bundle.getString("sourceId");
                    if (!bundle.getString(Constants.USERNAME).equals(new Preference(this).getPref(Constants.USERNAME))) {
                        new Preference(this).savePref(Constants.NOTIFUSERNAME, bundle.getString(Constants.USERNAME));
                        UserUtils.showUserConfirmation(this, bundle.getString(Constants.USERNAME), postid);
                    }
                } catch (Exception e) {
                    postid = getIntent().getStringExtra(POSTID);
                }
            } else {
                if (new Preference(this).getPref(Constants.NOTIFUSERNAME)
                        .equals(new Preference(this).getPref(Constants.USERNAME))) {
                    postid = new Preference(this).getPref(Constants.NOTIFPOSTID);
                    new Preference(this).savePref(Constants.NOTIFPOSTID, "");
                    new Preference(this).savePref(Constants.NOTIFUSERNAME, "");
                } else {
                    UserUtils.showUserConfirmation(this, bundle.getString(Constants.USERNAME),
                        new Preference(this).getPref(Constants.NOTIFPOSTID));
                }
            }
            RetrofitNetworkInterface retrofitNetworkInterface = RetrofitClient.createService(RetrofitNetworkInterface.class);
            JsonObject getPostDetailReq = new JsonObject();
            getPostDetailReq.addProperty("userid", new Preference(Comments.this).getPref(Constants.USERID));
            getPostDetailReq.addProperty("postid", postid);
            Map<String, String> header = new HashMap<>();
            header.put("X-ACCESS-KEY", BuildConfig.APP_ID);
            header.put("Token", new Preference(getApplicationContext()).getPref(Constants.token));
            Call<GetPostModelNew> call = retrofitNetworkInterface.getPostDetails(header, getPostDetailReq);
            call.enqueue(new Callback<GetPostModelNew>() {
                @Override
                public void onResponse(Call<GetPostModelNew> call, Response<GetPostModelNew> response) {
                    if (response.code() == 200) {
                        if (response.body().getStatus().equals(getString(R.string.success_status))) {
                            if (response.body().getData().size() > 0) {
                                postDetail = new PostDetailsModel(
                                        Long.parseLong(response.body().getData().get(0).getPOSTID()),
                                Integer.parseInt(response.body().getData().get(0).getTOPICID()),
                                response.body().getData().get(0).getPOSTDATETIME(),
                                response.body().getData().get(0).getPOSTBYUSERID(),
                                response.body().getData().get(0).getUSERNAME(),
                                response.body().getData().get(0).getMEDIACONTENT(),
                                response.body().getData().get(0).getMEDIAFLAG(),
                                response.body().getData().get(0).getDPURL() != null ? response.body().getData().get(0).getDPURL().toString() : "",
                                response.body().getData().get(0).getTOTALNS(),
                                response.body().getData().get(0).getLCOUNT(),
                                response.body().getData().get(0).getHCOUNT(),
                                response.body().getData().get(0).getPOSTACTIONTYPE() != null ? response.body().getData().get(0).getPOSTACTIONTYPE().toString() : "",
                                response.body().getData().get(0).getUUACTION(),
                                response.body().getData().get(0).getPOSTCOMMENTCOUNT(),
                                response.body().getData().get(0).getPOSTCONTENT(),
                                response.body().getData().get(0).getBookmark(),
                                PostModelClass.getPostCellModel(response.body().getData().get(0).getPOSTCONTENT()));
                                init();
                                binding.mainLayout.setVisibility(View.VISIBLE);
                            }
                        } else {
                            binding.mainLayout.setVisibility(View.GONE);
                            binding.errorText.setVisibility(View.VISIBLE);
                        }
                    }
                }

                @Override
                public void onFailure(Call<GetPostModelNew> call, Throwable t) {
                    binding.mainLayout.setVisibility(View.GONE);
                    binding.errorText.setVisibility(View.VISIBLE);
                    Toast.makeText(Comments.this, getString(R.string.internal_error_occured), Toast.LENGTH_SHORT).show();
                }
            });
        } catch (Exception e) {
            binding.mainLayout.setVisibility(View.GONE);
            binding.errorText.setVisibility(View.VISIBLE);
            new Preference(this).savePref(Constants.NOTIFPOSTID, "");
            new Preference(this).savePref(Constants.NOTIFUSERNAME, "");
            Toast.makeText(Comments.this, getString(R.string.internal_error_occured), Toast.LENGTH_SHORT).show();
        }
    }

    private void init() {
        /* if (new Preference(getApplicationContext()).getIntPref(Constants.HOWTOUSE) == 0) {
             FeedFragment.load = false;
             Intent intent = new Intent(this, HowToUseActivity.class);
             startActivity(intent);
         }*/
        rxBus = new RxBus();
        disposables = new CompositeDisposable();
        boundService = new BoundService();
        binding.commentEdittext.setHint(HtmlCompat.fromHtml(String.format(getString(R.string.comment_hint),
            new Preference(this).getPref(Constants.USERNAME)), HtmlCompat.FROM_HTML_SEPARATOR_LINE_BREAK_LIST_ITEM));
        binding.statusTextParentPost.setText(String.valueOf(postDetail.getUSERNAME().charAt(0)));
        GradientDrawable background = (GradientDrawable) binding.statusChangeLayoutParentPost.getBackground();
        background.setColor(new ColorChange(this).colorChange(String.valueOf(postDetail.getUSERNAME().toLowerCase().charAt(0))));
        binding.statusImageParentPost.setVisibility(View.VISIBLE);
        binding.postCommentView.addOnScrollListener(new RecyclerView.OnScrollListener() {
            @Override
            public void onScrolled(@NonNull RecyclerView recyclerView, int dx, int dy) {
                super.onScrolled(recyclerView, dx, dy);
                final LinearLayoutManager linearLayoutManager = (LinearLayoutManager) binding.postCommentView.getLayoutManager();
                if (!isLoading) {
                    if (linearLayoutManager != null && linearLayoutManager.findLastCompletelyVisibleItemPosition() ==
                        commentsList.size() - 1) {
                        displayComments(commentsType, true);
                        isLoading = true;
                    }
                }
            }
        });
        binding.postCommentView.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                switch (event.getAction()) {
                    case MotionEvent.ACTION_SCROLL:
                    case MotionEvent.ACTION_MOVE:
                    binding.addMediaToComment.setVisibility(View.GONE);
//                    binding.commentEdittext.setVisibility(View.GONE);
                    break;
                    case MotionEvent.ACTION_CANCEL:
                    case MotionEvent.ACTION_UP:
                    binding.addMediaToComment.setVisibility(View.VISIBLE);
                    binding.commentEdittext.setVisibility(View.VISIBLE);
                    break;
                }
                return false;
            }
        });
        try {
            Glide.with(this)
                .load(postDetail.getDP_URL())
                .transform(new CircleCrop(),
                    new RoundedCorners(5))
                .into(binding.statusImageParentPost);
        } catch (Exception e) {
            e.printStackTrace();
        }
        if (postDetail.getPOST_ACTION_TYPE() == null) {
            postDetail.setPOST_ACTION_TYPE("");
        }
        if (postDetail.getPOST_ACTION_TYPE().toLowerCase().equalsIgnoreCase("l")) {
            binding.likeParentPostIv.setImageDrawable(getResources().getDrawable(R.drawable.ic_like_post_selected));
            binding.parentPostHate.setImageDrawable(getResources().getDrawable(R.drawable.ic_hate_post));
        } else if (postDetail.getPOST_ACTION_TYPE().toLowerCase().equalsIgnoreCase("h")) {
            binding.likeParentPostIv.setImageDrawable(getResources().getDrawable(R.drawable.ic_love_post));
            binding.parentPostHate.setImageDrawable(getResources().getDrawable(R.drawable.ic_hate_post_selected));
        } else {
            binding.likeParentPostIv.setImageDrawable(getResources().getDrawable(R.drawable.ic_love_post));
            binding.parentPostHate.setImageDrawable(getResources().getDrawable(R.drawable.ic_hate_post));
        }
        if (postDetail.getUSERNAME().equals(new Preference(getApplicationContext()).getPref(Constants.USERNAME))) {
            binding.editPostLayoutParentPost.setVisibility(View.VISIBLE);
            binding.removeUserParentPost.setVisibility(View.GONE);
        } else {
            binding.editPostLayoutParentPost.setVisibility(View.GONE);
            binding.removeUserParentPost.setVisibility(View.VISIBLE);
        }

        sendImagesAdapter = new SendImagesAdapter(this, imagesUri, this, getString(R.string.comments));
        binding.selectedImagesComments.setAdapter(sendImagesAdapter);
        binding.backArrow.setOnClickListener(this);
//        binding.allComments.setOnClickListener(this);
//        binding.networkComments.setOnClickListener(this);
        binding.appBarLayout.addOnOffsetChangedListener(new AppBarLayout.OnOffsetChangedListener() {
            @Override
            public void onOffsetChanged(AppBarLayout appBarLayout, int verticalOffset) {
                if (Math.abs(verticalOffset) - appBarLayout.getTotalScrollRange() == 0) {
                    binding.toolbar.setVisibility(View.VISIBLE);
                } else {
                    binding.toolbar.setVisibility(View.GONE);
                }
            }
        });
        binding.shareParentPost.setOnClickListener(this);
        binding.parentPostCommentIv.setOnClickListener(this);
        binding.clearAll.setOnClickListener(this);
        binding.likeCountParentPost.setOnClickListener(this);
        binding.hCountParentPost.setOnClickListener(this);
        binding.antiMindedLayout.setOnClickListener(this);
        binding.antiMindedLayoutToolbar.setOnClickListener(this);
        binding.likeMindedLayout.setOnClickListener(this);
        binding.likeMindedLayoutToolbar.setOnClickListener(this);
        binding.likeParentPostIv.setOnClickListener(this);
        binding.deleteParentPost.setOnClickListener(this);
        binding.closeReplyLayout.setOnClickListener(this);
        binding.parentPostHate.setOnClickListener(this);
        binding.sortByTv.setOnClickListener(this);
        binding.sortByTvToolbar.setOnClickListener(this);
        binding.addMediaToComment.setOnClickListener(this);
        binding.removeUserParentPost.setOnClickListener(this);
        binding.hintIv.setOnClickListener(this);
        binding.hintIvToolbar.setOnClickListener(this);
        binding.attachmentTv.setOnClickListener(this);
        binding.attachmentIv.setOnClickListener(this);
        //binding.swipeRefreshComments.setOnRefreshListener(this);
        binding.likeCountParentPost.setText(postDetail.getLCOUNT());
        binding.hCountParentPost.setText(postDetail.getHCOUNT());
        binding.previewImage.setOnClickListener(this);
        if (postDetail.getPOST_CONTENT() != null){
        binding.descriptionChildPost.setText(postDetail.getPOST_CONTENT()
            .replaceAll("(?m)(^ *| +(?= |$))", "")
            .replaceAll("(?m)^$([\r\n]+?)(^$[\r\n]+?^)+", "$1").trim());
        }
        if (postDetail.getBOOKMARK_FLAG() != null) {
            if (postDetail.getBOOKMARK_FLAG().equalsIgnoreCase("B")) {
                binding.bookmark.setImageDrawable(getResources().getDrawable(R.drawable.bookmark_click));
            }

        }
        if (postDetail.getPOST_CONTENT().trim().length() > 500)
            TextViewResizable.makeTextViewResizable(binding.descriptionChildPost, 5, "More", true);
        binding.commentCountParentPost.setText(
            postDetail.getPOST_COMMENT_COUNT().equals(getString(R.string.nulll)) ? ZERO : postDetail.getPOST_COMMENT_COUNT());
        howManyComments = Integer.parseInt(postDetail.getPOST_COMMENT_COUNT().equals(getString(R.string.nulll)) ? ZERO : postDetail.getPOST_COMMENT_COUNT());
        binding.usernameParentPost.setText(postDetail.getUSERNAME());
        binding.statusChangeLayoutParentPost.setOnClickListener(this);
        binding.updatedTimeParentPost.setText(new TimeUtils().time(postDetail.getPOST_DATETIME(), this));
        if (postDetail.getPOST_CONTENT().contains("/")) {
            new ExtractWebURLPreview(this, binding.webPreviewImage, binding.previewHeader, binding.previewDescription
            , binding.webPageImageLayout, binding.descriptionChildPost, this)
            .getPreview(postDetail.getPOST_CONTENT(), String.valueOf(postDetail.getPOST_ID()));
        }

        if (postDetail.getMEDIA_FLAG() != null) {
            if (postDetail.getMEDIA_FLAG().equals(getString(R.string.flay_Y))) {
                List<String> imageList = Arrays.asList(postDetail.getMEDIA_CONTENT().toString().split(","));
                if (ExtractWebURLPreview.extractLinks(postDetail.getPOST_CONTENT()).length == 1) {
                    binding.imageRecyclerParentPost.setVisibility(View.GONE);
                    binding.attachmentTv.setText(String.format(getString(R.string.attachment_count_text),
                        String.valueOf(imageList.size())));
                    binding.attachmentIv.setVisibility(View.VISIBLE);
                    binding.attachmentTv.setVisibility(View.VISIBLE);
                } else {
                    binding.imageRecyclerParentPost.setVisibility(View.VISIBLE);
                    FeedPostImagesAdapter feedPostImagesAdapter = new FeedPostImagesAdapter(this, imageList);
                    binding.imageRecyclerParentPost.setAdapter(feedPostImagesAdapter);
                    if (imageList.size() > 1)
                        binding.imageRecyclerParentPost.addItemDecoration(new LinePagerIndicatorDecoration());
                }
            }
        }
        binding.bookmark.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (binding.bookmark.getDrawable().getConstantState() == getApplicationContext().getResources().getDrawable(R.drawable.bookmark_click).getConstantState()) {
                    FeedFragment.removeBookmark(String.valueOf(postDetail.getPOST_ID()), binding.bookmark);
                    //postDetailsModelArrayList.get(getAdapterPosition()).setBOOKMARK_FLAG("");

                } else
                    FeedFragment.postBookmark(String.valueOf(postDetail.getPOST_ID()), binding.bookmark);
                //postDetailsModelArrayList.get(getAdapterPosition()).setBOOKMARK_FLAG("B");
                // }
            }
        });

        binding.commentEdittext.setOnTouchListener(this);
        binding.commentEdittext.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (s.toString().trim().length() > 0) {
                    binding.clearAll.setVisibility(View.VISIBLE);
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        binding.commentEdittext.setCompoundDrawableTintList(ColorStateList.valueOf(getResources().getColor(R.color.com_facebook_blue)));


                    } else {

                    }
                } else {
                    binding.clearAll.setVisibility(View.GONE);
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        binding.commentEdittext.setCompoundDrawableTintList(ColorStateList.valueOf(getResources().getColor(R.color.gray)));
                    }

                }
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });
        isEdit = false;
        RecyclerView.LayoutManager mLayoutManager = new LinearLayoutManager(getApplicationContext());
        binding.postCommentView.setLayoutManager(mLayoutManager);
        binding.postCommentView.setItemAnimator(new DefaultItemAnimator());

        RecyclerUtils.ScrollImageByOne scrollImageByOne = new RecyclerUtils.ScrollImageByOne();
        scrollImageByOne.attachToRecyclerView(binding.imageRecyclerParentPost);
        if (!postDetail.getPOST_COMMENT_COUNT().equals("null"))
            displayComments(commentsType, false);
        else
            getCommentCount();
        if (new Preference(this).getPref(Constants.SORTORDER).equals(Constants.OLDONTOP)) {
            binding.sortByTvToolbar.setText(getString(R.string.oldest));
            binding.sortByTv.setText(getString(R.string.oldest));
        } else {
            if (new Preference(this).getPref(Constants.SORTORDER).equals(Constants.NEWONTOP) ||
                new Preference(this).getPref(Constants.SORTORDER).isEmpty()) {
                binding.sortByTvToolbar.setText(getString(R.string.latest));
                binding.sortByTv.setText(getString(R.string.latest));
            }
        }
        createBottomsheet();
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (DashBoard.selectTab != 0) {
            onBackPressed();
        }
    }

    public void createBottomsheet() {
        ImageView imagePicker, videoPicker;
        view = getLayoutInflater().inflate(R.layout.image_video_picker, null);
        imagePicker = view.findViewById(R.id.select_image_iv);
        imagePicker.setOnClickListener(this);
        videoPicker = view.findViewById(R.id.select_video_iv);
        videoPicker.setOnClickListener(this);
        mBottomSheetDialog = new Dialog(this,
        R.style.BottomDialogSheet);
        mBottomSheetDialog.setContentView(view);
        mBottomSheetDialog.setCancelable(true);
        mBottomSheetDialog.getWindow().setLayout(LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.WRAP_CONTENT);
        mBottomSheetDialog.getWindow().setGravity(Gravity.BOTTOM);
    }

    private void getCommentCount() {
        RetrofitNetworkInterface retrofitNetworkInterface = RetrofitClient.createService(RetrofitNetworkInterface.class);
        JsonObject getCommentCountRequest = new JsonObject();
        getCommentCountRequest.addProperty("userid", new Preference(getApplicationContext()).getPref(Constants.USERID));
        getCommentCountRequest.addProperty("postid", String.valueOf(postDetail.getPOST_ID()));
        Map<String, String> header = new HashMap<>();
        header.put("X-ACCESS-KEY", BuildConfig.APP_ID);
        header.put("Token", new Preference(getApplicationContext()).getPref(Constants.token));
        Call<CommentCountModel> call = retrofitNetworkInterface.getCommentCount(header, getCommentCountRequest);
        try {
            call.enqueue(new Callback<CommentCountModel>() {
                @Override
                public void onResponse(Call<CommentCountModel> call, Response<CommentCountModel> response) {
                    if (response.code() == 200) {
                        try {
                            if (response.body().getStatus().equals(getString(R.string.success_status))) {
                                binding.antiMindedCountTv.setText(String.format(getString(R.string.anti_minded),
                                    response.body().getData().getCountANTI()));
                                binding.likeMindedCountTv.setText(String.format(getString(R.string.network),
                                    response.body().getData().getCountNW()));
                                binding.antiMindedCountTvToolbar.setText(String.format(getString(R.string.anti_minded),
                                    response.body().getData().getCountANTI()));
                                binding.likeMindedCountTvToolbar.setText(String.format(getString(R.string.network),
                                    response.body().getData().getCountNW()));
                                if (commentsType.equals(getString(R.string.network)))
                                    binding.commentCountParentPost.setText(response.body().getData().getCountNW());
                                else
                                    binding.commentCountParentPost.setText(response.body().getData().getCountANTI());
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                }

                @Override
                public void onFailure(Call<CommentCountModel> call, Throwable t) {

                }
            });
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void doLikePost(final String postId, String actionType) {
        try {
            RetrofitNetworkInterface retrofitNetworkInterface = RetrofitClient.createService(RetrofitNetworkInterface.class);
            JsonObject likeDislikeObject = new JsonObject();
            likeDislikeObject.addProperty("userid", new Preference(this).getPref(Constants.USERID));
            likeDislikeObject.addProperty("actionSource", getString(R.string.post_type));
            likeDislikeObject.addProperty("actionType", actionType);
            likeDislikeObject.addProperty("sourceID", postId);
            Map<String, String> header = new HashMap<>();
            header.put("X-ACCESS-KEY", BuildConfig.APP_ID);
            header.put("Token", new Preference(getApplicationContext()).getPref(Constants.token));
            Call<BaseResponse> call = retrofitNetworkInterface.userActionCommon(header, likeDislikeObject);
            Log.d("requestcalling", "doLikePost:" + call.request());
            call.enqueue(new Callback<BaseResponse>() {
                @Override
                public void onResponse(Call<BaseResponse> call, Response<BaseResponse> response) {
                    if (response.code() == 200) {
                        if (response.body() != null) {
                            if (response.body().getStatus().equals(getString(R.string.success_status))) {
                                //  FeedFragment.refresh = true;
                            }
                        }
                    }
                }

                @Override
                public void onFailure(Call<BaseResponse> call, Throwable t) {
                    t.printStackTrace();
                }
            });

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void displayComments(String type, Boolean loadMore) {
        if (loadMore) {
            commentsList.add(null);
            mAdapter.notifyItemInserted(commentsList.size() - 1);
            commentsList.remove(commentsList.size() - 1);
            int scrollPosition = commentsList.size();
            mAdapter.notifyItemRemoved(scrollPosition);
            currentSize = scrollPosition;
            mAdapter.notifyDataSetChanged();
        } else {
            commentsList.clear();
            currentSize = 0;
            getCommentCount();
        }
        String sortOrder = new Preference(this).getPref(Constants.SORTORDER).isEmpty() ? Constants.NEWONTOP :
        new Preference(this).getPref(Constants.SORTORDER);
        RetrofitNetworkInterface retrofitNetworkInterface = RetrofitClient.createService(RetrofitNetworkInterface.class);
        JsonObject commmentJsonObject = new JsonObject();
        commmentJsonObject.addProperty("userid", new Preference(getApplicationContext()).getPref(Constants.USERID));
        commmentJsonObject.addProperty("postid", String.valueOf(postDetail.getPOST_ID()));
        commmentJsonObject.addProperty("sortOrder", sortOrder);
        commmentJsonObject.addProperty("fromIndex", currentSize);
        commmentJsonObject.addProperty("toIndex", nextLimit);
        Map<String, String> header = new HashMap<>();
        header.put("X-ACCESS-KEY", BuildConfig.APP_ID);
        header.put("Token", new Preference(getApplicationContext()).getPref(Constants.token));
        if (type.equals(getString(R.string.network)))
            call = retrofitNetworkInterface.commentsByPostNW(header, commmentJsonObject);
        else
            call = retrofitNetworkInterface.commentsByPostAnti(header, commmentJsonObject);
        try {
            call.enqueue(new Callback<CommentModel>() {
                @Override
                public void onResponse(Call<CommentModel> call, Response<CommentModel> response) {
                    if (response.body() != null) {
                        if (response.body().getStatus().equals(getString(R.string.success_status))) {
                            commentsList.addAll(response.body().getData());
                            mAdapter = new CommentsAdapter(
                                    response.body().getData(),
                            Comments.this,
                            binding.commentEdittext,
                            Comments.this,
                            commentsInterface);
                            binding.postCommentView.setAdapter(mAdapter);
                            new Handler().postDelayed(new Runnable() {
                                @Override
                                public void run() {
                                    if (sortOrder.equals(Constants.NEWONTOP))
                                        binding.postCommentView.smoothScrollToPosition(0);
                                    else
                                        binding.postCommentView.smoothScrollToPosition(commentsList.size());
                                    isLoading = false;
                                }
                            }, 500);
                            if (!loadMore) {
                                if (commentsList.size() > 0)
                                    binding.noCommentsTv.setVisibility(View.GONE);
                                else
                                    binding.noCommentsTv.setVisibility(View.VISIBLE);
                            }
                        } else
                            Toast.makeText(Comments.this,
                                getString(R.string.something_went_wrong), Toast.LENGTH_SHORT).show();
                    } else
                        Toast.makeText(Comments.this,
                            getString(R.string.something_went_wrong), Toast.LENGTH_SHORT).show();
                }

                @Override
                public void onFailure(Call<CommentModel> call, Throwable t) {
                    Toast.makeText(Comments.this,
                        getString(R.string.internal_error_occured), Toast.LENGTH_SHORT).show();
                }
            });

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onBackPressed() {
//        try {
        Intent data = new Intent();
        data.putExtra("commentCount", String.valueOf(howManyComments));

        if (postDetail != null && postDetail.getLCOUNT() != null) {
            data.putExtra("likeCount", postDetail.getLCOUNT());
            Log.d("Like", postDetail.getLCOUNT().toString());

            if (postDetail.getHCOUNT() != null) {
                data.putExtra("hateCount", postDetail.getHCOUNT());
                Log.d("Like", postDetail.getHCOUNT().toString());
            }

            if (postDetail.getPOST_ACTION_TYPE() != null) {
                data.putExtra("myLikeOrHate", postDetail.getPOST_ACTION_TYPE());
                Log.d("Like", postDetail.getPOST_ACTION_TYPE().toString());
            }
        }
        data.putExtra("position", position);
        Log.d("comment_count", String.valueOf(howManyComments));
        setResult(RESULT_OK, data);
        if (!isBound)
            super.onBackPressed();
//        }catch (Exception e){e.printStackTrace();}
    }

    public void postComment(String id, String type) {
        RequestBody embeddedContent;
        RequestBody embeddedFlag;
        try {
            Map<String, String> header = new HashMap<>();
            header.put("X-ACCESS-KEY", BuildConfig.APP_ID);
            header.put("Token", new Preference(getApplicationContext()).getPref(Constants.token));
            List<MultipartBody.Part> avatar = new ArrayList<>();
            RetrofitNetworkInterface retrofitNetworkInterface = RetrofitClient.createService(RetrofitNetworkInterface.class);
            RequestBody commentContent = RequestBody.create(MediaType.parse("text/plain"),
            binding.commentEdittext.getText().toString().trim());
            RequestBody userId = RequestBody.create(MediaType.parse("text/plain"),
            new Preference(getApplicationContext()).getPref(Constants.USERID));
            RequestBody causeID = RequestBody.create(MediaType.parse("text/plain"), id);
            if (new EmbeddedContent().getEmbeddedContent(binding.commentEdittext.getText().toString()) != null &&
                !new EmbeddedContent().getEmbeddedContent(binding.commentEdittext.getText().toString()).isEmpty()) {
                embeddedFlag = RequestBody.create(MediaType.parse("text/plain"), getString(R.string.flay_Y));
                embeddedContent = RequestBody.create(MediaType.parse("text/plain"),
                    new EmbeddedContent().getEmbeddedContent(binding.commentEdittext.getText().toString()));
            } else {
                embeddedFlag = RequestBody.create(MediaType.parse("text/plain"), getString(R.string.flay_N));
                embeddedContent = RequestBody.create(MediaType.parse("text/plain"), "");
            }
            if (imagesUri.size() != 0) {
                avatar.clear();
                for (int i = 0; i < imagesUri.size(); i++) {
                    RequestBody requestFile = RequestBody.create(MediaType.parse("image/*"), FileUtil.from(this, imagesUri.get(i)));
                    avatar.add(MultipartBody.Part.createFormData("avatar[]",
                        FileUtil.from(this, imagesUri.get(i)).getName(), requestFile));
                }
            }
            //making API call

            Log.d("taggy", "post comment called  type->" + type);


            if (type.equals(getString(R.string.post_type))) {
                commentCall = retrofitNetworkInterface.CommentOnPostNew(header,
                    commentContent,
                    userId,
                    causeID,
                    avatar,
                    embeddedFlag,
                    embeddedContent
                );
            } else {
                commentCall = retrofitNetworkInterface.newCommentOnComment(header,
                    commentContent,
                    userId,
                    causeID,
                    avatar,
                    embeddedFlag,
                    embeddedContent
                );
            }

//            Log.d("taggy","post comment called  comment call->"+new Gson().toJson(commentCall.request()));
//            Log.d("taggy","post comment called  commentContent->"+commentContent);
//            Log.d("taggy","post comment called  userId->"+userId);
//            Log.d("taggy","post comment called  causeID->"+causeID);
//            Log.d("taggy","post comment called  avatar->"+avatar);
//            Log.d("taggy","post comment called  embeddedFlag->"+embeddedFlag);
//            Log.d("taggy","post comment called  embeddedContent->"+embeddedContent);

            commentCall.enqueue(new Callback<BaseResponse>() {
                @Override
                public void onResponse(Call<BaseResponse> call, Response<BaseResponse> response) {
                    if (response.code() == 200) {
                        if (response.body().getStatus().equals(getString(R.string.success_status))) {
                            new Preference(Comments.this).savePref(Constants.SORTORDER, Constants.NEWONTOP);
                            binding.sortByTvToolbar.setText(getString(R.string.latest));
                            binding.sortByTv.setText(getString(R.string.latest));
                            //FeedFragment.refresh = true;
                            ActivityFragment.refresh = true;
                            resetData();
                            Toast.makeText(Comments.this, getString(R.string.comment_added), Toast.LENGTH_SHORT).show();
                            commentedPostPosition = 0;
                            binding.commentEdittext.setEnabled(true);
                            Handler handler = new Handler();
                            displayComments(commentsType, false);
                            handler.postDelayed(
                                new Runnable() {
                                    @Override
                                    public void run() {

                                    }
                                }, 100
                            );

                            howManyComments++;

                        } else {
                            avatar.clear();
                            Toast.makeText(Comments.this,
                                getString(R.string.something_went_wrong), Toast.LENGTH_SHORT).show();
                        }
                    } else {
                        avatar.clear();
                        Toast.makeText(Comments.this,
                            getString(R.string.something_went_wrong), Toast.LENGTH_SHORT).show();
                    }
                }

                @Override
                public void onFailure(Call<BaseResponse> call, Throwable t) {
                    avatar.clear();
                    Toast.makeText(Comments.this, getString(R.string.something_went_wrong), Toast.LENGTH_SHORT).show();
                }
            });
        } catch (Exception e) {
            Toast.makeText(Comments.this, getString(R.string.something_went_wrong), Toast.LENGTH_SHORT).show();
            e.printStackTrace();
        }
    }

    void editComments() {
        binding.commentEdittext.requestFocus();
        binding.commentEdittext.setLinksClickable(true);
        binding.commentEdittext.setMovementMethod(LinkMovementMethod.getInstance());

        CommonInterface commonInterface = new CommonInterface() {
            @Override
            public void OnCommonInterface(String response) {
                String status = "";
                try {
                    status = new JSONObject(response).getString("status");
                    if (status.equalsIgnoreCase(Constants.SUCCESS)) {
                        isEdit = false;
                        resetData();
                        displayComments(commentsType, false);
                        Toast.makeText(Comments.this, getString(R.string.posted_successfully), Toast.LENGTH_SHORT).show();
                    } else
                        Toast.makeText(Comments.this, getString(R.string.something_went_wrong), Toast.LENGTH_SHORT).show();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        };
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("comments", binding.commentEdittext.getText().toString());
            jsonObject.put("embedded_flag", "Y");
            jsonObject.put("commentid", commentId);
            jsonObject.put("embedded_content", "");
            JSONObject comments = new JSONObject();
            comments.put("comments", jsonObject);
            comments.put("userid", new Preference(getApplicationContext()).getPref(Constants.USERID));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void resetData() {
        new SoftKeypad().hide(Comments.this);
        binding.mediaWithCommentLayout.setVisibility(View.GONE);
        binding.replyEtLayout.setVisibility(View.GONE);
        binding.commentEdittext.setText("");
        imagesUri.clear();
        fileList.clear();
    }

    @Override
    public boolean onTouch(View v, MotionEvent event) {
        if (v.getId() == R.id.comment_edittext) {
            final int DRAWABLE_RIGHT = 2;
            if (event.getAction() == MotionEvent.ACTION_UP) {
                if (isLikeOrHate())
                //               Toast.makeText(getApplicationContext(), postDetail.getPOST_ACTION_TYPE()+","+lorh, Toast.LENGTH_SHORT).show();
                    if (UserUtils.isGuestUser(this)) {
                        //                   binding.commentEdittext.setEnabled(false);
                        UserUtils.showConfirmation(this);
                    } else {
                        if (event.getRawX() >= (binding.commentEdittext.getRight()
                                    - binding.commentEdittext.getCompoundDrawables()[DRAWABLE_RIGHT].getBounds().width())) {
                            if (binding.commentEdittext.getText().toString().trim().isEmpty())
                                Toast.makeText(this, R.string.post_empty, Toast.LENGTH_LONG).show();
                            else {
                                if (binding.replyEtLayout.getVisibility() != View.VISIBLE) {
//                                final Snackbar snackBar = Snackbar.make(getCurrentFocus(), R.string.replying_to_main_post, Snackbar.LENGTH_INDEFINITE);
//                                snackBar.setAction(getString(R.string.ok), new View.OnClickListener() {
//                                            @Override
//                                            public void onClick(View v) {
//                                                postComment(String.valueOf(postDetail.getPOST_ID()), getString(R.string.post_type));
//                                                snackBar.dismiss();
//                                            }
//                                        }).show();

                                    if (count == 0) {
                                        if (isLikeOrHate()) {
                                            alertDialog.setMessage(R.string.replying_to_main_post)
                                                .setCancelable(false)
                                                .setPositiveButton("Comment", (dialogInterface, i) -> {
                                                postComment(String.valueOf(postDetail.getPOST_ID()), getString(R.string.post_type));
                                                count = 0;
                                                dialogInterface.cancel();
                                            })
                                            .setNegativeButton("cancel", (dialogInterface, i) -> {
                                                dialogInterface.cancel();
                                            });

                                            alert = alertDialog.create();
                                            alert.setTitle("Comment");
                                            alert.show();
                                        }
//                                    binding.commentEdittext.setEnabled(false);
//                                    count = 1;
                                    }

                                } else {
                                    postComment(commentId, getString(R.string.comment_type));
                                }
                            }
                            return true;
                        }
                    }
            }
        }
        return false;
    }

    private void attachMediaFile(String type) {
        mBottomSheetDialog.dismiss();
        new SoftKeypad().hide(this);
        if ((4 - imagesUri.size()) > 0) {
            if (type.equals(getString(R.string.image))) {
                Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
                intent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true);
                intent.setType("image/*");
                startActivityForResult(Intent.createChooser(intent, getString(R.string.select_picture)), REQUEST_MULTIPLE_FILES);
            } else {
                Intent intent = new Intent();
                intent.setType("video/*");
                intent.setAction(Intent.ACTION_GET_CONTENT);
                startActivityForResult(intent, REQUEST_FOR_VIDEO_FILE);
            }
            Toast.makeText(this, String.format(getString(R.string.select_images), String.valueOf(4 - imagesUri.size())), Toast.LENGTH_SHORT).show();
        } else
            Toast.makeText(this, R.string.cannot_add_images, Toast.LENGTH_SHORT).show();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        try {
            if (resultCode == RESULT_OK) {
                if (requestCode == REQUEST_FOR_VIDEO_FILE) {
                    binding.mediaWithCommentLayout.setVisibility(View.VISIBLE);
                    if (data != null && data.getData() != null) {
                        File file = new File(getExternalFilesDir(Environment.DIRECTORY_MOVIES),
                            System.currentTimeMillis() + "_" + getString(R.string.app_name) + ".mp4");
                        long length = (FileUtil.from(this, data.getData()).length() / 1024) / 1024;
                        if (length > 50) {
                            Toast.makeText(this, R.string.video_max_size_reached, Toast.LENGTH_SHORT).show();
                        } else {
                            destPath = String.valueOf(file);
                            String inputPath = FileUtil.from(this, data.getData()).getPath();
                            compressVideo(inputPath, destPath);
                        }
                    }
                } else {
                    if (requestCode == REQUEST_MULTIPLE_FILES) {
                        binding.mediaWithCommentLayout.setVisibility(View.VISIBLE);
                        Uri selectedImageUri;
                        if (data.getClipData() != null) {
                            int count = data.getClipData().getItemCount();
                            if (imagesUri.size() + count <= 4) {
                                for (int i = 0; i < count; i++) {
                                    selectedImageUri = data.getClipData().getItemAt(i).getUri();
                                    compressFile((FileUtil.from(this, selectedImageUri)));
                                }
                            } else
                                Toast.makeText(this, R.string.upload_4_images_only, Toast.LENGTH_SHORT).show();
                        } else if (data.getData() != null) {
                            binding.mediaWithCommentLayout.setVisibility(View.VISIBLE);
                            selectedImageUri = data.getData();
                            if (imagesUri.size() < 4) {
                                compressFile((FileUtil.from(this, selectedImageUri)));
                            } else
                                Toast.makeText(this, R.string.upload_4_images_only, Toast.LENGTH_SHORT).show();
                        }
                    }
                }
            }
        } catch (Exception e) {
            binding.mediaWithCommentLayout.setVisibility(View.GONE);
            e.printStackTrace();
        }
    }

    private ServiceConnection boundServiceConnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            BoundService.MyBinder binderBridge = (BoundService.MyBinder) service;
            boundService = binderBridge.getService();
            rxBus = binderBridge.getRxbus();
            if (disposables != null) {
                if (rxBus != null) {
                    disposables.add(rxBus.asFlowable().subscribe(
                        event -> {
                        if (event instanceof ChangeInProgress) {
                            binding.progressBar.setProgress((int) ((ChangeInProgress) event).getChange());
                            if (((ChangeInProgress) event).isCompleted()) {
                                // video process done.
                                binding.progressBar.setVisibility(View.GONE);
                                binding.progressBarTv.setVisibility(View.GONE);
                                getWindow().clearFlags(WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE);
                                File file = new File(destPath);
                                imagesUri.add(Uri.fromFile(file));
                                sendImagesAdapter.notifyDataSetChanged();
                                if (isBound) {
                                    unbindService(boundServiceConnection);
                                    isBound = false;
                                }
                            }
                        }
                    }));
                    isBound = true;
                }
            }
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
            isBound = false;
            boundService = null;
        }
    };

    private void compressVideo(String inputPath, String destPath) {
        try {
            binding.progressBar.setVisibility(View.VISIBLE);
            binding.progressBarTv.setVisibility(View.VISIBLE);
            getWindow().setFlags(WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE,
                WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE);
            Intent intent = new Intent(this, BoundService.class);
            intent.putExtra(DESTPATH, destPath);
            intent.putExtra(INPUTPATH, inputPath);
            startService(intent);
            bindService(intent, boundServiceConnection, BIND_AUTO_CREATE);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void compressFile(File file) {
        new Compressor(this)
            .compressToFileAsFlowable(file)
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(new Consumer<File>() {
                @Override
                public void accept(File file) {
                    imagesUri.add(Uri.fromFile(file));
                    sendImagesAdapter.notifyDataSetChanged();
                }
            }, new Consumer<Throwable>() {
                @Override
                public void accept(Throwable throwable) {
                    throwable.printStackTrace();
                }
            });
    }

    private void setColor(int likeMindedLayoutColor, int likeMindedResColor, int antiMindedLayoutColor, int antiMindedResColor) {
        //like minded
        binding.likeMindedLayout.getBackground().setTint(getResources().getColor(likeMindedLayoutColor));
        binding.likeMindedSymbol.setTextColor(getResources().getColor(likeMindedResColor));
        binding.likeMindedCountTv.setTextColor(getResources().getColor(likeMindedResColor));
        binding.likeMindedIv1.setColorFilter(ContextCompat.getColor(this, likeMindedResColor));
        binding.likeMindedIv2.setColorFilter(ContextCompat.getColor(this, likeMindedResColor));
        //toolbar
        binding.likeMindedLayoutToolbar.getBackground().setTint(getResources().getColor(likeMindedLayoutColor));
        binding.likeMindedSymbolToolbar.setTextColor(getResources().getColor(likeMindedResColor));
        binding.likeMindedCountTvToolbar.setTextColor(getResources().getColor(likeMindedResColor));
        binding.likeMindedIv1Toolbar.setColorFilter(ContextCompat.getColor(this, likeMindedResColor));
        binding.likeMindedIv2Toolbar.setColorFilter(ContextCompat.getColor(this, likeMindedResColor));

        //anti minded
        binding.antiMindedLayout.getBackground().setTint(getResources().getColor(antiMindedLayoutColor));
        binding.antiMindedSymbol.setTextColor(getResources().getColor(antiMindedResColor));
        binding.antiMindedCountTv.setTextColor(getResources().getColor(antiMindedResColor));
        binding.antiMindedIv1.setColorFilter(ContextCompat.getColor(this, antiMindedResColor));
        binding.antiMindedIv2.setColorFilter(ContextCompat.getColor(this, antiMindedResColor));
        //toolbaar
        binding.antiMindedLayoutToolbar.getBackground().setTint(getResources().getColor(antiMindedLayoutColor));
        binding.antiMindedSymbolToolbar.setTextColor(getResources().getColor(antiMindedResColor));
        binding.antiMindedCountTvToolbar.setTextColor(getResources().getColor(antiMindedResColor));
        binding.antiMindedIv1Toolbar.setColorFilter(ContextCompat.getColor(this, antiMindedResColor));
        binding.antiMindedIv2Toolbar.setColorFilter(ContextCompat.getColor(this, antiMindedResColor));
    }

    public void deleteMainPost(String postid) {
        CommonInterface commonInterface = new CommonInterface() {
            @Override
            public void OnCommonInterface(String response) {
                String status = "";
                try {
                    status = new JSONObject(response).getString("status");
                    if (status.equalsIgnoreCase(Constants.SUCCESS)) {
                        FeedFragment.loadProgress = 0;
                        ActivityFragment.refresh = true;
                        onBackPressed();
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        };
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("userid", new Preference(this).getPref(Constants.USERID));
            jsonObject.put("postid", postid);
            new CommonAsync(this, commonInterface, jsonObject).execute(Constants.deletePost);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void showConfirmation(String id, String type) {
        AlertDialog.Builder dialogBuilder = new AlertDialog.Builder(this, R.style.MyCustomDialogTheme);
        LayoutInflater inflater = this.getLayoutInflater();
        final View dialogView = inflater.inflate(R.layout.confirm_dialog, null);
        dialogBuilder.setView(dialogView);
        final TextView dialogText = dialogView.findViewById(R.id.top_tv);
        final TextView descText = dialogView.findViewById(R.id.description_tv);
        descText.setVisibility(View.VISIBLE);
        final Button btnYes = dialogView.findViewById(R.id.btnyes);
        btnYes.setText(getString(R.string.yes));
        final Button btnCancel = dialogView.findViewById(R.id.btncancel);
        btnCancel.setText(getString(R.string.no));
        final AlertDialog alertDialog = dialogBuilder.create();
        dialogText.setText(getString(R.string.confirmation));
        if (type.equals(getString(R.string.post_type)))
            descText.setText(getString(R.string.deletepost));
        else if (type.equals(getString(R.string.comment_type)))
            descText.setText(getString(R.string.deletecomment));
        btnYes.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                try {
                    alertDialog.dismiss();
                    if (type.equals(getString(R.string.post_type)))
                        deleteMainPost(id);
                    else if (type.equals(getString(R.string.comment_type)))
                        deleteComment(id);
                } catch (Exception e) {
                    e.printStackTrace();
                }
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

    public void showRemoveFrag(String type, String SourceId) {
        postIdRemoveUser = SourceId;
        KOType = type;
        FragmentManager fm = getSupportFragmentManager();
        ReportDialogFragment reportDialogFragment = new ReportDialogFragment(this);
        ReportDialogFragment.TYPE = type;
        ReportDialogFragment.POSTID = SourceId;
        reportDialogFragment.show(fm, "ReportDialogFragment");
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {

            case R.id.h_count_parent_post:
            LoveHateUsersListFragment loveHateUsersListFragment =
            LoveHateUsersListFragment.newInstance(String.valueOf(postDetail.getPOST_ID()),
                getString(R.string.hate));
            loveHateUsersListFragment.show(getSupportFragmentManager(), "LoveHateUserListFragment");
            break;

            case R.id.like_count_parent_post:
            LoveHateUsersListFragment loveHateUsersListFragment1 =
            LoveHateUsersListFragment.newInstance(String.valueOf(postDetail.getPOST_ID()),
                getString(R.string.love));
            loveHateUsersListFragment1.show(getSupportFragmentManager(), "LoveHateUserListFragment");
            break;

            case R.id.attachment_iv:
            case R.id.attachment_tv:
            ArrayList<String> arrImageList = new ArrayList<String>(Arrays.asList(
                postDetail.getMEDIA_CONTENT().toString().split(",")
            ));
            Intent fullScreenIntent = new Intent(this, FullScreenImageActivity.class);
            fullScreenIntent.putStringArrayListExtra(IMAGELIST, arrImageList);
            fullScreenIntent.putExtra(IMAGEPOSITION, 0);
            startActivity(fullScreenIntent);
            break;

            case R.id.status_change_layout_parent_post:
            Intent intent = new Intent(this, CommonInterests.class);
            intent.putExtra(TOPICID, postDetail.getTOPICID());
            intent.putExtra(USERNAME, postDetail.getUSERNAME());
            intent.putExtra(PROFILEIMAGE, postDetail.getDP_URL());
            startActivity(intent);
            break;

            case R.id.error_text:
            getPostDetail();
            break;

            case R.id.select_image_iv:
            attachMediaFile(getString(R.string.image));
            break;

            case R.id.select_video_iv:
            attachMediaFile(getString(R.string.video));
            break;

            case R.id.back_arrow:
            onBackPressed();
            break;

            case R.id.close_reply_layout:
            binding.replyEtLayout.setVisibility(View.GONE);
            break;

            case R.id.remove_user_parent_post:
            showRemoveFrag(getString(R.string.post_type), String.valueOf(postDetail.getPOST_ID()));
            break;

            case R.id.delete_parent_post:
            //FeedFragment.refresh = true;
            showConfirmation(String.valueOf(postDetail.getPOST_ID()), getString(R.string.post_type));
            break;

            case R.id.like_minded_layout_toolbar:
            case R.id.like_minded_layout:
            commentsType = getString(R.string.network);
            setColor(R.color.colorPrimary, R.color.white, R.color.white,
                R.color.colourGrey);
            displayComments(commentsType, false);
            break;

            case R.id.hint_iv:
            case R.id.hint_iv_toolbar:
            Intent termninologyintent = new Intent(this, Terminology.class);
            startActivity(termninologyintent);
            break;

            case R.id.anti_minded_layout_toolbar:
            case R.id.anti_minded_layout:
            commentsType = getString(R.string.anti_minded);
            setColor(R.color.white, R.color.colourGrey, R.color.colorPrimary,
                R.color.white);
            displayComments(commentsType, false);
            break;

            case R.id.sort_by_tv_toolbar:
            case R.id.sort_by_tv:
            if (binding.sortByTv.getText().toString().equals(getString(R.string.latest))) {
                new Preference(this).savePref(Constants.SORTORDER, Constants.OLDONTOP);
                binding.sortByTvToolbar.setText(getString(R.string.oldest));
                binding.sortByTv.setText(getString(R.string.oldest));
            } else {
                new Preference(this).savePref(Constants.SORTORDER, Constants.NEWONTOP);
                binding.sortByTvToolbar.setText(getString(R.string.latest));
                binding.sortByTv.setText(getString(R.string.latest));
            }
            displayComments(commentsType, false);
            break;

            case R.id.parent_post_comment_iv:
            isEdit = false;
            if (UserUtils.isGuestUser(Comments.this)) {
                UserUtils.showConfirmation(Comments.this);
            } else {
//                    /*binding.clearAll.setVisibility(View.VISIBLE);*/
//                    binding.addMediaToComment.setVisibility(View.VISIBLE);
////                binding.emptyBottomView.setVisibility(View.VISIBLE);
//                    binding.commentEdittext.setVisibility(View.VISIBLE);
//                    binding.commentEdittext.setText("");
//                    binding.commentEdittext.requestFocus();
//                    new SoftKeypad().show(this);
            }
            break;

            case R.id.parent_post_hate:
            if (postDetail.getPOST_ACTION_TYPE().toLowerCase().equals("l")) {
                binding.likeCountParentPost.setText(Integer.parseInt(postDetail.getLCOUNT()) == 0 ? ZERO :
                String.valueOf(Integer.parseInt(postDetail.getLCOUNT()) - 1));
                postDetail.setLCOUNT(String.valueOf(Integer.parseInt(postDetail.getLCOUNT()) - 1));
                doLikePost(String.valueOf(postDetail.getPOST_ID()),getString(R.string.unlike));
            }
            if (postDetail.getPOST_ACTION_TYPE().toLowerCase().equals("h")) {
                binding.parentPostHate.setImageDrawable(getResources().getDrawable(R.drawable.ic_hate_post));
                postDetail.setPOST_ACTION_TYPE("");
                binding.hCountParentPost.setText(String.valueOf(Integer.parseInt(postDetail.getHCOUNT()) - 1));
                postDetail.setHCOUNT(String.valueOf(Integer.parseInt(postDetail.getHCOUNT()) - 1));
                doLikePost(String.valueOf(postDetail.getPOST_ID()), getString(R.string.unhate));
            } else {
                binding.parentPostHate.setImageDrawable(getResources().getDrawable(R.drawable.ic_hate_post_selected));
                postDetail.setPOST_ACTION_TYPE("H");
                binding.hCountParentPost.setText(String.valueOf(Integer.parseInt(postDetail.getHCOUNT()) + 1));
                postDetail.setHCOUNT(String.valueOf(Integer.parseInt(postDetail.getHCOUNT()) + 1));
                doLikePost(String.valueOf(postDetail.getPOST_ID()), getString(R.string.dohate));
            }
            binding.likeParentPostIv.setImageDrawable(getResources().getDrawable(R.drawable.ic_love_post));
            break;

            case R.id.clear_all:
            resetData();
            break;

            case R.id.like_parent_post_iv:
            if (postDetail.getPOST_ACTION_TYPE().toLowerCase().equals("h")) {
                binding.hCountParentPost.setText(Integer.parseInt(postDetail.getHCOUNT()) == 0 ? ZERO :
                String.valueOf(Integer.parseInt(postDetail.getHCOUNT()) - 1));
                postDetail.setHCOUNT(String.valueOf(Integer.parseInt(postDetail.getHCOUNT()) - 1));
                doLikePost(String.valueOf(postDetail.getPOST_ID()), getString(R.string.unhate));
            }
            if (postDetail.getPOST_ACTION_TYPE().toLowerCase().equals("l")) {
                binding.likeParentPostIv.setImageDrawable(getResources().getDrawable(R.drawable.ic_love_post));
                postDetail.setPOST_ACTION_TYPE("");
                binding.likeCountParentPost.setText(String.valueOf(Integer.parseInt(postDetail.getLCOUNT()) - 1));
                postDetail.setLCOUNT(String.valueOf(Integer.parseInt(postDetail.getLCOUNT()) - 1));
                doLikePost(String.valueOf(postDetail.getPOST_ID()), getString(R.string.unlike));
            } else {
                binding.likeParentPostIv.setImageDrawable(getResources().getDrawable(R.drawable.ic_like_post_selected));
                postDetail.setPOST_ACTION_TYPE("L");
                binding.likeCountParentPost.setText(String.valueOf(Integer.parseInt(postDetail.getLCOUNT()) + 1));
                postDetail.setLCOUNT(String.valueOf(Integer.parseInt(postDetail.getLCOUNT()) + 1));
                doLikePost(String.valueOf(postDetail.getPOST_ID()), getString(R.string.like));
            }
            binding.parentPostHate.setImageDrawable(getResources().getDrawable(R.drawable.ic_hate_post));
            break;

            case R.id.add_media_to_comment:
            if (UserUtils.isGuestUser(this)) {
                UserUtils.showConfirmation(this);
            } else {
                createBottomsheet();
                mBottomSheetDialog.show();
            }
            break;

            case R.id.share_parent_post:
            DynamicLinksUtil.createDynamicUri(String.valueOf(new Preference(this).getIntPref(Constants.TOPICID)),
                String.valueOf(postDetail.getPOST_ID()),
                this,
                postDetail.getPostCellModel().getPostTitle(),
                postDetail.getPostCellModel().getUrlForPreview(),
                "");
            break;
        }
    }

    @Override
    public void onRefresh() {
        displayComments(commentsType, false);
//        binding.swipeRefreshComments.setRefreshing(false);
    }

    @Override
    public void removeImage(Uri imagePath, int position) {
        try {
            fileList.remove(position);
            imagesUri.remove(position);
        } catch (Exception e) {
            imagesUri.remove(position);
        }

        sendImagesAdapter.notifyDataSetChanged();
        binding.selectedImagesComments.invalidate();
        if (!(imagesUri.size() > 0))
            binding.mediaWithCommentLayout.setVisibility(View.GONE);
    }

    private void prepareToPost(String type, CommentModel.Data commentData) {
        //binding.clearAll.setVisibility(View.VISIBLE);
//        binding.emptyBottomView.setVisibility(View.VISIBLE);
        binding.commentEdittext.setVisibility(View.VISIBLE);
        binding.addMediaToComment.setVisibility(View.VISIBLE);
        binding.replyEtLayout.setVisibility(View.VISIBLE);
        binding.commentEdittext.setText("");
        binding.commentEdittext.requestFocus();
        new SoftKeypad().show(this);
        if (type.equals(getString(R.string.child_post))) {
            commentId = commentData.getCOMMENTID();
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                binding.replyToName.setText(Html.fromHtml(
                    String.format(getString(R.string.replying_to), commentData.getCOMMENTBYUNAME()),
                    HtmlCompat.FROM_HTML_SEPARATOR_LINE_BREAK_LIST_ITEM));
            } else
                binding.replyToName.setText(String.format(getString(R.string.replying_to_normal), commentData.getCOMMENTBYUNAME()));
            binding.replyToHeader.setText(commentData.getCOMMENTCONTENT().replaceAll("(?m)(^ *| +(?= |$))", "")
                .replaceAll("(?m)^$([\r\n]+?)(^$[\r\n]+?^)+", "$1").trim());
        } else {
            commentId = commentData.getPARENTCOMMENTID();
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                binding.replyToName.setText(Html.fromHtml(
                    String.format(getString(R.string.replying_to), commentData.getPARENTCOMMENTUNAME()),
                    HtmlCompat.FROM_HTML_SEPARATOR_LINE_BREAK_LIST_ITEM));
            } else
                binding.replyToName.setText(String.format(getString(R.string.replying_to_normal), commentData.getPARENTCOMMENTUNAME()));
            binding.replyToHeader.setText(commentData.getPARENTCOMMENTCONTENT().replaceAll("(?m)(^ *| +(?= |$))", "")
                .replaceAll("(?m)^$([\r\n]+?)(^$[\r\n]+?^)+", "$1").trim());
        }
    }


    @Override
    public void scrollImage(int position) {

    }

    @Override
    public void removeUser(String KOtype, String commentId) {
        showRemoveFrag(KOtype, commentId);
    }

    @Override
    public void postDetail(CommentModel.Data commentData, String type) {
        if (UserUtils.isGuestUser(Comments.this)) {
            UserUtils.showConfirmation(Comments.this);
        } else {
            prepareToPost(type, commentData);
        }
    }

//    private void deleteComment(String commentId) {
//        CommonInterface commonInterface = new CommonInterface() {
//            @Override
//            public void OnCommonInterface(String response) {
//                String status = "";
//                try {
//                    status = new JSONObject(response).getString("status");
//                    if (status.equalsIgnoreCase(Constants.SUCCESS)) {
//                        FeedFragment.refresh = true;
//                        ActivityFragment.refresh = true;
//                        displayComments(commentsType, false);
//                    } else
//                        Toast.makeText(Comments.this, getString(R.string.something_went_wrong), Toast.LENGTH_SHORT).show();
//                } catch (Exception e) {
//                    e.printStackTrace();
//                }
//            }
//        };
//        try {
//            JSONObject jsonObject = new JSONObject();
//            jsonObject.put("userid", new Preference(getApplicationContext()).getPref(Constants.USERID));
//            jsonObject.put("comment_id", commentId);
//            new CommonAsync(this, commonInterface  ,  jsonObject).execute(Constants.deleteComment);
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//    }

    private void deleteComment(String commentId) {
        Map<String, String> header = new HashMap<>();
        header.put("X-ACCESS-KEY", BuildConfig.APP_ID);
        header.put("Token", new Preference(getApplicationContext()).getPref(Constants.token));
        RetrofitNetworkInterface retrofitNetworkInterface = RetrofitClient.createService(RetrofitNetworkInterface.class);
        Call<ResponseBody> call = retrofitNetworkInterface.deleteCommentApiCalling(header, new Preference(getApplicationContext()).getPref(Constants.USERID), commentId);
        call.enqueue(new Callback<ResponseBody>() {
            @Override
            public void onResponse(Call<ResponseBody> call, Response<ResponseBody> response) {
                if (response.code() == 200) {
                    String status = "";
                    try {
                        JSONObject jsonObject = new JSONObject(response.body().string());
                        status = jsonObject.getString("status");
                        if (status.equalsIgnoreCase(Constants.SUCCESS)) {
                            //  FeedFragment.refresh = true;
                            howManyComments--;
                            ActivityFragment.refresh = true;
                            displayComments(commentsType, false);
                        } else
                            Toast.makeText(Comments.this, getString(R.string.something_went_wrong), Toast.LENGTH_SHORT).show();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }

            }

            @Override
            public void onFailure(Call<ResponseBody> call, Throwable t) {

            }
        });
    }


    @Override
    public void deletePost(String commentId) {
        showConfirmation(commentId, getString(R.string.comment_type));
    }

    @Override
    public void onLinkClicked(String linkText, TextViewClickMovement.LinkType linkType) {
        CustomTabsIntent.Builder customIntent = new CustomTabsIntent.Builder();
        customIntent.setToolbarColor(getApplication().getResources().getColor(R.color.colorPrimary));
        customIntent.enableUrlBarHiding();
        customIntent.setShowTitle(true);
        openCustomTab(Comments.this, customIntent.build(), Uri.parse(linkText));
//
//        Intent browserIntent = new Intent(this, WebViewLoaderActivity.class);
//        browserIntent.putExtra(Constants.URL_TO_LOAD, linkText);
//        this.startActivity(browserIntent);
    }

    public static void openCustomTab(Activity activity, CustomTabsIntent customTabsIntent, Uri uri) {
        try {
            String packageName = "com.android.chrome";
            if (packageName != null) {

                customTabsIntent.intent.setPackage(packageName);

                customTabsIntent.launchUrl(activity, uri);
            } else {

                activity.startActivity(new Intent(Intent.ACTION_VIEW, uri));
            }
        } catch (Exception ee) {
            ee.printStackTrace();
        }
        // package name is the default package

    }

    @Override
    public void onLongClick(String text) {

    }

    @Override
    public void onNavBackCliked() {
        if (!postIdRemoveUser.equals(""))
            showRemoveFrag(KOType, postIdRemoveUser);
    }

    @Override
    public void onCompleteReport(String type) {
        if (type.equals(getString(R.string.comment_type)))
            displayComments(commentsType, false);
        else onBackPressed();
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
        if (type.equals(getString(R.string.comment_type)))
            displayComments(commentsType, false);
        else onBackPressed();
    }

    @Override
    public void onKickOut() {

    }


    public Boolean isLikeOrHate() {
        if (!postDetail.getPOST_ACTION_TYPE().toLowerCase().equalsIgnoreCase("l") &&
            !postDetail.getPOST_ACTION_TYPE().toLowerCase().equalsIgnoreCase("h")) {

            InputMethodManager imm = (InputMethodManager) getApplicationContext().getSystemService(Activity.INPUT_METHOD_SERVICE);
            imm.hideSoftInputFromWindow(view.getWindowToken(), 0);

            Dialog topicPopup = new Dialog(Comments.this);
            topicPopup.setContentView(R.layout.image_dialog);
            TextView cancel = topicPopup.findViewById(R.id.okay_text);

            cancel.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    topicPopup.dismiss();
                }
            });
            topicPopup.getWindow().setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            if (!topicPopup.isShowing()) {
                topicPopup.show();
            }
            return false;
        }
        return true;
    }
}
