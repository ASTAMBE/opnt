package com.opinito.social.Utils;

import android.app.Activity;
import android.content.Context;
import android.graphics.drawable.GradientDrawable;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.appcompat.app.ActionBar;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.bitmap.CircleCrop;
import com.bumptech.glide.load.resource.bitmap.RoundedCorners;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.Preference;
import com.opinito.social.R;

import dagger.hilt.android.internal.Contexts;

public class Customize {

    public static void customSupportBar(Activity activity, ActionBar actionBar, String titleText, String userPostTitle) {
        final ViewGroup actionBarLayout = (ViewGroup) activity.getLayoutInflater().inflate(
                R.layout.action_bar,
                null);
        actionBar.setDisplayHomeAsUpEnabled(false);
        actionBar.setDisplayShowTitleEnabled(false);
        actionBar.setDisplayShowCustomEnabled(true);
        actionBar.setCustomView(actionBarLayout);
        final ImageView navigateBackIv = actionBarLayout.findViewById(R.id.action_bar_back);
        navigateBackIv.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                activity.onBackPressed();
            }
        });
        final ImageView logo = actionBarLayout.findViewById(R.id.action_bar_logo);
        logo.setVisibility(View.GONE);
        final TextView title = actionBarLayout.findViewById(R.id.action_bar_title);
        final TextView topicName = actionBarLayout.findViewById(R.id.topic_name);
        title.setText(titleText);
        if (titleText.equals(activity.getString(R.string.app_name)) ||
                titleText.equals(activity.getString(R.string.discussion))
                || titleText.equals(activity.getString(R.string.common_interests))
                || titleText.equals(activity.getString(R.string.search))
                || titleText.equals(activity.getString(R.string.switch_profile))) {
            navigateBackIv.setVisibility(View.VISIBLE);
            logo.setVisibility(View.VISIBLE);
        }
        if (titleText.equals(activity.getString(R.string.app_name)))
            navigateBackIv.setVisibility(View.GONE);
        if (userPostTitle != null) {
            topicName.setVisibility(View.VISIBLE);
            topicName.setText(String.format("%s..", userPostTitle.substring(0, 4)));
        } else if (titleText.equals(activity.getString(R.string.discussion))) {
            topicName.setVisibility(View.VISIBLE);
            if (new Preference(activity).getPref(Constants.USERNAME).length() > 8)
                topicName.setText(String.format("%s..", new Preference(activity).getPref(Constants.USERNAME).substring(0, 8)));
            else topicName.setText(new Preference(activity).getPref(Constants.USERNAME));
        }
    }

    public static void getChatSupportBar(Activity activity, ActionBar actionBar, String userName, String profileUrl){
        final ViewGroup actionBarLayout = (ViewGroup) activity.getLayoutInflater().inflate(
                R.layout.chat_action_bar,
                null);
        actionBar.setDisplayHomeAsUpEnabled(false);
        actionBar.setDisplayShowTitleEnabled(false);
        actionBar.setDisplayShowCustomEnabled(true);
        actionBar.setCustomView(actionBarLayout);
        final ImageView navigateBackIv = actionBarLayout.findViewById(R.id.nav_back_iv);
        navigateBackIv.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                activity.onBackPressed();
            }
        });
        final ImageView profileImageView = actionBarLayout.findViewById(R.id.profileImage);
        final TextView chatUsernameTv = actionBarLayout.findViewById(R.id.chat_username_tv);
        final TextView profileImageText = actionBarLayout.findViewById(R.id.profile_image_text);
        if (userName != null) {
            chatUsernameTv.setText(userName);
            profileImageText.setText(String.valueOf(userName.charAt(0)));
            GradientDrawable background = (GradientDrawable) profileImageView.getBackground();
            background.setColor(new ColorChange(activity).colorChange(String.valueOf(userName.toLowerCase().charAt(0))));
        }
        try {
            if (profileUrl != null) {
                if (!profileUrl.isEmpty() && !profileUrl.equals("null")) {
                    Glide.with(activity)
                            .load(profileUrl)
                            .transform(new CircleCrop(),
                                    new RoundedCorners(5))
                            .into(profileImageView);
                    profileImageText.setVisibility(View.GONE);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static int getCountryFlagRes(String countryCode, Context context){
        if (countryCode.equals(context.getString(R.string.IND)))
            return R.drawable.indflag;
        else if(countryCode.equals(context.getString(R.string.GGG)) || countryCode.equals(context.getString(R.string.global)))
                return R.drawable.gggflag;
        else if ((countryCode.equals(context.getString(R.string.USA))))
            return R.drawable.usaflag;
        else return R.drawable.gggflag;
    }
}
