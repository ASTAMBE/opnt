package com.opinito.social.Adapter

import android.content.Context
import android.icu.text.Transliterator.Position
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import androidx.appcompat.content.res.AppCompatResources
import androidx.constraintlayout.helper.widget.Carousel.Adapter
import androidx.recyclerview.widget.RecyclerView
import com.opinito.social.Utils.ColorChange
import com.opinito.social.code_revamp.models.user_interests.response.Data
import com.opinito.social.databinding.TopicsGridItemBinding


class TopicsGridAdapter(
    val context: Context,
    private var topicsList: List<Data?>?,
    private val onItemClick: ((topicID: String?, isTopicSelected: String?,position:Int) -> Unit),
    private val onItemLongClick: ((position:Int) -> Unit)
) : RecyclerView.Adapter<TopicsGridAdapter.ViewHolder>() {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view = TopicsGridItemBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return ViewHolder(view)
    }

    override fun getItemCount(): Int {
        return topicsList!!.size
    }


    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.apply {
            val item = topicsList?.get(position)

            binding.topicsName.text = item?.TOPIC

            if (item?.SLCT == "Y") {
                binding.topicImageView.setImageDrawable(
                    AppCompatResources.getDrawable(
                        context, ColorChange.getDrawableTiles(
                            item.TOPIC.toString()
                        )
                    )
                )
            } else {
                binding.topicImageView.setImageDrawable(
                    AppCompatResources.getDrawable(
                        context, ColorChange.getDrawableTilesUnselected(
                            item?.TOPIC.toString()
                        )
                    )
                )
            }
            binding.topic = item
            binding.topicImageView.setOnLongClickListener {
                onItemLongClick.invoke(position)
                true
            }

            binding.topicImageView.setOnClickListener {
                onItemClick.invoke(item?.TOPICID, item?.SLCT,position)
            }
        }
    }

    class ViewHolder(val binding: TopicsGridItemBinding) : RecyclerView.ViewHolder(binding.root)

}