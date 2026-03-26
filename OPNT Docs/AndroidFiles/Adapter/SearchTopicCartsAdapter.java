package com.opinito.social.Adapter;

import android.app.Activity;

import androidx.appcompat.content.res.AppCompatResources;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.opinito.social.Constants.Preference;
import com.opinito.social.Fragment.ListFragment;
import com.opinito.social.Interface.OnLoadMoreListener;
import com.opinito.social.Model.MultiSearchTopicModel;
import com.opinito.social.Model.SearchTopicCartsModel;
import com.opinito.social.R;
import java.util.ArrayList;
import java.util.List;

/**
 * Updated by Ashish on 4/9/2020.
 */

public class SearchTopicCartsAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {
    private List<MultiSearchTopicModel> searchTopicCartsModelArrayList;
    Activity context;
    private final int VIEW_TYPE_ITEM = 0;
    private final int VIEW_TYPE_LOADING = 1;
    public OnLoadMoreListener mOnLoadMoreListener;
    private int visibleThreshold = 1;
    private int lastVisibleItem, totalItemCount;
    private ListFragment listFragment;
    RecyclerView mrecyclerView;
    private boolean isLoading;
    private String currentTopicId;
    private boolean isCheckOne =true , isCheckTwo = true , isCheckThree = true , isCheckFour = true , isCheckFive = true , isCheckSix = true , isCheckSeven = true , isCheckEight = true , isCheckNine = true , isCheckTen = true ,isCheckEleven = true;
    public class MyViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener{
        private TextView search_topicname;
        private TextView topic_name;
        private TextView search_love_count;
        private TextView search_hate_count;
        private ImageView search_like;
        private ImageView search_hate;
        private ImageView reportCart;


        public MyViewHolder(View view) {
            super(view);
            topic_name = view.findViewById(R.id.topic);
            search_topicname = view.findViewById(R.id.topicname);
            search_love_count = view.findViewById(R.id.total_love_count);
            search_hate_count = view.findViewById(R.id.total_hate_count);
            search_like = view.findViewById(R.id.like);
            reportCart = view.findViewById(R.id.report_cart);
            reportCart.setOnClickListener(this);
            search_like.setOnClickListener(this);
            search_hate = view.findViewById(R.id.hate);
            search_hate.setOnClickListener(this);
        }

        @Override
        public void onClick(View v) {
            if (v.getId() == R.id.like){
                if (searchTopicCartsModelArrayList.get(getAdapterPosition()).getCART().toLowerCase().equalsIgnoreCase("l")) {
                    search_like.setImageDrawable(AppCompatResources.getDrawable(context,R.drawable.ic_love_grey_new));
                    search_hate.setImageDrawable(AppCompatResources.getDrawable(context,R.drawable.ic_skull_grey_new));
                    searchTopicCartsModelArrayList.get(getAdapterPosition()).setCART("");
                } else {
                    search_like.setImageDrawable(AppCompatResources.getDrawable(context,R.drawable.heart_fill));
                    search_hate.setImageDrawable(AppCompatResources.getDrawable(context,R.drawable.ic_skull_grey_new));
                    searchTopicCartsModelArrayList.get(getAdapterPosition()).setCART("L");
                }
                ListFragment.isCartUpdated = true;
                context.invalidateOptionsMenu();
            } else if (v.getId() == R.id.hate){
                if (searchTopicCartsModelArrayList.get(getAdapterPosition()).getCART().toLowerCase().equalsIgnoreCase("h")) {
                    search_hate.setImageDrawable(AppCompatResources.getDrawable(context,R.drawable.ic_skull_grey_new));
                    search_like.setImageDrawable(AppCompatResources.getDrawable(context,R.drawable.ic_love_grey_new));
                    searchTopicCartsModelArrayList.get(getAdapterPosition()).setCART("");
                } else {
                    search_hate.setImageDrawable(AppCompatResources.getDrawable(context, R.drawable.skull_fill));
                    search_like.setImageDrawable(AppCompatResources.getDrawable(context,R.drawable.ic_love_grey_new));
                    searchTopicCartsModelArrayList.get(getAdapterPosition()).setCART("H");
                }
                ListFragment.isCartUpdated = true;
                context.invalidateOptionsMenu();
            } else if (v.getId() == R.id.report_cart){
                listFragment.reportCartConfirmation(String.valueOf(searchTopicCartsModelArrayList.get(getAdapterPosition()).getKEYID()));
            }
        }
    }

    public SearchTopicCartsAdapter(ArrayList<MultiSearchTopicModel> searchTopicCartsModelArrayList, Activity context,
                                   RecyclerView recyclerView, ListFragment listFragment, String s) {
        this.searchTopicCartsModelArrayList = searchTopicCartsModelArrayList;
        this.context = context;
        this.mrecyclerView = recyclerView;
        this.listFragment = listFragment;
        this.currentTopicId =s;

        final LinearLayoutManager linearLayoutManager = (LinearLayoutManager) mrecyclerView.getLayoutManager();
        mrecyclerView.addOnScrollListener(new RecyclerView.OnScrollListener() {
            @Override
            public void onScrolled(RecyclerView recyclerView, int dx, int dy) {
                super.onScrolled(recyclerView, dx, dy);

                totalItemCount = linearLayoutManager.getItemCount();
                lastVisibleItem = linearLayoutManager.findLastVisibleItemPosition();

                if (!isLoading && totalItemCount <= (lastVisibleItem + visibleThreshold)) {
                    if (mOnLoadMoreListener != null) {
                        mOnLoadMoreListener.onLoadMore();
                    }
                    isLoading = true;
                }
            }
        });
    }

    public void setLoaded() {
        isLoading = false;
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        if (viewType == VIEW_TYPE_ITEM) {
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.custom_topiccart, parent, false);
            return new MyViewHolder(view);
        } else if (viewType == VIEW_TYPE_LOADING) {
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.progressbar, parent, false);
            return new LoadingViewHolder(view);
        }
        return null;
    }

    public class LoadingViewHolder extends RecyclerView.ViewHolder {
        public ProgressBar progressBar;

        public LoadingViewHolder(View itemView) {
            super(itemView);
            progressBar = itemView.findViewById(R.id.progressBar1);
        }
    }

    public void setOnLoadMoreListener(OnLoadMoreListener mOnLoadMoreListener) {
        this.mOnLoadMoreListener = mOnLoadMoreListener;
    }

    @Override
    public void onBindViewHolder(final RecyclerView.ViewHolder holder, final int position) {
        if (holder instanceof SearchTopicCartsAdapter.MyViewHolder) {
            MyViewHolder userViewHolder = (MyViewHolder) holder;

//            for(int i = 0 ; i < searchTopicCartsModelArrayList.size() ; i++) //40
//            {

                if(currentTopicId.equals(searchTopicCartsModelArrayList.get(position).getTOPICID())) {
                    if (position == 0) {
                        userViewHolder.topic_name.setVisibility(View.VISIBLE);
                        userViewHolder.topic_name.setText(searchTopicCartsModelArrayList.get(0).getTNAME());
                    } else {
                        userViewHolder.topic_name.setVisibility(View.GONE);
                        new Preference(context).saveIntPref("number", position);
                    }
                }
                else if(searchTopicCartsModelArrayList.get(position).getTOPICID().equals("1") && !currentTopicId.equals(searchTopicCartsModelArrayList.get(position).getTOPICID())) {
                    if(isCheckOne)
                    {
                        userViewHolder.topic_name.setVisibility(View.VISIBLE);
                        userViewHolder.topic_name.setText(searchTopicCartsModelArrayList.get(position).getTNAME());
                        isCheckOne = false;
                    }
                }else if(searchTopicCartsModelArrayList.get(position).getTOPICID().equals("2") && !currentTopicId.equals(searchTopicCartsModelArrayList.get(position).getTOPICID())) {
                   if(isCheckTwo){
                       userViewHolder.topic_name.setVisibility(View.VISIBLE);
                       userViewHolder.topic_name.setText(searchTopicCartsModelArrayList.get(position).getTNAME());
                       isCheckTwo = false;
                   }

                }else if(searchTopicCartsModelArrayList.get(position).getTOPICID().equals("3") && !currentTopicId.equals(searchTopicCartsModelArrayList.get(position).getTOPICID())) {
                    if(isCheckThree)
                    {
                        userViewHolder.topic_name.setVisibility(View.VISIBLE);
                        userViewHolder.topic_name.setText(searchTopicCartsModelArrayList.get(position).getTNAME());
                        isCheckThree = false;
                    }
                }else if(searchTopicCartsModelArrayList.get(position).getTOPICID().equals("4") && !currentTopicId.equals(searchTopicCartsModelArrayList.get(position).getTOPICID())) {
                  if(isCheckFour)
                  {
                      userViewHolder.topic_name.setVisibility(View.VISIBLE);
                      userViewHolder.topic_name.setText(searchTopicCartsModelArrayList.get(position).getTNAME());
                      isCheckFour = false;
                  }
                }else if(searchTopicCartsModelArrayList.get(position).getTOPICID().equals("5") && !currentTopicId.equals(searchTopicCartsModelArrayList.get(position).getTOPICID())) {
                    if(isCheckFive)
                    {
                        userViewHolder.topic_name.setVisibility(View.VISIBLE);
                        userViewHolder.topic_name.setText(searchTopicCartsModelArrayList.get(position).getTNAME());
                        isCheckFive = false;
                    }
                }else if(searchTopicCartsModelArrayList.get(position).getTOPICID().equals("6") && !currentTopicId.equals(searchTopicCartsModelArrayList.get(position).getTOPICID())) {
                    if(isCheckSix)
                    {
                        userViewHolder.topic_name.setVisibility(View.VISIBLE);
                        userViewHolder.topic_name.setText(searchTopicCartsModelArrayList.get(position).getTNAME());
                        isCheckSix = false;
                    }
                }else if(searchTopicCartsModelArrayList.get(position).getTOPICID().equals("7") && !currentTopicId.equals(searchTopicCartsModelArrayList.get(position).getTOPICID())) {
                    if(isCheckSeven)
                    {
                        userViewHolder.topic_name.setVisibility(View.VISIBLE);
                        userViewHolder.topic_name.setText(searchTopicCartsModelArrayList.get(position).getTNAME());
                        isCheckSeven = false;
                    }
                }else if(searchTopicCartsModelArrayList.get(position).getTOPICID().equals("8") && !currentTopicId.equals(searchTopicCartsModelArrayList.get(position).getTOPICID())) {
                    if(isCheckEight)
                    {
                        userViewHolder.topic_name.setVisibility(View.VISIBLE);
                        userViewHolder.topic_name.setText(searchTopicCartsModelArrayList.get(position).getTNAME());
                        isCheckEight = false;
                    }
                }else if(searchTopicCartsModelArrayList.get(position).getTOPICID().equals("9") && !currentTopicId.equals(searchTopicCartsModelArrayList.get(position).getTOPICID())) {
                    if(isCheckNine)
                    {   userViewHolder.topic_name.setVisibility(View.VISIBLE);
                        userViewHolder.topic_name.setText(searchTopicCartsModelArrayList.get(position).getTNAME());
                        isCheckNine = false;
                    }
                }else if(searchTopicCartsModelArrayList.get(position).getTOPICID().equals("10") && !currentTopicId.equals(searchTopicCartsModelArrayList.get(position).getTOPICID())) {
                    if(isCheckTen)
                    {
                        userViewHolder.topic_name.setVisibility(View.VISIBLE);
                        userViewHolder.topic_name.setText(searchTopicCartsModelArrayList.get(position).getTNAME());
                        isCheckTen = false;
                    }
                }else if(searchTopicCartsModelArrayList.get(position).getTOPICID().equals("11") && !currentTopicId.equals(searchTopicCartsModelArrayList.get(position).getTOPICID())) {
                    if(isCheckEleven)
                    {
                        userViewHolder.topic_name.setVisibility(View.VISIBLE);
                        userViewHolder.topic_name.setText(searchTopicCartsModelArrayList.get(position).getTNAME());
                        isCheckEleven = false;
                    }

                }else {
                    userViewHolder.topic_name.setVisibility(View.GONE);
                }

//                else
//                    {
//                        int num = new Preference(context).getIntPref("number") + 1;
//                     if(num == position)
//                     {
//                        userViewHolder.topic_name.setVisibility(View.VISIBLE);
//                        userViewHolder.topic_name.setText(searchTopicCartsModelArrayList.get(num).getTNAME());
//                     }else
//                         {
//                        userViewHolder.topic_name.setVisibility(View.GONE);
//                        if(isCheck)
//                        {
//
//                        }
//                        }



            userViewHolder.search_topicname.setText(searchTopicCartsModelArrayList.get(position).getKEYWORDS());
            userViewHolder.search_love_count.setText(searchTopicCartsModelArrayList.get(position).getLCOUNT());
            userViewHolder.search_hate_count.setText(searchTopicCartsModelArrayList.get(position).getHCOUNT());
            if (searchTopicCartsModelArrayList.get(position).getCART() == null)
                searchTopicCartsModelArrayList.get(position).setCART("");
            if (searchTopicCartsModelArrayList.get(position).getCART().toLowerCase().equalsIgnoreCase("l")) {
                userViewHolder.search_like.setImageDrawable(AppCompatResources.getDrawable(context,R.drawable.heart_fill));
                userViewHolder.search_hate.setImageDrawable(AppCompatResources.getDrawable(context,R.drawable.ic_skull_grey_new));
            } else if (searchTopicCartsModelArrayList.get(position).getCART().toLowerCase().equalsIgnoreCase("h")) {
                userViewHolder.search_hate.setImageDrawable(AppCompatResources.getDrawable(context, R.drawable.skull_fill));
                userViewHolder.search_like.setImageDrawable(AppCompatResources.getDrawable(context,R.drawable.ic_love_grey_new));
            }
        }
//        else if (holder instanceof TopicCartsAdapter.LoadingViewHolder) {
//            LoadingViewHolder loadingViewHolder = (LoadingViewHolder) holder;
//            loadingViewHolder.progressBar.setIndeterminate(true);
        }



    @Override
    public int getItemCount() {
        return searchTopicCartsModelArrayList == null ? 0 : searchTopicCartsModelArrayList.size();
    }

    @Override
    public int getItemViewType(int position) {
        return searchTopicCartsModelArrayList.get(position) == null ? VIEW_TYPE_LOADING : VIEW_TYPE_ITEM;
    }
}



