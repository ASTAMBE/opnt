package com.opinito.social.Adapter;

import android.app.Activity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.opinito.social.Model.ListLatestKeyword;
import com.opinito.social.R;
import com.opinito.social.Utils.BottomSheetDialog;

import org.jetbrains.annotations.NotNull;

import java.util.List;

/**
 * Created by Abhay on 11/June/2021.
 */
public class NestedKeywordAdapter extends RecyclerView.Adapter<NestedKeywordAdapter.ViewHolder> {
    List<ListLatestKeyword> list;
    Activity context;
    BottomSheetDialog bottomNavigationView;
    OnShareClickedListener mCallback;

    public NestedKeywordAdapter(List<ListLatestKeyword> list, Activity context, BottomSheetDialog bottomNavigationView) {
        this.list = list;
        this.context = context;
        this.bottomNavigationView = bottomNavigationView;
    }

    public interface OnShareClickedListener {
        public void ShareClicked(String cart, String keyid, String topicid, int manipulate);
    }

    public void setOnShareClickedListener(OnShareClickedListener mCallback) {
        this.mCallback = mCallback;
    }

    @NonNull
    @NotNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull @NotNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_footer_latestkeyword, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull @NotNull ViewHolder holder, int position) {

        holder.keywordTV.setText(list.get(position).getKEYWORDS());
    }


    @Override
    public int getItemCount() {
        return list.size();
    }

    public class ViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener {
        TextView keywordTV;
        ImageView like, hate, report;

        public ViewHolder(@NonNull @NotNull View itemView) {
            super(itemView);
            like = itemView.findViewById(R.id.like_latestKeyword);
            like.setOnClickListener(this);

            hate = itemView.findViewById(R.id.hate_latest_keyword);
            hate.setOnClickListener(this);
            report = itemView.findViewById(R.id.report_latest_keyword);
            report.setOnClickListener(this);
            keywordTV = itemView.findViewById(R.id.topicname_latest_keywords);
        }

        @Override
        public void onClick(View v) {

            if (v.getId() == R.id.like_latestKeyword) {
                if (list.get(getAdapterPosition()).getCART().toLowerCase().equalsIgnoreCase("l")) {
                    like.setColorFilter(ContextCompat.getColor(context, R.color.colourGrey));
                    hate.setColorFilter(ContextCompat.getColor(context, R.color.colourGrey));
                    list.get(getAdapterPosition()).setCART("");
                    mCallback.ShareClicked(list.get(getAdapterPosition()).getCART(), list.get(getAdapterPosition()).getTAG1KEYID(), list.get(getAdapterPosition()).getTOPICID(), 0);
                } else {
                    like.setColorFilter(ContextCompat.getColor(context, R.color.colorPrimary));
                    hate.setColorFilter(ContextCompat.getColor(context, R.color.colourGrey));
                    list.get(getAdapterPosition()).setCART("L");
                    mCallback.ShareClicked(list.get(getAdapterPosition()).getCART(), list.get(getAdapterPosition()).getTAG1KEYID(), list.get(getAdapterPosition()).getTOPICID(), 1);


                }

                context.invalidateOptionsMenu();
            } else if (v.getId() == R.id.hate_latest_keyword) {
                if (list.get(getAdapterPosition()).getCART().toLowerCase().equalsIgnoreCase("h")) {
                    hate.setColorFilter(ContextCompat.getColor(context, R.color.colourGrey));
                    like.setColorFilter(ContextCompat.getColor(context, R.color.colourGrey));
                    list.get(getAdapterPosition()).setCART("");
                    mCallback.ShareClicked(list.get(getAdapterPosition()).getCART(), list.get(getAdapterPosition()).getTAG1KEYID(), list.get(getAdapterPosition()).getTOPICID(), 2);

                } else {
                    hate.setColorFilter(ContextCompat.getColor(context, R.color.colorPrimary));
                    like.setColorFilter(ContextCompat.getColor(context, R.color.colourGrey));
                    list.get(getAdapterPosition()).setCART("H");
                    mCallback.ShareClicked(list.get(getAdapterPosition()).getCART(), list.get(getAdapterPosition()).getTAG1KEYID(), list.get(getAdapterPosition()).getTOPICID(), 3);

                }

                context.invalidateOptionsMenu();
            }

        }
    }

}
