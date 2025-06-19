package com.opinito.social.Adapter;

import android.app.Activity;
import android.content.Intent;
import android.graphics.drawable.GradientDrawable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.opinito.social.Activity.ChatMessagesActivity;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.Preference;
import com.opinito.social.Model.LoveHatePostCountModel;
import com.opinito.social.R;
import com.opinito.social.Utils.ColorChange;
import com.opinito.social.Utils.TimeUtils;
import com.opinito.social.Utils.UserUtils;
import com.opinito.social.databinding.CustomUserListBinding;

import java.util.List;

public class LoveHateUserListAdapter extends RecyclerView.Adapter<LoveHateUserListAdapter.LoveHateViewHolder> {

    private List<LoveHatePostCountModel.Data> dataList;
    private CustomUserListBinding binding;
    private Activity activity;

    public LoveHateUserListAdapter(List<LoveHatePostCountModel.Data> dataList, Activity activity) {
        this.dataList = dataList;
        this.activity = activity;
    }

    public class LoveHateViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener {
        public LoveHateViewHolder(@NonNull View itemView) {
            super(itemView);
            binding.chatWithUserIv.setOnClickListener(this);
        }

        @Override
        public void onClick(View v) {
            if (v.getId() == R.id.chat_with_user_iv) {
                try {
                    if (UserUtils.isGuestUser(activity)) {
                        UserUtils.showConfirmation(activity);
                    } else {
                        Intent chatIntent = new Intent(activity, ChatMessagesActivity.class);
                        chatIntent.putExtra(Constants.PROFILEIMAGE, dataList.get(getAdapterPosition()).getdPURL() != null?
                                dataList.get(getAdapterPosition()).getdPURL().toString() : "");
                        chatIntent.putExtra(Constants.USERNAME, dataList.get(getAdapterPosition()).getUSERNAME());
                        activity.startActivity(chatIntent);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    }

    @NonNull
    @Override
    public LoveHateViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        binding = CustomUserListBinding.inflate(LayoutInflater.from(parent.getContext()), parent, false);
        return new LoveHateUserListAdapter.LoveHateViewHolder(binding.getRoot());
    }

    @Override
    public void onBindViewHolder(@NonNull LoveHateViewHolder holder, int position) {
        if (new Preference(activity).getPref(Constants.USERNAME).equals(dataList.get(position).getUSERNAME())) {
            binding.usernameTv.setText(String.format(activity.getString(R.string.you_text), dataList.get(position).getUSERNAME()));
            binding.chatWithUserIv.setVisibility(View.GONE);
        } else {
            binding.usernameTv.setText(dataList.get(position).getUSERNAME());
            if (new Preference(activity).getBooleanPref(Constants.ISCHATENABLED)) {
                if (dataList.get(position).getCHF().equals(activity.getString(R.string.flay_Y))) {
                    binding.disabledChatTv.setVisibility(View.GONE);
                    binding.chatWithUserIv.setVisibility(View.VISIBLE);
                } else {
                    binding.disabledChatTv.setVisibility(View.VISIBLE);
                    binding.chatWithUserIv.setVisibility(View.GONE);
                }
            }
        }
        binding.updatedTime.setText(new TimeUtils().timeAgo(dataList.get(position).getPOSTACTIONDTM()));
        binding.profileImageText.setText(String.valueOf(dataList.get(position).getUSERNAME().toUpperCase().charAt(0)));
        GradientDrawable background = (GradientDrawable) binding.profileImage.getBackground();
        background.setColor(new ColorChange(activity).colorChange(
                String.valueOf(dataList.get(position).getUSERNAME().toLowerCase().charAt(0))));
        if (dataList.get(position).getdPURL() != null) {
            if (!dataList.get(position).getdPURL().toString().trim().isEmpty())
                binding.profileImageText.setVisibility(View.GONE);
            Glide.with(activity)
                    .load(dataList.get(position).getdPURL().toString())
                    .apply(RequestOptions.circleCropTransform())
                    .into(binding.profileImage);
        }
    }

    @Override
    public int getItemCount() {
        return dataList.size();
    }
}
