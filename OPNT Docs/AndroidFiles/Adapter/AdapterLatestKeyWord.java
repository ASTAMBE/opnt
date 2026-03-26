package com.opinito.social.Adapter;

import android.app.Activity;
import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.fragment.app.FragmentActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.opinito.social.Model.ListLatestKeyword;
import com.opinito.social.R;
import com.opinito.social.Utils.BottomSheetDialog;

import org.jetbrains.annotations.NotNull;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**
 * Created by Abhay on 11/June/2021.
 */
public class AdapterLatestKeyWord extends RecyclerView.Adapter<AdapterLatestKeyWord.ViewHolder>implements NestedKeywordAdapter.OnShareClickedListener {
    Context context;
    List<String> arrlist;
    List<ListLatestKeyword> arraylist;
    List<ListLatestKeyword> nestedlist;
    HashMap<String, List<ListLatestKeyword>> hashMap = new HashMap<>();
    NestedKeywordAdapter adapter;
    RecyclerView recyclerView;
    Activity activity;
    BottomSheetDialog bottomSheetDialog;
    OnClickedListener mCallback;

    public AdapterLatestKeyWord(Context context, List<String> arrlist, ArrayList<ListLatestKeyword> arrayList, FragmentActivity activity, BottomSheetDialog bottomSheetDialog) {
        this.context = context;
        this.arrlist = arrlist;
        this.arraylist = arrayList;
        this.activity=activity;
        this.bottomSheetDialog=bottomSheetDialog;
//        prepareData(arrlist);

    }


    public interface OnClickedListener {
        public void Clicked(String cart,String keyid, String topicid, int manipulate);
    }
    public void setOnClickedListener(OnClickedListener mCallback) {
        this.mCallback = mCallback;
    }



    @NonNull
    @NotNull
    @Override

    public ViewHolder onCreateViewHolder(@NonNull @NotNull ViewGroup parent, int viewType) {
            View view1 = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_header_latestkeword, parent, false);
            return new ViewHolder(view1);

    }


    @Override
    public void onBindViewHolder(@NonNull @NotNull ViewHolder holder, int position) {
        Log.d("taggy","heading-"+arrlist.get(position)+"--size"+arraylist.size());
        holder.headerTextView.setText(arrlist.get(position));
        nestedlist=new ArrayList<>();
        for (int i=0;i<arraylist.size();i++){
            Log.d("taggy",arraylist.get(i).getTOPIC()+"---"+arrlist.get(position));
            if(arrlist.get(position).equals(arraylist.get(i).getTOPIC())){

                nestedlist.add(new ListLatestKeyword(arraylist.get(i).getCART(),arraylist.get(i).getDATE(),arraylist.get(i).getKEYWORDS(),arraylist.get(i).getTAG1KEYID(),
                        arraylist.get(i).getTOPIC(),arraylist.get(i).getTOPICID()));
//                Log.d("taggy","matched--"+arrlist.get(position)+"--->"+nestedlist.get(0).getTOPIC());
            }
        }
        for (int i=0;i<nestedlist.size();i++)
        Log.d("taggy",nestedlist.get(i).getKEYWORDS());
        Log.d("taggy","*****************************************************");
        adapter=new NestedKeywordAdapter(nestedlist,activity,bottomSheetDialog );
        adapter.setOnShareClickedListener(this);
        holder.nestedRv.setLayoutManager(new LinearLayoutManager(context));
        holder.nestedRv.setAdapter(adapter);



    }

    @Override
    public int getItemCount() {
        return arrlist.size();
    }

    @Override
    public void ShareClicked(String cart, String keyid, String topicid, int manipulate) {
        mCallback.Clicked(cart,keyid,topicid,manipulate);

    }

    public class ViewHolder extends RecyclerView.ViewHolder {
        TextView TopicName;
        TextView headerTextView;
        RecyclerView nestedRv;

        public ViewHolder(@NonNull @NotNull View itemView) {
            super(itemView);
            headerTextView = itemView.findViewById(R.id.section_header);
            TopicName = itemView.findViewById(R.id.topicname_latest_keywords);
            nestedRv=itemView.findViewById(R.id.nested_rv_latestKeyword);

        }
    }
}
