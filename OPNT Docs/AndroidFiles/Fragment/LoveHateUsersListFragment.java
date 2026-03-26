package com.opinito.social.Fragment;

import android.graphics.drawable.Drawable;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import android.text.Spannable;
import android.text.SpannableString;
import android.text.style.ImageSpan;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.material.bottomsheet.BottomSheetDialogFragment;
import com.google.gson.JsonObject;
import com.opinito.social.Adapter.LoveHateUserListAdapter;
import com.opinito.social.BuildConfig;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.Preference;
import com.opinito.social.Interface.RetrofitNetworkInterface;
import com.opinito.social.Model.LoveHatePostCountModel;
import com.opinito.social.R;
import com.opinito.social.RetrofitClient;
import com.opinito.social.Utils.DynamicLinksUtil;
import com.opinito.social.databinding.FragmentLoveHateUsersListBinding;

import java.util.HashMap;
import java.util.Map;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

import static com.facebook.FacebookSdk.getApplicationContext;


public class LoveHateUsersListFragment extends BottomSheetDialogFragment implements View.OnClickListener {

    private static final String ARG_POSTID = "postId";
    private static final String ARG_REACT_TYPE = "reactType";
    private String postId;
    private String reactType;
    private FragmentLoveHateUsersListBinding binding;

    public LoveHateUsersListFragment() {
        // Required empty public constructor
    }

    public static LoveHateUsersListFragment newInstance(String postId, String reactType) {
        LoveHateUsersListFragment fragment = new LoveHateUsersListFragment();
        Bundle args = new Bundle();
        args.putString(ARG_POSTID, postId);
        args.putString(ARG_REACT_TYPE, reactType);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
            postId = getArguments().getString(ARG_POSTID);
            reactType = getArguments().getString(ARG_REACT_TYPE);
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        binding = FragmentLoveHateUsersListBinding.inflate(inflater, container, false);
        return binding.getRoot();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        init();
        showLoveHateCount();
    }

    private void init() {
        binding.actionBarBack.setOnClickListener(this);
        binding.emptyTv.setOnClickListener(this);
        setContentWithIconLoveHate(getString(R.string.love_text_header), binding.actionBarTitle);
        setContentWithIconLoveHate(getString(R.string.no_user_count_found), binding.emptyTv);
    }

    private void setContentWithIconLoveHate(String text, TextView textView) {
        SpannableString sb = new SpannableString(text);
        Drawable drawable1;
        if (reactType.equals(getString(R.string.love)))
            drawable1 = getResources().getDrawable(R.drawable.ic_love_grey);
        else
            drawable1 = getResources().getDrawable(R.drawable.ic_skull_grey);
        if (text.equals(getString(R.string.love_text_header)))
            drawable1.setTint(getResources().getColor(R.color.white));
        else
            drawable1.setTint(getResources().getColor(R.color.colourGrey));
        drawable1.setBounds(0, 0, getResources().getDimensionPixelSize(R.dimen.spannable_img_btn_width), getResources().getDimensionPixelSize(R.dimen.spannable_img_btn_width));
        int pos1 = text.indexOf('@');
        ImageSpan span1 = new ImageSpan(drawable1, ImageSpan.ALIGN_CENTER);
        sb.setSpan(span1, pos1, pos1 + 1, Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
        textView.setText(sb);
    }

    private void showLoveHateCount() {
        try {
            RetrofitNetworkInterface retrofitNetworkInterface = RetrofitClient.createService(RetrofitNetworkInterface.class);
            JsonObject loveHateCountObject = new JsonObject();
            loveHateCountObject.addProperty("userid", new Preference(getActivity()).getPref(Constants.USERID));
            loveHateCountObject.addProperty("postid", postId);
            loveHateCountObject.addProperty("reactType", reactType);
            loveHateCountObject.addProperty("from", Constants.ZERO);
            loveHateCountObject.addProperty("to", Constants.to);
            Map<String, String> header = new HashMap<>();
            header.put("X-ACCESS-KEY", BuildConfig.APP_ID);
            header.put("Token", new Preference(getApplicationContext()).getPref(Constants.token));
            Call<LoveHatePostCountModel> countModelCall = retrofitNetworkInterface.whoLHMyPost(header , loveHateCountObject);
            countModelCall.enqueue(new Callback<LoveHatePostCountModel>() {
                @Override
                public void onResponse(Call<LoveHatePostCountModel> call, Response<LoveHatePostCountModel> response) {
                    try {
                        if (response.code() == 200) {
                            if (response.body() != null) {
                                if (response.body().getStatus().equals(getString(R.string.success_status))) {
                                    if (response.body().getData().size() > 0) {
                                        binding.showLoveHateUsersRecycler.setVisibility(View.VISIBLE);
                                        binding.emptyTv.setVisibility(View.GONE);
                                        LoveHateUserListAdapter loveHateUserListAdapter = new LoveHateUserListAdapter(response.body().getData(), getActivity());
                                        binding.showLoveHateUsersRecycler.setAdapter(loveHateUserListAdapter);
                                    } else {
                                        binding.showLoveHateUsersRecycler.setVisibility(View.GONE);
                                        binding.emptyTv.setVisibility(View.VISIBLE);
                                    }
                                } else {
                                    binding.showLoveHateUsersRecycler.setVisibility(View.GONE);
                                    binding.emptyTv.setVisibility(View.VISIBLE);
                                }
                            }
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }

                @Override
                public void onFailure(Call<LoveHatePostCountModel> call, Throwable t) {
                    Toast.makeText(getActivity(), getString(R.string.something_went_wrong), Toast.LENGTH_SHORT).show();
                }
            });
        } catch (Exception e) {
            Toast.makeText(getActivity(), getString(R.string.internal_error_occured), Toast.LENGTH_SHORT).show();
            e.printStackTrace();
        }
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        binding = null;
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.action_bar_back:
                dismiss();
                break;

            case R.id.empty_tv:
                DynamicLinksUtil.createDynamicUri(String.valueOf(new Preference(getActivity()).getIntPref(Constants.TOPICID)),
                        postId, getContext(), "", "","");
                break;
        }
    }
}
