package com.opinito.social.Adapter;

import android.content.Context;
import android.graphics.drawable.GradientDrawable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.bitmap.CircleCrop;
import com.bumptech.glide.load.resource.bitmap.RoundedCorners;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.Preference;
import com.opinito.social.Model.GoogleSigninRequest;
import com.opinito.social.R;
import com.opinito.social.Utils.ColorChange;
import com.opinito.social.Utils.Customize;

import java.util.ArrayList;

public class GogUserListAdapter extends RecyclerView.Adapter<GogUserListAdapter.MyViewHolder> {
    private ArrayList<GoogleSigninRequest> googleSigninRequests;
    private Context context;
    private String dpUrl;

    public class MyViewHolder extends RecyclerView.ViewHolder {
        private TextView topicname, countryCode, statusText;
        private RelativeLayout row_layout;
        private ImageView row_select, profileImage;
        private RelativeLayout statuschangeLayout;
        private ImageView countryCodeIv;

        public MyViewHolder(View view) {
            super(view);
            topicname = view.findViewById(R.id.username);
            statusText = view.findViewById(R.id.status_text);
            countryCode = view.findViewById(R.id.country_code);
            row_layout = view.findViewById(R.id.row_layout);
            row_select = view.findViewById(R.id.img_select);
            countryCodeIv = view.findViewById(R.id.flag_iv_activity);
            profileImage = view.findViewById(R.id.profile_image);
            statuschangeLayout = view.findViewById(R.id.status_change_layout_parent_post);
        }
    }

    public GogUserListAdapter(ArrayList<GoogleSigninRequest> googleSigninRequest, Context context, String dpUrl) {
        this.googleSigninRequests = googleSigninRequest;
        this.context = context;
        this.dpUrl = dpUrl;
    }

    @NonNull
    @Override
    public GogUserListAdapter.MyViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View itemView = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.custom_goguserlist, parent, false);
        return new GogUserListAdapter.MyViewHolder(itemView);
    }


    @Override
    public void onBindViewHolder(@NonNull GogUserListAdapter.MyViewHolder holder, int position) {

        holder.topicname.setText(googleSigninRequests.get(position).getUSERNAME());
        holder.countryCode.setText(googleSigninRequests.get(position).getCOUNTRY_CODE());
        holder.statusText.setText(String.valueOf(googleSigninRequests.get(position).getUSERNAME().charAt(0)));
        holder.countryCodeIv.setImageDrawable(context.getResources().getDrawable(Customize.getCountryFlagRes(
                googleSigninRequests.get(position).getCOUNTRY_CODE(), context
        )));
        GradientDrawable background = (GradientDrawable) holder.statuschangeLayout.getBackground();
        background.setColor(new ColorChange(context).colorChange(
                String.valueOf(googleSigninRequests.get(position).getUSERNAME().toLowerCase().charAt(0))));
        Glide.with(context).
                load(dpUrl)
                .transform(new CircleCrop(),
                        new RoundedCorners(5))
                .into(holder.profileImage);
        holder.row_layout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (!googleSigninRequests.get(position).getSELECTED())
                    selectedListItem(position);
                else {
                    googleSigninRequests.get(position).setSELECTED(false);
                    notifyDataSetChanged();
                }
            }
        });
        if (googleSigninRequests.get(position).getSELECTED()) {
//            holder.row_select.setVisibility(View.VISIBLE);
            holder.row_layout.setBackground(context.getDrawable(R.drawable.yellow_out_line));
        } else {
            holder.row_layout.setBackground(context.getDrawable(R.drawable.grey_outline_bg));
//            holder.row_select.setVisibility(View.GONE);
        }
    }

    public void clearSelections() {
        for (int i = 0; i < googleSigninRequests.size(); i++) {
            googleSigninRequests.get(i).setSELECTED(false);
        }
        notifyDataSetChanged();
    }

    void selectedListItem(int position) {
        for (int i = 0; i < googleSigninRequests.size(); i++) {
            googleSigninRequests.get(i).setSELECTED(false);
        }
        googleSigninRequests.get(position).setSELECTED(true);
        notifyDataSetChanged();
    }

    @Override
    public int getItemCount() {
        return googleSigninRequests.size();
    }
}
