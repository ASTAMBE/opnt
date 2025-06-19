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
import com.opinito.social.Model.ConvertGuestUserModel;
import com.opinito.social.R;
import com.opinito.social.Utils.ColorChange;

import java.util.ArrayList;

public class ConvertGuestUserAdapter extends RecyclerView.Adapter<ConvertGuestUserAdapter.MyViewHolder> {

    private ArrayList<ConvertGuestUserModel> convertGuestUserModels;
    private Context context;
    private String dpUrl;

    public class MyViewHolder extends RecyclerView.ViewHolder {
        private TextView topicname, countryCode, statusText;
        private RelativeLayout row_layout;
        private ImageView row_select, profileImage;
        private RelativeLayout statuschangeLayout;

        public MyViewHolder(View view) {
            super(view);
            topicname = view.findViewById(R.id.username);
            statusText = view.findViewById(R.id.status_text);
            countryCode = view.findViewById(R.id.country_code);
            row_layout = view.findViewById(R.id.row_layout);
            row_select = view.findViewById(R.id.img_select);
            profileImage = view.findViewById(R.id.profile_image);
            statuschangeLayout = view.findViewById(R.id.status_change_layout_parent_post);
        }
    }

    public ConvertGuestUserAdapter(ArrayList<ConvertGuestUserModel> convertGuestUserModels, Context context, String dpUrl){
        this.convertGuestUserModels = convertGuestUserModels;
        this.context = context;
        this.dpUrl = dpUrl;
    }

    @NonNull
    @Override
    public ConvertGuestUserAdapter.MyViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View itemView = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.custom_guestuserlist, parent, false);
        return new ConvertGuestUserAdapter.MyViewHolder(itemView);
    }

    @Override
    public void onBindViewHolder(@NonNull ConvertGuestUserAdapter.MyViewHolder holder, int position) {

        holder.topicname.setText(convertGuestUserModels.get(position).getData().getUSERNAME());
        holder.countryCode.setText(convertGuestUserModels.get(position).getData().getCOUNTRYCODE());
        holder.statusText.setText(String.valueOf(convertGuestUserModels.get(position).getData().getUSERNAME().charAt(0)));
        GradientDrawable background = (GradientDrawable) holder.statuschangeLayout.getBackground();
        background.setColor(new ColorChange(context).colorChange(
                String.valueOf(convertGuestUserModels.get(position).getData().getUSERNAME().toLowerCase().charAt(0))));
        Glide.with(context).
                load(dpUrl)
                .transform(new CircleCrop(),
                        new RoundedCorners(5))
                .into(holder.profileImage);
        holder.row_layout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (!convertGuestUserModels.get(position).getSELECTED())
                    selectedListItem(position);
                else {
                    convertGuestUserModels.get(position).setSELECTED(false);
                    notifyDataSetChanged();
                }
            }
        });
        if (convertGuestUserModels.get(position).getSELECTED()) {
//            holder.row_select.setVisibility(View.VISIBLE);
            holder.row_layout.setBackground(context.getDrawable(R.drawable.yellow_out_line));
        } else {
            holder.row_layout.setBackground(context.getDrawable(R.drawable.grey_outline_bg));
//            holder.row_select.setVisibility(View.GONE);
        }
    }

    public void clearSelections() {
        for (int i = 0; i < convertGuestUserModels.size(); i++) {
            convertGuestUserModels.get(i).setSELECTED(false);
        }
        notifyDataSetChanged();
    }

    void selectedListItem(int position){
        for (int i=0;i<convertGuestUserModels.size();i++){
            convertGuestUserModels.get(i).setSELECTED(false);
        }
        convertGuestUserModels.get(position).setSELECTED(true);
        ConvertGuestUserAdapter.this.notifyDataSetChanged();
    }

    @Override
    public int getItemCount() {
        return convertGuestUserModels.size();
    }
}
