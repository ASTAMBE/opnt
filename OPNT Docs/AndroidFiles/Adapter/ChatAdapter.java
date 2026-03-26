package com.opinito.social.Adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.Preference;
import com.opinito.social.Utils.TimeUtils;
import com.opinito.social.databinding.ChatItemOtherUserBinding;
import com.opinito.social.databinding.CustomChatItemBinding;
import java.util.HashMap;
import java.util.List;

public class ChatAdapter extends RecyclerView.Adapter<ChatAdapter.ChatViewHolder> {

    private List<HashMap<String, String>> snapList;
    private Context context;
    private CustomChatItemBinding binding;
    private ChatItemOtherUserBinding chatbinding;
    private String MESSAGETEXT = "messageText";
    private String MESSAGEBY = "messageBy";
    private String SENTATDTM = "sentAtDTM";

    public ChatAdapter(List<HashMap<String, String>> snapList, Context context) {
        this.snapList = snapList;
        this.context = context;
    }

    class ChatViewHolder extends RecyclerView.ViewHolder {

        public ChatViewHolder(@NonNull View itemView) {
            super(itemView);
        }
    }

    @NonNull
    @Override
    public ChatViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        if (viewType == 1) {
            binding = CustomChatItemBinding.inflate(LayoutInflater.from(parent.getContext()), parent, false);
            return new ChatViewHolder(binding.getRoot());
        }
        else {
            chatbinding = ChatItemOtherUserBinding.inflate(LayoutInflater.from(parent.getContext()), parent, false);
            return new ChatViewHolder(chatbinding.getRoot());
        }
    }

    @Override
    public void onBindViewHolder(@NonNull ChatViewHolder holder, int position) {
        if (getItemViewType(position) == 1) {
            bindViews(position, binding.messageDtm,
                    binding.messageText);
        } else {
            bindViews(position, chatbinding.messageDtm,
                    chatbinding.messageText);
        }
    }

    private void bindViews(int position, TextView messageDtm, TextView messageText){
        messageText.setText(snapList.get(position).get(MESSAGETEXT));
        messageDtm.setText(new TimeUtils().time(snapList.get(position).get(SENTATDTM), context));
    }

    @Override
    public int getItemCount() {
        return snapList.size();
    }

    @Override
    public int getItemViewType(int position) {
        if (snapList.get(position).get(MESSAGEBY).equals(new Preference(context).getPref(Constants.USERNAME)))
            return 1;
        else
            return 0;
    }
}
