package com.opinito.social.Activity

import android.content.Intent
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.LinearLayout
import androidx.viewpager.widget.ViewPager.OnPageChangeListener
import com.opinito.social.R
import com.opinito.social.code_revamp.BaseActivity
import com.opinito.social.code_revamp.adapter.SplashViewPagerAdapter
import com.opinito.social.databinding.ActivityWelcomeBinding

class WelcomeActivity : BaseActivity() {

    private lateinit var binding: ActivityWelcomeBinding
    private var layouts = mutableListOf<Int>()
    private var ivArrayDotsPager = mutableListOf<ImageView>()
    private fun getItem(i: Int): Int {
        return binding.viewPager.currentItem + i
    }

    private fun launchHomeScreen() {
        startActivity(Intent(this@WelcomeActivity, Login::class.java))
        finish()
    }

    //  viewpager change listener
    private var viewPagerPageChangeListener: OnPageChangeListener = object : OnPageChangeListener {
        override fun onPageSelected(position: Int) {
            for (i in 0 until ivArrayDotsPager.size) {
                ivArrayDotsPager[i].setImageResource(R.drawable.page_inactive)
            }
            ivArrayDotsPager[position].setImageResource(R.drawable.page_active)
            if (position == layouts.size - 1) {
                binding.btnNext.background = null
                binding.btnNext.text = getString(R.string.done)
                binding.skipButton.visibility = View.GONE
            } else {
                binding.btnNext.setBackgroundResource(R.drawable.next_welcome_screen)
                binding.skipButton.visibility = View.VISIBLE
                binding.btnNext.text = ""
            }
            if (position == layouts.size - 3) {
                binding.btnPrevious.visibility = View.INVISIBLE
            } else {
                binding.btnPrevious.visibility = View.VISIBLE
            }
        }

        override fun onPageScrolled(arg0: Int, arg1: Float, arg2: Int) {}
        override fun onPageScrollStateChanged(arg0: Int) {}
    }

    private fun setupPagerIndicatorDots() {
        ivArrayDotsPager = mutableListOf()

        for (i in 0 until 3) {
            val item = ImageView(this@WelcomeActivity)
            val params = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT
            )
            params.setMargins(5, 0, 5, 0)
            item.layoutParams = params
            item.setImageResource(R.drawable.page_inactive)
            item.setOnClickListener { view -> view.alpha = 1f }
            binding.layoutDots.addView(item)
            binding.layoutDots.bringToFront()
            ivArrayDotsPager.add(item)
        }
    }

    override fun initUI() {
        binding = ActivityWelcomeBinding.inflate(layoutInflater)
        setContentView(binding.root)
        binding.btnPrevious.visibility = View.INVISIBLE

        binding.skipButton.setOnClickListener {
            startActivity(Intent(this@WelcomeActivity, Login::class.java))
            finish()
        }
        // layouts of all welcome sliders
        layouts.add(R.layout.welcome_slide_1)
        layouts.add(R.layout.welcome_slide_2)
        layouts.add(R.layout.welcome_slide_3)
        setupPagerIndicatorDots()
        val myViewPagerAdapter = SplashViewPagerAdapter(this, layouts)
        binding.viewPager.adapter = myViewPagerAdapter
        binding.viewPager.addOnPageChangeListener(viewPagerPageChangeListener)
        ivArrayDotsPager[0].setImageResource(R.drawable.page_active)
        binding.btnPrevious.setOnClickListener {
            val current = getItem(-1)
            if (current < layouts.size) {
                // move to next screen
                binding.viewPager.currentItem = current
            } else {
                launchHomeScreen()
            }
        }
        binding.btnNext.setOnClickListener {
            // checking for last page
            // if last page home screen will be launched
            val current = getItem(+1)
            if (current < layouts.size) {
                // move to next screen
                binding.btnPrevious.visibility = View.VISIBLE
                binding.viewPager.currentItem = current
            } else {
                launchHomeScreen()
            }
        }
    }
}