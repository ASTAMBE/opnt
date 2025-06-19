package com.opinito.social.Adapter;

import android.animation.ObjectAnimator;
import android.content.Context;
import android.graphics.drawable.GradientDrawable;
import androidx.recyclerview.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.bitmap.CircleCrop;
import com.bumptech.glide.load.resource.bitmap.RoundedCorners;
import com.opinito.social.Constants.TimeAgo;
import com.opinito.social.Model.NetworkNameModel;
import com.opinito.social.R;
import com.opinito.social.Utils.ColorChange;
import com.opinito.social.Utils.TimeUtils;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;

/**
 * Created by 502687702 on 7/17/2017.
 */

public class NetworkNamesAdapter extends RecyclerView.Adapter<NetworkNamesAdapter.MyViewHolder> {
    private ArrayList<NetworkNameModel> networkNameModelArrayList;
    Context context;

    public class MyViewHolder extends RecyclerView.ViewHolder {
        private TextView username;
        private TextView match;
        ProgressBar ProgressBar;
        private ImageView userImage;
        private TextView status_text;
        private TextView matchSince;
        private RelativeLayout statuschangeLayout;
        public MyViewHolder(View view) {
            super(view);
            userImage = view.findViewById(R.id.status_image);
            username = view.findViewById(R.id.username);
            matchSince = view.findViewById(R.id.match_since);
            ProgressBar = view.findViewById(R.id.horizontal_progress_bar);
            match = view.findViewById(R.id.match);
            status_text = view.findViewById(R.id.status_text);
            statuschangeLayout = view.findViewById(R.id.status_change_layout_parent_post);
        }
    }

    public NetworkNamesAdapter(ArrayList<NetworkNameModel> networkNameModelArrayList, Context context) {
        this.networkNameModelArrayList = networkNameModelArrayList;
        this.context = context;
    }

    @Override
    public NetworkNamesAdapter.MyViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View itemView = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.custom_networkname, parent, false);

        return new NetworkNamesAdapter.MyViewHolder(itemView);
    }

    @Override
    public void onBindViewHolder(NetworkNamesAdapter.MyViewHolder holder, int position) {
        holder.username.setText(networkNameModelArrayList.get(position).getUSERNAME());
        holder.matchSince.setText(new TimeUtils().convertdateWithOutTime(networkNameModelArrayList.get(position).getIN_NW_SINCE()));
        double progress = networkNameModelArrayList.get(position).getNET_STRENGTH()*100;
        holder.match.setText(String.format(context.getString(R.string.opinion_match), (int) progress));
        ObjectAnimator.ofInt(holder.ProgressBar, "progress", 0,(int) progress).setDuration(800).start();
        if (!networkNameModelArrayList.get(position).getUSERNAME().isEmpty()) {
                holder.userImage.setVisibility(View.VISIBLE);
                holder.status_text.setVisibility(View.VISIBLE);
                holder.status_text.setText(String.valueOf(networkNameModelArrayList.get(position).getUSERNAME().charAt(0)));
                Glide.with(context)
                        .load(networkNameModelArrayList.get(position).getDP_URL())
                        .transform(new CircleCrop(),
                                new RoundedCorners(5))
                        .into(holder.userImage);
                GradientDrawable background = (GradientDrawable) holder.statuschangeLayout.getBackground();
                background.setColor(new ColorChange(context).colorChange(String.valueOf(networkNameModelArrayList.get(position).getUSERNAME().toLowerCase().charAt(0))));
        }
    }

    @Override
    public int getItemCount() {
        return networkNameModelArrayList.size();
    }

}
