package com.opinito.social.Adapter;

import static android.app.PendingIntent.getActivity;

import android.content.Context;
import android.content.Intent;

import androidx.recyclerview.widget.RecyclerView;

import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.opinito.social.Activity.DashBoard;
import com.opinito.social.Activity.NetworkNames;
import com.opinito.social.Activity.UserPostDetails;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.Preference;
import com.opinito.social.Fragment.ActivityFragment;
import com.opinito.social.Fragment.FeedFragment;
import com.opinito.social.Fragment.ProfileFragment;
import com.opinito.social.Fragment.SendPostFragment;
import com.opinito.social.Model.ProfileModel;
import com.opinito.social.R;
import com.opinito.social.Utils.ColorChange;

import java.util.ArrayList;

/**
 * Created by 502687702 on 7/12/2017.
 */

public class ProfileAdapter extends RecyclerView.Adapter<ProfileAdapter.MyViewHolder> {
    private ArrayList<ProfileModel.Data> profileModelArrayList;
    private Context context;
    private final String TOPICNAME = "topicname";
    private final String TOPICID = "topicid";
    private final String TYPE = "type";

    public class MyViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener{
        private TextView topicname;
        private TextView network;
        private TextView posts;
        private TextView bookmark;
        private TextView commentCount;
        private ImageView interestImage;
        private TextView deltacount;
        private LinearLayout postLayout, commentLayout , bookmarkLayout,networkLayout;
        private LinearLayout topicsLayout;

        public MyViewHolder(View view) {
            super(view);
            topicname = view.findViewById(R.id.topics);
            network = view.findViewById(R.id.network_count_tv);
            commentCount = view.findViewById(R.id.comment_count_tv);
            commentLayout = view.findViewById(R.id.comment_layout);
            commentLayout.setOnClickListener(this);
            posts = view.findViewById(R.id.post_count_tv);
            bookmarkLayout = view.findViewById(R.id.bookmarkLayout);
            bookmarkLayout.setOnClickListener(this);
            interestImage = view.findViewById(R.id.interest_image);
            bookmark = view.findViewById(R.id.bookmark_count_tv);
            deltacount = view.findViewById(R.id.deltacount);
            networkLayout = view.findViewById(R.id.networkLayout);
            networkLayout.setOnClickListener(this);
            postLayout = view.findViewById(R.id.postLayout);
            postLayout.setOnClickListener(this);
            topicsLayout = view.findViewById(R.id.topicslayout);
            topicsLayout.setOnClickListener(this);
        }

        @Override
        public void onClick(View v) {
            switch (v.getId()){
                case R.id.postLayout:
                    try {
                        Intent intent = new Intent(context, UserPostDetails.class);
                        intent.putExtra(TOPICID, profileModelArrayList.get(getAdapterPosition()).getTOPICID());
                        intent.putExtra(TOPICNAME, profileModelArrayList.get(getAdapterPosition()).getTOPIC());
                        intent.putExtra(TYPE, Constants.profilePosts);
                        context.startActivity(intent);
                        new Preference(context).saveIntPref("posttopic", Integer.parseInt(profileModelArrayList.get(getAdapterPosition()).getTOPICID()));
                    } catch (Exception e){
                        e.printStackTrace();
                    }
                    break;

                case R.id.comment_layout:
                    try {
                        Intent intent = new Intent(context, UserPostDetails.class);
                        intent.putExtra(TOPICID, profileModelArrayList.get(getAdapterPosition()).getTOPICID());
                        intent.putExtra(TOPICNAME, profileModelArrayList.get(getAdapterPosition()).getTOPIC());
                        intent.putExtra(TYPE, Constants.myCommentPosts);
                        context.startActivity(intent);
                        new Preference(context).saveIntPref("posttopic", Integer.parseInt(profileModelArrayList.get(getAdapterPosition()).getTOPICID()));
                    } catch (Exception e){
                        e.printStackTrace();
                    }
                    break;

                case R.id.networkLayout:
                    try {
                        Intent intent = new Intent(context, NetworkNames.class);
                        intent.putExtra(TOPICNAME, profileModelArrayList.get(getAdapterPosition()).getTOPIC());
                        intent.putExtra(TOPICID, profileModelArrayList.get(getAdapterPosition()).getTOPICID());
                        context.startActivity(intent);
                    } catch (Exception e){
                        e.printStackTrace();
                    }
                    break;

                case R.id.topicslayout:
                    try{
                        new Preference(context).saveIntPref(Constants.TOPICID,
                                Integer.parseInt(profileModelArrayList.get(getAdapterPosition()).getTOPICID()));

 //                       ((DashBoard) context).reloadFeedList();
//                        ((DashBoard) context).Tabselection(0);
                    } catch (Exception e){
                        e.printStackTrace();
                    }
                    break;

                case R.id.bookmarkLayout:
                    try {
                        Intent intent = new Intent(context, UserPostDetails.class);
                        intent.putExtra(TOPICID, profileModelArrayList.get(getAdapterPosition()).getTOPICID());
                        intent.putExtra(TOPICNAME, profileModelArrayList.get(getAdapterPosition()).getTOPIC());
                        intent.putExtra(TYPE, Constants.myBookmark);
                        context.startActivity(intent);
                        new Preference(context).saveIntPref("posttopic", Integer.parseInt(profileModelArrayList.get(getAdapterPosition()).getTOPICID()));
                    } catch (Exception e){
                        e.printStackTrace();
                    }
                    break;
            }
        }
    }

    public ProfileAdapter(ArrayList<ProfileModel.Data> profileModelArrayList, Context context) {
        this.profileModelArrayList = profileModelArrayList;
        this.context = context;

    }

    @Override
    public ProfileAdapter.MyViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View itemView = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.custom_profile, parent, false);

        return new ProfileAdapter.MyViewHolder(itemView);
    }

    @Override
    public void onBindViewHolder(ProfileAdapter.MyViewHolder holder, final int position) {
        Log.d("tetingak", "onBindViewHolder: "+profileModelArrayList.get(position).getTOPIC());
            holder.topicname.setText(profileModelArrayList.get(position).getTOPIC());
            holder.network.setText(profileModelArrayList.get(position).getNETSIZE());
            holder.posts.setText(profileModelArrayList.get(position).getPOSTCOUNT());
            holder.bookmark.setText(profileModelArrayList.get(position).getBookmarkCount());
            holder.commentCount.setText(profileModelArrayList.get(position).getCommentCount());
            holder.interestImage.setImageDrawable(context.getDrawable(ColorChange.getDrawable(profileModelArrayList.get(position).getTOPIC())));

            if (Integer.parseInt(profileModelArrayList.get(position).getPCDELTA()) > 0) {
                holder.deltacount.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {

                    }
                });
                holder.deltacount.setVisibility(View.VISIBLE);
                holder.deltacount.setText(String.format("%s %s", profileModelArrayList.get(position).getPCDELTA(), context.getString(R.string.new_posts_added)));
            } else {
                holder.deltacount.setVisibility(View.GONE);
            }
        }



    @Override
    public int getItemCount() {
        return profileModelArrayList.size();
    }
}
