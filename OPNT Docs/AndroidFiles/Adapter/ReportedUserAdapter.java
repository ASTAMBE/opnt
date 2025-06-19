package com.opinito.social.Adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.opinito.social.Model.UserKOContent;
import com.opinito.social.R;
import com.opinito.social.Utils.TimeUtils;
import com.opinito.social.databinding.ReportContentItemBinding;

import java.util.List;

public class ReportedUserAdapter extends RecyclerView.Adapter<ReportedUserAdapter.ReportContentViewHolder> {

    private List<UserKOContent.Data> userKOContents;
    private Context context;
    private ReportContentItemBinding binding;

    public ReportedUserAdapter(List<UserKOContent.Data> userKOContents, Context context) {
        this.userKOContents = userKOContents;
        this.context = context;
    }

    @NonNull
    @Override
    public ReportContentViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        binding = ReportContentItemBinding.inflate(LayoutInflater.from(parent.getContext()), parent, false);
        return new ReportContentViewHolder(binding.getRoot());
    }

    @Override
    public void onBindViewHolder(@NonNull ReportContentViewHolder holder, int position) {
        binding.contentTypeTv.setText(String.format(context.getResources().getString(R.string.content_type),
                userKOContents.get(position).getCTYPE()));
        binding.contentTv.setText(userKOContents.get(position).getCONTENT());
        binding.contentReportedDtm.setText(new TimeUtils().time(userKOContents.get(position).getDTM(), context));
    }

    @Override
    public int getItemCount() {
        return userKOContents.size();
    }

    class ReportContentViewHolder extends RecyclerView.ViewHolder {
        public ReportContentViewHolder(@NonNull View itemView) {
            super(itemView);
        }
    }
}
