package com.opinito.social.Fragment

import android.app.Activity
import android.app.AlertDialog
import android.app.Dialog
import android.content.Context
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
import android.widget.EditText
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
import androidx.recyclerview.widget.StaggeredGridLayoutManager
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout.OnRefreshListener
import com.facebook.FacebookSdk.getApplicationContext
import com.google.gson.JsonObject
import com.opinito.social.Activity.Comments
import com.opinito.social.Activity.CommonInterests
import com.opinito.social.Activity.DashBoard
import com.opinito.social.Activity.SearchResultsActivity
import com.opinito.social.Activity.Terminology
import com.opinito.social.Adapter.PostAdapter
import com.opinito.social.Adapter.UserDiscussionAdapter
import com.opinito.social.BuildConfig
import com.opinito.social.Constants.Constants
import com.opinito.social.Constants.Constants.PROFILEIMAGE
import com.opinito.social.Constants.Constants.TOPICID
import com.opinito.social.Constants.Constants.USERNAME
import com.opinito.social.Constants.Preference
import com.opinito.social.Fragment.BlockUserFragment.BlockDialogListener
import com.opinito.social.Fragment.ReportDialogFragment.DialogListener
import com.opinito.social.Interface.RetrofitNetworkInterface
import com.opinito.social.Model.ListLatestKeyword
import com.opinito.social.Model.PostDetailsModel
import com.opinito.social.Model.WebLoadModel
import com.opinito.social.R
import com.opinito.social.RetrofitClient
import com.opinito.social.Utils.BottomSheetDialog
import com.opinito.social.Utils.DynamicLinksUtil
import com.opinito.social.Utils.LatestKeyCall
import com.opinito.social.Utils.customToolBar
import com.opinito.social.Utils.gone
import com.opinito.social.Utils.invisible
import com.opinito.social.Utils.scrollTo
import com.opinito.social.Utils.toast
import com.opinito.social.Utils.visible
import com.opinito.social.code_revamp.adapter.NewsHoriAdapter
import com.opinito.social.code_revamp.models.NewsDetails
import com.opinito.social.code_revamp.models.delete_post.DeletePostRequest
import com.opinito.social.code_revamp.models.get_instream_nw.GetInstreamNwRequest
import com.opinito.social.code_revamp.models.get_instream_nw.GetInstreamNwResponseItem
import com.opinito.social.code_revamp.models.get_post_counts.GetPostCountsRequest
import com.opinito.social.code_revamp.models.get_user_topics.GetUserTopicRequest
import com.opinito.social.code_revamp.models.get_user_topics.GetUserTopicResponseItem
import com.opinito.social.code_revamp.models.post_bookmark.PostBookmarkRequest
import com.opinito.social.code_revamp.models.remove_bookmark.RemoveBookmarkRequest
import com.opinito.social.code_revamp.models.user_action_common.UserActionCommonRequest
import com.opinito.social.code_revamp.network_layer.NetworkResult
import com.opinito.social.code_revamp.view_models.NewsViewModel
import com.opinito.social.databinding.FeedfragmentBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import okhttp3.ResponseBody
import org.json.JSONObject
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale


//import com.opinito.social.databinding.FeedfragmentBinding;
/**
 * Created by 502687702 on 7/6/2017.
 */
/**
 * Last Modified by Ashish on 13/03/2020
 */
@AndroidEntryPoint
class FeedFragment : Fragment(), OnRefreshListener, DialogListener, BlockDialogListener,
    PostAdapter.OnItemClickListener<Any>, NewsHoriAdapter.OnItemClickListener {

    private var currentPosition: Int = 0
    private var isScrolling: Boolean = false
    private var scrollLimit: Boolean = true
    private var loadMore: Boolean = false
    private lateinit var binding: FeedfragmentBinding
    private var startrange = 0
    private var endrange = 20
    private val count = 0
    private var topicid = 0
    private var mInflater: LayoutInflater? = null
    private var tag = 0
    private var handler: Handler? = null
    private val TOPICNAME = "topicname"
    private var keywordscall: LatestKeyCall? = null
    private var date: String? = null
    private var storedDate: String? = null
    private var arrlistLatestKeywords: ArrayList<ListLatestKeyword>? = null
    private var tabProgress = true
    private var currentItm = 0
    private var scroledItem = 0
    private var totalItm = 0
    private val mRecyclerView: RecyclerView? = null
    private var linearLayoutManager: LinearLayoutManager? = null
    private var nopostPopup: Dialog? = null
    private val context: Context? = null
    private var dialogCount = 0
    private var mAdapter: PostAdapter? = null
    private var topicAdapter: NewsHoriAdapter? = null
    private val newsViewModel by viewModels<NewsViewModel>()
    var topicPopup: Dialog? = null
    private var newsItemList: MutableList<GetInstreamNwResponseItem?> = mutableListOf()
    val newsDetailsList = mutableListOf<NewsDetails>()

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int, permissions: Array<out String>, grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?
    ): View? {
        customToolBar(
            requireContext(),
            false,
            getString(R.string.feeds),
            (activity as AppCompatActivity?)?.supportActionBar
        )
        Log.d("newsCallbacks", "onCreateView")
        binding = FeedfragmentBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        Log.d("newsCallbacks", "onViewCreated")
        userTopicObserver()
        postCountObserver()
        deletePostObserver()
        getNewsPostObserver()
        postBookmarkObserver()
        val scope = CoroutineScope(Dispatchers.IO)
        mAdapter = PostAdapter(requireActivity(), this)

//        val staggeredGridLayoutManager = StaggeredGridLayoutManager(3, LinearLayoutManager.VERTICAL)
        linearLayoutManager =
            LinearLayoutManager(requireActivity(), LinearLayoutManager.VERTICAL, false)
//        binding.postRecycler.layoutManager = staggeredGridLayoutManager
        binding.postRecycler.layoutManager = linearLayoutManager
        binding.postRecycler.adapter = mAdapter

        topicAdapter = NewsHoriAdapter(requireActivity(), this)
        binding.topicHoriScroll?.adapter = topicAdapter
        init()
//        if (checkLatestKeywordApiCall() || checkCountryCode() || checkUser()) try {
//            latestKeyword
//        } catch (e: Exception) {
//            e.fillInStackTrace()
//        }

//        Log.e("Count", " $currentItm : $totalItm : $scroledItem")


        binding.likeMindedLayout.setOnClickListener {
            Preference(activity).savePref(Constants.instream, Constants.instreamNW)
            setColor(
                R.drawable.button_round,
                R.color.white,
                R.drawable.grey_outline_bg,
                R.color.colourGrey
            )
            clearNewsItemList()
            displayPost()
        }
        binding.antiMindedLayout.setOnClickListener {
            Preference(activity).savePref(Constants.instream, Constants.instreamAnti)
            setColor(
                R.drawable.grey_outline_bg,
                R.color.colourGrey,
                R.drawable.button_round,
                R.color.white
            )
            clearNewsItemList()
            displayPost()
        }
        binding.hintIv.setOnClickListener {
            val intent = Intent(activity, Terminology::class.java)
            startActivity(intent)
        }

        binding.postRecycler.addOnScrollListener(object : RecyclerView.OnScrollListener() {
            override fun onScrollStateChanged(recyclerView: RecyclerView, newState: Int) {
                super.onScrollStateChanged(recyclerView, newState)
                if (newState == AbsListView.OnScrollListener.SCROLL_STATE_FLING) {
                    isScrolling = true
                }
            }

            override fun onScrolled(recyclerView: RecyclerView, dx: Int, dy: Int) {
                super.onScrolled(recyclerView, dx, dy)
                if (dy > 0) {
                    currentItm = linearLayoutManager?.childCount ?: 0
                    totalItm = linearLayoutManager?.itemCount ?: 0
                    scroledItem = linearLayoutManager?.findFirstVisibleItemPosition() ?: 0
//                    Log.e(
//                        "Count",
//                        "current->$currentItm : total->$totalItm : scrolled->$scroledItem"
//                    )
                    if (isScrolling && currentItm + scroledItem == totalItm) {
                        isScrolling = false
                        startrange = totalItm
                        if ((Preference(activity).getPref(Constants.instream) == Constants.instreamNW)) {
                            newsViewModel.getInstreamNW(
                                GetInstreamNwRequest(
                                    startrange,
                                    endrange,
                                    topicid,
                                    Preference(activity).getPref(Constants.USERID)
                                )
                            )
                        } else {
                            newsViewModel.getInstreamAnti(
                                GetInstreamNwRequest(
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


    private fun getNewsPost(topicID: Int) {
        newsViewModel.getInstreamNW(
            GetInstreamNwRequest(
                startrange, endrange, topicID, Preference(activity).getPref(Constants.USERID)
            )
        )
    }

    private fun getNewsPostAnti(topicID: Int) {
        newsViewModel.getInstreamAnti(
            GetInstreamNwRequest(
                startrange, endrange, topicID, Preference(activity).getPref(Constants.USERID)
            )
        )
    }

    private fun checkUser(): Boolean {
        val currentUser = Preference(activity).getPref(USERNAME)
        val prevUser = Preference(getApplicationContext()).getPref(Constants.PREV_USER)
        Log.d("taggy", "currentUser->$currentUser  prevUser-->$prevUser")
        if ((currentUser == prevUser)) {
            return false
        }
        Preference(getApplicationContext()).savePref(Constants.PREV_USER, currentUser)
        return true
    }

    override fun onDestroyView() {
        super.onDestroyView()
        Log.d("newsCallbacks", "onDestroyView")
    }

    private fun checkLatestKeywordApiCall(): Boolean {
        date = SimpleDateFormat("dd-MM-yyyy", Locale.getDefault()).format(Date())
        Log.d("taggy", date.toString())
        storedDate = Preference(getApplicationContext()).getPref(Constants.date)
        return storedDate != date
    }

    private fun init() {
        setHasOptionsMenu(true)
        mInflater = LayoutInflater.from(activity)
        binding.swipeRefresh.setOnRefreshListener(this)
        Log.e("Size", postDetailsModelArrayList.size.toString())
        binding.postRecycler.setItemViewCacheSize(200)

        if ((Preference(activity).getPref(Constants.instream) == "")) Preference(activity).savePref(
            Constants.instream, Constants.instreamNW
        )
    }

    override fun onRefresh() {
        clearNewsItemList()
        displayTopics()
        binding.swipeRefresh.isRefreshing = false
        Log.d("newsCallbacks", "onRefresh")
    }

    override fun onCreateOptionsMenu(menu: Menu, inflater: MenuInflater) {
        inflater.inflate(R.menu.menu_search, menu)
        super.onCreateOptionsMenu(menu, inflater)
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        if (item.itemId == R.id.search) {
            if (topicsModelArrayList.size > 0) {
                val intent = Intent(activity, SearchResultsActivity::class.java)
                for (i in topicsModelArrayList.indices) {
                    if (topicsModelArrayList[i].TOPICID == Preference(
                            activity
                        ).getIntPref(TOPICID)
                    ) {
                        intent.putExtra(TOPICNAME, topicsModelArrayList[i].TOPIC)
                    }
                }
                startActivity(intent)
            } else {
                Toast.makeText(activity, R.string.bad_search_text, Toast.LENGTH_SHORT).show()
            }
        }
        return super.onOptionsItemSelected(item)
    }


    private fun displayTopics() {
        newsViewModel.getUserTopic(
            GetUserTopicRequest(Preference(activity).getPref(Constants.USERID))
        )
        binding.progressBar.visible()
    }


    private fun userTopicObserver() {
        newsViewModel.userTopicResponseLiveData.observe(viewLifecycleOwner) {

            when (it) {
                is NetworkResult.Success -> {
                    binding.progressBar.invisible()
                    topicsModelArrayList = it.data as ArrayList<GetUserTopicResponseItem>
                    topicAdapter?.updateList(topicsModelArrayList)
                    val selectedTopic: Int =
                        Preference(requireContext()).getIntPref(Constants.TOPICCARTID)
                    val index = topicsModelArrayList.indexOfFirst {
                        selectedTopic == it.TOPICID
                    }
                    binding.topicHoriScroll?.scrollTo(index)
                }

                is NetworkResult.Error -> {
                    requireContext().toast(it.message.toString())
                }

                is NetworkResult.Loading -> {

                }

            }
        }
    }

    private fun postBookmarkObserver() {
        newsViewModel.postBookmarkLiveData.observe(viewLifecycleOwner) {
            when (it) {
                is NetworkResult.Success -> {

                }

                is NetworkResult.Error -> {
                    requireContext().toast(it.message.toString())
                }

                is NetworkResult.Loading -> {

                }

            }
        }
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        //       if (((DashBoard) getActivity()).getTabPosition() == 0 && !WebViewLoaderActivity.isWebviewLoaded)
        run { displayTopics() }
    }

    override fun onResume() {
        super.onResume()

        Log.d("newsCallbacks", "onResume")
        if ((Preference(activity).getPref(Constants.instream) == Constants.instreamNW)) setColor(
            R.drawable.button_round, R.color.white, R.drawable.grey_outline_bg, R.color.colourGrey
        ) else if ((Preference(
                activity
            ).getPref(Constants.instream) == Constants.instreamAnti)
        ) setColor(
            R.drawable.grey_outline_bg, R.color.colourGrey, R.drawable.button_round, R.color.white
        )
        if (refresh) {
            refresh = false
            //            if (checkLatestKeywordApiCall()||checkCountryCode()||checkUser())
//                getLatestKeyword();
        }

    }

    private fun scrollTopic(position: Int) {
        binding.topicHoriScroll?.layoutManager?.scrollToPosition(position)
    }


    private fun clearNewsItemList() {
        newsItemList.clear()
        mAdapter?.updateList(newsItemList)
        startrange = 0
    }

    private fun getNewsPostObserver() {
        newsViewModel.getInstrteamNwLiveData.observe(viewLifecycleOwner) {
            when (it) {
                is NetworkResult.Success -> {
                    binding.progressBar.invisible()
                    if (it.data?.isNotEmpty() == true) {
                        CoroutineScope(Dispatchers.Main).launch {
                            binding.nullAdapterTv.gone()
                            newsItemList.addAll(it.data as Collection<GetInstreamNwResponseItem?>)
                            mAdapter?.updateList(newsItemList)
                        }
                    } else {
                        if (linearLayoutManager?.childCount!! <= 0) {
                            scrollLimit = false
                            binding.nullAdapterTv.visible()
                        } else {
                            binding.nullAdapterTv.gone()

                            if (topicPopup == null) {
                                topicPopup = Dialog(requireActivity())
                                topicPopup?.setContentView(R.layout.dailoglayout)
                                val keywordText: TextView? =
                                    topicPopup?.findViewById(R.id.text_dialog)
                                keywordText?.text =
                                    "Start a discussion with your like-minded network -click here"
                                val cancel: TextView? =
                                    topicPopup?.findViewById<TextView>(R.id.skip_text)
                                cancel?.text = "Start Posting"
                                cancel?.setOnClickListener {
                                    topicPopup?.dismiss()
                                    findNavController().navigate(R.id.action_feedFragment_to_sendPostFragment)
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
                    binding.progressBar.visible()
                }

                else -> {

                }

            }
        }
    }


    private fun displayPost() {
        if ((Preference(activity).getPref(Constants.instream) == Constants.instreamNW)) {
            getNewsPost(Preference(activity).getIntPref(TOPICID))
        } else {
            getNewsPostAnti(Preference(activity).getIntPref(TOPICID))
        }
    }

    private fun getAllNwCount(topicId: Int?) {
        newsViewModel.getPostCount(
            GetPostCountsRequest(
                topicId.toString(), Preference(activity).getPref(Constants.USERID)
            )
        )
    }

    private fun postCountObserver() {
        newsViewModel.getPostCountLivedata.observe(viewLifecycleOwner) {
            when (it) {
                is NetworkResult.Success -> {
                    binding.filterLayout.visible()
                    binding.antiMindedCountTv.text = String.format(
                        getString(R.string.anti_minded),
                        it.data?.data?.ANTI_POST_COUNT.toString()
                    )
                    binding.likeMindedCountTv.text = String.format(
                        getString(R.string.network),
                        it.data?.data?.NW_POST_COUNT.toString()
                    )
                }

                is NetworkResult.Error -> {
                    binding.filterLayout.gone()
//                    requireContext().toast(it.message.toString())
                }

                is NetworkResult.Loading -> {

                }

            }
        }
    }

    private fun doLikePost(postId: String?, actionType: String?) {
        newsViewModel.userActionCommon(
            UserActionCommonRequest(
                getString(R.string.post_type),
                actionType,
                postId,
                Preference(activity).getPref(Constants.USERID)
            )
        )
    }

    fun alertdialog(pref: String?, pref1: String?) {

        // Create an alert builder
        val builder = AlertDialog.Builder(getContext())
        builder.setTitle("AK_TESTING")

        // set the custom layout
        val customLayout = layoutInflater.inflate(
            R.layout.custom_layout, null
        )
        builder.setView(customLayout)
        val userid = customLayout.findViewById<EditText>(
            R.id.userid
        )
        userid.setText(pref)
        val usertoken = customLayout.findViewById<EditText>(
            R.id.user_token
        )
        usertoken.setText(pref1)


        // add a button
        builder.setPositiveButton(
            "OK"
        ) { dialog, which -> // send data from the
            // AlertDialog to the Activity
            dialog.dismiss()
        }

        // create and show
        // the alert dialog
        val dialog = builder.create()
        dialog.show()
    }

    private fun showRemoveFrag(postId: String) {
        postIdRemoveUser = postId
        val fm = fragmentManager
        val reportDialogFragment = ReportDialogFragment(this)
        ReportDialogFragment.TYPE = getString(R.string.post_type)
        ReportDialogFragment.POSTID = postId
        reportDialogFragment.setTargetFragment(this@FeedFragment, 300)
        reportDialogFragment.show((fm)!!, "ReportDialogFragment")
    }

    fun deletePost(postid: String?) {
        newsViewModel.deletePost(
            DeletePostRequest(
                postid?.toInt(), Preference(activity).getPref(Constants.USERID)
            )
        )
        mAdapter?.notifyDataSetChanged()

    }

    private fun deletePostObserver() {
        newsViewModel.deletePostLiveData.observe(viewLifecycleOwner) {
            when (it) {
                is NetworkResult.Success -> {
                    requireContext().toast("Post Deleted")
                }

                is NetworkResult.Error -> {
                    requireContext().toast(it.message.toString())
                }

                is NetworkResult.Loading -> {

                }

            }
        }
    }

    fun sendPost(postId: Long) {
//        ((DashBoard) getActivity()).Tabselection(2);
        requireParentFragment().findNavController()
            .navigate(R.id.action_feedFragment_to_sendPostFragment)
        (activity as DashBoard?)!!.editPost(postId)
    }

    fun editPost(topicId: Int, topicDescription: String?, postId: Long, mediaContent: Any?) {
        SendPostFragment.topicid = topicId
        SendPostFragment.topicdescription = topicDescription
        SendPostFragment.postid = postId
        SendPostFragment.mediaContent = mediaContent
    }

    private fun setColor(
        likeMindedLayoutBack: Int,
        likeMindedTextColor: Int,
        antiMindedLayoutBack: Int,
        antiMindedTextColor: Int
    ) {
        //like minded
        binding.likeMindedLayout.background = resources.getDrawable(likeMindedLayoutBack)
        binding.likeMindedCountTv.setTextColor(resources.getColor(likeMindedTextColor))

        //anti minded
        binding.antiMindedLayout.background = resources.getDrawable(antiMindedLayoutBack)
        binding.antiMindedCountTv.setTextColor(resources.getColor(antiMindedTextColor))
    }


    override fun onBlockClicked() {
        val fm = fragmentManager
        val reportDialogFragment = BlockUserFragment(this)
        BlockUserFragment.CONTENTID = postIdRemoveUser
        BlockUserFragment.TYPE = getString(R.string.post_type)
        reportDialogFragment.setTargetFragment(this@FeedFragment, 300)
        reportDialogFragment.show((fm)!!, "BlockUserFragment")
    }

    override fun onCompleteBlock(type: String) {
        displayPost()
    }

    override fun onKickOut() {
        onRefresh()
    }

    override fun onNavBackCliked() {
        if (postIdRemoveUser != "") showRemoveFrag(postIdRemoveUser)
    }

    override fun onCompleteReport(type: String) {
        displayPost()
    }

    private fun showUsersHateLike(postid: String?, type: String?) {
        val loveHateUsersListFragment = LoveHateUsersListFragment.newInstance(
            postid, type
        )
        val fm = fragmentManager as FragmentManager
        loveHateUsersListFragment.show(fm, "LoveHateUserListFragment")
    }

    private val latestKeyword: Unit
        get() {
            keywordscall = LatestKeyCall()
            arrlistLatestKeywords = ArrayList()
            keywordscall!!.getLatestKeyWord(getApplicationContext()).observe(
                viewLifecycleOwner
            ) { listLatestKeywords ->
                //                Log.d("taggy", listLatestKeywords.get(0).getKEYWORDS());
                try {
                    arrlistLatestKeywords?.addAll(listLatestKeywords)
                    val mdate = listLatestKeywords[0].date
                    Preference(getApplicationContext()).savePref(Constants.date, mdate)
                } catch (e: Exception) {
                    e.fillInStackTrace()
                }
                showDialog(arrlistLatestKeywords!!)
            }
        }

    private fun checkCountryCode(): Boolean {
        val prevCode = Preference(getApplicationContext()).getPref(Constants.prevCode)
        val currCode = Preference(getApplicationContext()).getPref(Constants.COUNTRYCODE)
        if ((prevCode == currCode)) {
            return false
        }
        Preference(getApplicationContext()).savePref(Constants.prevCode, currCode)
        return true
    }

    private fun showDialog(list: ArrayList<ListLatestKeyword>) {
        val bottomSheet = BottomSheetDialog(list)
        if (list.size != 0) {
            bottomSheet.show(
                requireActivity().supportFragmentManager, "ModalBottomSheet"
            )
        }
    }

    companion object {

        @JvmField
        var topicsModelArrayList = ArrayList<GetUserTopicResponseItem>()


        @JvmField
        var loadProgress = 0

        @JvmField
        var postDetailsModelArrayList = ArrayList<PostDetailsModel?>()
        var commentCount = ArrayList<Int>()

        @JvmField
        var webLoadModelArrayList = ArrayList<WebLoadModel>()

        @JvmField
        var refresh = false

        @JvmField
        var firstLoad = false

        @JvmField
        var BackFromComment = ""

        @JvmField
        var load = false

        @JvmField
        var scrollPosition = -1

        @JvmField
        var commentedPostPosition = 0

        @JvmField
        var imageOpen = false

        @JvmField
        var postIdRemoveUser = ""

        /*   @Override
    public void onActivityResult(int requestCode, int resultCode, @Nullable Intent data)
    {
        super.onActivityResult(requestCode, resultCode, data);

        System.out.println("Called Fragment");

        if (requestCode == 101) {
            if (resultCode == Activity.RESULT_OK) {

                Log.e("feedFragment",String.valueOf(data));

            }
        }

    }*/
//        fun updateCommentCount(count: Int) {
//            PostAdapter.updateTextCount(count)
//        }

        @JvmStatic
        fun postBookmark(postid: String?, imgBookmark: ImageView) {

            val retrofitNetworkInterface = RetrofitClient.createService(
                RetrofitNetworkInterface::class.java
            )
            val jsonObject = JsonObject()
            jsonObject.addProperty(
                "userid", Preference(getApplicationContext()).getPref(Constants.USERID)
            )
            jsonObject.addProperty("postid", postid)
            val header: MutableMap<String, String> = HashMap()
            header["X-ACCESS-KEY"] = BuildConfig.APP_ID
            header["Token"] = Preference(getApplicationContext()).getPref(Constants.token)
            val call = retrofitNetworkInterface.postBookmark(header, jsonObject)
            call.enqueue(object : Callback<ResponseBody> {
                override fun onResponse(
                    call: Call<ResponseBody>, response: Response<ResponseBody>
                ) {
                    if (response.code() == 200) {
                        var status = ""
                        try {
                            status = JSONObject(response.body()?.string()).getString("status")
                            if (status.equals("success", ignoreCase = true)) {
                                //FeedFragment.refresh = true;
                                ActivityFragment.refresh = true
                                imgBookmark.setImageDrawable(
                                    AppCompatResources.getDrawable(
                                        getApplicationContext(), R.drawable.bookmark_active
                                    )
                                )

                            }
                        } catch (e: Exception) {
                            e.printStackTrace()
                        }
                    }
                }

                override fun onFailure(call: Call<ResponseBody>, t: Throwable) {}
            })
        }

        @JvmStatic
        fun removeBookmark(postid: String?, imgBookmark: ImageView) {

            val retrofitNetworkInterface = RetrofitClient.createService(
                RetrofitNetworkInterface::class.java
            )
            val jsonObject = JsonObject()
            jsonObject.addProperty(
                "userid", Preference(getApplicationContext()).getPref(Constants.USERID)
            )
            jsonObject.addProperty("postid", postid)
            val header: MutableMap<String, String> = HashMap()
            header["X-ACCESS-KEY"] = BuildConfig.APP_ID
            header["Token"] = Preference(getApplicationContext()).getPref(Constants.token)
            val call = retrofitNetworkInterface.removeBookmark(header, jsonObject)
            call.enqueue(object : Callback<ResponseBody> {
                override fun onResponse(
                    call: Call<ResponseBody>, response: Response<ResponseBody>
                ) {
                    if (response.code() == 200) {
                        var status = ""
                        try {
                            status = JSONObject(response.body()?.string()).getString("status")
                            if (status.equals("success", ignoreCase = true)) {
                                //FeedFragment.refresh = true;
                                //ActivityFragment.refresh =true;
                                imgBookmark.setImageDrawable(
                                    AppCompatResources.getDrawable(
                                        getApplicationContext(), R.drawable.bookmark
                                    )
                                )
                            }
                        } catch (e: Exception) {
                            e.printStackTrace()
                        }
                    }
                }

                override fun onFailure(call: Call<ResponseBody>, t: Throwable) {}
            })
        }
    }

    private fun keyWordPopup() {
        val topicPopup = Dialog(requireContext())
        topicPopup.setContentView(R.layout.image_dialog)
        val cancel = topicPopup.findViewById<TextView>(R.id.okay_text)
        cancel.setOnClickListener { topicPopup.dismiss() }
        topicPopup.window?.setLayout(
            ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT
        )
        topicPopup.show()
    }


    private var resultLauncher =
        registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
            if (result.resultCode == Activity.RESULT_OK) {
                // There are no request codes
                val data: Intent? = result.data
                val commentCount = data?.getStringExtra("commentCount")
                val likeCount = data?.getStringExtra("likeCount")
                val hateCount = data?.getStringExtra("hateCount")
                val myLikeOrHate = data?.getStringExtra("myLikeOrHate")
                Log.d("Back from comment = ", "$likeCount,$hateCount,$myLikeOrHate")

                val viewHolder = currentPosition.let {
                    binding.postRecycler?.findViewHolderForAdapterPosition(
                        it
                    )
                } as PostAdapter.ViewHolder
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
                newsItemList[currentPosition]?.POST_ACTION_TYPE =
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
            }
        }

    override fun onPostClick(position: Int, data: Any, type: Any?) {
        currentPosition = position
        if (type is String) {
            when (type) {
                "likeCount" -> {
                    showUsersHateLike(data.toString(), "L")
                }

                "hCount" -> {
                    showUsersHateLike(data.toString(), "H")
                }

                "imgLikePost" -> {}
                "imgDislikePost" -> {}
                "statusChangeLayoutParentPost" -> {
                    val intent = Intent(requireActivity(), CommonInterests::class.java)
                    intent.putExtra(
                        TOPICID, /*newsItemList[position]?.TOPICID*/
                        Preference(requireContext()).getIntPref(TOPICID).toString()
                    )
                    intent.putExtra(USERNAME, newsItemList[position]?.USERNAME)
                    intent.putExtra(PROFILEIMAGE, newsItemList[position]?.DP_URL)
                    requireContext().startActivity(intent)
                }

                "imgcomment" -> {
                    val commentIntent = Intent(requireActivity(), Comments::class.java)
                    commentIntent.putExtra("postcontent", position)
                    commentIntent.putExtra("title", "Comment")
                    commentIntent.putExtra("postid", newsItemList[position]?.POST_ID)
                    resultLauncher.launch(commentIntent)
                }

                "bookmark" -> {
                    if (newsItemList[position]?.BOOKMARK_FLAG == "B") {
                        val postID = data.toString().toInt()
                        newsViewModel.removeBookmark(
                            RemoveBookmarkRequest(
                                postID, Preference(activity).getPref(Constants.USERID)
                            )
                        )
                        newsItemList[position]?.BOOKMARK_FLAG = ""
                    } else {
                        val postID = data.toString().toInt()
                        newsViewModel.postBookmark(
                            PostBookmarkRequest(
                                postID, Preference(activity).getPref(Constants.USERID)
                            )
                        )
                        newsItemList[position]?.BOOKMARK_FLAG = "B"
                    }
                }

                "sharePost" -> {
                    if (newsItemList[position]?.POST_ACTION_TYPE?.lowercase().equals(
                            "l", ignoreCase = true
                        ) || newsItemList[position]?.POST_ACTION_TYPE?.lowercase()
                            .equals("h", ignoreCase = true)
                    ) {
                        DynamicLinksUtil.createDynamicUri(
                            Preference(requireContext()).getIntPref(TOPICID).toString(),
                            data.toString(),
                            requireActivity(),
                            newsItemList[position]?.postCellModel?.postTitle,
                            newsItemList[position]?.postCellModel?.urlForPreview,
                            ""
                        )
                    } else {
                        keyWordPopup()
                    }
                }

                "showPostDetail" -> {
                    if (newsItemList[position]?.POST_ACTION_TYPE?.lowercase(Locale.getDefault())
                            .equals(
                                "l", ignoreCase = true
                            ) || newsItemList[position]?.POST_ACTION_TYPE?.lowercase(Locale.getDefault())
                            .equals("h", ignoreCase = true)
                    ) {
//                        val commentIntent = Intent(requireActivity(), Comments::class.java)
//                        commentIntent.putExtra("postcontent", position)
//                        commentIntent.putExtra("title", "Comments")
//                        commentIntent.putExtra("postid", newsItemList[position]?.POST_ID)
//                        requireContext().startActivity(commentIntent)

                        currentPosition = position
                        val commentIntent = Intent(requireActivity(), Comments::class.java)
                        commentIntent.putExtra("postcontent", position)
                        commentIntent.putExtra("title", "Comment")
                        commentIntent.putExtra("postid", newsItemList[position]?.POST_ID)
                        resultLauncher.launch(commentIntent)
                    } else {
                        keyWordPopup()
                    }
                }

                "UserActionCommon" -> {
                    doLikePost(newsItemList[position]?.POST_ID, data.toString())
                }

                "removeUser" -> {
                    showRemoveFrag(data.toString())
                }
            }
        }

    }

    override fun onTopicClick(topicId: Int?, position: Int) {
        clearNewsItemList()
        if (topicId != null) {
            topicid = topicId
        }
        val layoutManager = binding.topicHoriScroll?.layoutManager as LinearLayoutManager
        layoutManager.scrollToPositionWithOffset(position, 20)
        if (topicId != null) {
            Preference(activity).saveIntPref(Constants.TOPICID, topicId)
        }

        getAllNwCount(topicId)
        displayPost()
    }
}