package com.opinito.social.Utils

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.ActionBar
import androidx.recyclerview.widget.RecyclerView
import androidx.recyclerview.widget.RecyclerView.LayoutManager
import androidx.recyclerview.widget.RecyclerView.SmoothScroller
import androidx.swiperefreshlayout.widget.CircularProgressDrawable
import com.bumptech.glide.Glide
import com.opinito.social.Constants.Constants
import com.opinito.social.Constants.Preference
import com.opinito.social.R

fun View.visible() {
    visibility = View.VISIBLE
}

fun View.gone() {
    visibility = View.GONE
}

fun View.invisible() {
    visibility = View.INVISIBLE
}

fun Context.toast(message: String) {
    Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
}

fun getCircularLoader(context: Context): CircularProgressDrawable {
    val circularProgressDrawable = CircularProgressDrawable(context)
    circularProgressDrawable.strokeWidth = 5f
    circularProgressDrawable.centerRadius = 30f
    circularProgressDrawable.start()
    return circularProgressDrawable
}

fun customToolBar(context: Context, titleHide: Boolean, title: String, actionBar: ActionBar?) {
    actionBar!!.setDisplayShowHomeEnabled(false)
    actionBar.setDisplayShowTitleEnabled(false)
    val mInflater = LayoutInflater.from(context)
    val mCustomView = mInflater.inflate(R.layout.custom_actionbar, null)
    val mTitleTextView = mCustomView.findViewById<TextView>(R.id.title_text)
    val usernameTextView = mCustomView.findViewById<TextView>(R.id.username)
    mTitleTextView.text = title
    val cancel = mCustomView.findViewById<ImageView>(R.id.cancel_action)
    val opinIcon = mCustomView.findViewById<ImageView>(R.id.opin_icon)
    if (title == context.getString(R.string.feeds)) {
        usernameTextView.visibility = View.VISIBLE
        if (Preference(context).getPref(Constants.USERNAME).length > 8) usernameTextView.text =
            String.format(
                "%s..", Preference(context).getPref(
                    Constants.USERNAME
                ).substring(0, 8)
            ) else usernameTextView.text = Preference(context).getPref(
            Constants.USERNAME
        )
    } else usernameTextView.visibility = View.GONE
    if (titleHide) {
        cancel.visibility = View.VISIBLE
    } else {
        opinIcon.visibility = View.VISIBLE
        cancel.visibility = View.GONE
    }
    actionBar.customView = mCustomView
    actionBar.setDisplayShowCustomEnabled(true)
}

fun ImageView.loadImageFromGlide(url: String?) {
    if (url != null) {
        Glide.with(this)
            .load(url)
            .error(R.drawable.noimage)
            .placeholder(getCircularLoader(this.context))
            .into(this)
    }
}

fun RecyclerView.scrollTo(position: Int?) {
    if (position != null) {
        layoutManager?.scrollToPosition(position)
//        layoutManager?.smoothScrollToPosition(this,RecyclerView.State(),position)

    }
}

