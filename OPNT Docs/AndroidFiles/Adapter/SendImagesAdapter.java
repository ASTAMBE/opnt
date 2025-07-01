package com.opinito.social.Adapter;

import android.app.Activity;
import android.content.Context;
import android.net.Uri;
import android.util.DisplayMetrics;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.bitmap.CenterCrop;
import com.bumptech.glide.load.resource.bitmap.RoundedCorners;
import com.bumptech.glide.request.RequestOptions;
import com.opinito.social.Interface.ImageInterface;
import com.opinito.social.R;

import java.util.List;

public class SendImagesAdapter extends RecyclerView.Adapter<SendImagesAdapter.ImagesViewHolder> {

    private Activity context;
    private List<Uri> imagesList;
    private String type;
    private ImageInterface imageInterface;

    public SendImagesAdapter(Activity context, List<Uri> imagesList, ImageInterface imageInterface, String type) {
        this.context = context;
        this.imagesList = imagesList;
        this.type = type;
        this.imageInterface = imageInterface;
    }

    class ImagesViewHolder extends RecyclerView.ViewHolder {
        ImageView itemImage, removeImage, videoViewIv;
        public ImagesViewHolder(@NonNull View itemView) {
            super(itemView);
            itemImage = itemView.findViewById(R.id.main_image);
            removeImage = itemView.findViewById(R.id.remove_image);
            videoViewIv = itemView.findViewById(R.id.video_play_iv);
            removeImage.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    imageInterface.removeImage(imagesList.get(getAdapterPosition()), getAdapterPosition());
                }
            });
        }
    }

    @NonNull
    @Override
    public ImagesViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new ImagesViewHolder(LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_image, parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull ImagesViewHolder holder, int position) {
        if (imagesList.get(position).toString().contains(context.getString(R.string.mp4)))
            holder.videoViewIv.setVisibility(View.VISIBLE);
        else
            holder.videoViewIv.setVisibility(View.GONE);
        try {
            if (type.equals(context.getString(R.string.post))) {
                DisplayMetrics displayMetrics = new DisplayMetrics();
                context.getWindowManager().getDefaultDisplay().getMetrics(displayMetrics);
                Glide.with(context)
                        .load(imagesList.get(position))
                        .apply(new RequestOptions()
                                .transform(new CenterCrop())
                                .override(displayMetrics.widthPixels/6, displayMetrics.widthPixels/6))
                        .into(holder.itemImage);
            } else {
                Glide.with(context)
                        .load(imagesList.get(position))
                        .apply(new RequestOptions()
                                .transform(new CenterCrop(),
                                        new RoundedCorners(25))
                                .override(130, 130))
                        .into(holder.itemImage);
                Glide.with(context)
                        .load(R.drawable.ic_cancel_red_24dp)
                        .apply(new RequestOptions()
                        .override(50,50))
                        .into(holder.removeImage);
            }
        } catch (Exception e){

        }
    }

    @Override
    public int getItemCount() {
        return imagesList.size();
    }
}
