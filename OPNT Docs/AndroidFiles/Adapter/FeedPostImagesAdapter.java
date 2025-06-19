package com.opinito.social.Adapter;

import android.content.Context;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.MimeTypeMap;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.opinito.social.Activity.FullScreenImageActivity;
import com.opinito.social.Fragment.FeedFragment;
import com.opinito.social.R;
import com.opinito.social.Utils.BlurTransformation;

import java.util.ArrayList;
import java.util.List;

public class FeedPostImagesAdapter extends RecyclerView.Adapter<FeedPostImagesAdapter.FeedPostImageViewHolder> {

    private Context context;
    private List<String> imageList = new ArrayList<>();
    private String IMAGELIST = "imageslist";
    private String IMAGEPOSITION = "imagePosition";

    public FeedPostImagesAdapter(Context context, List<String> imageList) {
        this.context = context;
        this.imageList = imageList;
    }

    @NonNull
    @Override
    public FeedPostImageViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new FeedPostImageViewHolder(LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_post_image, parent, false));
    }

    private static String getMimeType(String fileUrl) {
        String extension = MimeTypeMap.getFileExtensionFromUrl(fileUrl);
        return MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension);
    }

    @Override
    public void onBindViewHolder(@NonNull FeedPostImageViewHolder holder, int position) {
        try {
            if (imageList.get(position).trim().endsWith("mp4"))
                holder.videoPlayIv.setVisibility(View.VISIBLE);
            else holder.videoPlayIv.setVisibility(View.GONE);
        } catch (Exception e) {
            e.printStackTrace();
        }

        Glide.with(context)
                .load(imageList.get(position).trim())
                .transform(new BlurTransformation(context))
                .placeholder(R.mipmap.ic_launcher)
                .into(holder.postImage);
    }

    @Override
    public int getItemCount() {
        return imageList.size();
    }

    class FeedPostImageViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener {
        private ImageView postImage;
        private TextView moreImagesTv, showHideTv;
        private ImageView blackOverlayIv, showHideIv;
        private ImageView videoPlayIv;
        private RelativeLayout parentLayout;

        public FeedPostImageViewHolder(@NonNull View itemView) {
            super(itemView);
            postImage = itemView.findViewById(R.id.post_image);
            postImage.setOnClickListener(this);
            videoPlayIv = itemView.findViewById(R.id.video_play_iv);
            moreImagesTv = itemView.findViewById(R.id.more_images_iv);
            showHideIv = itemView.findViewById(R.id.show_hide_iv);
            showHideIv.setBackgroundResource(R.drawable.ic_show_image);
            showHideIv.setOnClickListener(this);
            showHideTv = itemView.findViewById(R.id.show_hide_tv);
            blackOverlayIv = itemView.findViewById(R.id.black_overlay_iv);
            parentLayout = itemView.findViewById(R.id.image_parent_layout);
        }

        @Override
        public void onClick(View v) {
            switch (v.getId()) {
                case R.id.post_image:
                    if (blackOverlayIv.getVisibility() == View.GONE) {
                        FeedFragment.imageOpen = true;
                        ArrayList<String> arrImageList = new ArrayList<String>(imageList);
                        Intent fullScreenIntent = new Intent(context, FullScreenImageActivity.class);
                        fullScreenIntent.putStringArrayListExtra(IMAGELIST, arrImageList);
                        fullScreenIntent.putExtra(IMAGEPOSITION, getAdapterPosition());
                        context.startActivity(fullScreenIntent);
                    }
                    break;

                case R.id.show_hide_iv:
                    if (showHideIv.getBackground().getConstantState().equals(
                            context.getResources().getDrawable(R.drawable.ic_show_image).getConstantState())){
                        showHideTv.setVisibility(View.GONE);
                        blackOverlayIv.setVisibility(View.GONE);
                        showHideIv.setBackgroundResource(R.drawable.ic_hide_image);
                        Glide.with(context)
                                .load(imageList.get(getAdapterPosition()).trim())
                                .placeholder(R.mipmap.ic_launcher)
                                .into(postImage);
                    } else {
                        showHideTv.setVisibility(View.VISIBLE);
                        blackOverlayIv.setVisibility(View.VISIBLE);
                        showHideIv.setBackgroundResource(R.drawable.ic_show_image);
                        Glide.with(context)
                                .load(imageList.get(getAdapterPosition()).trim())
                                .transform(new BlurTransformation(context))
                                .placeholder(R.mipmap.ic_launcher)
                                .into(postImage);
                    }
            }
        }
    }
}
