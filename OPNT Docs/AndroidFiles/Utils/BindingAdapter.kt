package com.opinito.social.Utils

import android.widget.ImageView
import androidx.appcompat.content.res.AppCompatResources
import androidx.databinding.BindingAdapter

@BindingAdapter(value = ["app:topicName","app:isSelected"], requireAll = true)
fun setDrawableTileIcon(imageView: ImageView, topicName: String?, isSelected: String?) {

    if (isSelected == "Y") {
        imageView.setImageDrawable(
            AppCompatResources.getDrawable(
                imageView.context, ColorChange.getDrawableTiles(
                    topicName.toString()
                )
            )
        )
    } else {
        imageView.setImageDrawable(
            AppCompatResources.getDrawable(
                imageView.context, ColorChange.getDrawableTilesUnselected(
                    topicName.toString()
                )
            )
        )
    }
}

@BindingAdapter("app:setImageFromURL")
fun setImageFromURL(imageView: ImageView, url: String?) {
    if(url.isNullOrEmpty().not()) {
        imageView.loadImageFromGlide(url)
    }
}