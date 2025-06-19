package com.opinito.social.Adapter

import android.app.Activity
import android.content.Context
import android.content.res.ColorStateList
import android.net.Uri
import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.appcompat.content.res.AppCompatResources
import androidx.browser.customtabs.CustomTabsIntent
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.bumptech.glide.load.resource.bitmap.CircleCrop
import com.bumptech.glide.load.resource.bitmap.RoundedCorners
import com.facebook.shimmer.Shimmer
import com.facebook.shimmer.ShimmerDrawable
import com.opinito.social.R
import com.opinito.social.Utils.ColorChange
import com.opinito.social.Utils.ExtractWebURLPreview
import com.opinito.social.Utils.visible
import com.opinito.social.code_revamp.models.get_instream_nw.GetInstreamNwResponseItem
import com.opinito.social.databinding.CustomPostBinding
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.jsoup.Jsoup
import java.io.IOException
import java.util.Locale


class PostAdapter(
    val context: Context,
    private val listener: OnItemClickListener<Any>
) : RecyclerView.Adapter<PostAdapter.ViewHolder>() {
    private var newsPostDetailsList: MutableList<GetInstreamNwResponseItem?> = mutableListOf()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view = CustomPostBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return ViewHolder(view)
    }

    override fun getItemCount(): Int {
        return newsPostDetailsList.size
    }


    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.apply {
            binding.news = newsPostDetailsList[position]
            if (newsPostDetailsList[position]?.POST_CONTENT?.contains("/") == true) {

/*                CoroutineScope(Dispatchers.IO).launch {
                    try {
                        val newsDetails =
                            fetchNewsDetails(newsPostDetailsList[position]?.POST_CONTENT)
                        withContext(Dispatchers.Main) {
                            binding.header.text = newsDetails.title
                            binding.description.text = newsDetails.subtitle
                            Glide.with(context).load(newsDetails.imageUrl)
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
                                    newsPostDetailsList[position]?.POST_CONTENT,
                                    newsPostDetailsList[position]?.POST_ID
                                )
            }
            if (newsPostDetailsList[position]?.BOOKMARK_FLAG == "B") {
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
            if (newsPostDetailsList[position]?.POST_COMMENT_COUNT == null) {
                binding.commentCount.text = "0"
            } else {
                binding.commentCount.text = newsPostDetailsList[position]?.POST_COMMENT_COUNT
            }
            if (newsPostDetailsList[position]?.POST_ACTION_TYPE?.lowercase(Locale.getDefault())
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
            } else if (newsPostDetailsList[position]?.POST_ACTION_TYPE?.lowercase(Locale.getDefault())
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

            val postId = newsPostDetailsList[position]?.POST_ID
            if (newsPostDetailsList[position]?.USERNAME?.isNotEmpty() == true) {
                binding.statusText.visible()
                binding.statusText.text = newsPostDetailsList[position]?.USERNAME?.get(0).toString()

                binding.statusChangeLayoutParentPost.backgroundTintList = ColorStateList.valueOf(
                    ColorChange(context).colorChange(
                        newsPostDetailsList[position]?.USERNAME?.lowercase(
                            Locale.getDefault()
                        )?.get(0).toString()
                    )
                )

                if (newsPostDetailsList[position]?.DP_URL != "null" || newsPostDetailsList[position]?.DP_URL != "") {
                    Glide.with(context).load(newsPostDetailsList[position]?.DP_URL)
                        .transform(
                            CircleCrop(),
                            RoundedCorners(5)
                        )
                        .into(binding.statusImage)
                }
            }
            if (newsPostDetailsList.size <= 0) {


            }
            binding.webPageImageLayout.setOnClickListener {
                if (newsPostDetailsList[position]?.POST_CONTENT != null) {
                    if (newsPostDetailsList[position]?.POST_CONTENT?.contains("/") == true) {
                        val builder = CustomTabsIntent.Builder()
                        val customTabsIntent = builder.build()
                        customTabsIntent.launchUrl(
                            context,
                            Uri.parse(newsPostDetailsList[position]?.POST_CONTENT)
                        )
                    }
                }
            }

            binding.likeCount.setOnClickListener {
                if (postId != null) {
                    listener.onPostClick(holder.adapterPosition, postId, "likeCount")
                }
            }
            binding.hCount.setOnClickListener {

                listener.onPostClick(holder.adapterPosition, postId!!, "hCount")
            }

            binding.imgLikePost.setOnClickListener {
                if (newsPostDetailsList[position]?.POST_ACTION_TYPE?.lowercase(Locale.getDefault()).equals("H", ignoreCase = true)) {
                    userActionCommon("H0", position)
                    binding.likeCount.text = newsPostDetailsList[position]?.LCOUNT?.toInt()?.plus(1).toString()
                    binding.hCount.text = (newsPostDetailsList[position]?.HCOUNT.toString())
                    newsPostDetailsList[position]?.POST_ACTION_TYPE = "L"
                    binding.imgDislikePost.setImageDrawable(AppCompatResources.getDrawable(context, R.drawable.ic_skull_grey_new))
                    binding.imgLikePost.setImageDrawable(AppCompatResources.getDrawable(context, R.drawable.heart_fill))
                    userActionCommon("L1", position)
                } else if (newsPostDetailsList[position]?.POST_ACTION_TYPE?.lowercase(Locale.getDefault()).equals("L", ignoreCase = true)) {
                    userActionCommon("L0", position)
                    newsPostDetailsList[position]?.POST_ACTION_TYPE = ""
                    binding.likeCount.text = (newsPostDetailsList[position]?.LCOUNT?.toString())
                    binding.imgLikePost.setImageDrawable(AppCompatResources.getDrawable(context, R.drawable.ic_love_grey_new))
                } else {
                    userActionCommon("L1", position)
                    newsPostDetailsList[position]?.POST_ACTION_TYPE = "L"
                    binding.likeCount.text = newsPostDetailsList[position]?.LCOUNT?.toInt()?.plus(1).toString()
                    binding.imgLikePost.setImageDrawable(AppCompatResources.getDrawable(context, R.drawable.heart_fill))
                }
            }
            binding.imgDislikePost.setOnClickListener {
                if (newsPostDetailsList[position]?.POST_ACTION_TYPE?.lowercase(Locale.getDefault()).equals("L", ignoreCase = true)) {
                    userActionCommon("L0", position)
                    binding.likeCount.text = (newsPostDetailsList[position]?.LCOUNT.toString())
                    binding.hCount.text = newsPostDetailsList[position]?.HCOUNT?.toInt()?.plus(1).toString()
                    newsPostDetailsList[position]?.POST_ACTION_TYPE = "H"
                    binding.imgLikePost.setImageDrawable(AppCompatResources.getDrawable(context, R.drawable.ic_love_grey_new))
                    binding.imgDislikePost.setImageDrawable(AppCompatResources.getDrawable(context, R.drawable.skull_fill))
                    userActionCommon("H1", position)
                } else if (newsPostDetailsList[position]?.POST_ACTION_TYPE?.lowercase(Locale.getDefault()).equals("H", ignoreCase = true)) {
                    userActionCommon("H0", position)
                    newsPostDetailsList[position]?.POST_ACTION_TYPE = ""
                    binding.hCount.text = (newsPostDetailsList[position]?.HCOUNT?.toString())
                    binding.imgDislikePost.setImageDrawable(AppCompatResources.getDrawable(context, R.drawable.ic_skull_grey_new))
                } else {
                    userActionCommon("H1", position)
                    newsPostDetailsList[position]?.POST_ACTION_TYPE = "H"
                    binding.hCount.text = newsPostDetailsList[position]?.HCOUNT?.toInt()?.plus(1).toString()
                    binding.imgDislikePost.setImageDrawable(AppCompatResources.getDrawable(context, R.drawable.skull_fill))
                }
            }
            binding.statusChangeLayoutParentPost.setOnClickListener {
                listener.onPostClick(
                    holder.adapterPosition,
                    postId!!,
                    "statusChangeLayoutParentPost"
                )
            }
            binding.imgcomment.setOnClickListener {
                listener.onPostClick(holder.adapterPosition, postId!!, "imgcomment")
            }
            binding.bookmark.setOnClickListener {
                listener.onPostClick(holder.adapterPosition, postId!!, "bookmark")
                notifyItemChanged(position)
            }
            binding.sharePost?.setOnClickListener {
                listener.onPostClick(holder.adapterPosition, postId!!, "sharePost")
            }
            binding.showPostDetail.setOnClickListener {
                listener.onPostClick(holder.adapterPosition, postId!!, "showPostDetail")
            }
            binding.removeUser?.setOnClickListener {
                listener.onPostClick(holder.adapterPosition, postId!!, "removeUser")
            }
        }
    }


    fun userActionCommon(action: String, position: Int) {
        listener.onPostClick(position, action, "UserActionCommon")
    }

    fun updateList(postDetailsList: MutableList<GetInstreamNwResponseItem?>) {
        newsPostDetailsList = postDetailsList
        notifyDataSetChanged()
    }

    class ViewHolder(val binding: CustomPostBinding) : RecyclerView.ViewHolder(binding.root)

    interface OnItemClickListener<T> {
        fun onPostClick(position: Int, data: T, type: Any?)
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


    private val shimmer = Shimmer.AlphaHighlightBuilder()// The attributes for a ShimmerDrawable is set by this builder
        .setDuration(1800) // how lAppCompatResourcesong the shimmering animation takes to do one full sweep
        .setBaseAlpha(0.1f) //the alpha of the underlying children
        .setHighlightAlpha(0.4f) // the shimmer alpha amount
        .setDirection(Shimmer.Direction.LEFT_TO_RIGHT)
        .setAutoStart(true)
        .build()

    // This is the placeholder for the imageView
    val shimmerDrawable = ShimmerDrawable().apply {
        setShimmer(shimmer)
    }
}
