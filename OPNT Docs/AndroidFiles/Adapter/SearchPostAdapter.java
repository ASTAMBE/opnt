package com.opinito.social.Adapter;

import android.app.Activity;
import android.content.Intent;
import android.content.res.ColorStateList;
import android.graphics.Color;
import android.graphics.Typeface;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.style.TextAppearanceSpan;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AbsListView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.opinito.social.Activity.Comments;
import com.opinito.social.Interface.OnLoadMoreListener;
import com.opinito.social.Model.SearchPostsModel;
import com.opinito.social.R;
import com.opinito.social.Utils.TimeUtils;

import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class SearchPostAdapter extends RecyclerView.Adapter<SearchPostAdapter.SearchViewHolder> {

    private Activity context;
    private static final String POSTID = "postid";
    private List<SearchPostsModel.Data> searchResultsList;
    private String searchQuery;

    public SearchPostAdapter(Activity context, List<SearchPostsModel.Data> searchResultsList, String searchQuery) {
        this.searchResultsList = searchResultsList;
        this.context = context;
        this.searchQuery = searchQuery;
    }

    @NonNull
    @Override
    public SearchViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new SearchViewHolder(LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_search_posts, parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull SearchViewHolder holder, int position) {
        highlightText(String.format(context.getString(R.string.by_username), searchResultsList.get(position).getPOSTBYUNAME()), holder.postByUname);
        setTrimmedString(searchResultsList.get(position).getPOSTCONTENT(), holder.postHeader);
        holder.updatedAt.setText(String.format(context.getString(R.string.last_updated), new TimeUtils().timeAgo(searchResultsList.get(position).getPOSTDTM())));
    }

    private void setTrimmedString(String fullText, TextView textView) {
        if (searchQuery != null && !searchQuery.isEmpty()) {
            int startPos = fullText.toLowerCase().indexOf(searchQuery.toLowerCase());
            int endPos = startPos + searchQuery.length();
            if (startPos > 100 && fullText.length() > 160) {
                String word = fullText.substring(0, 100) + "...";
                try {
                    if (startPos + 20 <= fullText.length())
                        word += fullText.substring(startPos, startPos + 20) + "...";
                    else
                        word += fullText.substring(startPos);
                } catch (Exception e) {
                    word += fullText.substring(startPos, endPos) + "...";
                }
                highlightText(word, textView);
            } else
                highlightText(fullText, textView);
        }
    }

    private void highlightText(String fullText, TextView textView) {
        try {
            if (searchQuery != null && !searchQuery.isEmpty()) {
                int startPos = fullText.toLowerCase().indexOf(searchQuery.toLowerCase());
                int endPos = startPos + searchQuery.length();

                if (startPos != -1) {
                    Spannable spannable = new SpannableString(fullText);
                    ColorStateList blueColor = new ColorStateList(new int[][]{new int[]{}},
                            new int[]{context.getResources().getColor(R.color.colorPrimary)});
                    TextAppearanceSpan highlightSpan = new TextAppearanceSpan(null, Typeface.BOLD, -1, blueColor, null);
                    spannable.setSpan(highlightSpan, startPos, endPos, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
                    textView.setText(spannable);
                } else {
                    textView.setText(fullText);
                }
            } else {
                textView.setText(fullText);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public int getItemCount() {
        return searchResultsList.size();
    }

    class SearchViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener {
        TextView postHeader, postByUname, updatedAt;
        RelativeLayout parentLayout;

        public SearchViewHolder(@NonNull View itemView) {
            super(itemView);
            parentLayout = itemView.findViewById(R.id.search_parent_layout);
            parentLayout.setOnClickListener(this);
            postByUname = itemView.findViewById(R.id.post_by_username);
            postHeader = itemView.findViewById(R.id.post_search_header);
            updatedAt = itemView.findViewById(R.id.post_search_updated_at);
        }

        @Override
        public void onClick(View v) {
            if (v.getId() == R.id.search_parent_layout) {
                try {
                    Intent intent = new Intent(context, Comments.class);
                    intent.putExtra(POSTID, searchResultsList.get(getAdapterPosition()).getPOSTID());
                    context.startActivity(intent);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    }
}
