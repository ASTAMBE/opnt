package com.opinito.social.Activity;

import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.SearchView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.gson.JsonObject;
import com.opinito.social.Adapter.SearchPostAdapter;
import com.opinito.social.BuildConfig;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.Preference;
import com.opinito.social.Interface.RetrofitNetworkInterface;
import com.opinito.social.Model.SearchPostsModel;
import com.opinito.social.R;
import com.opinito.social.RetrofitClient;
import com.opinito.social.Utils.Customize;
import com.opinito.social.Utils.SoftKeypad;
import com.opinito.social.databinding.ActivitySearchResultsBinding;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

import static com.facebook.FacebookSdk.getApplicationContext;

public class SearchResultsActivity extends AppCompatActivity {

    private ActivitySearchResultsBinding binding;
    private SearchPostAdapter searchPostAdapter;
    private List<SearchPostsModel.Data> searchResultsList = new ArrayList<>();
    private String quest = "";
    boolean isLoading = false;
    private int currentSize = 0;
    private int nextLimit = 20;
    private final String TOPICNAME = "topicname";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivitySearchResultsBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());
        initView();
    }

    private void initView() {
        try {
            Customize.customSupportBar(this, Objects.requireNonNull(getSupportActionBar()), getString(R.string.search), null);
            binding.searchViewResAct.setIconifiedByDefault(false);
            binding.searchViewResAct.setQueryHint(String.format(getString(R.string.search_hint), getIntent().getStringExtra(TOPICNAME).toLowerCase()));
            binding.noResultsFoundTv.setVisibility(View.GONE);
        } catch (Exception e) {
            e.printStackTrace();
        }
        listeners();
    }

    private void listeners() {
        binding.searchRecycler.addOnScrollListener(new RecyclerView.OnScrollListener() {
            @Override
            public void onScrolled(@NonNull RecyclerView recyclerView, int dx, int dy) {
                super.onScrolled(recyclerView, dx, dy);
                final LinearLayoutManager linearLayoutManager = (LinearLayoutManager) binding.searchRecycler.getLayoutManager();
                if (!isLoading) {
                    if (linearLayoutManager != null && linearLayoutManager.findLastCompletelyVisibleItemPosition() ==
                            searchResultsList.size() - 1) {
                        searchForPosts(true);
                        isLoading = true;
                    }
                }
            }
        });

        binding.searchViewResAct.setOnQueryTextListener(new SearchView.OnQueryTextListener() {
            @Override
            public boolean onQueryTextSubmit(String query) {
                if (query.trim().length() >= 2) {
                    binding.noResultsFoundTv.setVisibility(View.GONE);
                    quest = query;
                    searchForPosts(false);
                }
                return false;
            }

            @Override
            public boolean onQueryTextChange(String newText) {
                try {
                    if (newText.trim().length() > 2) {
                        binding.noResultsFoundTv.setVisibility(View.GONE);
                        quest = newText;
                        searchForPosts(false);
                        binding.searchRecycler.setVisibility(View.VISIBLE);
                    } else if (newText.trim().length() == 0) {
                        hideSearch();
                        new SoftKeypad().hide(SearchResultsActivity.this);
                    } else if (newText.trim().length() < 3) {
                        hideSearch();
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
                return false;
            }
        });
    }

    private void hideSearch(){
        binding.noResultsFoundTv.setVisibility(View.GONE);
        searchResultsList.clear();
        binding.searchRecycler.invalidate();
        binding.searchRecycler.setAdapter(null);
        binding.searchRecycler.setVisibility(View.GONE);
    }

    private void searchForPosts(Boolean loadMore) {
        binding.actResProgress.setVisibility(View.VISIBLE);
        if (loadMore) {
            try {
                searchResultsList.add(null);
                searchPostAdapter.notifyItemInserted(searchResultsList.size() - 1);
                searchResultsList.remove(searchResultsList.size() - 1);
                int scrollPosition = searchResultsList.size();
                searchPostAdapter.notifyItemRemoved(scrollPosition);
                currentSize = scrollPosition;
                searchPostAdapter.notifyDataSetChanged();
            } catch (Exception e) {
                e.printStackTrace();
            }
        } else {
            currentSize = 0;
        }
        try {
            RetrofitNetworkInterface retrofitNetworkInterface = RetrofitClient.createService(RetrofitNetworkInterface.class);
            JsonObject searchObject = new JsonObject();
            searchObject.addProperty("userid", new Preference(this).getPref(Constants.USERID));
            searchObject.addProperty("topicid", String.valueOf(new Preference(this).getIntPref(Constants.TOPICID)));
            searchObject.addProperty("searchterm", quest);
            searchObject.addProperty("from", String.valueOf(currentSize));
            searchObject.addProperty("to", String.valueOf(nextLimit));
            Map<String, String> header = new HashMap<>();
            header.put("X-ACCESS-KEY", BuildConfig.APP_ID);
            header.put("Token", new Preference(getApplicationContext()).getPref(Constants.token));
            Call<SearchPostsModel> call = retrofitNetworkInterface.userPostSearch(header,searchObject);
            call.enqueue(new Callback<SearchPostsModel>() {
                @Override
                public void onResponse(Call<SearchPostsModel> call, Response<SearchPostsModel> response) {
                    binding.actResProgress.setVisibility(View.GONE);
                    if (response.code() == 200) {
                        if (response.body() != null) {
                            if (response.body().getStatus().equals(getString(R.string.success_status))) {
                                try {
                                    if (response.body().getData().size() > 0) {
                                        binding.noResultsFoundTv.setVisibility(View.GONE);
                                        if (!loadMore) {
                                            searchResultsList.clear();
                                            searchResultsList.addAll(response.body().getData());
                                            searchPostAdapter = new SearchPostAdapter(SearchResultsActivity.this, searchResultsList, quest);
                                            binding.searchRecycler.setAdapter(searchPostAdapter);
                                        } else {
                                            searchResultsList.addAll(response.body().getData());
                                            searchPostAdapter.notifyItemInserted(searchResultsList.size() - 1);
                                            int scrollPosition = searchResultsList.size();
                                            searchPostAdapter.notifyItemRemoved(scrollPosition);
                                            searchPostAdapter.notifyDataSetChanged();
                                        }
                                        isLoading = false;
                                    }
                                } catch (Exception e) {
                                    searchResultsList.clear();
                                    Toast.makeText(SearchResultsActivity.this,
                                            getString(R.string.something_went_wrong), Toast.LENGTH_SHORT).show();
                                    e.printStackTrace();
                                }
                            } else {
                                if (!loadMore) {
                                    searchResultsList.clear();
                                    binding.noResultsFoundTv.setVisibility(View.VISIBLE);
                                }
                            }
                        }
                    }
                }

                @Override
                public void onFailure(Call<SearchPostsModel> call, Throwable t) {
                    binding.actResProgress.setVisibility(View.GONE);
                    Toast.makeText(SearchResultsActivity.this, getString(R.string.internal_error_occured), Toast.LENGTH_SHORT).show();
                }
            });
        } catch (Exception e) {
            Toast.makeText(SearchResultsActivity.this, getString(R.string.internal_error_occured), Toast.LENGTH_SHORT).show();
            e.printStackTrace();
        }
    }
}
