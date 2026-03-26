package com.opinito.social.Fragment

import android.app.Dialog
import android.content.Intent
import android.graphics.drawable.GradientDrawable
import android.net.Uri
import android.os.Bundle
import android.text.Editable
import android.text.Spanned
import android.text.TextWatcher
import android.util.Log
import android.view.LayoutInflater
import android.view.Menu
import android.view.MenuInflater
import android.view.MenuItem
import android.view.View
import android.view.ViewGroup
import android.view.Window
import android.widget.AbsListView
import android.widget.AdapterView
import android.widget.AdapterView.OnItemSelectedListener
import android.widget.ArrayAdapter
import android.widget.Button
import android.widget.EditText
import android.widget.ImageView
import android.widget.ProgressBar
import android.widget.RelativeLayout
import android.widget.Spinner
import android.widget.Switch
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.core.text.HtmlCompat
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.bumptech.glide.request.RequestOptions
import com.facebook.AccessToken
import com.facebook.CallbackManager
import com.facebook.CallbackManager.Factory.create
import com.facebook.FacebookCallback
import com.facebook.FacebookException
import com.facebook.FacebookSdk.getApplicationContext
import com.facebook.GraphRequest
import com.facebook.GraphResponse
import com.facebook.login.LoginManager
import com.facebook.login.LoginResult
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInAccount
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.common.api.ApiException
import com.google.android.gms.tasks.Task
import com.google.gson.JsonObject
import com.opinito.social.Activity.AllConversationsActivity
import com.opinito.social.Activity.DashBoard
import com.opinito.social.Activity.Login
import com.opinito.social.Activity.LoginFbUser
import com.opinito.social.Activity.MyActivityHolder
import com.opinito.social.Activity.SettingsActivity
import com.opinito.social.Activity.SwitchUserActivity
import com.opinito.social.Adapter.ProfilePopupAdapter
import com.opinito.social.Adapter.TopicsGridAdapter
import com.opinito.social.BuildConfig
import com.opinito.social.Constants.Constants
import com.opinito.social.Constants.Preference
import com.opinito.social.Interface.RetrofitNetworkInterface
import com.opinito.social.Model.BaseResponse
import com.opinito.social.Model.CheckUsernameRequest
import com.opinito.social.Model.LikeMindedBodyRequest
import com.opinito.social.Model.MindCountModel
import com.opinito.social.R
import com.opinito.social.RetrofitClient
import com.opinito.social.Utils.ColorChange
import com.opinito.social.Utils.Customize
import com.opinito.social.Utils.DynamicLinksUtil
import com.opinito.social.Utils.UserUtils
import com.opinito.social.Utils.customToolBar
import com.opinito.social.Utils.gone
import com.opinito.social.Utils.toast
import com.opinito.social.Utils.visible
import com.opinito.social.code_revamp.models.change_country_code.ChangeCountryCodeRequest
import com.opinito.social.code_revamp.models.showFreshContent.ShowFreshContentRequest
import com.opinito.social.code_revamp.models.showFreshContent.ShowFreshContentResponse
import com.opinito.social.code_revamp.models.showInitialDiscussions.Data
import com.opinito.social.code_revamp.models.showInitialDiscussions.ShowInitialDiscussionsRequest
import com.opinito.social.code_revamp.models.user_interests.request.SaveAllUserInterestsRequest
import com.opinito.social.code_revamp.models.user_interests.request.UserInterestsRequest
import com.opinito.social.code_revamp.models.user_interests.response.UserInterestsResponse
import com.opinito.social.code_revamp.network_layer.NetworkResult
import com.opinito.social.code_revamp.view_models.ProfileViewModel
import com.opinito.social.databinding.ProfileFragmentBinding
import com.opinito.social.databinding.ProfilePopupBinding
import dagger.hilt.android.AndroidEntryPoint
import okhttp3.ResponseBody
import org.json.JSONArray
import org.json.JSONObject
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.util.Locale
import java.util.Objects


/**
 * Created by 502687702 on 7/12/2017.
 */
@AndroidEntryPoint
class ProfileFragment : Fragment(), ProfilePopupAdapter.OnClickListener {
    private var selectedCountryCode: String? = null
    lateinit var binding: ProfileFragmentBinding
    private lateinit var profilePopupBinding: ProfilePopupBinding
    private var profilePopupAdapter: ProfilePopupAdapter? = null
    private var scrollLimit = true
    private var callbackManager1: CallbackManager? = null
    private var isScrolling = false
    private var topicCartsModelArrayList: MutableList<ShowFreshContentResponse.Data?>? = ArrayList()
    private lateinit var profilePopupDialog: Dialog
    private var userName: TextView? = null
    private var completesignup: TextView? = null
    private var countryCode: TextView? = null
    private var changeCountryCode: ImageView? = null
    private var defaultCountryCode: String? = null
    private var mGoogleSignInClient: GoogleSignInClient? = null
    private val profileInterestsModels: MutableList<UserInterestsResponse?> = ArrayList()
    private var usernameET: EditText? = null
    private var guestUserLayout: RelativeLayout? = null
    private var profileImageText: TextView? = null
    private var updateIntrestsDialog: Dialog? = null
    private var profileImage: ImageView? = null
    private var privacyImage: ImageView? = null
    private var activityIcon: ImageView? = null
    private var settings: ImageView? = null
    private var countryCodeIv: ImageView? = null
    private var chatSwitch: Switch? = null
    private var chattext: TextView? = null
    private var username: String? = null
    private var linearLayoutManager: LinearLayoutManager? = null
    private var recyclerView: RecyclerView? = null
    private var getContainer: ViewGroup? = null
    private var currentItm: Int? = null
    private var scroledItem: Int? = null
    private var totalItm: Int = 0
    private var topicId: Int? = null
    private var btnJoinDiscusion: Button? = null
    private var startIndex = 0
    var start: Int = 0
    var end: Int = 20
    private var firstCalled = true
    val selectedTopicIds = mutableListOf<String?>()
    private var isSelectionModeActive = false
    var showPopup: Boolean = false
    // Revampimg

    private var interestsList: MutableList<com.opinito.social.code_revamp.models.user_interests.response.Data?>? =
        ArrayList()
    private val profileViewModel by viewModels<ProfileViewModel>()
    private lateinit var topicsGridAdapter: TopicsGridAdapter

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?
    ): View {
        binding = ProfileFragmentBinding.inflate(inflater, container, false)
        profilePopupBinding = ProfilePopupBinding.inflate(layoutInflater)
        observeSaveAll()
        customToolBar(
            requireContext(),
            false,
            getString(R.string.profile),
            (activity as AppCompatActivity?)!!.supportActionBar
        )
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setHasOptionsMenu(true)
        bindObservers()
        countryCodeObserver()
        showInitialDiscussionsObserver()

        try {
            binding.saveAll?.setOnClickListener {

                saveAllInterests("Is this your final selection ?")
            }
            binding.settingsTv?.setOnClickListener {
                val intent = Intent(requireActivity(), SettingsActivity::class.java)
                startActivity(intent)
            }
            binding.myActivityTv?.setOnClickListener {
                val intent = Intent(requireActivity(), MyActivityHolder::class.java)
                startActivity(intent)
            }
            binding.editCountryCode.setOnClickListener { showConfirmation() }

            binding.switchProfileTv?.setOnClickListener { showLogoutConfirmation(getString(R.string.switch_user_confirmation)) }

        } catch (e: Exception) {
            e.printStackTrace()
        }
        val gso = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .requestEmail()
            .build()

//        val gso = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN).requestEmail()
//            .requestServerAuthCode(getString(R.string.server_client_id)).build()
        mGoogleSignInClient = GoogleSignIn.getClient(getApplicationContext(), gso)
        if (Preference(context).getPref(Constants.PROFILEIMAGE).isNotEmpty()
        ) binding.profileImageText.gone() else binding.profileImageText.visibility = View.VISIBLE
        try {
            binding.profileImageText.text =
                Preference(context).getPref(Constants.USERNAME).uppercase(
                    Locale.getDefault()
                )[0].toString()
            val background = binding.profileImage.background as GradientDrawable
            background.setColor(
                ColorChange(context).colorChange(
                    Preference(
                        context
                    ).getPref(Constants.USERNAME).lowercase(Locale.getDefault())[0].toString()
                )
            )
            Glide.with(requireActivity()).load(Preference(activity).getPref(Constants.PROFILEIMAGE))
                .apply(RequestOptions.circleCropTransform()).into(binding.profileImage)
        } catch (e: Exception) {
            e.printStackTrace()
        }
        binding.countryCode.text = Preference(activity).getPref(Constants.COUNTRYCODE)
        binding.username.text = Preference(activity).getPref(Constants.USERNAME)
        try {
            binding.flagIvActivity.setImageDrawable(
                resources.getDrawable(
                    Customize.getCountryFlagRes(
                        Preference(activity).getPref(Constants.COUNTRYCODE), requireActivity()
                    )
                )
            )
        } catch (e: Exception) {
            e.printStackTrace()
        }
        if (UserUtils.isGuestUser(context)) {
            binding.chatSwitch.isChecked = false
            setChatToggleForCurrentUser(getString(R.string.flay_N))
            binding.guestUserLayout.visible()
            binding.completesignup.setOnClickListener {
                updateIntrestsDialog = Dialog(requireActivity())
                updateIntrestsDialog?.setContentView(R.layout.guestsignup)
                updateIntrestsDialog?.setCanceledOnTouchOutside(false)
                updateIntrestsDialog?.show()
                usernameET = updateIntrestsDialog?.findViewById(R.id.username_et)
                val cancelTv = updateIntrestsDialog?.findViewById<TextView>(R.id.cancel_tv)
                val checkUsername =
                    updateIntrestsDialog!!.findViewById<TextView>(R.id.check_username)
                val facebookLogin =
                    updateIntrestsDialog!!.findViewById<Button>(R.id.facebook_login_button)
                val googleLogin =
                    updateIntrestsDialog!!.findViewById<Button>(R.id.google_login_button)
                googleLogin.isEnabled = true
                facebookLogin.isEnabled = true
                username = Preference(activity).getPref(Constants.DEVICENAME)
                binding.username.text = username
//                binding.username.setCompoundDrawablesWithIntrinsicBounds(
//                    0, 0, R.drawable.opinito_logo_round, 0
//                )
                usernameET?.addTextChangedListener(object : TextWatcher {
                    override fun beforeTextChanged(
                        s: CharSequence, start: Int, count: Int, after: Int
                    ) {
                    }

                    override fun onTextChanged(
                        s: CharSequence, start: Int, before: Int, count: Int
                    ) {
                        if (binding.username.text.toString().length > 5)
                            checkForUsernameValidity(checkUsername, facebookLogin, googleLogin)
                        else {
                            checkUsername.text = getString(R.string.username_length_check_text)
                            facebookLogin.isEnabled = false
                            googleLogin.isEnabled = false
                        }
                    }

                    override fun afterTextChanged(s: Editable) {}
                })
                cancelTv?.setOnClickListener { updateIntrestsDialog!!.dismiss() }
                googleLogin.setOnClickListener {
                    val intent = mGoogleSignInClient?.signInIntent
                    if (intent != null) {
                        startActivityForResult(intent, RC_SIGN_IN)
                    }
                }
                facebookLogin.setOnClickListener {
                    LoginManager.getInstance()
                        .logInWithReadPermissions(this@ProfileFragment, mutableListOf("email"))
                    LoginManager.getInstance().registerCallback(
                        callbackManager1,
                        object : FacebookCallback<LoginResult?> {
                            override fun onSuccess(loginResult: LoginResult?) {
                                if (loginResult != null) {
                                    GraphResult(loginResult.accessToken, loginResult)
                                }
                                // App code
                            }

                            override fun onCancel() {
                                Toast.makeText(context, "Cancelled", Toast.LENGTH_SHORT).show()
                                // App code
                            }

                            override fun onError(exception: FacebookException) {
                                Toast.makeText(context, "Error", Toast.LENGTH_SHORT).show()
                                // App code
                            }

                        })
                }
            }
        } else {
            binding.chatSwitch.isChecked = true
            binding.logoutIv.visible()
            binding.guestUserLayout.gone()
        }
        userInterests()
    }

    private fun showDialog() {
        start = 0
        startIndex = 0
        isScrolling = false
        scrollLimit = true
        topicCartsModelArrayList?.clear()

        if (::profilePopupDialog.isInitialized.not()) {
            profilePopupDialog = Dialog(requireActivity())
            profilePopupDialog.requestWindowFeature(Window.FEATURE_NO_TITLE)
            profilePopupDialog.window?.setBackgroundDrawableResource(android.R.color.transparent)
            profilePopupDialog.setContentView(profilePopupBinding.root)
        }
        setUpProfilePopupAdapter()
        linearLayoutManager =
            LinearLayoutManager(requireActivity(), LinearLayoutManager.VERTICAL, false)
        profilePopupBinding.topicsRv.layoutManager = linearLayoutManager
        btnJoinDiscusion = profilePopupBinding.joinDiscusion
        btnJoinDiscusion?.background = resources.getDrawable(R.drawable.button_round_gray)
        btnJoinDiscusion?.isEnabled = false


        profilePopupBinding.btnSwitchIntrest.setOnClickListener {

        }


        profilePopupBinding.topicsRv.addOnScrollListener(object : RecyclerView.OnScrollListener() {
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
                    Log.e("Count", " $currentItm : $totalItm : $scroledItem")
                    if (isScrolling && currentItm!! + scroledItem!! == totalItm && scrollLimit) {
                        isScrolling = false
                        start = totalItm
                        callInitialKWSApi(start, end)
                    }
                }
            }
        })

        profilePopupBinding.btnCancel.setOnClickListener {
            isSelectionModeActive = false
            binding.saveAll?.apply {
                isEnabled = false
                setBackgroundTintList(ContextCompat.getColorStateList(context, R.color.gray))
            }
            if (isSomeThingSelected) {
                showPopup = false
                val topicPopup = Dialog(requireContext())
                topicPopup.requestWindowFeature(Window.FEATURE_NO_TITLE)
                topicPopup.window?.setBackgroundDrawableResource(android.R.color.transparent)
                topicPopup.setContentView(R.layout.confirm_dialog)
                val cancel = topicPopup.findViewById<TextView>(R.id.btncancel)
                val txt = topicPopup.findViewById<TextView>(R.id.top_tv)
                val title = topicPopup.findViewById<TextView>(R.id.app_name_tv)
                title.text = "Cancel selection"
                title.visible()
                txt.text = "Do you wish to cancel ? \n If yes then your selection will be lost."
                val ok = topicPopup.findViewById<TextView>(R.id.btnyes)
                topicPopup.setCancelable(false)
                cancel.setOnClickListener { topicPopup.dismiss() }
                ok.setOnClickListener {
                    showPopup = false
                    profilePopupDialog.dismiss()
                    topicPopup.dismiss()
                    userInterests()
                    isSelectionModeActive = false
                    binding.saveAll?.apply {
                        isEnabled = false
                        setBackgroundTintList(
                            ContextCompat.getColorStateList(
                                context,
                                R.color.gray
                            )
                        )
                    }
                }
                topicPopup.window!!.setLayout(
                    ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT
                )
                topicPopup.show()
            } else {
                profilePopupDialog.dismiss()
                showPopup = false
            }

        }
        btnJoinDiscusion?.setOnClickListener {
            if (isSomeThingSelected) {
                val topicId = interestsList?.firstOrNull { it?.SLCT == "Y" }?.TOPICID
                binding.progressBar?.let { it1 -> savetoCart(topicId?.toInt() ?: 0, "li", it1) }

            } else {
                Toast.makeText(context, "Please Select Something", Toast.LENGTH_SHORT).show()
            }
        }
        callInitialKWSApi(start, end)
        profilePopupDialog.window!!.setLayout(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )
        profilePopupDialog.show()
    }

    private fun savetoCart(topicId: Int, who: String, progressBar: ProgressBar) {
        try {
            isSelectionModeActive = false
            if (isSomeThingSelected) {
                progressBar.visible()
                val jsonArray = JSONArray()
                for (i in topicCartsModelArrayList?.indices!!) {
                    if (topicCartsModelArrayList?.get(i)?.ACTION.equals("L", ignoreCase = true) ||
                        topicCartsModelArrayList?.get(i)?.ACTION.equals("H", ignoreCase = true)
                    ) {
                        val jsonObject = JSONObject()
                        jsonObject.put("CART", topicCartsModelArrayList!![i]?.ACTION)
                        jsonObject.put("KEYID", topicCartsModelArrayList!![i]?.KEYID)
                        jsonArray.put(jsonObject)
                    }
                }
                val retrofitNetworkInterface = RetrofitClient.createService(
                    RetrofitNetworkInterface::class.java
                )
                val saveCardsObject = JsonObject()
                saveCardsObject.addProperty(
                    "userid", Preference(
                        activity
                    ).getPref(Constants.USERID)
                )
                saveCardsObject.addProperty("topicid", topicId)
                saveCardsObject.addProperty("topiccarts", jsonArray.toString())
                val header: MutableMap<String, String> = HashMap()
                header["X-ACCESS-KEY"] = BuildConfig.APP_ID
                header["Token"] = Preference(getApplicationContext()).getPref(Constants.token)
                val call = retrofitNetworkInterface.saveCards(header, saveCardsObject)
                call.enqueue(object : Callback<ResponseBody?> {

                    override fun onResponse(
                        call: Call<ResponseBody?>, response: Response<ResponseBody?>
                    ) {
                        if (response.code() == 200) {

                            if (response.body() != null) {
                                Preference(activity).saveIntPref(Constants.TOPICID, topicId)
                                userInterests()
                                profilePopupDialog.dismiss()
                                profilePopupBinding.progress.gone()
                                findNavController().navigate(R.id.action_profileFragment_to_usersDiscussions)

//                                getLikeMindedCount(
//                                    topicId.toString(),
//                                    Preference(activity).getPref(Constants.USERID),
//                                    who
//                                )
//                                DashBoard.isFirstTimeLogin = false
                            }
                        } else Toast.makeText(
                            context, getString(R.string.something_went_wrong), Toast.LENGTH_SHORT
                        ).show()
                    }

                    override fun onFailure(call: Call<ResponseBody?>, t: Throwable) {
                        Toast.makeText(
                            context, getString(R.string.internal_error_occured), Toast.LENGTH_SHORT
                        ).show()
                    }
                })
            } else {
                Toast.makeText(context, "Please Select Something", Toast.LENGTH_SHORT).show()
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun callInitialKWSApi(start: Int, end: Int) {
        profileViewModel.showFreshContent(
            ShowFreshContentRequest(
                start, end, Preference(activity).getPref(Constants.USERID)
            )
        )
    }

    private fun showInitialDiscussionsObserver() {
        profileViewModel.showFreshContentResponseLiveData.observe(viewLifecycleOwner) { it ->
            when (it) {
                is NetworkResult.Success -> {
                    profilePopupBinding.progress.gone()

                    it.data?.data?.forEach {
                        it?.ACTION = ""
                    }
                    topicCartsModelArrayList?.addAll(it.data?.data as Collection<ShowFreshContentResponse.Data?>)
                    profilePopupAdapter?.updateList(topicCartsModelArrayList)
                }

                is NetworkResult.Error -> {
                    requireContext().toast(it.message.toString())
                }

                is NetworkResult.Loading -> {
                    profilePopupBinding.progress.visible()
                }

            }
        }
    }

    private fun setUpProfilePopupAdapter() {
        profilePopupAdapter = ProfilePopupAdapter(requireActivity(), this)
        { position, topicCartsModelArrayList1 ->
            topicCartsModelArrayList = topicCartsModelArrayList1
            if (isSomeThingSelected) {
                btnJoinDiscusion?.background =
                    ContextCompat.getDrawable(
                        requireContext(),
                        R.drawable.button_round_corner
                    )
                btnJoinDiscusion?.isEnabled = true
            } else {
                btnJoinDiscusion?.background =
                    ContextCompat.getDrawable(
                        requireContext(),
                        R.drawable.button_round_gray
                    )
                btnJoinDiscusion?.isEnabled = true
            }
        }

        profilePopupBinding.topicsRv.adapter = profilePopupAdapter

    }


    private fun handleSwitchEvent() {
        try {
            if (chatSwitch?.isChecked == true) {
                if (UserUtils.isGuestUser(context)) {
                    //            chattext.setVisibility(View.GONE);
                    chatSwitch?.isChecked = false
                    chatSwitch?.text = getString(R.string.disable_chats)
                    UserUtils.showConfirmation(activity)
                } else {
                    chattext?.visible()
                    chattext?.setOnClickListener {
                        val intent = Intent(activity, AllConversationsActivity::class.java)
                        startActivity(intent)
                    }
                    chatSwitch?.text = getString(R.string.enable_chats)
                    setChatToggleForCurrentUser(getString(R.string.flay_Y))
                }
            }
            chatSwitch?.setOnCheckedChangeListener { buttonView, isChecked ->
                if (isChecked) {
                    if (UserUtils.isGuestUser(context)) {
//                        chattext.setVisibility(View.GONE);
                        chatSwitch?.isChecked = false
                        chatSwitch?.text = getString(R.string.disable_chats)
                        UserUtils.showConfirmation(activity)
                    } else {
                        chattext?.visible()
                        chattext?.setOnClickListener {
                            val intent = Intent(activity, AllConversationsActivity::class.java)
                            startActivity(intent)
                        }
                        chatSwitch?.text = getString(R.string.enable_chats)
                        setChatToggleForCurrentUser(getString(R.string.flay_Y))
                    }
                } else {
                    chatSwitch?.isChecked = false
                    chattext?.gone()
                    chatSwitch?.text = getString(R.string.disable_chats)
                    setChatToggleForCurrentUser(getString(R.string.flay_N))
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun setChatToggleForCurrentUser(chatFlag: String) {
        try {
            val retrofitNetworkInterface = RetrofitClient.createService(
                RetrofitNetworkInterface::class.java
            )
            val jsonObject = JsonObject()
            jsonObject.addProperty("userid", Preference(activity).getPref(Constants.USERID))
            jsonObject.addProperty("chatflag", chatFlag)
            val header: MutableMap<String, String> = HashMap()
            header["X-ACCESS-KEY"] = BuildConfig.APP_ID
            header["Token"] = Preference(getApplicationContext()).getPref(Constants.token)
            val call = retrofitNetworkInterface.setUserChatFlag(header, jsonObject)
            call.enqueue(object : Callback<BaseResponse?> {
                override fun onResponse(
                    call: Call<BaseResponse?>, response: Response<BaseResponse?>
                ) {
                    if (response.code() == 200) {
                        if (response.body() != null) {
                            if (response.body()!!.status == getString(R.string.success_status)) {
                                ActivityFragment.refresh = true
                                if (chatFlag == getString(R.string.flay_Y)) Preference(
                                    activity
                                ).saveBooleanPref(Constants.ISCHATENABLED, true) else Preference(
                                    activity
                                ).saveBooleanPref(Constants.ISCHATENABLED, false)
                            }
                        }
                    }
                }

                override fun onFailure(call: Call<BaseResponse?>, t: Throwable) {}


            })
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        callbackManager1 = create()
    }

    private fun checkForUsernameValidity(
        usernameTv: TextView, facebookBut: Button, googleBut: Button
    ) {
        val retrofitNetworkInterface = RetrofitClient.createService(
            RetrofitNetworkInterface::class.java
        )
        val checkUsernameRequest = CheckUsernameRequest(usernameET!!.text.toString())
        val call = retrofitNetworkInterface.checkUsername(checkUsernameRequest)
        call.enqueue(object : Callback<List<BaseResponse?>?> {
            override fun onResponse(
                call: Call<List<BaseResponse?>?>, response: Response<List<BaseResponse?>?>
            ) {
                if (response.body()!![0]?.status == "Username Available") {
                    usernameTv.setTextColor(resources.getColor(android.R.color.holo_green_light))
                    usernameET!!.setCompoundDrawablesWithIntrinsicBounds(
                        0, 0, R.drawable.ic_verified_green, 0
                    )
                    usernameTv.text = response.body()!![0]?.status
                    facebookBut.isEnabled = true
                    googleBut.isEnabled = true
                } else {
                    facebookBut.isEnabled = false
                    googleBut.isEnabled = false
                    usernameTv.setTextColor(resources.getColor(android.R.color.holo_red_dark))
                    usernameET!!.setCompoundDrawablesWithIntrinsicBounds(
                        0, 0, R.drawable.ic_verified_user, 0
                    )
                    usernameTv.text = response.body()!![0]?.status
                }
            }

            override fun onFailure(call: Call<List<BaseResponse?>?>, t: Throwable) {}


        })
    }

    private fun GraphResult(account: GoogleSignInAccount) {
        try {
            Preference(activity).savePref(Constants.USERID, "")
            Preference(activity).saveIntPref(Constants.LOGGEDIN, 0)
            Preference(activity).savePref(Constants.GUESTUSER, "0")
            Preference(activity).savePref(Constants.PROFILEIMAGE, "profileurl")
            Preference(activity).savePref(Constants.REFFERED, "false")
            Preference(getApplicationContext()).savePref(Constants.USERNAME, username)
            Preference(getApplicationContext()).savePref(
                Constants.COUNTRYCODE, Preference(
                    activity
                ).getPref(Constants.COUNTRYCODE)
            )
            // new Preference(getApplicationContext()).saveIntPref(Constants.ISFB, 0);
            val userName = Objects.requireNonNull(usernameET!!.text).toString()
            Preference(getApplicationContext()).savePref(Constants.DEVICENAME, userName)
            Preference(getApplicationContext()).savePref(Constants.CONVERTED, "1")
            val intent = Intent(getApplicationContext(), LoginFbUser::class.java)
            intent.putExtra("providertype", account.account?.type)
            intent.putExtra("username", account.displayName)
            intent.putExtra("fname", account.givenName)
            intent.putExtra("lname", account.displayName)
            intent.putExtra("google_email", account.email)
            intent.putExtra("Google_username", account.displayName)
            intent.putExtra("Google_userid", account.id)
            if (Uri.EMPTY != account.photoUrl) intent.data = account.photoUrl
            startActivity(intent)
            requireActivity().finish()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun GraphResult(accessToken: AccessToken?, loginResult: LoginResult) {
        val request =
            GraphRequest.newMeRequest(accessToken, object : GraphRequest.GraphJSONObjectCallback {
                override fun onCompleted(
                    `object`: JSONObject?, response: GraphResponse?
                ) {
                    // Application code
                    Preference(getApplicationContext()).saveIntPref(Constants.ISFB, 1)
                    try {
                        Preference(activity).savePref(Constants.USERID, "")
                        Preference(activity).saveIntPref(Constants.LOGGEDIN, 0)
                        Preference(activity).savePref(Constants.REFFERED, "false")
                        Preference(getApplicationContext()).savePref(Constants.CONVERTED, "1")
                        Preference(activity).savePref(Constants.GUESTUSER, "0")
                        Preference(activity).savePref(Constants.PROFILEIMAGE, "")
                        Preference(getApplicationContext()).savePref(Constants.USERNAME, username)
                        Preference(getApplicationContext()).savePref(
                            Constants.COUNTRYCODE, Preference(
                                activity
                            ).getPref(Constants.COUNTRYCODE)
                        )
                        // new Preference(getApplicationContext()).saveIntPref(Constants.ISFB, 0);
                        Preference(getApplicationContext()).savePref(
                            Constants.DEVICENAME, usernameET?.text.toString()
                        )
                        val intent = Intent(getApplicationContext(), LoginFbUser::class.java)
                        intent.putExtra("fb_userid", loginResult.accessToken.userId)
                        intent.putExtra(
                            "fb_username", response?.getJSONObject()?.getString("name")
                        )
                        intent.putExtra("dp_url", loginResult.accessToken.userId)
                        intent.putExtra("providertype", "com.facebook")
                        startActivity(intent)
                        activity?.finish()
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                }
            })
        val parameters = Bundle()
        parameters.putString("fields", "id,name,first_name,last_name,email,gender")
        request.parameters = parameters
        request.executeAsync()
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        callbackManager1?.onActivityResult(requestCode, resultCode, data)
        if (requestCode == RC_SIGN_IN) {
            val task = GoogleSignIn.getSignedInAccountFromIntent(data)
            handleSignInResult(task)
        }
    }

    private fun handleSignInResult(completedTask: Task<GoogleSignInAccount>) {
        try {
            val account = completedTask.getResult(ApiException::class.java)
            GraphResult(account)
        } catch (e: Exception) {
            Log.d("sccscasc", "handleSignInResult: $e")
            //            Toast.makeText(getApplicationContext(), e.getMessage(), Toast.LENGTH_SHORT).show();
        }
    }

    fun userInterests() {

        if (!UserUtils.isGuestUser(activity)) {
            try {
//                chatSwitch!!.isChecked = Preference(activity).getBooleanPref(Constants.ISCHATENABLED)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
        profileViewModel.getInterests(
            UserInterestsRequest(
                Preference(getApplicationContext()).getPref(
                    Constants.USERID
                )
            )
        )

    }


    fun saveAllInterests() {
        val selectedTopicIdsString = selectedTopicIds.joinToString(",")
        profileViewModel.saveAllInterests(
            SaveAllUserInterestsRequest(
                selectedTopicIdsString, Preference(getApplicationContext()).getPref(
                    Constants.USERID
                )
            )
        )
    }

    private fun observeSaveAll() {
        profileViewModel.saveAllUserInterestsResponseLiveData.observe(viewLifecycleOwner) {
            when (it) {
                is NetworkResult.Success -> {
                    try {
                        if (showPopup) {
                            showDialog()
                        }
                        userInterests()
                        binding.progressBar?.gone()
                        Preference(requireActivity()).saveIntPref(
                            Constants.TOPICCARTID,
                            selectedTopicIds[0]?.toInt() ?: 9
                        )
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                }

                is NetworkResult.Error -> {
                    userInterests()
//                    Toast.makeText(requireContext(), it.message.toString(), Toast.LENGTH_SHORT)
//                        .show()
                }

                is NetworkResult.Loading -> {
                    binding.progressBar?.visible()
                }
            }
        }
    }


    private fun bindObservers() {
        profileViewModel.userInterestsResponseLiveData.observe(viewLifecycleOwner) {
            when (it) {
                is NetworkResult.Success -> {
                    binding.progressBar?.gone()
                    interestsList =
                        it.data?.data as MutableList<com.opinito.social.code_revamp.models.user_interests.response.Data?>?
                    topicsGridAdapter =
                        TopicsGridAdapter(
                            requireContext(),
                            interestsList,
                            onItemClick = { topicId, isTopicSelected, position ->
                                if (topicId != null) {
                                    if (isSelectionModeActive) {
                                        handleItemSelection(position)
                                    } else {
                                        if (isTopicSelected.equals("Y", true)) {
                                            Preference(requireActivity()).saveIntPref(
                                                Constants.TOPICCARTID,
                                                topicId.toInt()
                                            )
                                            findNavController().navigate(R.id.action_profileFragment_to_listFragment)
                                        } else {
//                                            showDialog(topicId.toInt())
                                        }
                                    }
                                }
                            },
                            onItemLongClick = { position ->
                                if (!isSelectionModeActive) {
                                    isSelectionModeActive = true
                                }
                                handleItemSelection(position)
                            }
                        )

                    binding.interestsGrid?.adapter = topicsGridAdapter
                }

                is NetworkResult.Error -> {
                    Toast.makeText(requireContext(), it.message.toString(), Toast.LENGTH_SHORT)
                        .show()
                }

                is NetworkResult.Loading -> {
                    binding.progressBar?.visible()
                }

            }
        }

    }

    private fun handleItemSelection(
        position: Int
    ) {
        val currentSelection = interestsList?.get(position)?.SLCT

        if (currentSelection == "Y") {
            interestsList?.get(position)?.SLCT = "N"
        } else {
            interestsList?.get(position)?.SLCT = "Y"
        }
        topicsGridAdapter.notifyDataSetChanged()
        updateSaveButtonState()
    }


    override fun onCreateOptionsMenu(menu: Menu, inflater: MenuInflater) {
        requireActivity().menuInflater.inflate(R.menu.menu_logout, menu)
        super.onCreateOptionsMenu(menu, inflater)
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        val id = item.itemId
        if (id == R.id.action_logout) {
            showLogoutConfirmation(getString(R.string.sure_to_logout))
            return true
        } else if (id == R.id.share) {
            DynamicLinksUtil.createDynamicUri(Constants.ZERO, Constants.ZERO, context, "", "", "")
            return true
        }
        return super.onOptionsItemSelected(item)
    }

    private fun showLogoutConfirmation(text: String) {
        val dialog = Dialog(requireContext())
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE)
        dialog.setContentView(R.layout.confirm_dialog)
        val dialogText = dialog.findViewById<TextView>(R.id.top_tv)
        dialogText.text = text
        val btnYes = dialog.findViewById<Button>(R.id.btnyes)
        val title = dialog.findViewById<TextView>(R.id.app_name_tv)
        dialog.window?.setBackgroundDrawableResource(android.R.color.transparent)
        val btnCancel = dialog.findViewById<Button>(R.id.btncancel)
        title.text = "Log out"
        title.visible()
        btnYes.setOnClickListener {
            dialog.dismiss()
            if (text == getString(R.string.sure_to_logout)) {
                UserUtils.logOutUser(activity)
                Preference(activity).saveIntPref(Constants.TOPICID, 0)
                Preference(activity).saveIntPref(Constants.TOPICCARTID, 0)
                Preference(activity).savePref(Constants.USERNAME, "")
                Preference(activity).savePref(Constants.PROVIDERTYPE, "")
                Preference(activity).savePref(Constants.PROFILEIMAGE, "")
                Preference(activity).savePref(Constants.date, "")
                val intent = Intent(activity, Login::class.java)
                startActivity(intent)
                requireActivity().finish()
            } else {
                val intent = Intent(activity, SwitchUserActivity::class.java)
                startActivity(intent)
                requireActivity().finish()
            }
        }
        btnCancel.setOnClickListener { dialog.dismiss() }
        dialog.setCanceledOnTouchOutside(false)
        dialog.show()
    }

    private fun changeCountryCodeCall(countryCodeSelected: String?) {
        selectedCountryCode = countryCodeSelected
        profileViewModel.changeCountryCode(
            ChangeCountryCodeRequest(
                countryCodeSelected, Preference(getApplicationContext()).getPref(Constants.USERID)
            )
        )
        Preference(getApplicationContext()).savePref(Constants.COUNTRYCODE, selectedCountryCode)
        binding.countryCode.text = selectedCountryCode
        try {
            binding.flagIvActivity.setImageDrawable(
                resources.getDrawable(
                    Customize.getCountryFlagRes(
                        selectedCountryCode, requireActivity()
                    )
                )
            )
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun countryCodeObserver() {
        profileViewModel.changeCountryCodeLiveData.observe(viewLifecycleOwner) {
            try {
                when (it) {
                    is NetworkResult.Success -> {
                        if (it.data?.status?.equals("success") == true) {
//                            Preference(getApplicationContext()).savePref(
//                                Constants.prevCode, Preference(getApplicationContext()).getPref(
//                                    Constants.COUNTRYCODE
//                                )
//                            )
//                            requireContext().toast(getString(R.string.country_code_updated))
//                            Preference(getApplicationContext()).savePref(
//                                Constants.COUNTRYCODE, selectedCountryCode
//                            )
//                            binding.countryCode.text = selectedCountryCode
//                            binding.flagIvActivity.setImageDrawable(
//                                resources.getDrawable(
//                                    Customize.getCountryFlagRes(
//                                        selectedCountryCode, requireActivity()
//                                    )
//                                )
//                            )
                        }
                    }

                    is NetworkResult.Error -> {
                        requireContext().toast(it.message.toString())
                    }

                    is NetworkResult.Loading -> {
                    }
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    private fun showConfirmation() {
        val dialogBuilder = AlertDialog.Builder(
            requireActivity(), R.style.MyCustomDialogTheme
//                    dialogBuilder.requestWindowFeature(Window.FEATURE_NO_TITLE)
//                    dialogBuilder.window?.setBackgroundDrawableResource(android.R.color.transparent)
        )
        defaultCountryCode = Preference(getApplicationContext()).getPref(Constants.COUNTRYCODE)
        //setting up the custom view
        val dialogView = this.layoutInflater.inflate(R.layout.alert_country_code, null)
        dialogBuilder.setView(dialogView)
        val countryCodeSpinner =
            dialogView.findViewById<View>(R.id.select_country_code_spinner) as Spinner
        val confirmationText = dialogView.findViewById<TextView>(R.id.confirmation_tv)
        val buttonYes = dialogView.findViewById<Button>(R.id.btnyes)
        val buttonCancel = dialogView.findViewById<Button>(R.id.btncancel)
        countryCodeSpinner.onItemSelectedListener = object : OnItemSelectedListener {
            override fun onItemSelected(
                parent: AdapterView<*>, view: View, position: Int, id: Long
            ) {
                defaultCountryCode = if (parent.getItemAtPosition(position).toString() == getString(
                        R.string.global
                    )
                ) getString(R.string.GGG) else parent.getItemAtPosition(position).toString()
                if (defaultCountryCode != Preference(getApplicationContext()).getPref(Constants.COUNTRYCODE)) {
                    confirmationText.visible()
                    confirmationText.text = HtmlCompat.fromHtml(
                        String.format(
                            getString(R.string.confirmation_country_code_change),
                            parent.getItemAtPosition(position).toString()
                        ), HtmlCompat.FROM_HTML_SEPARATOR_LINE_BREAK_LIST_ITEM
                    )
                } else {
                    defaultCountryCode =
                        Preference(getApplicationContext()).getPref(Constants.COUNTRYCODE)
                    confirmationText.gone()
                }
            }

            override fun onNothingSelected(parent: AdapterView<*>?) {}
        }
        //adding the list of country codes
        val countryCodes: MutableList<String> = ArrayList()
        countryCodes.add(getString(R.string.ind))
        countryCodes.add(getString(R.string.usa))
        countryCodes.add(getString(R.string.global))
        val countryCodeAdapter =
            ArrayAdapter(requireContext(), android.R.layout.simple_spinner_item, countryCodes)
        countryCodeAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        countryCodeSpinner.adapter = countryCodeAdapter
        for (i in countryCodes.indices) {
            val selectedCode =
                if (countryCodes[i] == getString(R.string.global)) getString(R.string.GGG) else countryCodes[i]
            if (selectedCode == Preference(getApplicationContext()).getPref(Constants.COUNTRYCODE)) countryCodeSpinner.setSelection(
                i
            )
        }
        val alertDialog = dialogBuilder.create()
        alertDialog.setCancelable(false)
        alertDialog.setCanceledOnTouchOutside(false)
        //setting actions
        buttonCancel.setOnClickListener { alertDialog.dismiss() }
        buttonYes.setOnClickListener {
            alertDialog.dismiss()
            if (defaultCountryCode != Preference(getApplicationContext()).getPref(Constants.COUNTRYCODE)) {
                changeCountryCodeCall(defaultCountryCode)
            }
        }
        alertDialog.show()
    }

//    override fun onClick(v: View) {
//        if (v.id == R.id.privacy_iv) {
//            val intent = Intent(activity, TermsandConditions::class.java)
//            intent.putExtra(getString(R.string.privacy_policy), getString(R.string.privacy_policy))
//            startActivity(intent)
//        }
//    }

    private fun getLikeMindedCount(topicID: String, userId: String, s: String) {
        binding.progressBar?.visible()
        profilePopupBinding.progress.visible()
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
                    call: Call<List<MindCountModel?>?>, response: Response<List<MindCountModel?>?>
                ) {
                    if (response.code() == 200) {
                        binding.progressBar?.gone()
                        val factory = LayoutInflater.from(context)
                        try {
                            val dialogView = factory.inflate(R.layout.dailoglayout, null)
                            dialogView.elevation = 5f
                            val topicName = response.body()!![0]?.topicName.toString()
                            val dialogText = dialogView.findViewById<TextView>(R.id.text_dialog)
                            val skipText = dialogView.findViewById<TextView>(R.id.skip_text)
                            if (s == "switch") {
                                skipText.text = "Switch"
                            }
                            val text = response.body()!![0]?.let {
                                String.format(
                                    getString(R.string.like_minded_count), it.count, topicName
                                )
                            }
                            val styledText: Spanned? = text?.let {
                                HtmlCompat.fromHtml(
                                    it, HtmlCompat.FROM_HTML_SEPARATOR_LINE_BREAK_LIST_ITEM
                                )
                            }
                            dialogText.text = styledText
                            val dialog = AlertDialog.Builder(
                                activity!!, R.style.MyCustomDialogTheme
                            ).create()
                            dialog.setView(dialogView)
                            skipText.setOnClickListener {
                                if (s == "join") {
                                    dialog.dismiss()
                                    profilePopupDialog.dismiss()
                                    profilePopupBinding.progress.gone()
                                    findNavController().navigate(R.id.action_profileFragment_to_usersDiscussions)
                                    load = false
                                } else {
                                    userInterests()
                                    dialog.dismiss()
                                    profilePopupBinding.progress.gone()
                                    profilePopupDialog.dismiss()
                                }
                            }
                            dialog.setCancelable(false)
                            dialog.setCanceledOnTouchOutside(false)
                            dialog.show()
                            /*getAllTopics();
                            DisplayTopicsCarts(new Preference(getActivity()).getIntPref(Constants.TOPICCARTID));*/
                        } catch (e: Exception) {
                        }
                    }
                }

                override fun onFailure(call: Call<List<MindCountModel?>?>, t: Throwable) {
                    load = false
                    FeedFragment.load = false
//                    (activity as DashBoard?)!!.reloadFeedList()
//                    (activity as DashBoard?)!!.Tabselection(0)
                    Toast.makeText(context, "Snap! Something went wrong", Toast.LENGTH_SHORT).show()
                }
            })
        } catch (e: Exception) {
            Toast.makeText(context, "Snap! Something went wrong", Toast.LENGTH_SHORT).show()
            /*ProfileFragment.load = false;
                FeedFragment.load = false;
                DisplayTopicsCarts(new Preference(getActivity()).getIntPref(Constants.TOPICCARTID));
                ((DashBoard) getActivity()).reloadFeedList();
                ((DashBoard) getActivity()).Tabselection(0);*/
        }
    }

    private val isSomeThingSelected: Boolean
        get() {
            if (topicCartsModelArrayList?.size!! > 0) {
                for (topicCartsModel in topicCartsModelArrayList!!) {
                    if (topicCartsModel?.ACTION.equals(
                            "l", ignoreCase = true
                        ) || topicCartsModel?.ACTION.equals("h", ignoreCase = true)
                    ) {
                        return true
                    }
                }
            }
            return false
        }

    fun updateSaveButtonState() {
        val selectedItemCount = interestsList?.count { it?.SLCT == "Y" } ?: 0
        if (selectedItemCount >= 2) {
            binding.saveAll?.apply {
                isEnabled = true
                setBackgroundTintList(ContextCompat.getColorStateList(context, R.color.yellow))
            }
            showPopup = true
        } else {
            binding.saveAll?.apply {
                isEnabled = false
                setBackgroundTintList(ContextCompat.getColorStateList(context, R.color.gray))
            }
        }
        if (selectedItemCount < 2) {
            requireActivity().toast("Please select multiple interests.")
        }
    }


    private fun saveAllInterests(text: String) {
        val dialog = Dialog(requireContext())
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE)
        dialog.setContentView(R.layout.confirm_dialog)
        val dialogText = dialog.findViewById<TextView>(R.id.top_tv)
        dialogText.text = text
        val btnYes = dialog.findViewById<Button>(R.id.btnyes)
        val title = dialog.findViewById<TextView>(R.id.app_name_tv)
        dialog.window?.setBackgroundDrawableResource(android.R.color.transparent)
        val btnCancel = dialog.findViewById<Button>(R.id.btncancel)
        title.text = "Warning!"
        title.visible()
        btnYes.setOnClickListener {
//            showDialog()
            selectedTopicIds.clear()
            interestsList?.forEach { topic ->
                topic?.let {
                    if (it.SLCT == "Y") {
                        selectedTopicIds.add(it.TOPICID)
                    }
                }
            }
            saveAllInterests()
            binding.saveAll?.isEnabled = false
            binding.saveAll?.setBackgroundTintList(
                ContextCompat.getColorStateList(
                    requireContext(),
                    R.color.gray
                )
            )
            isSelectionModeActive = false
            dialog.dismiss()
        }
        btnCancel.setOnClickListener { dialog.dismiss() }
        dialog.setCanceledOnTouchOutside(false)
        dialog.show()
    }

    companion object {


        @JvmField
        var load = false

        @JvmField
        var refresh = false

        @JvmField
        var reload = false
        private const val RC_SIGN_IN = 101
    }

    override fun onClick(position: Int) {
        if (isSomeThingSelected) {
            val topicId = interestsList?.firstOrNull { it?.SLCT == "Y" }?.TOPICID
            binding.progressBar?.let { it1 -> savetoCart(topicId?.toInt() ?: 0, "li", it1) }

        } else {
            Toast.makeText(context, "Please Select Something", Toast.LENGTH_SHORT).show()
        }
    }

}