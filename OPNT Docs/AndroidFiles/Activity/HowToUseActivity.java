package com.opinito.social.Activity;

import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentPagerAdapter;
import androidx.viewpager.widget.ViewPager;

import android.os.Bundle;
import android.view.View;

import com.opinito.social.Constants.Constants;
import com.opinito.social.Constants.Preference;
import com.opinito.social.Fragment.HowtoUsePagerFragment;
import com.opinito.social.R;
import com.opinito.social.databinding.ActivityHowToUseBinding;

public class HowToUseActivity extends AppCompatActivity implements View.OnClickListener {

    private ActivityHowToUseBinding binding;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityHowToUseBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());
        init();
    }

    private void init() {
        new Preference(this).saveIntPref(Constants.HOWTOUSE, 1);
        binding.skipTopTv.setOnClickListener(this);
        binding.nextLayout.setOnClickListener(this);
        binding.toDiscussionBottomTv.setOnClickListener(this);
        binding.tellMeMoreBottomTv.setOnClickListener(this);
        binding.howToUsePager.setAdapter(new HowToUsePagerAdapter(getSupportFragmentManager()));
        binding.tabLayout.setupWithViewPager(binding.howToUsePager);
        binding.howToUsePager.addOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            @Override
            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {
                if (position == 0) {
                    binding.nextLayout.setVisibility(View.VISIBLE);
                    binding.toDiscussionLayout.setVisibility(View.GONE);
                    binding.nextLayoutBottom.setVisibility(View.GONE);
                    binding.howToUseTv.setText(getString(R.string.introducing_opinito));
                    binding.tellMeMoreBottomTv.setText(getString(R.string.tell_me_more));
                } else if (position == 1) {
                    binding.nextLayout.setVisibility(View.GONE);
                    binding.toDiscussionLayout.setVisibility(View.VISIBLE);
                    binding.nextLayoutBottom.setVisibility(View.VISIBLE);
                    binding.howToUseTv.setText(getString(R.string.introducing_opinito));
                    binding.tellMeMoreBottomTv.setText(getString(R.string.tell_me_more));
                } else if (position == 2){
                    binding.nextLayout.setVisibility(View.GONE);
                    binding.toDiscussionLayout.setVisibility(View.VISIBLE);
                    binding.nextLayoutBottom.setVisibility(View.VISIBLE);
                    binding.tellMeMoreBottomTv.setText(getString(R.string.to_opinions));
                    binding.howToUseTv.setText(getString(R.string.howtouse));
                }
            }

            @Override
            public void onPageSelected(int position) {

            }

            @Override
            public void onPageScrollStateChanged(int state) {

            }
        });
    }

    @Override
    public void onBackPressed() {
        if (binding.tabLayout.getSelectedTabPosition() == 0) {
            super.onBackPressed();
        } else
            binding.tabLayout.selectTab(binding.tabLayout.getTabAt(binding.tabLayout.getSelectedTabPosition() - 1));
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.next_layout:
            case R.id.tell_me_more_bottom_tv:
                if (binding.tabLayout.getSelectedTabPosition() < 2)
                    binding.tabLayout.selectTab(binding.tabLayout.getTabAt(binding.tabLayout.getSelectedTabPosition() + 1));
                else {
                    DashBoard.selectTab = 1;
                    finish();
                }
                break;

            case R.id.skip_top_tv:
            case R.id.to_discussion_bottom_tv:
                DashBoard.isFirstTimeLogin = true;
                DashBoard.selectTab = 0;
                finish();
                break;
        }
    }

    private class HowToUsePagerAdapter extends FragmentPagerAdapter {
        public HowToUsePagerAdapter(FragmentManager fm) {
            super(fm);
        }

        public Fragment getItem(int position) {
            return HowtoUsePagerFragment.newInstance(position);
        }
        @Override
        public int getCount() {
            return 3;
        }
    }
}