package com.opinito.social.Adapter

import android.app.Dialog
import android.content.Context
import android.content.Intent
import android.view.LayoutInflater
import android.view.ViewGroup
import android.widget.TextView
import androidx.appcompat.content.res.AppCompatResources
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.RecyclerView
import com.opinito.social.Activity.Comments
import com.opinito.social.Adapter.ProfilePopupAdapter.ItemViewHolder
import com.opinito.social.R
import com.opinito.social.Utils.TextViewResizable
import com.opinito.social.Utils.visible
import com.opinito.social.code_revamp.Utils
import com.opinito.social.code_revamp.models.showFreshContent.ShowFreshContentResponse
import com.opinito.social.databinding.ProfilePopupItemBinding
import java.util.Locale

class ProfilePopupAdapter(
    private val context: Context,
    val onClickListener : OnClickListener,
    private val onItemClick: ((position: Int, topicCartsModelArrayList1: MutableList<ShowFreshContentResponse.Data?>?) -> Unit)
) : RecyclerView.Adapter<ItemViewHolder?>() {
    var postId = ""
    private var topicCartsModelArrayList: MutableList<ShowFreshContentResponse.Data?>? =
        mutableListOf()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ItemViewHolder {
        val view =
            ProfilePopupItemBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return ItemViewHolder(view)
    }


    override fun onBindViewHolder(holder: ItemViewHolder, position: Int) {
        val pos = holder.adapterPosition
        holder.apply {

            binding.discuss.visible()
            binding.topicNameLatestKeywords.text = topicCartsModelArrayList?.get(pos)?.SHOW_CONTENT
//            if ((topicCartsModelArrayList?.get(position)?.SHOW_CONTENT?.trim()?.length ?: 0) > 80) {
//                TextViewResizable.makeTextViewResizable(binding.topicNameLatestKeywords, 3, "More", true);
//            }
//            Utils.MakeTextViewResizable.makeTextViewResizable(
//                binding.topicNameLatestKeywords,
//                3,
//                " See More",
//                true
//            )


            val action = topicCartsModelArrayList?.get(pos)?.ACTION?.uppercase(Locale.ROOT)

            val hateIcon =
                if (action == "H") R.drawable.skull_fill else R.drawable.ic_skull_grey_new
            val likeIcon = if (action == "L") R.drawable.heart_fill else R.drawable.ic_love_grey_new
            val discussBackground =
                if (action == "H" || action == "L") R.drawable.button_round_corner else R.drawable.button_round_gray

            binding.hateLatestKey.setImageDrawable(
                AppCompatResources.getDrawable(
                    context,
                    hateIcon
                )
            )
            binding.likeLatestKeyword.setImageDrawable(
                AppCompatResources.getDrawable(
                    context,
                    likeIcon
                )
            )
            binding.discuss.background = ContextCompat.getDrawable(context, discussBackground)




            binding.likeLatestKeyword.setOnClickListener {
                topicCartsModelArrayList?.get(pos)?.let { item ->
                    val isLiked = item.ACTION.equals("L", ignoreCase = true)

                    binding.hateLatestKey.setImageDrawable(
                        AppCompatResources.getDrawable(context, R.drawable.ic_skull_grey_new)
                    )
                    binding.likeLatestKeyword.setImageDrawable(
                        AppCompatResources.getDrawable(
                            context,
                            if (isLiked) R.drawable.ic_love_grey_new else R.drawable.heart_fill
                        )
                    )
                    binding.discuss.background = ContextCompat.getDrawable(
                        context,
                        if (isLiked) R.drawable.button_round_gray else R.drawable.button_round_corner
                    )

                    item.ACTION = if (isLiked) "" else "L"

                    onItemClick.invoke(pos, topicCartsModelArrayList)
                }
            }

            binding.hateLatestKey.setOnClickListener {
                try {
                    topicCartsModelArrayList?.get(pos)?.let { item ->
                        val isHated = item.ACTION.equals("H", ignoreCase = true)

                        binding.likeLatestKeyword?.setImageDrawable(
                            AppCompatResources.getDrawable(
                                context, R.drawable.ic_love_grey_new
                            )
                        )
                        binding.hateLatestKey.setImageDrawable(
                            AppCompatResources.getDrawable(
                                context,
                                if (isHated) R.drawable.ic_skull_grey_new else R.drawable.skull_fill
                            )
                        )
                        binding.discuss?.background = ContextCompat.getDrawable(
                            context,
                            if (isHated) R.drawable.button_round_gray else R.drawable.button_round_corner
                        )

                        item.ACTION = if (isHated) "" else "H"

                        onItemClick.invoke(pos, topicCartsModelArrayList)
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }

            binding.discuss?.setOnClickListener {
                if (topicCartsModelArrayList?.get(pos)?.ACTION?.contains("L") == true ||
                    topicCartsModelArrayList?.get(pos)?.ACTION?.contains("H") == true
                ) {
                    onClickListener.onClick(position)

                    val intent = Intent(context, Comments::class.java)
                    intent.putExtra("postid", topicCartsModelArrayList?.get(pos)?.POST_ID)
                    ContextCompat.startActivity(context, intent, null)
                    postId = ""
                } else {
                    val topicPopup = Dialog(context)
                    topicPopup.setContentView(R.layout.image_dialog)
                    val cancel = topicPopup.findViewById<TextView>(R.id.okay_text)
                    cancel.setOnClickListener { topicPopup.dismiss() }
                    topicPopup.window?.setLayout(
                        ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT
                    )
                    topicPopup.show()
                }
            }
        }

    }

    fun updateList(updatedList: MutableList<ShowFreshContentResponse.Data?>?) {
        topicCartsModelArrayList = updatedList ?: mutableListOf()

    }

    override fun getItemCount(): Int {
        return topicCartsModelArrayList?.size ?: 0
    }

    inner class ItemViewHolder(val binding: ProfilePopupItemBinding) :
        RecyclerView.ViewHolder(binding.root)

    interface OnClickListener {
        fun onClick(position: Int)
    }

}