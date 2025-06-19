package com.opinito.social.Fragment

import android.app.Activity
import android.content.Intent
import android.graphics.PorterDuff
import android.graphics.Typeface
import android.icu.number.IntegerWidth
import android.os.Bundle
import android.os.Handler
import android.text.Editable
import android.text.InputFilter
import android.text.Spanned
import android.text.TextWatcher
import android.util.Log
import android.view.LayoutInflater
import android.view.Menu
import android.view.MenuInflater
import android.view.MenuItem
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.AbsListView
import android.widget.Button
import android.widget.EditText
import android.widget.RelativeLayout
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.core.text.HtmlCompat
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout.OnRefreshListener
import com.facebook.FacebookSdk.getApplicationContext
import com.google.gson.JsonObject
import com.opinito.social.Activity.CreateTopicActivity
import com.opinito.social.Activity.DashBoard
import com.opinito.social.Adapter.SearchTopicCartsAdapter
import com.opinito.social.Adapter.TopicCartsAdapter
import com.opinito.social.BuildConfig
import com.opinito.social.Constants.Constants
import com.opinito.social.Constants.Preference
import com.opinito.social.Interface.RetrofitNetworkInterface
import com.opinito.social.Model.BaseResponse
import com.opinito.social.Model.LikeMindedBodyRequest
import com.opinito.social.Model.MindCountModel
import com.opinito.social.Model.MultiSearchTopicModel
import com.opinito.social.Model.SearchTopicCartsModel
import com.opinito.social.R
import com.opinito.social.RetrofitClient
import com.opinito.social.Utils.DynamicLinksUtil
import com.opinito.social.Utils.SoftKeypad
import com.opinito.social.Utils.UserUtils
import com.opinito.social.Utils.customToolBar
import com.opinito.social.Utils.gone
import com.opinito.social.Utils.scrollTo
import com.opinito.social.Utils.toast
import com.opinito.social.Utils.visible
import com.opinito.social.code_revamp.adapter.InterestsTopicAdapter
import com.opinito.social.code_revamp.models.getUserCarts.Data
import com.opinito.social.code_revamp.models.getUserCarts.GetUserCartsRequest
import com.opinito.social.code_revamp.models.get_user_topics.GetUserTopicRequest
import com.opinito.social.code_revamp.models.get_user_topics.GetUserTopicResponseItem
import com.opinito.social.code_revamp.network_layer.NetworkResult
import com.opinito.social.code_revamp.view_models.InterestsViewModel
import com.opinito.social.databinding.CartfragmentBinding
import dagger.hilt.android.AndroidEntryPoint
import okhttp3.ResponseBody
import org.json.JSONArray
import org.json.JSONObject
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.util.Locale

@AndroidEntryPoint
class ListFragment : Fragment(), OnRefreshListener, View.OnClickListener,
    InterestsTopicAdapter.OnItemClickListener, TopicCartsAdapter.OnClickListener {
    private var topicsModelArrayList: MutableList<GetUserTopicResponseItem> = mutableListOf()
    private var binding: CartfragmentBinding? = null
    private var mInflater: LayoutInflater? = null
    private var mAdapter: TopicCartsAdapter? = null
    private var interestsTopicAdapter: InterestsTopicAdapter? = null
    private var selectedTopicId = 0
    private var searchTopicCartsAdapter: SearchTopicCartsAdapter? = null
    private var topicCartsModelArrayList: MutableList<Data?>? = mutableListOf()
    private val searchTopicCartsModelArrayList = ArrayList<SearchTopicCartsModel>()
    private val multiSearchTopicModelArrayList = ArrayList<MultiSearchTopicModel>()
    private val list1 = ArrayList<MultiSearchTopicModel>()
    private val list2 = ArrayList<MultiSearchTopicModel>()
    private var topicid = 0
    private var previousLength = 0
    private var backSpace = false
    private var tag = 0
    private var sortOrder = "LATEST"
    private val interestsViewModel by viewModels<InterestsViewModel>()

    private var currentItm = 0
    private var scroledItem = 0
    private var totalItm = 0
    private var isScrolling = false
    private var linearLayoutManager: LinearLayoutManager? = null
    private  var startrange = 0
    private val increament  = 100

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = CartfragmentBinding.inflate(inflater, container, false)
        val view: View = binding!!.root
        customToolBar(
            requireContext(),
            false,
            getString(R.string.topics),
            (activity as AppCompatActivity?)?.supportActionBar
        )
        requireActivity().window.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE)
        setHasOptionsMenu(true)
        // getFragmentManager().beginTransaction().detach(this).attach(this).commit();
        init()
        Log.d("CartCallBacks", "on Create View")
        return view
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        topicObserver()
        userCartsObserver()
        interestsViewModel.getUserTopic(
            GetUserTopicRequest(
                Preference(requireActivity()).getPref(
                    Constants.USERID
                )
            )
        )


        binding?.cartsRecycler?.addOnScrollListener(object : RecyclerView.OnScrollListener() {
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
                    Log.e(
                        "Count",
                        "current->$currentItm : total->$totalItm : scrolled->$scroledItem"
                    )
                    if (isScrolling && currentItm + scroledItem == totalItm) {
                        isScrolling = false
                        startrange = totalItm

                        interestsViewModel.getUserCarts(
                            GetUserCartsRequest(
                                startrange,
                                sortOrder,
                                increament,
                                Preference(getActivity()).getIntPref(Constants.TOPICCARTID),
                                Preference(requireActivity()).getPref(Constants.USERID)
                            )
                        )

                    }
                }
            }
        })

        binding?.createTopicET?.setOnFocusChangeListener { v, hasFocus ->
            if (hasFocus) {
                // Scroll to make the EditText visible above the keyboard
//                binding?.addSearch.smoothScrollTo(0, v.top)
            }
        }
    }

    private fun topicObserver() {
        interestsViewModel.userTopicResponseLiveData.observe(viewLifecycleOwner) { it ->
            when (it) {
                is NetworkResult.Success -> {
                    topicsModelArrayList = it.data as MutableList<GetUserTopicResponseItem>
                    interestsTopicAdapter?.updateList(topicsModelArrayList)
                    val selectedTopic: Int =
                        Preference(requireContext()).getIntPref(Constants.TOPICCARTID)
                    val index = topicsModelArrayList.indexOfFirst {
                        selectedTopic == it.TOPICID
                    }
                    binding?.topicHoriScroll?.scrollTo(index)

                }

                is NetworkResult.Error -> {
                    requireContext().toast(it.message.toString())
                }

                is NetworkResult.Loading -> {

                }

            }
        }
    }

    private fun clearInterestsItemList() {
        topicCartsModelArrayList?.clear()
        mAdapter?.updateList(topicCartsModelArrayList)
    }

    private fun init() {
        mInflater = LayoutInflater.from(activity)
        searchTopicCartsAdapter = SearchTopicCartsAdapter(
            multiSearchTopicModelArrayList,
            activity,
            binding?.cartsSearchRecycler,
            this,
            Preference(
                activity
            ).getIntPref(Constants.TOPICCARTID).toString()
        )
        binding?.sortByAlphabetic?.setOnClickListener(this)
        binding?.sortByLatest?.setOnClickListener(this)
        binding?.sortByPopular?.setOnClickListener(this)
        binding?.swipeRefresh?.setOnRefreshListener(this)
        binding?.cartsRecycler?.setOnClickListener(this)
        binding?.searchCancelIv?.setOnClickListener(this)
        binding?.createTopicIV?.setOnClickListener(this)
        binding?.cartShare?.setOnClickListener(this)

        mAdapter = TopicCartsAdapter(requireActivity(), this)
        binding?.cartsRecycler?.adapter = mAdapter
        linearLayoutManager =
            LinearLayoutManager(requireActivity(), LinearLayoutManager.VERTICAL, false)
        binding?.cartsRecycler?.layoutManager = linearLayoutManager
        interestsTopicAdapter = InterestsTopicAdapter(requireActivity(), this)
        binding?.topicHoriScroll?.adapter = interestsTopicAdapter


        binding?.searchBox?.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence, start: Int, count: Int, after: Int) {
                previousLength = s.toString().trim { it <= ' ' }.length
            }

            override fun onTextChanged(s: CharSequence, start: Int, before: Int, count: Int) {
                if (!binding?.searchBox?.text.toString().trim { it <= ' ' }
                        .isEmpty()) binding?.searchCancelIv?.setImageDrawable(
                    resources.getDrawable(R.drawable.ic_cancel_black_24dp)
                ) else binding?.searchCancelIv?.setImageDrawable(
                    resources.getDrawable(R.drawable.ic_search_grey_24dp)
                )
                if (binding?.searchBox?.text.toString().trim { it <= ' ' }.length > 2) {
                    showSearchMode()
                    searchTopic(binding?.searchBox?.text.toString().trim { it <= ' ' })
                }
            }

            override fun afterTextChanged(s: Editable) {
                backSpace = previousLength > s.toString().trim { it <= ' ' }.length
                if (backSpace) {
                    if (s.toString().trim { it <= ' ' }.length >= 3) searchTopic(
                        binding?.searchBox?.text.toString()
                            .trim { it <= ' ' }) else if (s.toString().trim { it <= ' ' }
                            .isEmpty()) hideSearchMode()
                }
            }
        })
        binding?.cartsRecycler?.invalidate()
        searchTopicCartsAdapter?.notifyDataSetChanged()
        binding?.cartsSearchRecycler?.invalidate()
        binding?.searchBox?.filters = arrayOf(EmojiExcludeFilter(), InputFilter.LengthFilter(60))
    }

    private fun showSearchMode() {
        binding?.emptyViewSearch?.visibility = View.VISIBLE
        binding?.cartsSearchRecycler?.visibility = View.VISIBLE
        binding?.createTopicIV?.visibility = View.VISIBLE
        binding?.createTopicET?.visibility = View.VISIBLE
        binding?.createTopicTv?.visibility = View.VISIBLE
        binding?.cartsRecycler?.visibility = View.GONE
    }

    private fun hideSearchMode() {
        searchTopicCartsModelArrayList.clear()
        binding?.searchCancelIv?.setImageDrawable(resources.getDrawable(R.drawable.ic_search_grey_24dp))
        binding?.cartsSearchRecycler?.visibility = View.GONE
        binding?.emptyViewSearch?.visibility = View.GONE
        binding?.cartsRecycler?.visibility = View.VISIBLE
        binding?.createTopicIV?.visibility = View.GONE
        binding?.createTopicET?.visibility = View.GONE
        binding?.createTopicTv?.visibility = View.GONE
        binding?.searchBox?.setText("")
        binding?.createTopicET?.setText("")
        SoftKeypad().hide(activity)
    }

    override fun onRefresh() {
        clearInterestsItemList()
        getUserCarts(Preference(activity).getIntPref(Constants.TOPICCARTID))
        binding?.swipeRefresh?.isRefreshing = false
    }

    private fun setColor(popularColor: Int, alphaColor: Int, latestColor: Int) {
        binding?.sortByPopular?.background?.setColorFilter(
            resources.getColor(popularColor),
            PorterDuff.Mode.SRC_ATOP
        )
        binding?.sortByAlphabetic?.background?.setColorFilter(
            resources.getColor(alphaColor),
            PorterDuff.Mode.SRC_ATOP
        )
        binding?.sortByLatest?.background?.setColorFilter(
            resources.getColor(latestColor),
            PorterDuff.Mode.SRC_ATOP
        )
    }

    override fun onClick(v: View) {
        val params = RelativeLayout.LayoutParams(
            RelativeLayout.LayoutParams.WRAP_CONTENT,
            RelativeLayout.LayoutParams.MATCH_PARENT
        )
        when (v.id) {
            R.id.create_topic_IV -> if (UserUtils.isGuestUser(activity)) {
                UserUtils.showConfirmation(activity)
            } else {
                if (!binding?.createTopicET?.text.toString().trim { it <= ' ' }.isEmpty()) {
                    showProgress()
                    validateUserKeyWord(binding?.createTopicET?.text.toString().trim { it <= ' ' })
                    hideSearchMode()
                } else {
                    Toast.makeText(activity, "Please enter a valid keyword", Toast.LENGTH_SHORT)
                        .show()
                }
            }

            R.id.search_cancel_iv -> if (!binding?.searchBox?.text.toString().trim { it <= ' ' }
                    .isEmpty()) hideSearchMode()

            R.id.cart_share -> DynamicLinksUtil.createDynamicUri(
                Preference(
                    activity
                ).getIntPref(Constants.TOPICCARTID).toString(),
                Constants.ZERO,
                context,
                "",
                "", ""
            )

            R.id.sort_by_popular -> {
                binding?.sortByPopular?.typeface = Typeface.DEFAULT_BOLD
                binding?.sortByLatest?.typeface = Typeface.DEFAULT
                binding?.sortByAlphabetic?.typeface = Typeface.DEFAULT
                binding?.sortByPopular?.id?.let { params.addRule(RelativeLayout.ALIGN_TOP, it) }
                binding?.sortByPopular?.id?.let { params.addRule(RelativeLayout.ALIGN_BOTTOM, it) }
                binding?.sortByPopular?.id?.let { params.addRule(RelativeLayout.ALIGN_END, it) }
                binding?.sortByIv?.layoutParams = params
                setColor(R.color.colourLightGrey, android.R.color.white, android.R.color.white)
                sortOrder = getString(R.string.popular).uppercase(Locale.getDefault())
                getUserCarts(Preference(activity).getIntPref(Constants.TOPICCARTID))
                clearInterestsItemList()
            }

            R.id.sort_by_latest -> {
                binding?.sortByLatest?.typeface = Typeface.DEFAULT_BOLD
                binding?.sortByAlphabetic?.typeface = Typeface.DEFAULT
                binding?.sortByPopular?.typeface = Typeface.DEFAULT
                binding?.sortByLatest?.let { params.addRule(RelativeLayout.ALIGN_TOP, it.id) }
                binding?.sortByLatest?.let { params.addRule(RelativeLayout.ALIGN_BOTTOM, it.id) }
                binding?.sortByLatest?.let { params.addRule(RelativeLayout.ALIGN_END, it.id) }
                binding?.sortByIv?.layoutParams = params
                setColor(android.R.color.white, android.R.color.white, R.color.colourLightGrey)
                sortOrder = getString(R.string.latest).uppercase(Locale.getDefault())
                getUserCarts(Preference(activity).getIntPref(Constants.TOPICCARTID))
                clearInterestsItemList()
            }

            R.id.sort_by_alphabetic -> {
                binding?.sortByPopular?.typeface = Typeface.DEFAULT
                binding?.sortByLatest?.typeface = Typeface.DEFAULT
                binding?.sortByAlphabetic?.typeface = Typeface.DEFAULT_BOLD
                binding?.sortByAlphabetic?.let { params.addRule(RelativeLayout.ALIGN_TOP, it.id) }
                binding?.sortByAlphabetic?.let { params.addRule(RelativeLayout.ALIGN_BOTTOM, it.id) }
                binding?.sortByAlphabetic?.let { params.addRule(RelativeLayout.ALIGN_END, it.id) }
                binding?.sortByIv?.layoutParams = params
                setColor(android.R.color.white, R.color.colourLightGrey, android.R.color.white)
                sortOrder = getString(R.string.alpha).uppercase(Locale.getDefault())
                clearInterestsItemList()
                getUserCarts(Preference(activity).getIntPref(Constants.TOPICCARTID))
            }
        }
    }

    private inner class EmojiExcludeFilter : InputFilter {
        override fun filter(
            source: CharSequence,
            start: Int,
            end: Int,
            dest: Spanned,
            dstart: Int,
            dend: Int
        ): String? {
            for (i in start until end) {
                val type = Character.getType(source[i])
                if (type == Character.SURROGATE.toInt() || type == Character.OTHER_SYMBOL.toInt()) {
                    return ""
                }
            }
            return null
        }
    }

    private fun validateUserKeyWord(userKeyword: String) {
        val retrofitNetworkInterface = RetrofitClient.createService(
            RetrofitNetworkInterface::class.java
        )
        val jsonObject = JsonObject()
        jsonObject.addProperty(
            "topicid",
            Preference(activity).getIntPref(Constants.TOPICCARTID).toString()
        )
        jsonObject.addProperty("userid", Preference(activity).getPref(Constants.USERID))
        jsonObject.addProperty("userKW", userKeyword)
        val header: MutableMap<String, String> = HashMap()
        header["X-ACCESS-KEY"] = BuildConfig.APP_ID
        header["Token"] = Preference(getApplicationContext()).getPref(Constants.token)
        val call = retrofitNetworkInterface.ValidateUserKeyWordApi(header, jsonObject)
        call.enqueue(object : Callback<ResponseBody?> {
            override fun onResponse(call: Call<ResponseBody?>, response: Response<ResponseBody?>) {
                if (response.code() == 200) {
                    var status = ""
                    try {
                        status = JSONArray(response.body()?.string()).getJSONObject(0)
                            .getString("CHKSTATUS")
                        if (status.equals("1", ignoreCase = true)) {
                            binding?.searchBox?.setText("")
                            binding?.createTopicET?.setText("")
                            val intent = Intent(activity, CreateTopicActivity::class.java)
                            for (i in topicsModelArrayList.indices) {
                                if (Preference(activity).getIntPref(Constants.TOPICCARTID) == topicsModelArrayList[i].TOPICID) {
                                    intent.putExtra(
                                        Constants.KEYWORD,
                                        topicsModelArrayList[i].TOPIC
                                    )
                                    intent.putExtra(
                                        Constants.KEYWORD_TOPIC_ID,
                                        topicCartsModelArrayList?.get(i)?.TOPICID
                                    )
                                    break
                                }
                            }
                            intent.putExtra(Constants.KEYWORD_DESCRIPTION, userKeyword)
                            startActivity(intent)
                            hideProgress()
                        } else {
                            Toast.makeText(context, "Opinito Policy Violated !", Toast.LENGTH_LONG)
                                .show()
                            hideProgress()
                        }
                    } catch (e: Exception) {
                        hideProgress()
                        e.printStackTrace()
                    }
                }
            }

            override fun onFailure(call: Call<ResponseBody?>, t: Throwable) {
                Toast.makeText(
                    activity,
                    getString(R.string.internal_error_occured),
                    Toast.LENGTH_SHORT
                ).show()
            }
        })
    }

    private fun searchTopic(searchTerm: String) {
        val retrofitNetworkInterface = RetrofitClient.createService(
            RetrofitNetworkInterface::class.java
        )
        val jsonObject = JsonObject()
        jsonObject.addProperty(
            "topicid",
            Preference(activity).getIntPref(Constants.TOPICCARTID).toString()
        )
        jsonObject.addProperty("userid", Preference(activity).getPref(Constants.USERID))
        //jsonObject.addProperty("country_code", new Preference(getActivity()).getPref(Constants.COUNTRYCODE));
        jsonObject.addProperty("searchTerm", searchTerm)
        val header: MutableMap<String, String> = HashMap()
        header["X-ACCESS-KEY"] = BuildConfig.APP_ID
        header["Token"] = Preference(getApplicationContext()).getPref(Constants.token)
        val call = retrofitNetworkInterface.searchTopic(header, jsonObject)
        call.enqueue(object : Callback<List<MultiSearchTopicModel?>?> {
            override fun onResponse(
                call: Call<List<MultiSearchTopicModel?>?>,
                response: Response<List<MultiSearchTopicModel?>?>
            ) {
                if (response.body() != null) {
                    list1.clear()
                    list2.clear()
                    multiSearchTopicModelArrayList.clear()
                    multiSearchTopicModelArrayList.addAll(response.body() as Collection<MultiSearchTopicModel>) //47
                    for (i in multiSearchTopicModelArrayList.indices) {
                        if (multiSearchTopicModelArrayList[i].topicid == Preference(
                                activity
                            ).getIntPref(Constants.TOPICCARTID).toString()
                        ) {
                            val n = MultiSearchTopicModel(
                                multiSearchTopicModelArrayList[i].tname,
                                multiSearchTopicModelArrayList[i].topicid,
                                multiSearchTopicModelArrayList[i].keyid,
                                multiSearchTopicModelArrayList[i].keywords,
                                multiSearchTopicModelArrayList[i].qsrc,
                                multiSearchTopicModelArrayList[i].hcount,
                                multiSearchTopicModelArrayList[i].lcount,
                                multiSearchTopicModelArrayList[i].tcount,
                                multiSearchTopicModelArrayList[i].cart
                            )
                            list1.add(n)
                        } else {
                            val n = MultiSearchTopicModel(
                                multiSearchTopicModelArrayList[i].tname,
                                multiSearchTopicModelArrayList[i].topicid,
                                multiSearchTopicModelArrayList[i].keyid,
                                multiSearchTopicModelArrayList[i].keywords,
                                multiSearchTopicModelArrayList[i].qsrc,
                                multiSearchTopicModelArrayList[i].hcount,
                                multiSearchTopicModelArrayList[i].lcount,
                                multiSearchTopicModelArrayList[i].tcount,
                                multiSearchTopicModelArrayList[i].cart
                            )
                            list2.add(n)
                        }
                    }
                    multiSearchTopicModelArrayList.clear()
                    multiSearchTopicModelArrayList.addAll(list1)
                    multiSearchTopicModelArrayList.addAll(list2)
                    try {
                        searchTopicCartsAdapter = SearchTopicCartsAdapter(
                            multiSearchTopicModelArrayList, activity,
                            binding?.cartsSearchRecycler, this@ListFragment, Preference(
                                requireActivity()
                            ).getIntPref(Constants.TOPICCARTID).toString()
                        )
                    }catch (e:Exception){e.printStackTrace()}
                    binding?.cartsSearchRecycler?.adapter = searchTopicCartsAdapter
                    if (searchTopicCartsAdapter?.itemCount == 0) binding?.createTopicET?.setText(
                        binding?.searchBox?.text.toString()
                    ) else binding?.createTopicET?.setText("")
//                    showSearchMode()
                }
            }

            override fun onFailure(call: Call<List<MultiSearchTopicModel?>?>, t: Throwable) {}
        })
    }

    override fun onCreateOptionsMenu(menu: Menu, inflater: MenuInflater) {
        requireActivity().menuInflater.inflate(R.menu.menu_save, menu)
        super.onCreateOptionsMenu(menu, inflater)
    }

    override fun onPrepareOptionsMenu(menu: Menu) {
        menu.findItem(R.id.action_save).setTitle("Save")
        if (DashBoard.isFirstTimeLogin) {
            if (isCartUpdated && isSomeThingSelected) {
                isCartUpdated = false
            } else {
                menu.findItem(R.id.action_save).setEnabled(false)
            }
        } else {
            if (isCartUpdated) {
                if (isSomeThingSelected){
                menu.findItem(R.id.action_save).setEnabled(true)
                }
                isCartUpdated = false
            } else {
                menu.findItem(R.id.action_save).setEnabled(false)
            }
        }
        super.onPrepareOptionsMenu(menu)
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        val id = item.itemId
        if (id == R.id.action_save) {
            if (binding?.cartsSearchRecycler?.visibility == View.VISIBLE) {
                if (multiSearchTopicModelArrayList.size > 0) {
                    SaveSearchResultsCards()
                }
            } else {
                if ((topicCartsModelArrayList?.size?: 0) > 0) {
                    SaveCards()
                }
            }
            return true
        }
        return super.onOptionsItemSelected(item)
    }

    fun SaveCards() {
        showProgress()
        val jsonArray = JSONArray()
        for (i in topicCartsModelArrayList?.indices!!) {
            if (topicCartsModelArrayList!![i]?.CART.equals("L", ignoreCase = true) ||
                topicCartsModelArrayList!![i]?.CART.equals("H", ignoreCase = true)
            ) {
                try {
                    val jsonObject = JSONObject()
                    jsonObject.put("CART", topicCartsModelArrayList!![i]?.CART)
                    jsonObject.put("KEYID", topicCartsModelArrayList!![i]?.KEYID)
                    jsonArray.put(jsonObject)
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }
        //remove topic from cart ideal payload {"userid":"c2c93378-dd10-11ed-933d-0680b5bc1ca5","topicid":"10","topiccarts":"[]"}
        try {
            val retrofitNetworkInterface = RetrofitClient.createService(
                RetrofitNetworkInterface::class.java
            )
            val saveCardsObject = JsonObject()
            saveCardsObject.addProperty("userid", Preference(activity).getPref(Constants.USERID))
            saveCardsObject.addProperty(
                "topicid",
                Preference(activity).getIntPref(Constants.TOPICCARTID).toString()
            )
            saveCardsObject.addProperty("topiccarts", jsonArray.toString())
            val header: MutableMap<String, String> = HashMap()
            header["X-ACCESS-KEY"] = BuildConfig.APP_ID
            header["Token"] = Preference(getApplicationContext()).getPref(Constants.token)
            val call = retrofitNetworkInterface.saveCards(header, saveCardsObject)
            call.enqueue(object : Callback<ResponseBody?> {
                override fun onResponse(
                    call: Call<ResponseBody?>,
                    response: Response<ResponseBody?>
                ) {
                    hideProgress()
                    if (response.code() == 200) {
                        if (response.body() != null) {
                            Preference(activity).saveIntPref(Constants.TOPICID, topicid)
                            getLikeMindedCount(
                                Preference(activity).getIntPref(Constants.TOPICCARTID).toString(),
                                Preference(activity).getPref(Constants.USERID)
                            )
                            DashBoard.isFirstTimeLogin = false
                        }
                    } else Toast.makeText(
                        context,
                        getString(R.string.something_went_wrong),
                        Toast.LENGTH_SHORT
                    ).show()
                }

                override fun onFailure(call: Call<ResponseBody?>, t: Throwable) {
                    hideProgress()
                    Toast.makeText(
                        context,
                        getString(R.string.internal_error_occured),
                        Toast.LENGTH_SHORT
                    ).show()
                }
            })
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun getLikeMindedCount(topicID: String, userId: String) {
        val retrofitNetworkInterface = RetrofitClient.createService(
            RetrofitNetworkInterface::class.java
        )
        val likeMindedBodyRequest = LikeMindedBodyRequest(topicID, userId)
        val header: MutableMap<String, String> = HashMap()
        header["X-ACCESS-KEY"] = BuildConfig.APP_ID
        header["Token"] = Preference(getApplicationContext()).getPref(Constants.token)
        try {
            val call = retrofitNetworkInterface.getMindedCount(header, likeMindedBodyRequest)
            call.enqueue(object : Callback<List<MindCountModel?>?> {
                override fun onResponse(
                    call: Call<List<MindCountModel?>?>,
                    response: Response<List<MindCountModel?>?>
                ) {
                    if (response.code() == 200) {
                        val factory = LayoutInflater.from(context)
                        try {
                            if (response.body()?.get(0)?.count != "0") {

                                val dialogView = factory.inflate(R.layout.dailoglayout, null)
                                dialogView.elevation = 5f
                                val topicName = response.body()?.get(0)?.topicName.toString()
                                val dialogText = dialogView.findViewById<TextView>(R.id.text_dialog)
                                val skipText = dialogView.findViewById<TextView>(R.id.skip_text)
                                val text = String.format(
                                    getString(R.string.like_minded_count),
                                    response.body()?.get(0)?.count,
                                    topicName
                                )
                                val styledText: CharSequence = HtmlCompat.fromHtml(
                                    text,
                                    HtmlCompat.FROM_HTML_SEPARATOR_LINE_BREAK_LIST_ITEM
                                )
                                dialogText.text = styledText
                                val dialog = AlertDialog.Builder(
                                    requireActivity(), R.style.MyCustomDialogTheme
                                ).create()
                                dialog.setView(dialogView)
                                skipText.setOnClickListener {
                                    dialog.dismiss()
                                    ProfileFragment.load = false
                                    FeedFragment.load = false
                                    ActivityFragment.refresh = true
                                    findNavController()
                                        .navigate(R.id.action_listFragment_to_usersDiscussions3)
                                }
                                dialog.setCancelable(false)
                                dialog.setCanceledOnTouchOutside(false)
                                dialog.show()
//                            DisplayTopicsCarts(Preference(activity).getIntPref(Constants.TOPICCARTID))
                            } else {
                                findNavController()
                                    .navigate(R.id.action_listFragment_to_usersDiscussions3)
                            }
                        } catch (e: Exception) {
                        }
                    }
                }

                override fun onFailure(call: Call<List<MindCountModel?>?>, t: Throwable) {
                    ProfileFragment.load = false
                    FeedFragment.load = false
                    findNavController()
                        .navigate(R.id.action_listFragment_to_feedFragment)
                    Toast.makeText(context, "Snap! Something went wrong", Toast.LENGTH_SHORT).show()
                }
            })
        } catch (e: Exception) {
            Toast.makeText(context, "Snap! Something went wrong", Toast.LENGTH_SHORT).show()
            ProfileFragment.load = false
            FeedFragment.load = false
            findNavController()
                .navigate(R.id.action_listFragment_to_feedFragment)
        }
    }

    fun reportCartConfirmation(keyId: String) {
        val dialogView = LayoutInflater.from(activity).inflate(R.layout.cart_report_dialog, null)
        dialogView.elevation = 5f
        val cancelButton = dialogView.findViewById<Button>(R.id.cancel_button)
        val okButton = dialogView.findViewById<Button>(R.id.login_button)
        val reportEditText = dialogView.findViewById<EditText>(R.id.report_edittext)
        val charCountTv = dialogView.findViewById<TextView>(R.id.char_count_tv)
        charCountTv.text = String.format(getString(R.string.get_60), Constants.ZERO)
        val dialog = AlertDialog.Builder(
            requireActivity(), R.style.MyCustomDialogTheme
        ).create()
        dialog.setView(dialogView)
        okButton.setOnClickListener {
            if (!reportEditText.text.toString().trim { it <= ' ' }.isEmpty()) {
                dialog.dismiss()
                userKWReport(keyId, reportEditText.text.toString().trim { it <= ' ' })
            } else {
                Toast.makeText(
                    activity,
                    getString(R.string.reason_cannot_be_blank),
                    Toast.LENGTH_LONG
                ).show()
            }
        }
        cancelButton.setOnClickListener { dialog.dismiss() }
        reportEditText.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence, start: Int, before: Int, count: Int) {}
            override fun afterTextChanged(s: Editable) {
                charCountTv.text = String.format(getString(R.string.get_60), s.length.toString())
            }
        })
        dialog.setCancelable(false)
        dialog.setCanceledOnTouchOutside(false)
        dialog.show()
    }

    private fun userKWReport(keyId: String, comment: String) {
        try {
            val retrofitNetworkInterface = RetrofitClient.createService(
                RetrofitNetworkInterface::class.java
            )
            val userKWRequest = JsonObject()
            userKWRequest.addProperty("userid", Preference(activity).getPref(Constants.USERID))
            userKWRequest.addProperty(
                "topicid",
                Preference(activity).getIntPref(Constants.TOPICCARTID).toString()
            )
            userKWRequest.addProperty("keyid", keyId)
            userKWRequest.addProperty("comment", comment)
            val header: MutableMap<String, String> = HashMap()
            header["X-ACCESS-KEY"] = BuildConfig.APP_ID
            header["Token"] = Preference(getApplicationContext()).getPref(Constants.token)
            val call = retrofitNetworkInterface.userKWReport(header, userKWRequest)
            call.enqueue(object : Callback<BaseResponse?> {
                override fun onResponse(
                    call: Call<BaseResponse?>,
                    response: Response<BaseResponse?>
                ) {
                    if (response.code() == 200) {
                        if (response.body() != null) {
                            if (response.body()?.status == getString(R.string.success_status)) {
                                Toast.makeText(
                                    activity,
                                    getString(R.string.keywork_reported),
                                    Toast.LENGTH_LONG
                                ).show()
                            } else {
                                Toast.makeText(
                                    activity,
                                    getString(R.string.something_went_wrong),
                                    Toast.LENGTH_SHORT
                                ).show()
                            }
                        }
                    }
                }

                override fun onFailure(call: Call<BaseResponse?>, t: Throwable) {
                    Toast.makeText(
                        activity,
                        getString(R.string.internal_error_occured),
                        Toast.LENGTH_SHORT
                    ).show()
                }
            })
        } catch (e: Exception) {
            Toast.makeText(activity, getString(R.string.internal_error_occured), Toast.LENGTH_SHORT)
                .show()
            e.printStackTrace()
        }
    }

    private fun SaveSearchResultsCards() {
        showProgress()
        val jsonArray = JSONArray()
        for (i in multiSearchTopicModelArrayList.indices) {
            if (multiSearchTopicModelArrayList[i].cart.equals("L", ignoreCase = true) ||
                multiSearchTopicModelArrayList[i].cart.equals("H", ignoreCase = true)
            ) {
                try {
                    val jsonObject = JSONObject()
                    jsonObject.put("CART", multiSearchTopicModelArrayList[i].cart)
                    jsonObject.put("KEYID", multiSearchTopicModelArrayList[i].keyid)
                    jsonObject.put("TOPICID", multiSearchTopicModelArrayList[i].topicid)
                    jsonArray.put(jsonObject)
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }
        try {
            val selectedTopicId = jsonArray.getJSONObject(0)["TOPICID"].toString()
            val retrofitNetworkInterface = RetrofitClient.createService(
                RetrofitNetworkInterface::class.java
            )
            val saveSearchCart = JsonObject()
            saveSearchCart.addProperty("userid", Preference(activity).getPref(Constants.USERID))
            //saveSearchCart.addProperty("topicid", String.valueOf(new Preference(getActivity()).getIntPref(Constants.TOPICCARTID)));
            saveSearchCart.addProperty("topicid", selectedTopicId)
            saveSearchCart.addProperty("topiccarts", jsonArray.toString())
            val header: MutableMap<String, String> = HashMap()
            header["X-ACCESS-KEY"] = BuildConfig.APP_ID
            header["Token"] = Preference(getApplicationContext()).getPref(Constants.token)
            val call = retrofitNetworkInterface.addSearchTopicToCart(header, saveSearchCart)
            call.enqueue(object : Callback<ResponseBody?> {
                override fun onResponse(
                    call: Call<ResponseBody?>,
                    response: Response<ResponseBody?>
                ) {
                    hideProgress()
                    if (response.code() == 200) {
                        if (response.body() != null) {
                            hideSearchMode()
                            Preference(activity).saveIntPref(
                                Constants.TOPICID,
                                selectedTopicId.toInt()
                            )
                            getLikeMindedCount(
                                Preference(activity).getIntPref(Constants.TOPICID).toString(),
                                Preference(activity).getPref(Constants.USERID)
                            )
                        }
                    } else Toast.makeText(
                        context,
                        getString(R.string.something_went_wrong),
                        Toast.LENGTH_SHORT
                    ).show()
                }

                override fun onFailure(call: Call<ResponseBody?>, t: Throwable) {
                    hideProgress()
                    Toast.makeText(
                        context,
                        getString(R.string.internal_error_occured),
                        Toast.LENGTH_SHORT
                    ).show()
                }
            })
        } catch (e: Exception) {
            hideProgress()
            e.printStackTrace()
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        binding = null
        Log.d("CartCallBacks", "on Destroy View")
    }


    override fun onResume() {
        super.onResume()
        if (Preference(this.activity).getBooleanPref(Constants.IS_FROM_CREATE_TOPIC)) {
            binding?.searchBox?.setText("")
            findNavController()
                .navigate(R.id.action_listFragment_to_feedFragment)

            Preference(this.activity).saveBooleanPref(Constants.IS_FROM_CREATE_TOPIC, false)
        }
        Log.d("CartCallBacks", "on Resume")
    }

    private fun showProgress() {
        try {
            if (binding?.barProgress != null) {
                binding?.barProgress?.visibility = View.VISIBLE
                requireActivity().window.setFlags(
                    WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE,
                    WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE
                )
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun hideProgress() {
        try {
            if (binding?.barProgress != null) {
                binding?.barProgress?.visibility = View.GONE
                requireActivity().window.clearFlags(WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private val isSomeThingSelected: Boolean
        private get() {
            if ((topicCartsModelArrayList?.size ?: 0) > 0) {
                for (topicCartsModel in topicCartsModelArrayList!!) {
                    if (topicCartsModel?.CART?.lowercase(Locale.getDefault()).equals("l",ignoreCase = true) ||
                        topicCartsModel?.CART?.lowercase(Locale.getDefault()).equals("h",ignoreCase = true)
                    ) {
                        return true
                    }
                }
            }
            return false
        }
    private val isSomeThingSelectedOnSearchResults: Boolean
        private get() {
            if (searchTopicCartsModelArrayList.size > 0) {
                for (topicCartsModel in searchTopicCartsModelArrayList) {
                    if (topicCartsModel.cart.lowercase(Locale.getDefault()) == "l" || topicCartsModel.cart.lowercase(
                            Locale.getDefault()
                        ) == "h"
                    ) {
                        return true
                    }
                }
            }
            return false
        }

    companion object {
        @JvmField
        var load = false

        @JvmField
        var isCartUpdated = false

        @JvmField
        var firstLoad = false
    }

    override fun onTopicClick(topicId: Int?, position: Int) {
        clearInterestsItemList()
        startrange = 0
        if (topicId != null) {
            topicid = topicId
        }
        val layoutManager = binding?.topicHoriScroll?.layoutManager as LinearLayoutManager
        layoutManager.scrollToPositionWithOffset(position, 20)
        if (topicId != null) {
            Preference(requireActivity()).saveIntPref(Constants.TOPICID, topicId)
        }
        getUserCarts(topicId)
    }

    private fun getUserCarts(topicId: Int?) {
        binding?.barProgress?.visible()
        interestsViewModel.getUserCarts(
            GetUserCartsRequest(
                0,
                sortOrder,
                100,
                topicId,
                Preference(requireActivity()).getPref(Constants.USERID)
            )
        )
    }

    private fun userCartsObserver() {
        interestsViewModel.userCartsResponseLiveData.observe(viewLifecycleOwner) {
            when (it) {
                is NetworkResult.Success -> {
                    binding?.barProgress?.gone()
                    topicCartsModelArrayList?.addAll(it.data?.data as MutableList<Data>)
                    mAdapter?.updateList(topicCartsModelArrayList)
                }

                is NetworkResult.Error -> {
                    requireContext().toast(it.message.toString())
                    binding?.barProgress?.gone()
                }

                is NetworkResult.Loading -> {
                    binding?.barProgress?.visible()
                }

            }
        }
    }

    override fun onItemClick(keyId: String?) {
        if (keyId != null) {
            reportCartConfirmation(keyId)
        }
    }

    override fun likeHateClicked() {
        isCartUpdated = true
        requireActivity().invalidateOptionsMenu()
    }
}