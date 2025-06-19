package com.opinito.social.Adapter

import android.app.Dialog
import android.content.Context
import android.view.LayoutInflater
import android.view.ViewGroup
import android.widget.TextView
import androidx.appcompat.content.res.AppCompatResources
import androidx.recyclerview.widget.RecyclerView
import com.opinito.social.R
import com.opinito.social.code_revamp.models.getUserCarts.Data
import com.opinito.social.databinding.CustomTopiccartBinding
import java.util.Locale

/**
 * Created by chanti on 7/11/2017.
 */
class TopicCartsAdapter(val context: Context, private val clickListener: OnClickListener) :
    RecyclerView.Adapter<TopicCartsAdapter.MyViewHolder>() {
    private var topicList: MutableList<Data?>? = mutableListOf()
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MyViewHolder {
        val view =
            CustomTopiccartBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return MyViewHolder(view)
    }

    override fun getItemCount(): Int {
        return topicList?.size!!
    }

    override fun onBindViewHolder(holder: MyViewHolder, position: Int) {
        val pos = holder.adapterPosition
        holder.apply {
            binding.topicname.text = topicList?.get(pos)?.KEYWORDS
            binding.totalHateCount.text = topicList?.get(pos)?.HCNT
            binding.totalLoveCount.text = topicList?.get(pos)?.LCNT

            if (topicList?.get(pos)?.CART?.lowercase(Locale.getDefault())
                    .equals("l", ignoreCase = true)
            ) {
                binding.like.setImageDrawable(AppCompatResources.getDrawable(context,R.drawable.heart_fill))
                binding.hate.setImageDrawable(AppCompatResources.getDrawable(context,R.drawable.ic_skull_grey_new))
            } else if (topicList?.get(pos)?.CART?.lowercase(Locale.getDefault())
                    .equals("h", ignoreCase = true)
            ) {
                binding.hate.setImageDrawable(AppCompatResources.getDrawable(context, R.drawable.skull_fill))
                binding.like.setImageDrawable(AppCompatResources.getDrawable(context,R.drawable.ic_love_grey_new))
            } else {
                binding.hate.setImageDrawable(AppCompatResources.getDrawable(context,R.drawable.ic_skull_grey_new))
                binding.like.setImageDrawable(AppCompatResources.getDrawable(context,R.drawable.ic_love_grey_new))
            }

            binding.topicname.setOnClickListener {
                keyWordPopup(pos)
            }
            binding.hate.setOnClickListener {
                if (topicList?.get(pos)?.CART
                        ?.lowercase(Locale.getDefault()).equals("h", ignoreCase = true)
                ) {
                    binding.hate.setImageDrawable(AppCompatResources.getDrawable(context,R.drawable.ic_skull_grey_new))
                    binding.like.setImageDrawable(AppCompatResources.getDrawable(context,R.drawable.ic_love_grey_new))
                    topicList?.get(pos)?.CART = ""
                } else {
                    binding.hate.setImageDrawable(AppCompatResources.getDrawable(context, R.drawable.skull_fill))
                    binding.like.setImageDrawable(AppCompatResources.getDrawable(context,R.drawable.ic_love_grey_new))
                    topicList?.get(pos)?.CART = "H"
                }
                clickListener.likeHateClicked()
            }
            binding.like.setOnClickListener {
                if (topicList?.get(pos)?.CART
                        ?.lowercase(Locale.getDefault()).equals("l", ignoreCase = true)
                ) {
                    binding.hate.setImageDrawable(AppCompatResources.getDrawable(context,R.drawable.ic_skull_grey_new))
                    binding.like.setImageDrawable(AppCompatResources.getDrawable(context,R.drawable.ic_love_grey_new))
                    topicList?.get(pos)?.CART = ""
                } else {
                    binding.like.setImageDrawable(AppCompatResources.getDrawable(context,R.drawable.heart_fill))
                    binding.hate.setImageDrawable(AppCompatResources.getDrawable(context,R.drawable.ic_skull_grey_new))
                    topicList?.get(pos)?.CART = "L"
                }
                clickListener.likeHateClicked()
            }
            binding.reportCart.setOnClickListener {
                clickListener.onItemClick(topicList?.get(pos)?.KEYID.toString())
            }
        }
    }

    fun updateList(topicCartsModelArrayList: MutableList<Data?>?) {
        topicList = topicCartsModelArrayList
        notifyDataSetChanged()
    }

    inner class MyViewHolder(val binding: CustomTopiccartBinding) :
        RecyclerView.ViewHolder(binding.root)

    private fun keyWordPopup(position: Int) {
        try {
            val topicPopup = Dialog(context)
            topicPopup.setContentView(R.layout.dailoglayout)
            val keywordText = topicPopup.findViewById<TextView>(R.id.text_dialog)
            keywordText.text = topicList?.get(position)?.KEYWORDS
            val cancel = topicPopup.findViewById<TextView>(R.id.skip_text)
            cancel.text = "Cancel"
            cancel.setOnClickListener { topicPopup.dismiss() }
            topicPopup.window!!
                .setLayout(
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT
                )
            topicPopup.show()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }


    interface OnClickListener {
        fun onItemClick(keyId: String?)
        fun likeHateClicked()
    }
}