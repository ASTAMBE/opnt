package com.opinito.social.code_revamp.adapter

import android.content.Context
import android.graphics.Typeface
import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.appcompat.content.res.AppCompatResources
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.RecyclerView
import com.opinito.social.Constants.Constants
import com.opinito.social.Constants.Preference
import com.opinito.social.R
import com.opinito.social.Utils.ColorChange
import com.opinito.social.Utils.gone
import com.opinito.social.Utils.visible
import com.opinito.social.code_revamp.models.get_user_topics.GetUserTopicResponseItem
import com.opinito.social.databinding.CustomTabsBinding

class NewsHoriAdapter(
    val context: Context,
    private val listener: OnItemClickListener
) : RecyclerView.Adapter<NewsHoriAdapter.ItemViewHolder>() {
    private var topicList: MutableList<GetUserTopicResponseItem> = mutableListOf()
    private var selectedTopic: Int = Preference(context).getIntPref(Constants.TOPICCARTID)


    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ItemViewHolder {
        val view =
            CustomTabsBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return ItemViewHolder(view)
    }

    override fun getItemCount(): Int {
        return topicList.size
    }

    override fun onBindViewHolder(holder: ItemViewHolder, position: Int) {
        val pos = holder.adapterPosition
        holder.apply {
            binding.customTabIv.setImageDrawable(
                AppCompatResources.getDrawable(
                    context,
                    ColorChange.getDrawable(
                        topicList[pos].TOPIC
                    )
                )
            )
            if (selectedTopic == topicList[pos].TOPICID) {
                binding.customTabHoriLine.visible()
                binding.customTabIv.setColorFilter(
                    ContextCompat.getColor(
                        context,
                        R.color.colorPrimary
                    )
                )
                binding.customTabTv.setTextColor(
                    ContextCompat.getColor(
                        context,
                        R.color.colorPrimary
                    )
                )
                binding.customTabTv.setTypeface(null, Typeface.BOLD)
                listener.onTopicClick(topicList[pos].TOPICID, pos)


            } else {
                binding.customTabHoriLine.gone()
                binding.customTabIv.setColorFilter(
                    ContextCompat.getColor(
                        context,
                        R.color.colourGrey
                    )
                )
                binding.customTabTv.setTextColor(
                    ContextCompat.getColor(
                        context,
                        R.color.colourGrey
                    )
                )
                binding.customTabTv.setTypeface(null, Typeface.NORMAL)
            }
            binding.customTabTv.text = topicList[pos].TOPIC

            binding.root.setOnClickListener {
                selectedTopic = topicList[pos].TOPICID ?: 9
                Preference(context).saveIntPref(Constants.TOPICCARTID, selectedTopic)
                notifyDataSetChanged()
            }
        }

    }

    fun updateList(topicsList: MutableList<GetUserTopicResponseItem>) {
        topicList = topicsList
        notifyDataSetChanged()
    }

    inner class ItemViewHolder(val binding: CustomTabsBinding) :
        RecyclerView.ViewHolder(binding.root)

    interface OnItemClickListener {
        fun onTopicClick(topicId: Int?, position: Int)
    }
}