package com.opinito.social.Utils;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.util.Patterns;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.browser.customtabs.CustomTabsIntent;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.engine.DiskCacheStrategy;
import com.bumptech.glide.load.resource.bitmap.RoundedCorners;
import com.bumptech.glide.request.RequestOptions;
import com.mega4tech.linkpreview.GetLinkPreviewListener;
import com.mega4tech.linkpreview.LinkPreview;
import com.mega4tech.linkpreview.LinkUtil;
import com.opinito.social.Activity.Comments;
import com.opinito.social.Activity.WebViewLoaderActivity;
import com.opinito.social.Adapter.CommentsAdapter;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.TextViewClickMovement;
import com.opinito.social.LinkService;
import com.opinito.social.Model.WebLoadModel;
import com.opinito.social.R;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;

public class ExtractWebURLPreview {

    private Activity context;
    private WebLoadModel webLoadModel;
    private ImageView webPreviewImage;
    private TextView previewHeader;
    private TextView previewDescription;
    private RelativeLayout webPageImageLayout;
    private TextView remainingText;
    private TextViewClickMovement.OnTextViewClickMovementListener textViewClickMovement;

    public ExtractWebURLPreview(Activity context, ImageView webPreviewImage,
                                TextView previewHeader, TextView previewDescription, RelativeLayout webPageImageLayout,
                                TextView remainingText, TextViewClickMovement.OnTextViewClickMovementListener textViewClickMovement) {
        this.context = context;
        this.webPreviewImage = webPreviewImage;
        this.previewHeader = previewHeader;
        this.previewDescription = previewDescription;
        this.webPageImageLayout = webPageImageLayout;
        this.remainingText = remainingText;
        this.textViewClickMovement = textViewClickMovement;
    }

    public void getPreview(String postContent, String postId) {
        try {
            LinkUtil.getInstance().getLinkPreview(context,
                    extractLinks(postContent)[0],
                    new GetLinkPreviewListener() {
                        @Override
                        public void onSuccess(final LinkPreview link) {
                            try {
                                webLoadModel = new WebLoadModel(link.getTitle(),
                                        link.getImageLink(),
                                        link.getLink(),
                                        link.getDescription(),
                                        Long.parseLong(postId),
                                        postContent.substring(extractLinks(postContent)[0].length()));
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                            checkAndPostLinkPreviewForUrl(link.getLink(), webLoadModel);
                            context.runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    setWebLayoutPreview(webLoadModel, postContent);
                                }
                            });
                        }

                        @Override
                        public void onFailed(final Exception e) {
                        }
                    });
        } catch (Exception e) {

        }
    }

    private void setWebLayoutPreview(WebLoadModel webLoadModel, String postContent) {
        try {
            Animation slideDown = AnimationUtils.loadAnimation(context, R.anim.slide_down);
            webPageImageLayout.setVisibility(View.VISIBLE);
            previewDescription.setVisibility(View.VISIBLE);
            previewHeader.setVisibility(View.VISIBLE);
            webPreviewImage.setVisibility(View.VISIBLE);
            remainingText.setVisibility(View.VISIBLE);
//            webPageImageLayout.startAnimation(slideDown);
            Glide.with(context)
                    .load(webLoadModel.getLead_image_url())
                    .transform(new RoundedCorners(25))
                    .placeholder(R.mipmap.ic_launcher)
                    .into(webPreviewImage);
            previewHeader.setText(webLoadModel.getTitle());
            previewDescription.setText(webLoadModel.getExcerpt());
            webPageImageLayout.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
//                    Intent browserIntent = new Intent(context, WebViewLoaderActivity.class);
//                    browserIntent.putExtra(Constants.URL_TO_LOAD, webLoadModel.getUrl());
//                    context.startActivity(browserIntent);
                    CustomTabsIntent.Builder customIntent = new CustomTabsIntent.Builder();
                    customIntent.setToolbarColor(context.getResources().getColor(R.color.colorPrimary));
                    customIntent.enableUrlBarHiding();
                    customIntent.setShowTitle(true);
                    Comments.openCustomTab(context,customIntent.build(), Uri.parse(webLoadModel.getUrl()));
                }
            });
            remainingText.setText(postContent
                    .replaceAll("(?m)(^ *| +(?= |$))", "")
                    .replaceAll("(?m)^$([\r\n]+?)(^$[\r\n]+?^)+", "$1").trim());
            remainingText.setMovementMethod(new TextViewClickMovement(textViewClickMovement, context));
            if (remainingText.getText().toString().replace(extractLinks(postContent)[0], "")
                    .replaceAll("(?m)(^ *| +(?= |$))", "")
                    .replaceAll("(?m)^$([\r\n]+?)(^$[\r\n]+?^)+", "$1").trim().isEmpty())
                remainingText.setVisibility(View.GONE);
//            if (extractLinks(postContent).length > 1)
//                webPageImageLayout.setVisibility(View.GONE);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private synchronized void checkAndPostLinkPreviewForUrl(String link, WebLoadModel webLoadModel) {
        Intent intent = new Intent(context, LinkService.class);
        intent.putExtra("webmodelObj", webLoadModel);
        intent.putExtra("linkPreviewUrl", link);
        context.startService(intent);
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
