package com.opinito.social.Fragment;

import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.Toast;

import com.google.gson.JsonObject;
import com.jakewharton.rxbinding2.widget.RxTextView;
import com.opinito.social.Activity.Comments;
import com.opinito.social.Activity.DashBoard;
import com.opinito.social.BuildConfig;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.Preference;
import com.opinito.social.Interface.RetrofitNetworkInterface;
import com.opinito.social.Model.BaseResponse;
import com.opinito.social.R;
import com.opinito.social.RetrofitClient;
import com.opinito.social.databinding.FragmentBlockUserBinding;

import java.util.HashMap;
import java.util.Map;

import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.CompositeDisposable;
import io.reactivex.observers.DisposableObserver;
import io.reactivex.schedulers.Schedulers;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

import static com.facebook.FacebookSdk.getApplicationContext;

public class BlockUserFragment extends DialogFragment implements View.OnClickListener {

    public static String CONTENTID = "";
    public static String TYPE = "";
    private String reportTypeCode = "";
    private FragmentBlockUserBinding binding;
    private BlockDialogListener blockDialogListener;
    private CompositeDisposable compositeDisposable = new CompositeDisposable();

    public BlockUserFragment(BlockDialogListener blockDialogListener) {
        this.blockDialogListener = blockDialogListener;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        binding = FragmentBlockUserBinding.inflate(inflater, container, false);
        View view = binding.getRoot();
        return view;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        setCancelable(false);
        getDialog().getWindow().setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
        binding.navBackIv.setOnClickListener(this);
        binding.cancelIv.setOnClickListener(this);
        binding.reportButton.setOnClickListener(this);
        binding.charCountTv.setText(String.format(getString(R.string.get_100), Constants.ZERO));
        binding.radioGroup.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(RadioGroup group, int checkedId) {
                RadioButton selectedRadio = (RadioButton) view.findViewById(group.getCheckedRadioButtonId());
                if (group.getCheckedRadioButtonId() != -1) {
                    if (selectedRadio.getText().toString().equals(getString(R.string.other))) {
                        reportTypeCode = "OT";
                        binding.reasonEdittext.setEnabled(true);
                        binding.reasonEdittext.requestFocus();
                    } else {
                        binding.reasonEdittext.setEnabled(true);
                        binding.reasonEdittext.setText("");
                        if (selectedRadio.getText().toString().equals(getString(R.string.nudity_or_porn)))
                            reportTypeCode = "NP";
                        else if (selectedRadio.getText().toString().equals(getString(R.string.violent_speech)))
                            reportTypeCode = "VS";
                        else if (selectedRadio.getText().toString().equals(getString(R.string.threatening_speech)))
                            reportTypeCode = "TS";
                    }
                }
            }
        });
        compositeDisposable.add(
                RxTextView
                        .textChanges(binding.reasonEdittext)
                        .subscribeOn(Schedulers.io())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribeWith(new DisposableObserver<CharSequence>() {
                            @Override
                            public void onNext(CharSequence textChangeEvent) {
                                binding.charCountTv.setText(String.format(getString(R.string.get_100),
                                        String.valueOf(textChangeEvent.length())));
                            }

                            @Override
                            public void onError(Throwable e) {

                            }

                            @Override
                            public void onComplete() {

                            }
                        })
        );
    }

    public void reportUser() {
        try {
            RetrofitNetworkInterface retrofitNetworkInterface = RetrofitClient.createService(RetrofitNetworkInterface.class);
            JsonObject reportJson = new JsonObject();
            reportJson.addProperty("userid", new Preference(getActivity()).getPref(Constants.USERID));
            reportJson.addProperty("contentType", TYPE);
            reportJson.addProperty("contentID", CONTENTID);
            reportJson.addProperty("reportTypeCode", reportTypeCode);
            reportJson.addProperty("userComment", binding.reasonEdittext.getText().toString().trim());
            Map<String, String> header = new HashMap<>();
            header.put("X-ACCESS-KEY", BuildConfig.APP_ID);
            header.put("Token", new Preference(getApplicationContext()).getPref(Constants.token));
            Call<BaseResponse> removeuserCall = retrofitNetworkInterface.userContentReport(header ,reportJson);
            removeuserCall.enqueue(new Callback<BaseResponse>() {
                @Override
                public void onResponse(Call<BaseResponse> call, Response<BaseResponse> response) {
                    try {
                        if (response.code() == 200) {
                            if (response.body().getStatus().equalsIgnoreCase(Constants.SUCCESS)) {
                                ActivityFragment.refresh = true;
                                FeedFragment.refresh = true;
                                FeedFragment.postIdRemoveUser = "";
                                FeedFragment.postIdRemoveUser = "";
                                Comments.KOType = "";
                                Comments.postIdRemoveUser = "";
                                blockDialogListener.onCompleteReport(TYPE);
                                Toast.makeText(getContext(), getString(R.string.reported_successfully), Toast.LENGTH_SHORT).show();
                                dismiss();
                            } else
                                Toast.makeText(getContext(), getString(R.string.something_went_wrong), Toast.LENGTH_SHORT).show();
                        } else
                            Toast.makeText(getContext(), getString(R.string.internal_error_occured), Toast.LENGTH_SHORT).show();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }

                @Override
                public void onFailure(Call<BaseResponse> call, Throwable t) {
                    Toast.makeText(getContext(), getString(R.string.internal_error_occured), Toast.LENGTH_SHORT).show();
                }
            });

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        compositeDisposable.clear();
        binding = null;
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.report_button:
                if (!reportTypeCode.equals("")) {
                    if (reportTypeCode.equals("OT")) {
                        if (!binding.reasonEdittext.getText().toString().trim().isEmpty())
                            reportUser();
                        else
                            Toast.makeText(getContext(), R.string.explain_cause_of_report, Toast.LENGTH_SHORT).show();
                    } else
                        reportUser();
                } else
                    Toast.makeText(getContext(), R.string.select_report_reason, Toast.LENGTH_SHORT).show();
                break;

            case R.id.nav_back_iv:
//                blockDialogListener.onNavBackCliked();
                dismiss();
                break;

            case R.id.cancel_iv:
                dismiss();
                break;
        }
    }

    public interface BlockDialogListener {
        void onNavBackCliked();
        void onCompleteReport(String type);
    }
}
