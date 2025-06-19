package com.opinito.social.Adapter

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.res.ColorStateList
import android.net.Uri
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.appcompat.content.res.AppCompatResources
import androidx.browser.customtabs.CustomTabsIntent
import androidx.core.content.ContextCompat.startActivity
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.bumptech.glide.load.resource.bitmap.CircleCrop
import com.bumptech.glide.load.resource.bitmap.RoundedCorners
import com.opinito.social.Constants.Constants
import com.opinito.social.Constants.Preference
import com.opinito.social.R
import com.opinito.social.Utils.ColorChange
import com.opinito.social.Utils.ExtractWebURLPreview
import com.opinito.social.Utils.LinePagerIndicatorDecoration
import com.opinito.social.Utils.TextViewResizable
import com.opinito.social.Utils.gone
import com.opinito.social.Utils.visible
//import com.opinito.social.code_revamp.models.NewsDetails
import com.opinito.social.code_revamp.models.get_discussions_nw.GetDiscussionsNwResponseItem
import com.opinito.social.databinding.DiscussionPostItemBinding
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.jsoup.Jsoup
import java.io.IOException
import java.util.Locale


class UserDiscussionAdapter(
    val context: Context,
    private val listener: OnItemClickListener
) : RecyclerView.Adapter<UserDiscussionAdapter.ViewHolder>() {
    private var discussionPostDetailsList: MutableList<GetDiscussionsNwResponseItem?> =
        mutableListOf()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view =
            DiscussionPostItemBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return ViewHolder(view)
    }

    override fun getItemCount(): Int {
        return discussionPostDetailsList.size
    }


    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val pos = holder.adapterPosition
        holder.apply {
            binding.webPageImageLayout.gone()
            binding.postImagesRecycler.gone()
            binding.discussion = discussionPostDetailsList[position]
            if (discussionPostDetailsList[position]?.POST_CONTENT?.contains("/") == true) {
                binding.postedtext.gone()
/*                CoroutineScope(Dispatchers.IO).launch {
                    try {
                        val newsDetails =
                            fetchNewsDetails(discussionPostDetailsList[position]?.POST_CONTENT)
                        withContext(Dispatchers.Main) {
                            binding.header.text = newsDetails.title
                            binding.description.text = newsDetails.subtitle
                            Glide.with(context)
                                .load(newsDetails.imageUrl)
                                .transform(RoundedCorners(25))
                                .placeholder(R.mipmap.ic_launcher)
                                .into(binding.webpageimage)
                            binding.webPageImageLayout.visible()
                        }
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                }*/
                                ExtractWebURLPreview(
                                    context as Activity,
                                    binding.webpageimage,
                                    binding.header,
                                    binding.description,
                                    binding.webPageImageLayout,
                                    binding.remaningdescription,
                                    null
                                ).getPreview(
                                    discussionPostDetailsList[position]?.POST_CONTENT,
                                    discussionPostDetailsList[position]?.POST_ID
                                )

            } else {
                binding.postedtext.text = discussionPostDetailsList[position]?.POST_CONTENT
                if ((discussionPostDetailsList[position]?.POST_CONTENT?.trim()?.length
                        ?: 0) > 500
                ) {
                    TextViewResizable.makeTextViewResizable(binding.postedtext, 5, "More", true)
                }
                binding.postedtext.visible()
                binding.webPageImageLayout.gone()
            }
            if (discussionPostDetailsList[position]?.USERNAME.equals(
                    Preference(context).getPref(
                        Constants.USERNAME
                    )
                )
            ) {
                binding.editDeleteIv.visible()
                binding.removeUser.gone()
                binding.delete.visible()
            } else {
                binding.editDeleteIv.gone()
                binding.delete.gone()
                binding.removeUser.visible()
            }
            if (discussionPostDetailsList[position]?.BOOKMARK_FLAG == "B") {
                binding.bookmark.setImageDrawable(
                    AppCompatResources.getDrawable(
                        context,
                        R.drawable.bookmark_active
                    )
                )
            } else {
                binding.bookmark.setImageDrawable(
                    AppCompatResources.getDrawable(
                        context,
                        R.drawable.ic_bookmark_gray
                    )
                )
            }
            if (discussionPostDetailsList[pos]?.MEDIA_FLAG == context.getString(R.string.flay_Y)) {
                if (discussionPostDetailsList[pos]?.MEDIA_CONTENT != "" ||
                    discussionPostDetailsList[pos]?.MEDIA_CONTENT != null
                ) {
                    val imageList: List<String> =
                        discussionPostDetailsList[pos]?.MEDIA_CONTENT.toString()
                            .split(",".toRegex())
                            .dropLastWhile { it.isEmpty() }.toList()

                    binding.attachmentTv.text = String.format(
                        context.getString(R.string.attachment_count_text),
                        imageList.size.toString()
                    )
                    if (binding.webPageImageLayout.visibility != View.VISIBLE) {
                        binding.attachmentIv.gone()
                        binding.attachmentTv.gone()
                        binding.postImagesRecycler.visible()
                        val feedPostImagesAdapter = FeedPostImagesAdapter(context, imageList)
                        binding.postImagesRecycler.adapter = feedPostImagesAdapter
                        if (imageList.size > 1) binding.postImagesRecycler.addItemDecoration(
                            LinePagerIndicatorDecoration()
                        )
                    } else {
                        binding.attachmentIv.visible()
                        binding.attachmentTv.visible()
                        binding.postImagesRecycler.gone()
                    }
                }
            } else {
                binding.attachmentIv.gone()
                binding.postImagesRecycler.gone()
            }
            if (discussionPostDetailsList[position]?.POST_COMMENT_COUNT == null) {
                binding.commentCount.text = "0"
            } else {
                binding.commentCount.text = discussionPostDetailsList[position]?.POST_COMMENT_COUNT
            }
            if (discussionPostDetailsList[position]?.POST_ACTION_TYPE?.lowercase(Locale.getDefault())
                    .equals("h", ignoreCase = true)
            ) {
                binding.imgLikePost.setImageDrawable(
                    AppCompatResources.getDrawable(
                        context,
                        R.drawable.ic_love_grey_new
                    )
                )
                binding.imgDislikePost.setImageDrawable(
                    AppCompatResources.getDrawable(
                        context,
                        R.drawable.skull_fill
                    )
                )
            } else if (discussionPostDetailsList[position]?.POST_ACTION_TYPE?.lowercase(Locale.getDefault())
                    .equals("l", ignoreCase = true)
            ) {
                binding.imgLikePost.setImageDrawable(
                    AppCompatResources.getDrawable(
                        context,
                        R.drawable.heart_fill
                    )
                )
                binding.imgDislikePost.setImageDrawable(
                    AppCompatResources.getDrawable(
                        context,
                        R.drawable.ic_skull_grey_new
                    )
                )
            } else {
                binding.imgLikePost.setImageDrawable(
                    AppCompatResources.getDrawable(
                        context,
                        R.drawable.ic_love_grey_new
                    )
                )
                binding.imgDislikePost.setImageDrawable(
                    AppCompatResources.getDrawable(
                        context,
                        R.drawable.ic_skull_grey_new
                    )
                )
            }

            val postId = discussionPostDetailsList[position]?.POST_ID
            if (discussionPostDetailsList[position]?.USERNAME?.isNotEmpty() == true) {
                binding.statusText.visible()
                binding.statusText.text =
                    discussionPostDetailsList[position]?.USERNAME?.get(0).toString()

                binding.statusChangeLayoutParentPost.backgroundTintList = ColorStateList.valueOf(
                    ColorChange(context).colorChange(
                        discussionPostDetailsList[position]?.USERNAME?.lowercase(
                            Locale.getDefault()
                        )?.get(0).toString()
                    )
                )

                if (discussionPostDetailsList[position]?.DP_URL != "null" || discussionPostDetailsList[position]?.DP_URL != "") {
                    Glide.with(context).load(discussionPostDetailsList[position]?.DP_URL)
                        .transform(
                            CircleCrop(),
                            RoundedCorners(5)
                        )
                        .into(binding.statusImage)
                }
            }

            binding.likeCount.setOnClickListener {
                if (postId != null) {
                    listener.onLikeCountClick(holder.adapterPosition, postId)
                }
            }
            binding.hCount.setOnClickListener {

                listener.onHateCountClick(holder.adapterPosition, postId)
            }

            binding.imgLikePost.setOnClickListener {
                if (discussionPostDetailsList[position]?.POST_ACTION_TYPE?.lowercase(Locale.getDefault()).equals("H", ignoreCase = true)) {
                    userActionCommon(postId, "H0")
                    binding.likeCount.text = discussionPostDetailsList[position]?.LCOUNT?.toInt()?.plus(1).toString()
                    binding.hCount.text = (discussionPostDetailsList[position]?.HCOUNT.toString())
                    discussionPostDetailsList[position]?.POST_ACTION_TYPE = "L"
                    binding.imgDislikePost.setImageDrawable(AppCompatResources.getDrawable(context, R.drawable.ic_skull_grey_new))
                    binding.imgLikePost.setImageDrawable(AppCompatResources.getDrawable(context, R.drawable.heart_fill))
                    userActionCommon(postId, "L1")
                } else if (discussionPostDetailsList[position]?.POST_ACTION_TYPE?.lowercase(Locale.getDefault()).equals("L", ignoreCase = true)) {
                    userActionCommon(postId, "L0")
                    discussionPostDetailsList[position]?.POST_ACTION_TYPE = ""
                    binding.likeCount.text = (discussionPostDetailsList[position]?.LCOUNT?.toString())
                    binding.imgLikePost.setImageDrawable(AppCompatResources.getDrawable(context, R.drawable.ic_love_grey_new))
                } else {
                    userActionCommon(postId, "L1")
                    discussionPostDetailsList[position]?.POST_ACTION_TYPE = "L"
                    binding.likeCount.text = discussionPostDetailsList[position]?.LCOUNT?.toInt()?.plus(1).toString()
                    binding.imgLikePost.setImageDrawable(AppCompatResources.getDrawable(context, R.drawable.heart_fill))
                }
            }
            binding.imgDislikePost.setOnClickListener {
                if (discussionPostDetailsList[position]?.POST_ACTION_TYPE?.lowercase(Locale.getDefault()).equals("L", ignoreCase = true)) {
                    userActionCommon(postId, "L0")
                    binding.likeCount.text = (discussionPostDetailsList[position]?.LCOUNT.toString())
                    binding.hCount.text = discussionPostDetailsList[position]?.HCOUNT?.toInt()?.plus(1).toString()
                    discussionPostDetailsList[position]?.POST_ACTION_TYPE = "H"
                    binding.imgLikePost.setImageDrawable(AppCompatResources.getDrawable(context, R.drawable.ic_love_grey_new))
                    binding.imgDislikePost.setImageDrawable(AppCompatResources.getDrawable(context, R.drawable.skull_fill))
                    userActionCommon(postId, "H1")
                } else if (discussionPostDetailsList[position]?.POST_ACTION_TYPE?.lowercase(Locale.getDefault()).equals("H", ignoreCase = true)) {
                    userActionCommon(postId, "H0")
                    discussionPostDetailsList[position]?.POST_ACTION_TYPE = ""
                        binding.hCount.text = (discussionPostDetailsList[position]?.HCOUNT?.toString())
                    binding.imgDislikePost.setImageDrawable(AppCompatResources.getDrawable(context, R.drawable.ic_skull_grey_new))
                } else {
                    userActionCommon(postId, "H1")
                    discussionPostDetailsList[position]?.POST_ACTION_TYPE = "H"
                    binding.hCount.text = discussionPostDetailsList[position]?.HCOUNT?.toInt()?.plus(1).toString()
                    binding.imgDislikePost.setImageDrawable(AppCompatResources.getDrawable(context, R.drawable.skull_fill))
                }
            }
            binding.statusChangeLayoutParentPost.setOnClickListener {
                listener.onPostProfileClick(
                    pos,
                    postId,
                )
            }
            binding.editDeleteIv.setOnClickListener {
                listener.editDeleteClick(pos,postId)
            }

            binding.imgcomment.setOnClickListener {
                listener.onPostCommentClick(pos, postId)
            }
            binding.bookmark.setOnClickListener {
                if (discussionPostDetailsList[position]?.BOOKMARK_FLAG == ""){
                    discussionPostDetailsList[position]?.BOOKMARK_FLAG == "B"
                    listener.onPostBookmarkClick(pos, postId)
                    binding.bookmark.setImageDrawable(
                        AppCompatResources.getDrawable(
                            context,
                            R.drawable.bookmark_active
                        )
                    )
                }else{
                    listener.onPostBookmarkClick(pos, postId)
                    binding.bookmark.setImageDrawable(
                        AppCompatResources.getDrawable(
                            context,
                            R.drawable.ic_bookmark_gray
                        )
                    )
                }

            }
            binding.sharePost.setOnClickListener {

                listener.onPostShareClick(
                    pos,
                    postId,
                    discussionPostDetailsList[position]?.POST_CONTENT
                )
            }
            binding.showPostDetail.setOnClickListener {
                listener.onPostDetailsClick(pos, postId)
            }
            binding.removeUser.setOnClickListener {
                listener.onRemoveUserClick(pos, postId)
            }
            binding.webPageImageLayout.setOnClickListener {
                if (discussionPostDetailsList[position]?.POST_CONTENT != null) {
                    if (discussionPostDetailsList[position]?.POST_CONTENT?.contains("/") == true) {
                        val builder = CustomTabsIntent.Builder()
                        val customTabsIntent = builder.build()
                        customTabsIntent.launchUrl(
                            context,
                            Uri.parse(discussionPostDetailsList[position]?.POST_CONTENT)
                        )
                    }
                }
            }
        }
    }

    private fun openUrl(url: String) {
        val intent = Intent(Intent.ACTION_VIEW)
        intent.data = Uri.parse(url)
        startActivity(context, intent, null)
    }


    fun userActionCommon(postId: String?, action: String) {
        listener.onLikeHateClick(postId, action)
    }

    fun updateList(postDetailsList: MutableList<GetDiscussionsNwResponseItem?>) {
        discussionPostDetailsList = postDetailsList
        notifyDataSetChanged()
    }

/*    private suspend fun fetchNewsDetails(url: String?): NewsDetails {
        return withContext(Dispatchers.IO) {
            try {
                val doc = Jsoup.connect(url).get()

                // Fetch title
                val title = doc.title()

                // Fetch subtitle (if available)
                val subtitle = doc.select("meta[property=og:description]").attr("content")

                // Fetch main image URL
                val imageUrl = doc.select("meta[property=og:image]").attr("content")

                NewsDetails(title, subtitle, imageUrl)
            } catch (e: IOException) {
                e.printStackTrace()
                throw e
            }
        }
    }*/

    class ViewHolder(val binding: DiscussionPostItemBinding) : RecyclerView.ViewHolder(binding.root)

    interface OnItemClickListener {
        fun onLikeHateClick(postId: String?, action: String?)
        fun onPostProfileClick(pos: Int, postId: String?)
        fun onPostCommentClick(pos: Int, postId: String?)
        fun onPostBookmarkClick(pos: Int, postId: String?)
        fun onPostShareClick(pos: Int, postId: String?, tilte: String?)
        fun onPostDetailsClick(pos: Int, postId: String?)
        fun onRemoveUserClick(pos: Int, postId: String?)
        fun onLikeCountClick(pos: Int, postId: String)
        fun onHateCountClick(pos: Int, postId: String?)
        fun editDeleteClick(pos: Int,postId: String?)
    }

}
