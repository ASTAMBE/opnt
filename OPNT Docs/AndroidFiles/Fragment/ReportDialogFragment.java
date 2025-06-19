package com.opinito.social.Fragment;

import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;
import androidx.fragment.app.Fragment;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

import com.google.gson.JsonObject;
import com.opinito.social.Activity.Comments;
import com.opinito.social.Activity.DashBoard;
import com.opinito.social.BuildConfig;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.Preference;
import com.opinito.social.Interface.RetrofitNetworkInterface;
import com.opinito.social.Model.BaseResponse;
import com.opinito.social.R;
import com.opinito.social.RetrofitClient;
import com.opinito.social.databinding.FragmentReportDialogBinding;

import java.net.InterfaceAddress;
import java.util.HashMap;
import java.util.Map;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

import static com.facebook.FacebookSdk.getApplicationContext;

/**
 * A simple {@link Fragment} subclass.
 */
public class ReportDialogFragment extends DialogFragment implements View.OnClickListener {

    private FragmentReportDialogBinding binding;
    private DialogListener dialogListener;
    public static String POSTID = "";
    public static String TYPE = "";


    public ReportDialogFragment(DialogListener dialogListener) {
        this.dialogListener = dialogListener;
        // Required empty public constructor
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        binding = FragmentReportDialogBinding.inflate(inflater, container, false);
        View view = binding.getRoot();
        return view;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        init();
    }

    private void init() {
        setCancelable(false);
        getDialog().getWindow().setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
        binding.blockLayout.setOnClickListener(this);
        binding.cancelIv.setOnClickListener(this);
        binding.kickOutLayout.setOnClickListener(this);
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        binding = null;
    }

    @Override
    public int getTheme() {
        return R.style.MyCustomDialogTheme;
    }

    public void removeUser() {
        try {
            RetrofitNetworkInterface retrofitNetworkInterface = RetrofitClient.createService(RetrofitNetworkInterface.class);
            JsonObject kickOutJsonObject = new JsonObject();
            kickOutJsonObject.addProperty("userid", new Preference(getActivity()).getPref(Constants.USERID));
            kickOutJsonObject.addProperty("KOtype", TYPE);
            kickOutJsonObject.addProperty("SourceId", POSTID);
            Map<String, String> header = new HashMap<>();
            header.put("X-ACCESS-KEY", BuildConfig.APP_ID);
            header.put("Token", new Preference(getApplicationContext()).getPref(Constants.token));
            Call<BaseResponse> removeuserCall = retrofitNetworkInterface.KOUserCommon(header ,kickOutJsonObject);
            removeuserCall.enqueue(new Callback<BaseResponse>() {
                @Override
                public void onResponse(Call<BaseResponse> call, Response<BaseResponse> response) {
                    try {
                        if (response.code() == 200) {
                            if (response.body().getStatus().equalsIgnoreCase(Constants.SUCCESS)) {
                                ActivityFragment.refresh = true;
                                FeedFragment.postIdRemoveUser = "";
                                FeedFragment.refresh = true;
                                Comments.KOType = "";
                                Comments.postIdRemoveUser = "";
                                Toast.makeText(getContext(), getString(R.string.user_removed), Toast.LENGTH_SHORT).show();
                                dialogListener.onCompleteBlock(TYPE);
                                dismiss();
                            }
                        } else
                            Toast.makeText(getContext(), getString(R.string.something_went_wrong), Toast.LENGTH_SHORT).show();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }

                @Override
                public void onFailure(Call<BaseResponse> call, Throwable t) {
                }
            });

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {

            case R.id.kick_out_layout:
                dialogListener.onKickOut();
                removeUser();
                break;

            case R.id.cancel_iv:
                dismiss();
                break;

            case R.id.block_layout:
                dialogListener.onBlockClicked();
                dismiss();
                break;
        }
    }

    public interface DialogListener {
        void onBlockClicked();
        void onCompleteBlock(String type);
        void onKickOut();
    }

}
