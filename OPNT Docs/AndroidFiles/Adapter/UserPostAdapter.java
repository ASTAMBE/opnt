package com.opinito.social.Adapter;

import android.app.Activity;
import android.content.Intent;
import android.graphics.drawable.GradientDrawable;

import androidx.annotation.NonNull;
import androidx.browser.customtabs.CustomTabsIntent;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.net.Uri;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AbsListView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.bitmap.CircleCrop;
import com.bumptech.glide.load.resource.bitmap.RoundedCorners;
import com.opinito.social.Activity.Comments;
import com.opinito.social.Activity.FullScreenImageActivity;
import com.opinito.social.Activity.UserPostDetails;
import com.opinito.social.Activity.CommonInterests;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.Preference;
import com.opinito.social.Constants.TextViewClickMovement;
import com.opinito.social.Fragment.FeedFragment;
import com.opinito.social.Fragment.LoveHateUsersListFragment;
import com.opinito.social.Interface.OnLoadMoreListener;
import com.opinito.social.Model.PostDetailsModel;
import com.opinito.social.R;
import com.opinito.social.Utils.ColorChange;
import com.opinito.social.Utils.DynamicLinksUtil;
import com.opinito.social.Utils.ExtractWebURLPreview;
import com.opinito.social.Utils.LinePagerIndicatorDecoration;
import com.opinito.social.Utils.RecyclerUtils;
import com.opinito.social.Utils.TextViewResizable;
import com.opinito.social.Utils.TimeUtils;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Created by 502687702 on 7/17/2017.
 */

public class UserPostAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> implements TextViewClickMovement.OnTextViewClickMovementListener {
    private ArrayList<PostDetailsModel> postDetailsModelArrayList;
    Activity context;
    private static final String TOPICDESCRIPTION = "topicdescription";
    private static final String POSTID = "postid";
    private static final String MEDIACONTENT = "media_content";
    private final int VIEW_TYPE_ITEM = 0;
    private final int VIEW_TYPE_LOADING = 1;
    private static final String POSTCONTENT = "postcontent";
    private String IMAGELIST = "imageslist";
    private String IMAGEPOSITION = "imagePosition";
    private final String TOPICID = "topicid";
    private final String type;
    private final String USERNAME = "username";
    private final String PROFILEIMAGE = "profileimage";
    int temp = 1;

    public OnLoadMoreListener mOnLoadMoreListener;

    private boolean isLoading;
    private int visibleThreshold = 1;
    private int lastVisibleItem, totalItemCount;
    RecyclerView mrecyclerView;
    String userName = "";
    private UserPostDetails activity;

    public class MyViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener {
        private TextView username;
        private TextView status_text;
        private TextView time;
        private TextView postedText;
        private RelativeLayout statuschangeLayout;
        private TextView hcount;
        private TextView likecount;
        private TextView commentcount;
        private ImageView delete;
        private ImageView userImage;
        private ImageView removeUser;
        private ImageView imgLikePost, imgDisLikePost, attachmentIv, bookmark;
        private TextView attachmentTv;
        private ImageView imgComment;
        private ImageView editUser;
        private ImageView webpageImage;
        private TextView header;
        private TextView description;
        private LinearLayout webImageLayout;
        private TextView remaningDescription;
        private ImageView share;
        private RelativeLayout webPageImageLayout;
        private RecyclerView postImagesRecycler;
        private LinearLayout editDeleteIv;
        private TextView showThisPost;

        public MyViewHolder(View view) {
            super(view);
            username = view.findViewById(R.id.username);
            status_text = view.findViewById(R.id.status_text);
            time = view.findViewById(R.id.time);
            postedText = view.findViewById(R.id.postedtext);
            statuschangeLayout = view.findViewById(R.id.status_change_layout_parent_post);
            webImageLayout = view.findViewById(R.id.webpageimagelayout);
            showThisPost = view.findViewById(R.id.show_post_detail);
            bookmark = view.findViewById(R.id.bookmark);
            bookmark.setOnClickListener(this);
            if (!type.equals(Constants.profilePosts))
                showThisPost.setText(context.getString(R.string.show_comments));
            webPageImageLayout = view.findViewById(R.id.web_page_image_layout);
            webPageImageLayout.setVisibility(View.GONE);
            attachmentIv = view.findViewById(R.id.attachment_iv);
            attachmentIv.setOnClickListener(this);
            attachmentTv = view.findViewById(R.id.attachment_tv);
            attachmentTv.setOnClickListener(this);
            userImage = view.findViewById(R.id.status_image);
            header = view.findViewById(R.id.header);
            description = view.findViewById(R.id.description);
            editDeleteIv = view.findViewById(R.id.edit_delete_iv);
            remaningDescription = view.findViewById(R.id.remaningdescription);
            webpageImage = view.findViewById(R.id.webpageimage);
            postImagesRecycler = view.findViewById(R.id.post_images_recycler);
            RecyclerUtils.ScrollImageByOne scrollImageByOne = new RecyclerUtils.ScrollImageByOne();
            scrollImageByOne.attachToRecyclerView(postImagesRecycler);
            hcount = view.findViewById(R.id.h_count);
            hcount.setOnClickListener(this);
            likecount = view.findViewById(R.id.like_count);
            likecount.setOnClickListener(this);
            commentcount = view.findViewById(R.id.comment_count);
            delete = view.findViewById(R.id.delete);
            removeUser = view.findViewById(R.id.removeuser);
            if (removeUser != null) {
                removeUser.setOnClickListener(this);
            }
            imgLikePost = view.findViewById(R.id.imgLikePost);
            imgDisLikePost = view.findViewById(R.id.imgDislikePost);
            imgComment = view.findViewById(R.id.imgcomment);
            editUser = view.findViewById(R.id.edit);
            editUser.setVisibility(View.GONE);
            share = view.findViewById(R.id.share);
        }

        @Override
        public void onClick(View v) {
            switch (v.getId()) {

                case R.id.like_count:
                    showUsersHateLike(getAdapterPosition(), context.getString(R.string.love));
                    break;

                case R.id.h_count:
                    showUsersHateLike(getAdapterPosition(), context.getString(R.string.hate));
                    break;
                case R.id.removeuser:
                    try {
                        activity.showRemoveFrag(String.valueOf(postDetailsModelArrayList.get(getAdapterPosition()).getPOST_ID()));
                    } catch (Exception e) {
                        notifyDataSetChanged();
                        e.printStackTrace();
                    }
                    break;

                case R.id.attachment_iv:
                case R.id.attachment_tv:
                    ArrayList<String> arrImageList = new ArrayList<String>(Arrays.asList(
                            postDetailsModelArrayList.get(getAdapterPosition()).getMEDIA_CONTENT().toString().split(",")
                    ));
                    Intent fullScreenIntent = new Intent(context, FullScreenImageActivity.class);
                    fullScreenIntent.putStringArrayListExtra(IMAGELIST, arrImageList);
                    fullScreenIntent.putExtra(IMAGEPOSITION, 0);
                    context.startActivity(fullScreenIntent);
                    break;
            }
        }
    }

    public UserPostAdapter(ArrayList<PostDetailsModel> postDetailsModelArrayList,
                           Activity context, RecyclerView recyclerView, UserPostDetails activity, String type) {
        this.postDetailsModelArrayList = postDetailsModelArrayList;
        this.context = context;
        this.mrecyclerView = recyclerView;
        this.activity = activity;
        this.type = type;
        userName = new Preference(context).getPref(Constants.USERNAME);

        final LinearLayoutManager linearLayoutManager = (LinearLayoutManager) mrecyclerView.getLayoutManager();
        mrecyclerView.addOnScrollListener(new RecyclerView.OnScrollListener() {

            @Override
            public void onScrollStateChanged(@NonNull RecyclerView recyclerView, int newState) {
                super.onScrollStateChanged(recyclerView, newState);
                if (newState == AbsListView.OnScrollListener.SCROLL_STATE_FLING) {
                    totalItemCount = linearLayoutManager.getItemCount();
                    lastVisibleItem = linearLayoutManager.findLastVisibleItemPosition();

                    if (!isLoading && totalItemCount <= (lastVisibleItem + visibleThreshold)) {
                        if (mOnLoadMoreListener != null) {
                            mOnLoadMoreListener.onLoadMore();
                        }
                        isLoading = true;
                    }
                }
            }
        });
    }

    public void showUsersHateLike(int position, String type) {
        LoveHateUsersListFragment loveHateUsersListFragment =
                LoveHateUsersListFragment.newInstance(String.valueOf(postDetailsModelArrayList.get(position).getPOST_ID()),
                        type);
        loveHateUsersListFragment.show(activity.getSupportFragmentManager(), "LoveHateUserListFragment");
    }

    public void setOnLoadMoreListener(OnLoadMoreListener mOnLoadMoreListener) {
        this.mOnLoadMoreListener = mOnLoadMoreListener;
    }

    @Override
    public int getItemViewType(int position) {
        return postDetailsModelArrayList.get(position) == null ? VIEW_TYPE_LOADING : VIEW_TYPE_ITEM;
    }

    public class LoadingViewHolder extends RecyclerView.ViewHolder {
        public ProgressBar progressBar;

        public LoadingViewHolder(View itemView) {
            super(itemView);
            progressBar = itemView.findViewById(R.id.progressBar1);
        }
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        if (viewType == VIEW_TYPE_ITEM) {
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.custom_post, parent, false);
            return new UserPostAdapter.MyViewHolder(view);
        } else if (viewType == VIEW_TYPE_LOADING) {
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.progressbar, parent, false);
            return new UserPostAdapter.LoadingViewHolder(view);
        }
        return null;
    }

    @Override
    public void onBindViewHolder(RecyclerView.ViewHolder holder, final int position) {

//        Log.d("img_p", postDetailsModelArrayList.get(position).getPOST_CONTENT());
        if (holder instanceof UserPostAdapter.MyViewHolder) {
            UserPostAdapter.MyViewHolder userViewHolder = (UserPostAdapter.MyViewHolder) holder;
            if (postDetailsModelArrayList.get(position).getBOOKMARK_FLAG().equalsIgnoreCase("Y")) {
                ((MyViewHolder) holder).bookmark.setImageDrawable(context.getResources().getDrawable(R.drawable.bookmark_click));
            }

            if (postDetailsModelArrayList.get(position).getMEDIA_FLAG().equals(context.getString(R.string.flay_Y))) {
                if (!postDetailsModelArrayList.get(position).getMEDIA_CONTENT().equals("") ||
                        postDetailsModelArrayList.get(position).getMEDIA_CONTENT() != null) {
                    userViewHolder.postImagesRecycler.setVisibility(View.VISIBLE);
                    List<String> imageList = Arrays.asList(postDetailsModelArrayList.get(position).getMEDIA_CONTENT().toString().split(","));
                    FeedPostImagesAdapter feedPostImagesAdapter = new FeedPostImagesAdapter(context, imageList);
                    userViewHolder.postImagesRecycler.setAdapter(feedPostImagesAdapter);
                    if (imageList.size() > 1)
                        userViewHolder.postImagesRecycler.addItemDecoration(new LinePagerIndicatorDecoration());
                }
            } else {
                userViewHolder.postImagesRecycler.setVisibility(View.GONE);
            }

            userViewHolder.webImageLayout.setVisibility(View.GONE);
            userViewHolder.remaningDescription.setVisibility(View.GONE);

            userViewHolder.hcount.setText("" + postDetailsModelArrayList.get(position).getHCOUNT());
            userViewHolder.likecount.setText("" + postDetailsModelArrayList.get(position).getLCOUNT());
            userViewHolder.commentcount.setText("" + postDetailsModelArrayList.get(position).getPOST_COMMENT_COUNT());
            userViewHolder.username.setText(postDetailsModelArrayList.get(position).getUSERNAME());
            userViewHolder.time.setText(new TimeUtils().time(postDetailsModelArrayList.get(position).getPOST_DATETIME(), context));
            userViewHolder.postedText.setVisibility(View.VISIBLE);
            userViewHolder.postedText.setText(postDetailsModelArrayList.get(position).getPOST_CONTENT()
                    .replaceAll("(?m)(^ *| +(?= |$))", "")
                    .replaceAll("(?m)^$([\r\n]+?)(^$[\r\n]+?^)+", "$1").trim());

            Log.d("taggy", userViewHolder.postedText.getText().toString());

            if (postDetailsModelArrayList.get(position).getPOST_CONTENT().trim().length() > 500) {
                TextViewResizable.makeTextViewResizable(userViewHolder.postedText, 5, "More", true);

            }
            userViewHolder.delete.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    activity.showConfirmation(String.valueOf(postDetailsModelArrayList.get(position).getPOST_ID()));
                }
            });

            userViewHolder.showThisPost.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    FeedFragment.scrollPosition = position;
                    Intent intent = new Intent(context, Comments.class);
                    intent.putExtra(POSTCONTENT, postDetailsModelArrayList.get(position));
                    intent.putExtra("mypost", 0);
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    context.startActivity(intent);
                }
            });

            userViewHolder.statuschangeLayout.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    Intent intent = new Intent(context, CommonInterests.class);
                    intent.putExtra(TOPICID, postDetailsModelArrayList.get(position).getTOPICID());
                    intent.putExtra(USERNAME, postDetailsModelArrayList.get(position).getUSERNAME());
                    intent.putExtra(PROFILEIMAGE, postDetailsModelArrayList.get(position).getDP_URL());
                    context.startActivity(intent);
                }
            });

            userViewHolder.share.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    DynamicLinksUtil.createDynamicUri(String.valueOf(new Preference(context).getIntPref(Constants.TOPICID)),
                            String.valueOf(postDetailsModelArrayList.get(position).getPOST_ID()),
                            context,
                            postDetailsModelArrayList.get(position).getPostCellModel().getPostTitle(),
                            postDetailsModelArrayList.get(position).getPostCellModel().getUrlForPreview(), "");
                }
            });

            userViewHolder.webPageImageLayout.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    for (int i = 0; i < UserPostDetails.webLoadModelArrayList.size(); i++) {
                        if (UserPostDetails.webLoadModelArrayList.get(i).getPOST_ID() == postDetailsModelArrayList.get(position).getPOST_ID()) {
                            CustomTabsIntent.Builder customIntent = new CustomTabsIntent.Builder();
                            customIntent.setToolbarColor(context.getResources().getColor(R.color.colorPrimary));
                            customIntent.enableUrlBarHiding();
                            customIntent.setShowTitle(true);
                            Comments.openCustomTab(context, customIntent.build(), Uri.parse(UserPostDetails.webLoadModelArrayList.get(i).getUrl()));
//                            Intent browserIntent = new Intent(context, WebViewLoaderActivity.class);
//                            browserIntent.putExtra(Constants.URL_TO_LOAD, UserPostDetails.webLoadModelArrayList.get(i).getUrl());
//                            context.startActivity(browserIntent);
                        }
                    }
                }
            });


            userViewHolder.imgLikePost.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    //feedFragment.doLikePost(String.valueOf(postDetailsModelArrayList.get(position).getPOST_ID()), String.valueOf(postDetailsModelArrayList.get(position).getTOPICID()), String.valueOf(postDetailsModelArrayList.get(position).getPOST_ID()), true, position);
                }
            });
            userViewHolder.imgDisLikePost.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    //feedFragment.doLikePost(String.valueOf(postDetailsModelArrayList.get(position).getPOST_ID()), String.valueOf(postDetailsModelArrayList.get(position).getTOPICID()), String.valueOf(postDetailsModelArrayList.get(position).getPOST_ID()), false,position);
                }
            });

            userViewHolder.imgComment.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    FeedFragment.scrollPosition = position;
                    Intent intent = new Intent(context, Comments.class);
                    intent.putExtra(POSTCONTENT, postDetailsModelArrayList.get(position));
                    intent.putExtra("mypost", 0);
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    context.startActivity(intent);
                }
            });
            userViewHolder.bookmark.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    FeedFragment.removeBookmark(String.valueOf(postDetailsModelArrayList.get(position).getPOST_ID()), userViewHolder.bookmark);
                }
            });
            /*userViewHolder.editUser.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    Intent intent = new Intent(context, EditComment.class);
                    intent.putExtra(TOPICID, postDetailsModelArrayList.get(position).getTOPICID());
                    intent.putExtra(TOPICDESCRIPTION, postDetailsModelArrayList.get(position).getPOST_CONTENT());
                    intent.putExtra(POSTID, postDetailsModelArrayList.get(position).getPOST_ID());
                    intent.putExtra(MEDIACONTENT, postDetailsModelArrayList.get(position).getMEDIA_CONTENT().toString());
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    context.startActivity(intent);

                }
            });*/

            if (postDetailsModelArrayList.get(position).getUSERNAME().equalsIgnoreCase(userName)) {
                userViewHolder.editDeleteIv.setVisibility(View.VISIBLE);
                if (userViewHolder.removeUser != null) {
                    userViewHolder.removeUser.setVisibility(View.GONE);
                }
            } else {
                userViewHolder.editDeleteIv.setVisibility(View.GONE);
                if (userViewHolder.removeUser != null){
                    userViewHolder.removeUser.setVisibility(View.VISIBLE);
                }
            }
            if (!postDetailsModelArrayList.get(position).getUSERNAME().isEmpty()) {
                if (userViewHolder.status_text != null) {
                    userViewHolder.status_text.setVisibility(View.VISIBLE);
                }
                userViewHolder.userImage.setVisibility(View.VISIBLE);
                userViewHolder.status_text.setText(String.valueOf(postDetailsModelArrayList.get(position).getUSERNAME().charAt(0)));
                GradientDrawable background = (GradientDrawable) userViewHolder.statuschangeLayout.getBackground();
                background.setColor(new ColorChange(context).colorChange(String.valueOf(postDetailsModelArrayList.get(position).getUSERNAME().toLowerCase().charAt(0))));
                try {
                    Glide.with(context).load(postDetailsModelArrayList.get(position)
                            .getDP_URL()).transform(new CircleCrop(), new RoundedCorners(5)).into(userViewHolder.userImage);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            try {
                if (postDetailsModelArrayList.get(position).getPOST_CONTENT().contains("/")) {
                    userViewHolder.postImagesRecycler.setVisibility(View.GONE);
                    userViewHolder.webImageLayout.setVisibility(View.VISIBLE);
                    userViewHolder.remaningDescription.setVisibility(View.GONE);
                    new ExtractWebURLPreview(context, userViewHolder.webpageImage, userViewHolder.header, userViewHolder.description,
                            userViewHolder.webPageImageLayout, userViewHolder.postedText, this)
                            .getPreview(postDetailsModelArrayList.get(position).getPOST_CONTENT(),
                                    String.valueOf(postDetailsModelArrayList.get(position).getPOST_ID()));
                } else {
                    userViewHolder.webPageImageLayout.setVisibility(View.GONE);
                }
                if (ExtractWebURLPreview.extractLinks(postDetailsModelArrayList.get(position).getPOST_CONTENT()).length > 1)
                    userViewHolder.webPageImageLayout.setVisibility(View.GONE);

                if (postDetailsModelArrayList.get(position).getMEDIA_FLAG().equals(context.getString(R.string.flay_Y))) {
                    if (!postDetailsModelArrayList.get(position).getMEDIA_CONTENT().equals("") ||
                            postDetailsModelArrayList.get(position).getMEDIA_CONTENT() != null) {
                        if (userViewHolder.webPageImageLayout.getVisibility() == View.VISIBLE) {
                            userViewHolder.attachmentTv.setVisibility(View.VISIBLE);
                            userViewHolder.attachmentIv.setVisibility(View.VISIBLE);
                        } else userViewHolder.postImagesRecycler.setVisibility(View.VISIBLE);
                    }
                } else {
                    userViewHolder.attachmentTv.setVisibility(View.GONE);
                    userViewHolder.attachmentIv.setVisibility(View.GONE);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        } else if (holder instanceof LoadingViewHolder) {
            LoadingViewHolder loadingViewHolder = (LoadingViewHolder) holder;
            loadingViewHolder.progressBar.setIndeterminate(true);
        }
    }

    @Override
    public void onLinkClicked(String linkText, TextViewClickMovement.LinkType linkType) {
//        Intent browserIntent = new Intent(context, WebViewLoaderActivity.class);
//        browserIntent.putExtra(Constants.URL_TO_LOAD, linkText);
//        context.startActivity(browserIntent);
    }

    @Override
    public void onLongClick(String text) {

    }

    @Override
    public int getItemCount() {
        return postDetailsModelArrayList == null ? 0 : postDetailsModelArrayList.size();
    }

    public void setLoaded() {
        isLoading = false;
    }

}
