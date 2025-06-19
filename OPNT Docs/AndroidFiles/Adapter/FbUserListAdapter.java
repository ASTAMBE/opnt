package com.opinito.social.Adapter;

import android.content.Context;

import androidx.recyclerview.widget.RecyclerView;

import android.graphics.drawable.GradientDrawable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.bitmap.CircleCrop;
import com.bumptech.glide.load.resource.bitmap.RoundedCorners;
import com.opinito.social.Model.FbUserModel;
import com.opinito.social.R;
import com.opinito.social.Utils.ColorChange;
import com.opinito.social.Utils.Customize;

import java.util.ArrayList;

/**
 * Created by chanti on 9/8/2017.
 */

public class FbUserListAdapter extends RecyclerView.Adapter<FbUserListAdapter.MyViewHolder> {
    private ArrayList<FbUserModel> fbUserModelArrayList;
    private Context context;
    private String profileUrl;

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

    public FbUserListAdapter(ArrayList<FbUserModel> fbUserModelArrayList, Context context, String profileUrl) {
        this.profileUrl = profileUrl;
        this.fbUserModelArrayList = fbUserModelArrayList;
        this.context = context;
    }

    @Override
    public FbUserListAdapter.MyViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View itemView = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.custom_fbuserlist, parent, false);
        return new FbUserListAdapter.MyViewHolder(itemView);
    }

    @Override
    public void onBindViewHolder(final FbUserListAdapter.MyViewHolder holder, final int position) {
        holder.topicname.setText(fbUserModelArrayList.get(position).getUSERNAME());
        holder.countryCode.setText(fbUserModelArrayList.get(position).getCOUNTRY_CODE());
        holder.statusText.setText(String.valueOf(fbUserModelArrayList.get(position).getUSERNAME().charAt(0)));
        holder.countryCodeIv.setImageDrawable(context.getResources().getDrawable(Customize.getCountryFlagRes(
                fbUserModelArrayList.get(position).getCOUNTRY_CODE(), context
        )));
        GradientDrawable background = (GradientDrawable) holder.statuschangeLayout.getBackground();
        background.setColor(new ColorChange(context).colorChange(
                String.valueOf(fbUserModelArrayList.get(position).getUSERNAME().toLowerCase().charAt(0))));
        Glide.with(context).
                load(profileUrl)
                .transform(new CircleCrop(),
                        new RoundedCorners(5))
                .into(holder.profileImage);
        holder.row_layout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (!fbUserModelArrayList.get(position).getSELECTED())
                    selectedListItem(position);
                else {
                    fbUserModelArrayList.get(position).setSELECTED(false);
                    notifyDataSetChanged();
                }
            }
        });
        if(fbUserModelArrayList.get(position).getSELECTED()){
//            holder.row_select.setVisibility(View.VISIBLE);
            holder.row_layout.setBackground(context.getDrawable(R.drawable.yellow_out_line));
        }else{
//            holder.row_select.setVisibility(View.GONE);
            holder.row_layout.setBackground(context.getDrawable(R.drawable.grey_outline_bg));
        }
    }

    public void clearSelections(){
        for (int i=0;i<fbUserModelArrayList.size();i++){
            fbUserModelArrayList.get(i).setSELECTED(false);
        }
        notifyDataSetChanged();
    }

    void selectedListItem(int position) {
        for (int i = 0; i < fbUserModelArrayList.size(); i++) {
            fbUserModelArrayList.get(i).setSELECTED(false);
        }
        fbUserModelArrayList.get(position).setSELECTED(true);
        notifyDataSetChanged();
    }

    @Override
    public int getItemCount() {
        return fbUserModelArrayList.size();
    }
}
