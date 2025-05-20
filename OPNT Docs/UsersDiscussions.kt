package com.opinito.social.Fragment

import android.app.Activity
import android.app.Dialog
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.util.Log
import android.view.LayoutInflater
import android.view.Menu
import android.view.MenuInflater
import android.view.MenuItem
import android.view.View
import android.view.ViewGroup
import android.widget.AbsListView
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.content.res.AppCompatResources
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout
import com.facebook.FacebookSdk.getApplicationContext
import com.opinito.social.Activity.Comments
import com.opinito.social.Activity.CommonInterests
import com.opinito.social.Activity.SearchResultsActivity
import com.opinito.social.Activity.Terminology
import com.opinito.social.Adapter.UserDiscussionAdapter
import com.opinito.social.Constants.Constants
import com.opinito.social.Constants.Constants.PROFILEIMAGE
import com.opinito.social.Constants.Constants.TOPICID
import com.opinito.social.Constants.Constants.USERNAME
import com.opinito.social.Constants.Preference
import com.opinito.social.Model.ListLatestKeyword
import com.opinito.social.R
import com.opinito.social.Utils.BottomSheetDialog
import com.opinito.social.Utils.DynamicLinksUtil
import com.opinito.social.Utils.LatestKeyCall
import com.opinito.social.Utils.customToolBar
import com.opinito.social.Utils.gone
import com.opinito.social.Utils.invisible
import com.opinito.social.Utils.scrollTo
import com.opinito.social.Utils.toast
import com.opinito.social.Utils.visible
import com.opinito.social.code_revamp.adapter.DiscussionHoriAdapter
import com.opinito.social.code_revamp.models.delete_post.DeletePostRequest
import com.opinito.social.code_revamp.models.get_discussions_nw.GetDiscussionsNwRequest
import com.opinito.social.code_revamp.models.get_discussions_nw.GetDiscussionsNwResponseItem
import com.opinito.social.code_revamp.models.get_post_counts.GetPostCountsRequest
import com.opinito.social.code_revamp.models.get_user_topics.GetUserTopicRequest
import com.opinito.social.code_revamp.models.get_user_topics.GetUserTopicResponseItem
import com.opinito.social.code_revamp.models.post_bookmark.PostBookmarkRequest
import com.opinito.social.code_revamp.models.remove_bookmark.RemoveBookmarkRequest
import com.opinito.social.code_revamp.models.user_action_common.UserActionCommonRequest
import com.opinito.social.code_revamp.network_layer.NetworkResult
import com.opinito.social.code_revamp.view_models.DiscussionsViewModel
import com.opinito.social.databinding.FragmentUsersDiscussionsBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.async
import kotlinx.coroutines.launch
import org.jsoup.Jsoup
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Created by 502687702 on 7/6/2017.
 */
/**
 * Last Modified by Ashish on 13/03/2020
 */
@AndroidEntryPoint
open class UsersDiscussions : Fragment(), SwipeRefreshLayout.OnRefreshListener,
    ReportDialogFragment.DialogListener, BlockUserFragment.BlockDialogListener,
    DiscussionHoriAdapter.OnItemClickListener, UserDiscussionAdapter.OnItemClickListener {
    private var currentItm = 0
    private var scroledItem = 0
    private var totalItm = 0
    private var isScrolling: Boolean = false
    private var scrollLimit: Boolean = false
    private var binding: FragmentUsersDiscussionsBinding? = null
    private var linearLayoutManager: LinearLayoutManager? = null
    private var mAdapter: UserDiscussionAdapter? = null
    private var startrange = 0
    private var endrange = 20
    private var topicid: Int? = null
    private var mInflater: LayoutInflater? = null
    private var tag = 0
    private var handler: Handler? = null
    private val TOPICNAME = "topicname"
    private var keywordscall: LatestKeyCall? = null
    var date: String? = null
    private var storedDate: String? = null
    private var arrlistLatestKeywords: ArrayList<ListLatestKeyword>? = null
    var tabProgress = true
    var topicPopup: Dialog? = null
    var popupCout = 0
    private var currentPosition: Int? = null
    private var postIdRemoveUser = ""
    private val discussionViewModel by viewModels<DiscussionsViewModel>()
    private var topicHoriAdapter: DiscussionHoriAdapter? = null
    private var discussionItemList: MutableList<GetDiscussionsNwResponseItem?> = mutableListOf()


    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?
    ): View? {
        binding = FragmentUsersDiscussionsBinding.inflate(inflater, container, false)
        val view: View = binding!!.root
        setHasOptionsMenu(true)
        customToolBar(
            requireContext(),
            false,
            getString(R.string.discussion1),
            (activity as AppCompatActivity?)!!.supportActionBar
        )
//        init()
        if (checkLatestKeywordApiCall() || checkCountryCode() || checkUser()) {
//            latestKeyword
        }
        return view
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        topicObserver()
        postCountObserver()
        discussionPostObserver()
        discussionViewModel.getUserTopic(GetUserTopicRequest(Preference(activity).getPref(Constants.USERID)))
        topicHoriAdapter = DiscussionHoriAdapter(requireActivity(), this)
        binding?.topicHoriScroll?.adapter = topicHoriAdapter
        linearLayoutManager =
            LinearLayoutManager(requireActivity(), LinearLayoutManager.VERTICAL, false)
        mAdapter = UserDiscussionAdapter(requireActivity(), this)
        binding?.postRecycler?.layoutManager = linearLayoutManager
        binding?.postRecycler?.adapter = mAdapter

        binding?.swipeRefresh?.setOnRefreshListener(this)
        binding?.likeMindedLayout?.setOnClickListener {
            Preference(activity).savePref(Constants.instream, Constants.instreamNW)
            setColor(
                R.drawable.button_round,
                R.color.white,
                R.drawable.grey_outline_bg,
                R.color.colourGrey
            )
            clearDiscussionItemList()
            showDiscussionsPost()
        }
        binding?.antiMindedLayout?.setOnClickListener {
            Preference(activity).savePref(Constants.instream, Constants.instreamAnti)
            setColor(
                R.drawable.grey_outline_bg,
                R.color.colourGrey,
                R.drawable.button_round,
                R.color.white
            )
            clearDiscussionItemList()
            showDiscussionsPost()
            startrange = 0

        }
        binding?.hintIv?.setOnClickListener {
            val intent = Intent(activity, Terminology::class.java)
            startActivity(intent)
        }

        binding?.postRecycler?.addOnScrollListener(object : RecyclerView.OnScrollListener() {
            override fun onScrollStateChanged(recyclerView: RecyclerView, newState: Int) {
                super.onScrollStateChanged(recyclerView, newState)
                if (newState == AbsListView.OnScrollListener.SCROLL_STATE_FLING) {
                    isScrolling = true
                }
            }

            override fun onScrolled(recyclerView: RecyclerView, dx: Int, dy: Int) {
                super.onScrolled(recyclerView, dx, dy)
                if (dy > 0) {
                    currentItm = linearLayoutManager!!.childCount
                    totalItm = linearLayoutManager!!.itemCount
                    scroledItem = linearLayoutManager!!.findFirstVisibleItemPosition()
                    Log.e(
                        "Count",
                        "current->$currentItm : total->$totalItm : scrolled->$scroledItem"
                    )
                    if (isScrolling && currentItm + scroledItem == totalItm) {
                        isScrolling = false
                        startrange = totalItm
                        if ((Preference(activity).getPref(Constants.instream) == Constants.instreamNW)) {
                            discussionViewModel.getDiscussionNW(
                                GetDiscussionsNwRequest(
                                    startrange,
                                    endrange,
                                    topicid,
                                    Preference(activity).getPref(Constants.USERID)
                                )
                            )
                        } else {
                            discussionViewModel.getDiscussionAnti(
                                GetDiscussionsNwRequest(
                                    startrange,
                                    endrange,
                                    topicid,
                                    Preference(activity).getPref(Constants.USERID)
                                )
                            )
                        }
                    }
                }
            }
        })
    }

    override fun onCreateOptionsMenu(menu: Menu, inflater: MenuInflater) {
        inflater.inflate(R.menu.menu_search, menu)
        super.onCreateOptionsMenu(menu, inflater)
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        if (item.itemId == R.id.search) {
            if (topicList.size > 0) {
                val intent = Intent(activity, SearchResultsActivity::class.java)
                for (i in topicList.indices) {
                    if (topicList[i].TOPICID.toString() == Preference(
                            activity
                        ).getIntPref(TOPICID).toString()
                    ) {
                        intent.putExtra(TOPICNAME, topicList[i].TOPIC)
                    }
                }
                startActivity(intent)
            } else {
                Toast.makeText(activity, R.string.bad_search_text, Toast.LENGTH_SHORT).show()
            }
        }
        return super.onOptionsItemSelected(item)
    }

    private fun discussionPostObserver() {
        discussionViewModel.getDiscussionNwLiveData.observe(viewLifecycleOwner) {
            when (it) {
                is NetworkResult.Success -> {
                    binding?.progressBar?.invisible()
                    if (it.data?.isNotEmpty() == true) {
                        binding?.nullAdapterTv?.gone()
                        discussionItemList.addAll(it.data as Collection<GetDiscussionsNwResponseItem?>)
                        mAdapter?.updateList(discussionItemList)
                    } else {
                        if (linearLayoutManager?.childCount!! <= 0) {
                            scrollLimit = false
                            binding?.nullAdapterTv?.visible()
                        } else {
                            binding?.nullAdapterTv?.gone()

                            if (topicPopup == null) {
                                topicPopup = Dialog(requireActivity())
                                topicPopup?.setContentView(R.layout.dailoglayout)
                                val keywordText: TextView? =
                                    topicPopup?.findViewById(R.id.text_dialog)
                                keywordText?.text =
                                    "Start a discussion with your like-minded network -click here"
                                val cancel: TextView? = topicPopup?.findViewById(R.id.skip_text)
                                cancel?.text = "Start Posting"
                                cancel?.setOnClickListener {
                                    topicPopup?.dismiss()
                                    findNavController().navigate(R.id.action_usersDiscussions_to_sendPostFragment)
                                }
                                topicPopup?.window?.setLayout(
                                    ViewGroup.LayoutParams.MATCH_PARENT,
                                    ViewGroup.LayoutParams.WRAP_CONTENT
                                )

                            } else if (topicPopup?.isShowing == false) {
                                topicPopup?.show()
                            }
                        }
                    }

                }

                is NetworkResult.Error -> {
                    requireContext().toast(it.message.toString())
                }

                is NetworkResult.Loading -> {
                    binding?.progressBar?.visible()
                }

                else -> {

                }

            }
        }
    }


    private fun clearDiscussionItemList() {
        discussionItemList.clear()
        mAdapter?.updateList(discussionItemList)
        startrange = 0
    }

    private fun showDiscussionsPost() {
        if ((Preference(activity).getPref(Constants.instream) == Constants.instreamNW)) {
            discussionViewModel.getDiscussionNW(
                GetDiscussionsNwRequest(
                    startrange, endrange, topicid, Preference(activity).getPref(Constants.USERID)
                )
            )
        } else {
            discussionViewModel.getDiscussionAnti(
                GetDiscussionsNwRequest(
                    startrange, endrange, topicid, Preference(activity).getPref(Constants.USERID)
                )
            )
        }

    }


    private fun topicObserver() {
        discussionViewModel.userTopicResponseLiveData.observe(viewLifecycleOwner) {
            when (it) {
                is NetworkResult.Success -> {
                    topicList = it.data as ArrayList<GetUserTopicResponseItem>
                    topicHoriAdapter?.updateList(topicList)
                    val selectedTopic: Int =
                        Preference(requireContext()).getIntPref(Constants.TOPICCARTID)
                    val index = topicList.indexOfFirst {
                        selectedTopic == it.TOPICID
                    }
                    binding?.topicHoriScroll?.scrollTo(index)
                }

                is NetworkResult.Error -> {
                    requireContext().toast(it.message.toString())
                }

                is NetworkResult.Loading -> { }
            }
        }
    }

    private fun postCountObserver() {
        discussionViewModel.getPostCountLivedata.observe(viewLifecycleOwner) {
            when (it) {
                is NetworkResult.Success -> {
                    binding?.filterLayout?.visible()
                    binding?.antiMindedCountTv?.text = String.format(
                        getString(R.string.anti_minded),
                        it.data?.data?.ANTI_POST_COUNT.toString()
                    )
                    binding?.likeMindedCountTv?.text = String.format(
                        getString(R.string.network),
                        it.data?.data?.NW_POST_COUNT.toString()
                    )
                }

                is NetworkResult.Error -> {
                    binding?.filterLayout?.gone()
//                    requireContext().toast(it.message.toString())
                }

                is NetworkResult.Loading -> {}
            }
        }
    }

    override fun onTopicClick(topicId: Int?, position: Int) {
        clearDiscussionItemList()
        topicid = topicId
        val layoutManager = binding?.topicHoriScroll?.layoutManager as LinearLayoutManager
        layoutManager.scrollToPositionWithOffset(position, 20)
        if (topicId != null) {
            Preference(activity).saveIntPref(TOPICID, topicId)
        }
        discussionViewModel.getPostCount(
            GetPostCountsRequest(
                topicId.toString(), Preference(activity).getPref(Constants.USERID)
            )
        )
        showDiscussionsPost()
    }

    private fun setColor(
        likeMindedLayoutBack: Int,
        likeMindedTextColor: Int,
        antiMindedLayoutBack: Int,
        antiMindedTextColor: Int
    ) {
        //like minded
        binding?.likeMindedLayout?.background = resources.getDrawable(likeMindedLayoutBack)
        binding?.likeMindedCountTv?.setTextColor(resources.getColor(likeMindedTextColor))

        //anti minded
        binding?.antiMindedLayout?.background = resources.getDrawable(antiMindedLayoutBack)
        binding?.antiMindedCountTv?.setTextColor(resources.getColor(antiMindedTextColor))
    }


    private fun keyWordPopup() {
        val topicPopup = Dialog(requireContext())
        topicPopup.setContentView(R.layout.image_dialog)
        val cancel = topicPopup.findViewById<TextView>(R.id.okay_text)
        cancel.setOnClickListener { topicPopup.dismiss() }
        topicPopup.window!!.setLayout(
            ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT
        )
        topicPopup.show()
    }

    fun showRemoveFrag(postId: String) {
        postIdRemoveUser = postId
        val fm = fragmentManager
        val reportDialogFragment = ReportDialogFragment(this)
        ReportDialogFragment.TYPE = getString(R.string.post_type)
        ReportDialogFragment.POSTID = postId
        reportDialogFragment.setTargetFragment(this@UsersDiscussions, 300)
        reportDialogFragment.show((fm)!!, "ReportDialogFragment")
    }

    override fun onLikeHateClick(postId: String?, actionType: String?) {
        doLikePost(postId, actionType)
    }

    override fun onPostProfileClick(pos: Int, postId: String?) {
        val intent = Intent(context, CommonInterests::class.java)
        intent.putExtra(TOPICID, discussionItemList[pos]?.TOPICID)
        intent.putExtra(USERNAME, discussionItemList[pos]?.USERNAME)
        intent.putExtra(PROFILEIMAGE, discussionItemList[pos]?.DP_URL)
        requireActivity().startActivity(intent)
    }

    override fun onPostCommentClick(pos: Int, postId: String?) {
        currentPosition = pos
        val commentIntent = Intent(requireActivity(), Comments::class.java)
        commentIntent.putExtra("postcontent", pos)
        commentIntent.putExtra("title", "Comment")
        commentIntent.putExtra("postid", discussionItemList[pos]?.POST_ID)
        resultLauncher.launch(commentIntent)

    }

    private var resultLauncher =
        registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
            if (result.resultCode == Activity.RESULT_OK) {
                val data: Intent? = result.data
                val commentCount = data?.getStringExtra("commentCount")
                val likeCount = data?.getStringExtra("likeCount")
                val hateCount = data?.getStringExtra("hateCount")
                val myLikeOrHate = data?.getStringExtra("myLikeOrHate")
                Log.d("Back from comment = ", "$likeCount,$hateCount,$myLikeOrHate")

                val viewHolder = currentPosition?.let {
                    binding?.postRecycler?.findViewHolderForAdapterPosition(
                        it
                    )
                } as UserDiscussionAdapter.ViewHolder
                if (likeCount != null) {
                    viewHolder.itemView.findViewById<TextView>(R.id.like_count)?.text = likeCount
                }
                if (hateCount != null) {
                    viewHolder.itemView.findViewById<TextView>(R.id.h_count)?.text = hateCount
                }
                if (commentCount != null) {
                    viewHolder.itemView.findViewById<TextView>(R.id.comment_count)?.text =
                        commentCount
                }
                discussionItemList[currentPosition!!]?.POST_ACTION_TYPE =
                    myLikeOrHate.toString()
                if (myLikeOrHate == "L") {
                    viewHolder.itemView.findViewById<ImageView>(R.id.imgLikePost)?.setImageDrawable(
                        AppCompatResources.getDrawable(requireContext(), R.drawable.heart_fill)
                    )
                    viewHolder.itemView.findViewById<ImageView>(R.id.imgDislikePost)
                        ?.setImageDrawable(
                            AppCompatResources.getDrawable(
                                requireContext(),
                                R.drawable.ic_skull_grey_new
                            )
                        )
                } else if (myLikeOrHate == "H") {
                    viewHolder.itemView.findViewById<ImageView>(R.id.imgLikePost)?.setImageDrawable(
                        AppCompatResources.getDrawable(
                            requireContext(),
                            R.drawable.ic_love_grey_new
                        )
                    )
                    viewHolder.itemView.findViewById<ImageView>(R.id.imgDislikePost)
                        ?.setImageDrawable(
                            AppCompatResources.getDrawable(
                                requireContext(),
                                R.drawable.skull_fill
                            )
                        )
                } else {
                    viewHolder.itemView.findViewById<ImageView>(R.id.imgDislikePost)
                        ?.setImageDrawable(
                            AppCompatResources.getDrawable(
                                requireContext(),
                                R.drawable.ic_skull_grey_new
                            )
                        )
                    viewHolder.itemView.findViewById<ImageView>(R.id.imgLikePost)?.setImageDrawable(
                        AppCompatResources.getDrawable(
                            requireContext(),
                            R.drawable.ic_love_grey_new
                        )
                    )
                }


                /* discussionItemList[currentPosition!!]?.POST_ACTION_TYPE =
                     myLikeOrHate.toString()
                 if (likeCount != null) {
                     discussionItemList[currentPosition!!]?.LCOUNT = likeCount.toString()
                 }
                 if (hateCount != null) {
                     discussionItemList[currentPosition!!]?.HCOUNT = hateCount.toString()
                 }
                 if (discussionItemList[currentPosition!!]?.POST_COMMENT_COUNT == null) {
                     discussionItemList[currentPosition!!]?.POST_COMMENT_COUNT =
                         commentCount.toString()
                 } else {
                     discussionItemList[currentPosition!!]?.POST_COMMENT_COUNT =
                         (discussionItemList[currentPosition!!]?.POST_COMMENT_COUNT?.toInt()
                             ?.plus(commentCount ?: 0)).toString()
                 }
                 if (currentPosition != null) {
                     mAdapter?.notifyItemChanged(currentPosition!!)
                 }*/
                Log.d("Activity_Result", commentCount.toString())

            }
        }

    override fun onPostBookmarkClick(pos: Int, postId: String?) {
        if (discussionItemList[pos]?.BOOKMARK_FLAG == "B") {
            if (postId != null) {
                discussionViewModel.removeBookmark(
                    RemoveBookmarkRequest(
                        postId.toInt(), Preference(activity).getPref(Constants.USERID)
                    )
                )
            }
            discussionItemList[pos]?.BOOKMARK_FLAG = ""
        } else {
            if (postId != null) {
                discussionViewModel.postBookmark(
                    PostBookmarkRequest(
                        postId.toInt(), Preference(activity).getPref(Constants.USERID)
                    )
                )
            }
            discussionItemList[pos]?.BOOKMARK_FLAG = "B"
        }
    }



    override fun onPostShareClick(pos: Int, postId: String?, url: String?) {
        if (discussionItemList[pos]?.POST_ACTION_TYPE?.lowercase().equals(
                "l",
                ignoreCase = true
            ) || discussionItemList[pos]?.POST_ACTION_TYPE?.lowercase()
                .equals("h", ignoreCase = true)
        ) {

            Log.d("urlIS", url.toString())
            GlobalScope.launch(Dispatchers.IO) {
                try {
                    val title = if (url?.contains("http", ignoreCase = true) == true) {
                        fetchTitle(url)
                    } else {
                        url
                    }

                    val previewUrl = if (url?.contains("http", ignoreCase = true) == true) {
                        fetchPreviewUrl(url)
                    } else {
                        url
                    }

                    Log.d("Title:", "$previewUrl")

                    DynamicLinksUtil.createDynamicUri(
                        Preference(requireContext()).getIntPref(TOPICID).toString(),
                        postId,
                        requireActivity(),
                        title.toString(),
                        previewUrl,
                        ""
                    )
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        } else {
            keyWordPopup()
        }
    }

//    override fun onPostShareClick(pos: Int, postId: String?, url: String?) {
//        if (discussionItemList[pos]?.POST_ACTION_TYPE?.lowercase().equals(
//                "l",
//                ignoreCase = true
//            ) || discussionItemList[pos]?.POST_ACTION_TYPE?.lowercase()
//                .equals("h", ignoreCase = true)
//        ) {
//
//            Log.d("urlIS", url.toString())
//            GlobalScope.launch(Dispatchers.IO) {
//                try {
//                    val title = url?.let { fetchTitle(it) }
//                    val previewUrl = url?.let { fetchPreviewUrl(it) }
//                    println("Title: $previewUrl")
//
//                    DynamicLinksUtil.createDynamicUri(
//                        Preference(requireContext()).getIntPref(TOPICID).toString(),
//                        postId,
//                        requireActivity(), title.toString(), previewUrl,
////                discussionItemList[pos]?.postCellModel?.postTitle,
////                    discussionItemList[pos]?.postCellModel?.urlForPreview,
//                        ""
//                    )
//                }catch (e:Exception){e.printStackTrace()}
//            }
//
//        } else {
//            keyWordPopup()
//        }
//    }

    override fun onPostDetailsClick(pos: Int, postId: String?) {
        if (discussionItemList[pos]?.POST_ACTION_TYPE?.lowercase(Locale.getDefault()).equals(
                "l",
                ignoreCase = true
            ) || discussionItemList[pos]?.POST_ACTION_TYPE?.lowercase(Locale.getDefault())
                .equals("h", ignoreCase = true)
        ) {
//            val commentIntent = Intent(requireActivity(), Comments::class.java)
//            commentIntent.putExtra("postcontent", pos)
//            commentIntent.putExtra("title", "Discussions")
//            commentIntent.putExtra("postid", discussionItemList[pos]?.POST_ID)
//            requireContext().startActivity(commentIntent)

            currentPosition = pos
            val commentIntent = Intent(requireActivity(), Comments::class.java)
            commentIntent.putExtra("postcontent", pos)
            commentIntent.putExtra("title", "Comment")
            commentIntent.putExtra("postid", discussionItemList[pos]?.POST_ID)
            resultLauncher.launch(commentIntent)
        } else {
            keyWordPopup()
        }
    }

    fun doLikePost(postId: String?, actionType: String?) {
        discussionViewModel.userActionCommon(
            UserActionCommonRequest(
                getString(R.string.post_type),
                actionType,
                postId,
                Preference(activity).getPref(Constants.USERID)
            )
        )
    }

    override fun onRemoveUserClick(pos: Int, postId: String?) {
        showRemoveFrag(postId.toString())
    }

    override fun onLikeCountClick(pos: Int, postId: String) {
        showUsersHateLike(pos, "L")
    }

    override fun onHateCountClick(pos: Int, postId: String?) {
        showUsersHateLike(pos, "H")
    }

    override fun editDeleteClick(postId: String?) {
        val topicPopup = Dialog(requireContext())
        topicPopup.setContentView(R.layout.confirm_dialog)
        val yes = topicPopup.findViewById<Button>(R.id.btnyes)
        val no = topicPopup.findViewById<Button>(R.id.btncancel)
        val text = topicPopup.findViewById<TextView>(R.id.top_tv)
        text.text = requireContext().resources.getString(R.string.deletepost)
        yes.setOnClickListener {
            discussionViewModel.deletePost(
                DeletePostRequest(
                    postId?.toInt(), Preference(activity).getPref(Constants.USERID)
                )
            )
            topicPopup.dismiss()
        }
        no.setOnClickListener { topicPopup.dismiss() }
        topicPopup.window!!.setLayout(
            ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT
        )
        topicPopup.setCancelable(false)
        topicPopup.setCanceledOnTouchOutside(false)
        topicPopup.show()
    }

    override fun onRefresh() {
        clearDiscussionItemList()
        discussionViewModel.getUserTopic(GetUserTopicRequest(Preference(activity).getPref(Constants.USERID)))
        binding?.swipeRefresh?.isRefreshing = false
    }

    override fun onNavBackCliked() {
        TODO("Not yet implemented")
    }

    override fun onCompleteReport(type: String?) {
//        displayPost(Preference(activity).getIntPref(Constants.TOPICID), false)
    }

    fun showUsersHateLike(position: Int, type: String?) {
        val loveHateUsersListFragment = LoveHateUsersListFragment.newInstance(
            discussionItemList[position]!!.POST_ID.toString(), type
        )
        val fm = fragmentManager as FragmentManager
        loveHateUsersListFragment.show(fm, "LoveHateUserListFragment")
    }

    override fun onBlockClicked() {
        val fm = fragmentManager as FragmentManager
        val reportDialogFragment = BlockUserFragment(this)
        BlockUserFragment.CONTENTID = postIdRemoveUser
        BlockUserFragment.TYPE = getString(R.string.post_type)
        reportDialogFragment.setTargetFragment(this@UsersDiscussions, 300)
        reportDialogFragment.show(fm, "BlockUserFragment")
    }

    override fun onCompleteBlock(type: String?) {
//        displayPost(Preference(activity).getIntPref(Constants.TOPICID), false)
    }

    override fun onKickOut() {
        onRefresh()
    }

    private fun checkLatestKeywordApiCall(): Boolean {
        date = SimpleDateFormat("dd-MM-yyyy", Locale.getDefault()).format(Date())
        Log.d("taggy", date.toString())
        storedDate = Preference(getApplicationContext()).getPref(Constants.date)
        return if ((storedDate == date)) {
            false
        } else true
    }

    fun checkCountryCode(): Boolean {
        val prevCode = Preference(getApplicationContext()).getPref(Constants.prevCode)
        val currCode = Preference(getApplicationContext()).getPref(Constants.COUNTRYCODE)
        if ((prevCode == currCode)) {
            return false
        }
        Preference(getApplicationContext()).savePref(Constants.prevCode, currCode)
        return true
    }

    private fun checkUser(): Boolean {
        val currentUser = Preference(activity).getPref(Constants.USERNAME)
        val prevUser = Preference(getApplicationContext()).getPref(Constants.PREV_USER)
        Log.d("taggy", "currentUser->$currentUser  prevUser-->$prevUser")
        if ((currentUser == prevUser)) {
            return false
        }
        Preference(getApplicationContext()).savePref(Constants.PREV_USER, currentUser)
        return true
    }

    private val latestKeyword: Unit
        private get() {
            keywordscall = LatestKeyCall()
            arrlistLatestKeywords = ArrayList()
            keywordscall!!.getLatestKeyWord(getApplicationContext()).observe(
                viewLifecycleOwner
            ) { listLatestKeywords ->
                //                Log.d("taggy", listLatestKeywords.get(0).getKEYWORDS());
                try {
                    arrlistLatestKeywords?.addAll(listLatestKeywords)
                    val mDate = listLatestKeywords[0].date
                    Preference(getApplicationContext()).savePref(Constants.date, mDate)
                } catch (e: Exception) {
                    e.fillInStackTrace()
                }
                showDialog(arrlistLatestKeywords!!)
            }
        }


    private fun showDialog(list: ArrayList<ListLatestKeyword>) {
        val bottomSheet = BottomSheetDialog(list)
        if (list.size != 0) {
            bottomSheet.show(
                requireActivity().supportFragmentManager, "ModalBottomSheet"
            )
        }
    }

    private fun fetchTitle(url: String): String {
        return try {
            val doc = Jsoup.connect(url).get()
            doc.title()
        } catch (e: IOException) {
            e.printStackTrace()
            ""
        }
    }

    private suspend fun fetchPreviewUrl(url: String): String {
        return try {
            val doc = Jsoup.connect(url).get()
            val previewUrl = doc.select("meta[property=og:url]").attr("content")
            previewUrl
        } catch (e: IOException) {
            e.printStackTrace()
            // Return default value or handle the error as needed
            ""
        } catch (e: Exception) {
            e.printStackTrace()
            // Return default value or handle the error as needed
            ""
        }
    }


    companion object {

        @JvmField
        var topicList = ArrayList<GetUserTopicResponseItem>()
    }

}