package com.opinito.social.Adapter;

import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.GradientDrawable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.bitmap.CircleCrop;
import com.bumptech.glide.load.resource.bitmap.RoundedCorners;
import com.opinito.social.Activity.ChatMessagesActivity;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Model.ChatUsersListModel;
import com.opinito.social.R;
import com.opinito.social.Utils.ColorChange;
import com.opinito.social.Utils.TimeUtils;
import com.opinito.social.databinding.ItemChatUserBinding;

import java.util.List;

public class ChatUsersListAdapter extends RecyclerView.Adapter<ChatUsersListAdapter.ChatUsersViewHolder>{

    private Context context;
    private List<ChatUsersListModel> usersList;
    private ItemChatUserBinding binding;

    public ChatUsersListAdapter(Context context, List<ChatUsersListModel> usersList) {
        this.context = context;
        this.usersList = usersList;
    }

    class ChatUsersViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener {
        public ChatUsersViewHolder(@NonNull View itemView) {
            super(itemView);
            binding.chatParentLayout.setOnClickListener(this);
        }

        @Override
        public void onClick(View v) {
            if (v.getId() == R.id.chat_parent_layout){
                try {
                    Intent chatIntent = new Intent(context, ChatMessagesActivity.class);
                    chatIntent.putExtra(Constants.PROFILEIMAGE, usersList.get(getAdapterPosition()).getProfileUrl());
                    chatIntent.putExtra(Constants.USERNAME, usersList.get(getAdapterPosition()).getUsername());
                    context.startActivity(chatIntent);
                } catch (Exception e){
                    e.printStackTrace();
                }
            }
        }
    }

    @NonNull
    @Override
    public ChatUsersViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        binding = ItemChatUserBinding.inflate(LayoutInflater.from(parent.getContext()), parent, false);
        return new ChatUsersViewHolder(binding.getRoot());
    }

    @Override
    public void onBindViewHolder(@NonNull ChatUsersViewHolder holder, int position) {

        binding.lastChatDtm.setText(String.format(context.getString(R.string.last_chat_text),
                new TimeUtils().time(usersList.get(position).getLastSeenDTM(), context)));
        Glide.with(context).load(usersList.get(position).getProfileUrl()).into(binding.profileImage);
        if (usersList.get(position).getUsername() != null) {
            binding.usernameTv.setText(usersList.get(position).getUsername());
            binding.profileImageText.setText(String.valueOf(usersList.get(position).getUsername().charAt(0)));
            GradientDrawable background = (GradientDrawable) binding.profileImage.getBackground();
            background.setColor(new ColorChange(context).colorChange(
                    String.valueOf(usersList.get(position).getUsername().toLowerCase().charAt(0))));
        }
        try {
            if (usersList.get(position).getProfileUrl() != null) {
                if (!usersList.get(position).getProfileUrl().isEmpty() && !usersList.get(position).getProfileUrl().equals("null")) {
                    Glide.with(context)
                            .load(usersList.get(position).getProfileUrl())
                            .transform(new CircleCrop(),
                                    new RoundedCorners(5))
                            .into(binding.profileImage);
                    binding.profileImageText.setVisibility(View.GONE);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public int getItemCount() {
        return usersList.size();
    }
}
