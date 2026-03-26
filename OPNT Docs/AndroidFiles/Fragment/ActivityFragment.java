package com.opinito.social.Fragment;

import static com.facebook.FacebookSdk.getApplicationContext;
import static com.opinito.social.Utils.UtilsKt.customToolBar;

import android.content.Intent;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.google.gson.JsonObject;
import com.opinito.social.Activity.AllConversationsActivity;
import com.opinito.social.Adapter.ProfileAdapter;
import com.opinito.social.BuildConfig;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.Preference;
import com.opinito.social.Interface.RetrofitNetworkInterface;
import com.opinito.social.Model.ProfileModel;
import com.opinito.social.R;
import com.opinito.social.RetrofitClient;
import com.opinito.social.Utils.ColorChange;
import com.opinito.social.Utils.Customize;
import com.opinito.social.Utils.UserUtils;
import com.opinito.social.databinding.FragmentActivityBinding;

import org.jetbrains.annotations.NotNull;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

/**
 * A simple {@link Fragment} subclass.
 */
public class ActivityFragment extends Fragment implements View.OnClickListener {

    private ArrayList<ProfileModel.Data> profileModelArrayList = new ArrayList<>();
    private FragmentActivityBinding binding;
    private ProfileAdapter mAdapter;
    public static Boolean refresh = true;

    public ActivityFragment() {
        // Required empty public constructor
    }


    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        binding = FragmentActivityBinding.inflate(inflater, container, false);
        View view = binding.getRoot();

        AppCompatActivity activity = (AppCompatActivity) requireActivity();
        customToolBar(requireContext(), false,
                getString(R.string.activity), activity.getSupportActionBar());
        init();
        return view;
    }

    private void init() {

        mAdapter = new ProfileAdapter(profileModelArrayList, getActivity());
        binding.username.setText(new Preference(getContext()).getPref(Constants.USERNAME));
        binding.countryCode.setText(new Preference(getContext()).getPref(Constants.COUNTRYCODE));
        binding.flagIvActivity.setImageDrawable(getResources().getDrawable(Customize.getCountryFlagRes(
                new Preference(getContext()).getPref(Constants.COUNTRYCODE), requireContext()
        )));
        if (!new Preference(getContext()).getPref(Constants.PROFILEIMAGE).isEmpty())
            binding.profileImageText.setVisibility(View.GONE);
        else binding.profileImageText.setVisibility(View.VISIBLE);
        try {
            binding.profileImageText.setText(
                    String.valueOf(new Preference(getContext()).getPref(Constants.USERNAME).toUpperCase().charAt(0)));
            GradientDrawable background = (GradientDrawable) binding.profileImage.getBackground();
            background.setColor(new ColorChange(getContext()).colorChange(
                    String.valueOf(new Preference(getContext()).getPref(Constants.USERNAME).toLowerCase().charAt(0))));
            Glide.with(requireActivity())
                    .load(new Preference(getContext()).getPref(Constants.PROFILEIMAGE))
                    .apply(RequestOptions.circleCropTransform())
                    .into(binding.profileImage);
        } catch (Exception e) {
            e.printStackTrace();
        }
        binding.profileRecyclerView.setAdapter(mAdapter);
        binding.addMoreInterest.setOnClickListener(this);
        binding.allConversationsTv.setOnClickListener(this);
        displayTopics();
    }

    public void displayTopics() {
        try {
            binding.countryCode.setText(new Preference(getContext()).getPref(Constants.COUNTRYCODE));
            binding.flagIvActivity.setImageDrawable(getResources().getDrawable(Customize.getCountryFlagRes(
                    new Preference(getContext()).getPref(Constants.COUNTRYCODE), requireContext()
            )));
            binding.progressBar.setVisibility(View.VISIBLE);
        } catch (Exception e) {
            e.printStackTrace();
        }
        try {
            RetrofitNetworkInterface retrofitNetworkInterface = RetrofitClient.createService(RetrofitNetworkInterface.class);
            JsonObject jsonObject = new JsonObject();
            jsonObject.addProperty("userid", new Preference(getActivity()).getPref(Constants.USERID));
            Map<String, String> header = new HashMap<>();
            header.put("X-ACCESS-KEY", BuildConfig.APP_ID);
            header.put("Token", new Preference(getApplicationContext()).getPref(Constants.token));
            Call<ProfileModel> call = retrofitNetworkInterface.MyActivity(header, jsonObject);
            call.enqueue(new Callback<ProfileModel>() {
                @Override
                public void onResponse(@NotNull Call<ProfileModel> call, @NotNull Response<ProfileModel> response) {
                    try {
                        binding.progressBar.setVisibility(View.GONE);
                        if (response.code() == 200) {
                            if (response.body() != null) {
                                if (response.body().getData().size() > 0) {
                                    if (response.body().getData().get(0).getChatEnabledFlag().equals(getString(R.string.flay_Y))) {
                                        binding.allConversationsTv.setVisibility(View.VISIBLE);
                                        binding.arrowAllConversation.setVisibility(View.VISIBLE);
                                        new Preference(getActivity()).saveBooleanPref(Constants.ISCHATENABLED, true);
                                    } else {
                                        new Preference(getActivity()).saveBooleanPref(Constants.ISCHATENABLED, false);
                                        binding.allConversationsTv.setVisibility(View.GONE);
                                        binding.arrowAllConversation.setVisibility(View.GONE);
                                    }
                                }
                                ProfileFragment.refresh = true;
                                profileModelArrayList.clear();
                                profileModelArrayList.addAll(response.body().getData());
           /*                 ArrayList<ProfileModel.Data> profileModelArrayList1 = new ArrayList<>();

                            for(int i=0;i<profileModelArrayList.size();i++)
                            {
                                if (new Preference(getContext()).getIntPref(Constants.TOPICCARTID)==Integer.parseInt(profileModelArrayList.get(i).getTOPICID())){
                                    profileModelArrayList1.add(profileModelArrayList.get(i));
                                }

                            }
                            profileModelArrayList.clear();
                            profileModelArrayList.addAll(profileModelArrayList1);
                            Log.d("testingak", "init: "+new Preference(getContext()).getPref(Constants.TOPICCARTID)+"--"+profileModelArrayList.size());*/

                                mAdapter.notifyDataSetChanged();
                            }
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }

                @Override
                public void onFailure(@NotNull Call<ProfileModel> call, @NotNull Throwable t) {
                    try {
                        binding.progressBar.setVisibility(View.GONE);
                        Toast.makeText(getActivity(), R.string.internal_error_occured, Toast.LENGTH_SHORT).show();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            });
        } catch (Exception e) {
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
            case R.id.add_more_interest:
                getActivity().onBackPressed();
//                    ((DashBoard) getActivity()).Tabselection(1);
                break;

            case R.id.all_conversations_tv:
                if (UserUtils.isGuestUser(getActivity())) {
                    UserUtils.showConfirmation(getActivity());
                } else {
                    Intent intent = new Intent(getActivity(), AllConversationsActivity.class);
                    startActivity(intent);
                }
                break;
        }
    }
}
