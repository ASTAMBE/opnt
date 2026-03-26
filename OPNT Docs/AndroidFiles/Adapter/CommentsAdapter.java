package com.opinito.social.Adapter;

import android.app.Activity;
import android.app.Dialog;
import android.content.Intent;
import android.graphics.drawable.GradientDrawable;

import androidx.browser.customtabs.CustomTabsIntent;
import androidx.core.text.HtmlCompat;
import androidx.recyclerview.widget.RecyclerView;

import android.net.Uri;
import android.os.Build;
import android.os.Handler;
import android.text.Html;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.bitmap.CircleCrop;
import com.bumptech.glide.load.resource.bitmap.RoundedCorners;
import com.opinito.social.Activity.Comments;
import com.opinito.social.Activity.FullScreenImageActivity;
import com.opinito.social.Activity.CommonInterests;
import com.opinito.social.Activity.WebViewLoaderActivity;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.Preference;
import com.opinito.social.Constants.TextViewClickMovement;
import com.opinito.social.Interface.CommentsInterface;
import com.opinito.social.Model.CommentModel;
import com.opinito.social.R;
import com.opinito.social.Utils.ColorChange;
import com.opinito.social.Utils.ExtractWebURLPreview;

import com.opinito.social.Utils.TextViewResizable;
import com.opinito.social.Utils.TimeUtils;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static com.opinito.social.Activity.Comments.postDetail;
import static com.opinito.social.Constants.TextViewClickMovement.*;

/**
 * Created by 502687702 on 8/8/2017.
 */

public class CommentsAdapter extends RecyclerView.Adapter<CommentsAdapter.MyViewHolder> implements TextViewClickMovement.OnTextViewClickMovementListener {
    private List<CommentModel.Data> commentModelArrayList;
    Activity context;
    EditText comments;
    String selectedUser;
    private Comments commentsObj;
    private String IMAGELIST = "imageslist";
    private String IMAGEPOSITION = "imagePosition";
    private CommentsInterface commentsInterface;
    private final String TOPICID = "topicid";
    private final String USERNAME = "username";
    private final String PROFILEIMAGE = "profileimage";
    private final String NETWORKNAMELIST = "networknamelist";

    public class MyViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener {
        private TextView username;
        private TextView comments;
        private ImageView editpost;
        private ImageView deletepost;
        private RelativeLayout statuschangeLayout;
        private LinearLayout editDeleteLayout, editDeleteLayoutParent;
        private TextView status_text;
        private TextView updatedAt;
        private ImageView remove_user, userImage, previewImage;
        private TextView imagesCount;
        private RelativeLayout attachmentLayout;
        private TextView attachmentTv;
        //parent post
        private TextView viewMoreTv;
        private ImageView parentPostComment;
        private TextView parentPostBy;
        private TextView parentPostContent;
        private TextView parentPostTime;
        private RelativeLayout parentPostLayout;
        private ImageView commentIv;
        private ImageView parentPostMediaContentIv;
        private RelativeLayout webPreviewLayout;
        private TextView previewHeader;
        private TextView previewDescription;
        private ImageView webPageImage;
        private ImageView removeParentUser, deleteParentpost;

        public MyViewHolder(View view) {
            super(view);
            commentIv = view.findViewById(R.id.child_posts_comment_iv);
            removeParentUser = view.findViewById(R.id.remove_user_parent);
            removeParentUser.setOnClickListener(this);
            deleteParentpost = view.findViewById(R.id.delete_post_parent);
            parentPostMediaContentIv = view.findViewById(R.id.parent_post_media_iv);
            deleteParentpost.setOnClickListener(this);
            commentIv.setOnClickListener(this);
            username = view.findViewById(R.id.username);
            comments = view.findViewById(R.id.description);
            attachmentLayout = view.findViewById(R.id.attachment_layout);
            attachmentLayout.setOnClickListener(this);
            attachmentTv = view.findViewById(R.id.attachment_tv);
            previewHeader = itemView.findViewById(R.id.preview_header);
            previewDescription = itemView.findViewById(R.id.preview_description);
            webPageImage = itemView.findViewById(R.id.web_preview_image);
            previewImage = view.findViewById(R.id.preview_image);
            previewImage.setOnClickListener(this);
            statuschangeLayout = view.findViewById(R.id.status_change_layout_parent_post);
            statuschangeLayout.setOnClickListener(this);
            parentPostBy = itemView.findViewById(R.id.parent_post_by);
            parentPostContent = itemView.findViewById(R.id.parent_post_content);
            parentPostTime = itemView.findViewById(R.id.parent_post_updated);
            viewMoreTv = itemView.findViewById(R.id.view_more_tv);
            viewMoreTv.setOnClickListener(this);
            status_text = view.findViewById(R.id.status_text);
            editDeleteLayout = view.findViewById(R.id.edit_post_layout);
            parentPostLayout = itemView.findViewById(R.id.parent_post_layout);
            editDeleteLayoutParent = itemView.findViewById(R.id.posts_like_dislike_layout_parent);
            parentPostLayout.setVisibility(View.GONE);
            userImage = view.findViewById(R.id.status_image);
            updatedAt = view.findViewById(R.id.updated_time_comment);
            editpost = view.findViewById(R.id.editPost);
            editpost.setVisibility(View.GONE);
            deletepost = view.findViewById(R.id.deletePost);
            remove_user = view.findViewById(R.id.remove_user);
            imagesCount = view.findViewById(R.id.images_count);
            parentPostComment = itemView.findViewById(R.id.posts_comment_iv_parent);
            parentPostComment.setOnClickListener(this);
            webPreviewLayout = itemView.findViewById(R.id.web_page_image_layout);
            webPreviewLayout.setOnClickListener(this);
        }

        @Override
        public void onClick(View v) {
            switch (v.getId()) {

                case R.id.status_change_layout_parent_post:
                    Intent intent = new Intent(context, CommonInterests.class);
                    intent.putExtra(TOPICID, Integer.parseInt(commentModelArrayList.get(getAdapterPosition()).getTOPICID()));
                    intent.putExtra(USERNAME, commentModelArrayList.get(getAdapterPosition()).getCOMMENTBYUNAME());
                    if (commentModelArrayList.get(getAdapterPosition()).getDPURL() != null)
                        intent.putExtra(PROFILEIMAGE, commentModelArrayList.get(getAdapterPosition()).getDPURL().toString());
                    context.startActivity(intent);
                    break;

                case R.id.remove_user_parent:
                    commentsInterface.removeUser(context.getString(R.string.comment_type),
                            commentModelArrayList.get(getAdapterPosition()).getPARENTCOMMENTID());
                    break;

                case R.id.delete_post_parent:
                    commentsInterface.deletePost(commentModelArrayList.get(getAdapterPosition()).getPARENTCOMMENTID());
                    break;

                case R.id.posts_comment_iv_parent:
                    commentsInterface.postDetail(commentModelArrayList.get(getAdapterPosition()),
                            context.getString(R.string.parent_post));
                    break;

                case R.id.child_posts_comment_iv:
                    if(!postDetail.getPOST_ACTION_TYPE().toLowerCase().equalsIgnoreCase("l") &&
                            !postDetail.getPOST_ACTION_TYPE().toLowerCase().equalsIgnoreCase("h")){

                        Dialog topicPopup = new Dialog(context);
                        topicPopup.setContentView(R.layout.image_dialog);
                        TextView cancel = topicPopup.findViewById(R.id.okay_text);

                        cancel.setOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                topicPopup.dismiss();
                            }
                        });
                        topicPopup.getWindow().setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                        topicPopup.show();
                    }else {
                        commentsInterface.postDetail(commentModelArrayList.get(getAdapterPosition()),
                                context.getString(R.string.child_post));
                    }

                    break;

                case R.id.view_more_tv:
                    viewMoreTv.setVisibility(View.GONE);
                    editDeleteLayoutParent.setVisibility(View.VISIBLE);
                    if (!commentModelArrayList.get(getAdapterPosition()).getPARENTMEDIACONTENT().isEmpty())
                        parentPostMediaContentIv.setVisibility(View.VISIBLE);
                    RelativeLayout.LayoutParams layoutParam = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT,
                            RelativeLayout.LayoutParams.WRAP_CONTENT);
                    parentPostLayout.setLayoutParams(layoutParam);
                    new Handler().postDelayed(new Runnable() {
                        @Override
                        public void run() {
                            viewMoreTv.setVisibility(View.VISIBLE);
                            editDeleteLayoutParent.setVisibility(View.GONE);
                            parentPostMediaContentIv.setVisibility(View.GONE);
                            RelativeLayout.LayoutParams layoutParam = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT,
                                    160);
                            parentPostLayout.setLayoutParams(layoutParam);
                        }
                    }, 5000);
                    break;

                case R.id.attachment_layout:
                    ArrayList<String> arrImageList = new ArrayList<String>(Arrays.asList(
                            commentModelArrayList.get(getAdapterPosition()).getMEDIACONTENT().split(",")
                    ));
                    Intent fullScreenIntent = new Intent(context, FullScreenImageActivity.class);
                    fullScreenIntent.putStringArrayListExtra(IMAGELIST, arrImageList);
                    fullScreenIntent.putExtra(IMAGEPOSITION, 0);
                    context.startActivity(fullScreenIntent);
            }
        }
    }

    public CommentsAdapter(List<CommentModel.Data> commentModelArrayList, Activity context, EditText comments,
                           Comments commentsObj, CommentsInterface commentsInterface) {
        this.commentModelArrayList = commentModelArrayList;
        this.context = context;
        this.comments = comments;
        this.commentsObj = commentsObj;
        this.commentsInterface = commentsInterface;
        selectedUser = new Preference(context).getPref(Constants.USERNAME);
    }

    @Override
    public CommentsAdapter.MyViewHolder onCreateViewHolder(ViewGroup parent, int viewType)
    {
        View itemView = LayoutInflater.from(parent.getContext())
                 .inflate(R.layout.custom_comment, parent , false);
        return new CommentsAdapter.MyViewHolder(itemView);
    }

    @Override
    public void onBindViewHolder(MyViewHolder holder, final int position) {
        holder.comments.setText(commentModelArrayList.get(position).getCOMMENTCONTENT()
                .replaceAll("(?m)(^ *| +(?= |$))", "")
                .replaceAll("(?m)^$([\r\n]+?)(^$[\r\n]+?^)+", "$1").trim());

        if (commentModelArrayList.get(position).getPARENTMEDIACONTENT() != null){
            if (!commentModelArrayList.get(position).getPARENTMEDIACONTENT().isEmpty()) {
                List<String> imageList = Arrays.asList(commentModelArrayList.get(position).getPARENTMEDIACONTENT().split(","));
                Glide.with(context).load(imageList.get(0).trim()).into(holder.parentPostMediaContentIv);
                holder.parentPostMediaContentIv.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Intent fullScreenIntent = new Intent(context, FullScreenImageActivity.class);
                        fullScreenIntent.putStringArrayListExtra(IMAGELIST, new ArrayList<>(imageList));
                        fullScreenIntent.putExtra(IMAGEPOSITION, 0);
                        context.startActivity(fullScreenIntent);
                    }
                });
            }
        }

        if (commentModelArrayList.get(position).getCOMMENTCONTENT().contains("/")) {
            new ExtractWebURLPreview(context, holder.webPageImage, holder.previewHeader, holder.previewDescription,
                    holder.webPreviewLayout, holder.comments, this)
                    .getPreview(commentModelArrayList.get(position).getCOMMENTCONTENT(),
                            commentModelArrayList.get(position).getCOMMENTID());
            if (holder.comments.getText().toString().trim().isEmpty())
                holder.comments.setVisibility(View.GONE);
            else if (holder.comments.getText().toString().trim().length() > 200) {
                holder.comments.setVisibility(View.VISIBLE);
            }
        }
        if (commentModelArrayList.get(position).getCOMMENTTYPE() != null) {
            if (!commentModelArrayList.get(position).getCOMMENTTYPE().equals(context.getString(R.string.comment_on_post))) {
                if (commentModelArrayList.get(position).getPARENTCOMMENTUNAME() != null) {
                    holder.parentPostLayout.setVisibility(View.VISIBLE);
                    if (!commentModelArrayList.get(position).getPARENTCOMMENTCONTENT().trim().equals(context.getString(R.string.deleted_content))) {
                        holder.parentPostComment.setVisibility(View.VISIBLE);
                        if (commentModelArrayList.get(position).getPARENTCOMMENTUNAME().
                                equals(new Preference(context).getPref(Constants.USERNAME))) {
                            holder.deleteParentpost.setVisibility(View.INVISIBLE);
                            holder.removeParentUser.setVisibility(View.GONE);
                        } else {
                            holder.deleteParentpost.setVisibility(View.GONE);
                            holder.removeParentUser.setVisibility(View.VISIBLE);
                        }
                    } else {
                        holder.deleteParentpost.setVisibility(View.GONE);
                        holder.removeParentUser.setVisibility(View.INVISIBLE);
                    }
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                        holder.parentPostBy.setText(Html.fromHtml(
                                String.format(
                                        context.getString(R.string.replying_to), commentModelArrayList.get(position).getPARENTCOMMENTUNAME()),
                                HtmlCompat.FROM_HTML_SEPARATOR_LINE_BREAK_LIST_ITEM));
                    } else {
                        holder.parentPostBy.setText(
                                String.format(
                                        context.getString(R.string.replying_to), commentModelArrayList.get(position).getPARENTCOMMENTUNAME()));
                    }
//                    holder.parentPostBy.setTextColor(new ColorChange(context).
//                            colorChange(String.valueOf(commentModelArrayList.get(position).getPARENTCOMMENTUNAME().toLowerCase().charAt(0))));
                    holder.parentPostContent.setText(commentModelArrayList.get(position).getPARENTCOMMENTCONTENT()
                            .replaceAll("(?m)(^ *| +(?= |$))", "")
                            .replaceAll("(?m)^$([\r\n]+?)(^$[\r\n]+?^)+", "$1").trim());
                    if (commentModelArrayList.get(position).getPARENTCOMMENTCONTENT().contains("/"))
                        holder.parentPostContent.setMovementMethod(new TextViewClickMovement(this, context));
                    if (commentModelArrayList.get(position).getPARENTCOMMENTCONTENT().trim().length() > 500)
                        TextViewResizable.makeTextViewResizable(holder.parentPostContent, 5, "More",
                                true);
                }
            } else
                holder.parentPostLayout.setVisibility(View.GONE);
        }
        if (commentModelArrayList.get(position).getMEDIAFLAG() != null) {
            if (commentModelArrayList.get(position).getMEDIAFLAG().equals(context.getString(R.string.flay_Y))) {
                List<String> imageList = Arrays.asList(commentModelArrayList.get(position).getMEDIACONTENT().split(","));
                    holder.attachmentLayout.setVisibility(View.VISIBLE);
                    holder.attachmentTv.setText(String.format(context.getString(R.string.attachment_count_text),
                            String.valueOf(imageList.size())));
            } else {
                holder.attachmentLayout.setVisibility(View.GONE);
            }
        }
        holder.username.setText(commentModelArrayList.get(position).getCOMMENTBYUNAME());
        holder.updatedAt.setText(new TimeUtils().time(commentModelArrayList.get(position).getCOMMENTDTM(), context));
        if (commentModelArrayList.get(position).getCOMMENTCONTENT().length() > 500)
            TextViewResizable.makeTextViewResizable(holder.comments, 5, "More", true);
        if (!commentModelArrayList.get(position).getCOMMENTBYUNAME().isEmpty()) {
            if (commentModelArrayList.get(position).getDPURL() == null || commentModelArrayList.get(position).getDPURL().equals("")) {
                holder.userImage.setVisibility(View.GONE);
                holder.status_text.setVisibility(View.VISIBLE);
                holder.status_text.setText(
                        String.valueOf(commentModelArrayList.get(position).getCOMMENTBYUNAME().charAt(0)));
                GradientDrawable background = (GradientDrawable) holder.statuschangeLayout.getBackground();
                background.setColor(new ColorChange(context).colorChange(
                        String.valueOf(commentModelArrayList.get(position).getCOMMENTBYUNAME().toLowerCase().charAt(0))));
            } else {
                holder.userImage.setVisibility(View.VISIBLE);
                holder.status_text.setVisibility(View.VISIBLE);
                holder.status_text.setText(
                        String.valueOf(commentModelArrayList.get(position).getCOMMENTBYUNAME().charAt(0)));
                GradientDrawable background = (GradientDrawable) holder.statuschangeLayout.getBackground();
                background.setColor(new ColorChange(context).colorChange(
                        String.valueOf(commentModelArrayList.get(position).getCOMMENTBYUNAME().toLowerCase().charAt(0))));
                Glide.with(context).load(commentModelArrayList.get(position)
                        .getDPURL().toString()).transform(new CircleCrop(),
                        new RoundedCorners(5))
                        .into(holder.userImage);
            }
        }
        if (!commentModelArrayList.get(position).getCOMMENTCONTENT().trim().equals(context.getString(R.string.deleted_content))) {
            holder.commentIv.setVisibility(View.VISIBLE);
            if (commentModelArrayList.get(position).getCOMMENTBYUNAME().equalsIgnoreCase(selectedUser)) {
                //holder.editpost.setVisibility(View.VISIBLE);
                holder.deletepost.setVisibility(View.VISIBLE);
                holder.editDeleteLayout.setVisibility(View.VISIBLE);
                holder.remove_user.setVisibility(View.GONE);
            } else {
                holder.editDeleteLayout.setVisibility(View.GONE);
                //holder.editpost.setVisibility(View.GONE);
                holder.deletepost.setVisibility(View.GONE);
                holder.remove_user.setVisibility(View.VISIBLE);
            }
        }

        /*holder.editpost.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Comments.isEdit = true;
                Comments.commentId = commentModelArrayList.get(position).getCOMMENT_ID();
                new SoftKeypad().show(context);
                comments.setText(commentModelArrayList.get(position).getCOMMENT_CONTENT());
                comments.requestFocus();
            }
        });*/

        holder.deletepost.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                commentsInterface.deletePost(commentModelArrayList.get(position).getCOMMENTID());
            }
        });

        holder.remove_user.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                commentsInterface.removeUser(context.getString(R.string.comment_type),
                        commentModelArrayList.get(position).getCOMMENTID());
            }
        });
    }

    @Override
    public int getItemCount() {
        return commentModelArrayList.size();
    }

    @Override
    public void onLinkClicked(String linkText, LinkType linkType) {
        CustomTabsIntent.Builder customIntent = new CustomTabsIntent.Builder();
        customIntent.setToolbarColor(context.getResources().getColor(R.color.colorPrimary));
        customIntent.enableUrlBarHiding();
        customIntent.setShowTitle(true);
        Comments.openCustomTab(context,customIntent.build(), Uri.parse(linkText));
//        Intent browserIntent = new Intent(context, WebViewLoaderActivity.class);
//        browserIntent.putExtra(Constants.URL_TO_LOAD, linkText);
//        context.startActivity(browserIntent);
    }

    @Override
    public void onLongClick(String text) {

    }
}
