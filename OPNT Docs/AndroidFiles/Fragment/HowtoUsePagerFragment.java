package com.opinito.social.Fragment;

import android.graphics.Typeface;
import android.graphics.drawable.Drawable;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import android.text.Spannable;
import android.text.SpannableString;
import android.text.style.ImageSpan;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.opinito.social.R;
import com.opinito.social.databinding.FragmentHowtoUsePagerBinding;

public class HowtoUsePagerFragment extends Fragment {

    private static final String ARG_POSITION = "position";
    private int mPosition;
    private FragmentHowtoUsePagerBinding binding;

    public HowtoUsePagerFragment() {
        // Required empty public constructor
    }

    public static HowtoUsePagerFragment newInstance(int param1) {
        HowtoUsePagerFragment fragment = new HowtoUsePagerFragment();
        Bundle args = new Bundle();
        args.putInt(ARG_POSITION, param1);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
            mPosition = getArguments().getInt(ARG_POSITION);
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        binding = FragmentHowtoUsePagerBinding.inflate(inflater, container, false);
        return binding.getRoot();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        if (mPosition == 0) {
            binding.parentContainer.setBackgroundColor(getResources().getColor(R.color.colorPrimary));
            binding.headerText.setVisibility(View.VISIBLE);
            binding.firstTv.setVisibility(View.GONE);
            binding.optional.setVisibility(View.GONE);
            binding.stepOne.setVisibility(View.GONE);
            binding.howToUseIv.setImageDrawable(getResources().getDrawable(R.drawable.ic_logo_new));
            binding.howToUseIv.setPadding(200, 150, 200, 150);
        } else {
            binding.parentContainer.setBackgroundColor(getResources().getColor(R.color.white));
            binding.howToUseIv.setVisibility(View.GONE);
            binding.headerText.setVisibility(View.GONE);
            binding.firstTv.setVisibility(View.VISIBLE);
            binding.stepOne.setVisibility(View.VISIBLE);
            binding.optional.setVisibility(View.VISIBLE);
            if (mPosition == 1) {
                binding.firstTv.setText(getString(R.string._01));
                binding.stepOne.setVisibility(View.VISIBLE);
                binding.stepOne.setText(getString(R.string.your_opinion_is_your_network));
                binding.stepOne.setTypeface(binding.stepOne.getTypeface(), Typeface.BOLD);
                binding.optional.setText(getString(R.string.optional_text_detailed));
            } else if (mPosition == 2) {
                binding.firstTv.setText(getString(R.string._02));
                binding.stepOne.setVisibility(View.GONE);
//                setContentWithIcon(getString(R.string.desp_content));
            }
        }
    }

    private void setContentWithIcon(String contents) {
        SpannableString sb = new SpannableString(contents);
        Drawable drawable = getResources().getDrawable(R.drawable.ic_cart_selected);
        drawable.setBounds(0, 0, getResources().getDimensionPixelSize(R.dimen.spannable_img_btn_width), getResources().getDimensionPixelSize(R.dimen.spannable_img_btn_width));
        int pos = contents.indexOf('!');
        ImageSpan span = new ImageSpan(drawable, ImageSpan.ALIGN_CENTER);
        sb.setSpan(span, pos, pos + 1, Spannable.SPAN_INCLUSIVE_EXCLUSIVE);

        SpannableString sb1 = new SpannableString(sb);
        Drawable drawable1 = getResources().getDrawable(R.drawable.ic_feed_selected);
        drawable1.setBounds(0, 0, getResources().getDimensionPixelSize(R.dimen.spannable_img_btn_width),
                getResources().getDimensionPixelSize(R.dimen.spannable_img_btn_width));
        int pos1 = contents.indexOf('%');
        ImageSpan spane1 = new ImageSpan(drawable1, ImageSpan.ALIGN_CENTER);
        sb1.setSpan(spane1, pos1, pos1 + 1, Spannable.SPAN_INCLUSIVE_EXCLUSIVE);

        SpannableString sb2 = new SpannableString(sb1);
        Drawable drawable2 = getResources().getDrawable(R.drawable.ic_create_post_selected);
        drawable2.setBounds(0, 0, getResources().getDimensionPixelSize(R.dimen.spannable_img_btn_width),
                getResources().getDimensionPixelSize(R.dimen.spannable_img_btn_width));
        int indexOf = contents.indexOf('^');
        ImageSpan span1 = new ImageSpan(drawable2, ImageSpan.ALIGN_CENTER);
        sb2.setSpan(span1, indexOf, indexOf + 1, Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
        binding.optional.setText(sb2);
    }

    private void setContentswithStepOneIcon(String contents, View view) {
        SpannableString sb = new SpannableString(contents);
        Drawable drawable = getResources().getDrawable(R.drawable.ic_cart_selected);
        drawable.setBounds(0, 0, getResources().getDimensionPixelSize(R.dimen.spannable_img_btn_width), getResources().getDimensionPixelSize(R.dimen.spannable_img_btn_width));
        int pos = contents.indexOf('!');
        ImageSpan span = new ImageSpan(drawable, ImageSpan.ALIGN_CENTER);
        sb.setSpan(span, pos, pos + 1, Spannable.SPAN_INCLUSIVE_EXCLUSIVE);

        SpannableString sb1 = new SpannableString(sb);
        Drawable drawable1 = getResources().getDrawable(R.drawable.ic_love_grey);
        drawable1.setTint(getResources().getColor(R.color.colorPrimary));
        drawable1.setBounds(0, 0, getResources().getDimensionPixelSize(R.dimen.spannable_img_btn_width), getResources().getDimensionPixelSize(R.dimen.spannable_img_btn_width));
        int pos1 = contents.indexOf('@');
        ImageSpan span1 = new ImageSpan(drawable1, ImageSpan.ALIGN_BOTTOM);
        sb1.setSpan(span1, pos1, pos1 + 1, Spannable.SPAN_INCLUSIVE_EXCLUSIVE);

        SpannableString sb2 = new SpannableString(sb1);
        Drawable drawable2 = getResources().getDrawable(R.drawable.ic_skull_grey);
        drawable2.setTint(getResources().getColor(R.color.colorPrimary));
        drawable2.setBounds(0, 0, getResources().getDimensionPixelSize(R.dimen.spannable_img_btn_width), getResources().getDimensionPixelSize(R.dimen.spannable_img_btn_width));
        int pos2 = contents.indexOf('$');
        ImageSpan span2 = new ImageSpan(drawable2, ImageSpan.ALIGN_BOTTOM);
        sb2.setSpan(span2, pos2, pos2 + 1, Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
        binding.stepOne.setText(sb2);
    }

    private void setContentswithOptionIcon(String contents, View view) {
        SpannableString sb = new SpannableString(contents);
        Drawable drawable = getResources().getDrawable(R.drawable.ic_love_grey);
        drawable.setTint(getResources().getColor(R.color.colorPrimary));
        drawable.setBounds(0, 0, getResources().getDimensionPixelSize(R.dimen.spannable_img_btn_width),
                getResources().getDimensionPixelSize(R.dimen.spannable_img_btn_width));
        int pos = contents.indexOf('@');
        ImageSpan span = new ImageSpan(drawable, ImageSpan.ALIGN_BOTTOM);
        sb.setSpan(span, pos, pos + 1, Spannable.SPAN_INCLUSIVE_EXCLUSIVE);

        SpannableString sb1 = new SpannableString(sb);
        Drawable drawable1 = getResources().getDrawable(R.drawable.ic_skull_grey);
        drawable1.setTint(getResources().getColor(R.color.colorPrimary));
        drawable1.setBounds(0, 0, getResources().getDimensionPixelSize(R.dimen.spannable_img_btn_width),
                getResources().getDimensionPixelSize(R.dimen.spannable_img_btn_width));
        int pos1 = contents.indexOf('$');
        ImageSpan span1 = new ImageSpan(drawable1, ImageSpan.ALIGN_BOTTOM);
        sb1.setSpan(span1, pos1, pos1 + 1, Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
        binding.optional.setText(sb1);
    }

    private void setContentswithStepTwoIcon(String contents, View view) {
        SpannableString sb = new SpannableString(contents);
        Drawable drawable = getResources().getDrawable(R.drawable.ic_feed_selected);
        drawable.setBounds(0, 0, getResources().getDimensionPixelSize(R.dimen.spannable_img_btn_width),
                getResources().getDimensionPixelSize(R.dimen.spannable_img_btn_width));
        int pos = contents.indexOf('%');
        ImageSpan span = new ImageSpan(drawable, ImageSpan.ALIGN_CENTER);
        sb.setSpan(span, pos, pos + 1, Spannable.SPAN_INCLUSIVE_EXCLUSIVE);

        SpannableString sb1 = new SpannableString(sb);
        Drawable drawable1 = getResources().getDrawable(R.drawable.ic_create_post_unselected);
        drawable1.setBounds(0, 0, getResources().getDimensionPixelSize(R.dimen.spannable_img_btn_width),
                getResources().getDimensionPixelSize(R.dimen.spannable_img_btn_width));
        int pos1 = contents.indexOf('^');
        ImageSpan span1 = new ImageSpan(drawable1, ImageSpan.ALIGN_CENTER);
        sb1.setSpan(span1, pos1, pos1 + 1, Spannable.SPAN_INCLUSIVE_EXCLUSIVE);

        SpannableString sb2 = new SpannableString(sb1);
        Drawable drawable2 = getResources().getDrawable(R.drawable.ic_comment);
        drawable2.setBounds(0, 0, getResources().getDimensionPixelSize(R.dimen.spannable_img_btn_width),
                getResources().getDimensionPixelSize(R.dimen.spannable_img_btn_width));
        int pos2 = contents.indexOf('*');
        ImageSpan span2 = new ImageSpan(drawable2, ImageSpan.ALIGN_BOTTOM);
        sb2.setSpan(span2, pos2, pos2 + 1, Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
        binding.stepOne.setText(sb2);
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        binding = null;
    }
}
