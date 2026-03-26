package com.opinito.social.Adapter;

import android.content.Context;

import androidx.recyclerview.widget.RecyclerView;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.opinito.social.Model.NetworkDetailsModel;
import com.opinito.social.R;

import java.util.ArrayList;

/**
 * Created by 502687702 on 7/17/2017.
 */

public class NetworkDetailsAdapter extends RecyclerView.Adapter<NetworkDetailsAdapter.MyViewHolder> {
    private ArrayList<NetworkDetailsModel> networkDetailsModelArrayList;
    private Context context;
    private String type;

    public class MyViewHolder extends RecyclerView.ViewHolder {
        private TextView topicname;
        private View line;

        public MyViewHolder(View view) {
            super(view);
            line = view.findViewById(R.id.hori_line);
            topicname = view.findViewById(R.id.topicname);
        }
    }

    public NetworkDetailsAdapter(ArrayList<NetworkDetailsModel> networkDetailsModelArrayList,
                                 Context context, String type) {
        this.networkDetailsModelArrayList = networkDetailsModelArrayList;
        this.context = context;
        this.type = type;
    }

    @Override
    public NetworkDetailsAdapter.MyViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View itemView = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.custom_networkdetail, parent, false);
        return new NetworkDetailsAdapter.MyViewHolder(itemView);
    }

    @Override
    public void onBindViewHolder(NetworkDetailsAdapter.MyViewHolder holder, final int position) {
        if (type.equals(context.getString(R.string.love))) {
            if (networkDetailsModelArrayList.get(position).getCART().equals(context.getString(R.string.love))) {
                holder.topicname.setVisibility(View.VISIBLE);
                holder.line.setVisibility(View.VISIBLE);
                holder.topicname.setTextColor(context.getResources().getColor(R.color.loveGreen));
                holder.topicname.setText(networkDetailsModelArrayList.get(position).getKEYWORDS());
            }
        }
        if (type.equals(context.getString(R.string.hate))) {
            if (networkDetailsModelArrayList.get(position).getCART().equals(context.getString(R.string.hate))) {
                holder.topicname.setVisibility(View.VISIBLE);
                holder.line.setVisibility(View.VISIBLE);
                holder.topicname.setTextColor(context.getResources().getColor(R.color.hateRed));
                holder.topicname.setText(networkDetailsModelArrayList.get(position).getKEYWORDS());
            }
        }
    }

    @Override
    public int getItemCount() {
        return networkDetailsModelArrayList.size();
    }
}
