package com.opinito.social.Activity

import android.app.Activity
import android.app.Dialog
import android.content.Context
import android.content.Intent
import android.content.IntentSender
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Parcelable
import android.text.TextUtils
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.view.Window
import android.widget.AbsListView
import android.widget.Button
import android.widget.TextView
import android.widget.Toast
import androidx.activity.viewModels
import androidx.annotation.RequiresApi
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.navigation.findNavController
import androidx.navigation.ui.setupWithNavController
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.facebook.FacebookSdk
import com.google.android.gms.tasks.OnCompleteListener
import com.google.android.gms.tasks.Task
import com.google.android.material.bottomnavigation.BottomNavigationView
import com.google.android.play.core.appupdate.AppUpdateInfo
import com.google.android.play.core.appupdate.AppUpdateManager
import com.google.android.play.core.appupdate.AppUpdateManagerFactory
import com.google.android.play.core.appupdate.AppUpdateOptions
import com.google.android.play.core.install.InstallStateUpdatedListener
import com.google.android.play.core.install.model.AppUpdateType
import com.google.android.play.core.install.model.InstallStatus
import com.google.android.play.core.install.model.UpdateAvailability
import com.google.firebase.messaging.FirebaseMessaging
import com.google.firebase.remoteconfig.FirebaseRemoteConfig
import com.google.firebase.remoteconfig.remoteConfigSettings
import com.google.gson.JsonObject
import com.opinito.social.Adapter.ProfilePopupAdapter
import com.opinito.social.Async.SaveLastPlatFormAsyncTask
import com.opinito.social.BuildConfig
import com.opinito.social.Constants.Constants
import com.opinito.social.Constants.Preference
import com.opinito.social.Fragment.ActivityFragment
import com.opinito.social.Fragment.FeedFragment
import com.opinito.social.Fragment.ListFragment
import com.opinito.social.Fragment.ProfileFragment
import com.opinito.social.Fragment.SendPostFragment
import com.opinito.social.Interface.CommonInterface
import com.opinito.social.Interface.RetrofitNetworkInterface
import com.opinito.social.Model.CopyUserCartsModel
import com.opinito.social.Model.ListLatestKeyword
import com.opinito.social.R
import com.opinito.social.R.id
import com.opinito.social.R.layout
import com.opinito.social.R.string
import com.opinito.social.R.style
import com.opinito.social.RetrofitClient
import com.opinito.social.SessionManager
import com.opinito.social.Utils.FileUtil
import com.opinito.social.Utils.LatestKeyCall
import com.opinito.social.Utils.UserUtils
import com.opinito.social.Utils.customToolBar
import com.opinito.social.Utils.gone
import com.opinito.social.Utils.toast
import com.opinito.social.Utils.visible
import com.opinito.social.code_revamp.models.showFreshContent.ShowFreshContentRequest
import com.opinito.social.code_revamp.models.showFreshContent.ShowFreshContentResponse
import com.opinito.social.code_revamp.models.user_interests.request.UserInterestsRequest
import com.opinito.social.code_revamp.network_layer.NetworkResult
import com.opinito.social.code_revamp.view_models.MainViewModel
import com.opinito.social.databinding.DashboardBinding
import com.opinito.social.databinding.ProfilePopupBinding
import dagger.hilt.android.AndroidEntryPoint
import okhttp3.ResponseBody
import org.json.JSONArray
import org.json.JSONObject
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale


/**
 * Updated by Ashish on 5/15/2020.
 */
@AndroidEntryPoint
class DashBoard : AppCompatActivity(),ProfilePopupAdapter.OnClickListener {
    lateinit var binding: DashboardBinding
    private var sharedText: String? = ""
    private var sharedPref: Preference? = null
    private var keywordscall: LatestKeyCall? = null
    private var arrlistLatestKeywords: ArrayList<ListLatestKeyword>? = null
    private var mFirebaseRemoteConfig: FirebaseRemoteConfig? = null
    private val firebaseDefaultMap: HashMap<String, Any>? = null
    private var back_pressed: Long = 0
    var date: String? = null
    private var storedDate: String? = null
    private val mainViewModel by viewModels<MainViewModel>()
    private var appUpdateManager: AppUpdateManager? = null
    private var installStateUpdatedListener: InstallStateUpdatedListener? = null
    private lateinit var sessionManager: SessionManager
    private lateinit var remoteConfig: FirebaseRemoteConfig

    /////
    private lateinit var profilePopupBinding: ProfilePopupBinding
    private var profilePopupAdapter: ProfilePopupAdapter? = null
    private var scrollLimit = true
    private var isScrolling = false
    private var topicCartsModelArrayList: MutableList<ShowFreshContentResponse.Data?>? = ArrayList()
    private lateinit var profilePopupDialog: Dialog
    private var linearLayoutManager: LinearLayoutManager? = null
    private var currentItm: Int? = null
    private var scroledItem: Int? = null
    private var totalItm: Int = 0
    private var btnJoinDiscusion: Button? = null
    var start: Int = 0
    var end: Int = 20
    private var isSelectionModeActive = false
    var showPopup: Boolean = false
    var showFreshDialog: Boolean = true
    var userInterestsList: MutableList<com.opinito.social.code_revamp.models.user_interests.response.Data?>? =
        ArrayList()


    /////
    @RequiresApi(api = Build.VERSION_CODES.O)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(layout.dashboard)
        sessionManager = SessionManager(this)
        profilePopupBinding = ProfilePopupBinding.inflate(layoutInflater)
        showFreshContentObserver()
        allInterestsObserver()
        checkSession()
        setupRemoteConfig()
//        mainViewModel = ViewModelProvider(this).get(MainViewModel::class.java)
        val navHostFragment = this.findNavController(id.nav_host_fragment)
        val navView: BottomNavigationView = findViewById(id.bottom_nav_view)
        navView.setupWithNavController(navHostFragment)

        mFirebaseRemoteConfig = FirebaseRemoteConfig.getInstance()

        sharedPref = Preference(this)
        customToolBar(this, false, getString(string.discussion1), supportActionBar)
        Preference(applicationContext).saveIntPref(Constants.isPreviouslyLoggedIn, 1)
        val bundle = intent.extras
        if (bundle != null) {
            try {
                val topicId = bundle.getString("sourceId")
                if (topicId != null) {
                    Preference(this).saveIntPref(Constants.TOPICID, topicId.toInt())
                    Preference(this).saveIntPref(Constants.TOPICCARTID, topicId.toInt())
                }
                if (bundle.getString(Constants.USERNAME) != Preference(this).getPref(Constants.USERNAME)) {
//                    UserUtils.showUserConfirmation(this, bundle.getString(Constants.USERNAME), null);
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }

        saveLastPlatformOnServer()
        checkIntent(211)
        if (checkLatestKeywordApiCall() || checkCountryCode() || checkUser()) {
//            latestKeyword

        }

        val lastRunDate = Preference(applicationContext).getPref(Constants.date)
        val today = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(Date())
        mainViewModel.getInterests(
            UserInterestsRequest(
                Preference(applicationContext).getPref(
                    Constants.USERID
                )
            )
        )
        if (lastRunDate != today) {
            topicCartsModelArrayList?.clear()
            showFreshContent(start, end)
            Preference(applicationContext).savePref(Constants.date, today)
        }
    }


    fun allInterestsObserver() {
        mainViewModel.userInterestsResponseLiveData.observe(this) {
            when (it) {
                is NetworkResult.Success -> {
                    if (it.data?.data?.any { it?.SLCT == "Y" } == false) {
                        val navController = findNavController(id.nav_host_fragment)
                        navController.navigate(id.action_usersDiscussions_to_profileFragment)
                    }
                }

                is NetworkResult.Error -> {

                }

                is NetworkResult.Loading -> {

                }

            }
        }
    }

    private fun checkSession() {
        if (sessionManager.isSessionExpired()) {
            showSessionExpiredPopup()
        } else {
//             Session is valid, continue with app
        }
    }


    private fun showSessionExpiredPopup() {
        val dialog = Dialog(this)
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE)
        dialog.setContentView(layout.confirm_dialog)
        val dialogText = dialog.findViewById<TextView>(id.top_tv)
        dialogText.text = "Your session has expired. Please log in again."
        dialog.window?.setBackgroundDrawableResource(android.R.color.transparent)
        val btnYes = dialog.findViewById<Button>(id.btnyes)
        val btnCancel = dialog.findViewById<Button>(id.btncancel)
        btnCancel.gone()
        btnYes.setOnClickListener {
            sessionManager.clearSession()
            UserUtils.logOutUser(this)
            Preference(this).saveIntPref(Constants.TOPICID, 0)
            Preference(this).saveIntPref(Constants.TOPICCARTID, 0)
            Preference(this).savePref(Constants.USERNAME, "")
            Preference(this).savePref(Constants.PROVIDERTYPE, "")
            Preference(this).savePref(Constants.PROFILEIMAGE, "")
            val intent = Intent(this, Login::class.java)
            startActivity(intent)
            this.finish()
            dialog.dismiss()
        }
        dialog.setCanceledOnTouchOutside(false)
        dialog.show()
    }


    fun getValue(parameterKey: String?, defaultValue: String): String? {
        var value = mFirebaseRemoteConfig?.getString(parameterKey!!)
        if (TextUtils.isEmpty(value)) value = defaultValue
        return value
    }

    private fun checkIntent(a: Int) {
        Log.d("Dialog open", a.toString())
        //check and store the intent data
        if (!Preference(applicationContext).getBooleanPref(Constants.ISDEEPLINK)) {
            val action = intent.action
            val type = intent.type
            if (Intent.ACTION_SEND == action && type != null) {
                if (type.startsWith(getString(string.text_type))) {
                    sharedText = intent.getStringExtra(Intent.EXTRA_TEXT)
                    if (sharedText != getString(string.sharedtext) && !sharedText!!.isEmpty()) if (!sharedText!!.contains(
                            "opinito"
                        ) && !sharedText!!.contains("https://graph.facebook.com/") && !sharedText!!.contains(
                            "Opinito"
                        ) && !sharedText!!.contains("OPINITO")
                    ) Preference(applicationContext).savePref(Constants.SHAREDTEXT, sharedText)
                } else {
                    if (type.startsWith(getString(string.image_type))) {
                        val sharedImageUri =
                            intent.getParcelableExtra<Parcelable>(Intent.EXTRA_STREAM).toString()
                        Preference(applicationContext).savePref(
                            Constants.SHAREDIMAGEPATH, sharedImageUri
                        )
                    } else {
                        if (type.startsWith(getString(string.video_type))) {
                            try {
                                val videoUri =
                                    intent.getParcelableExtra<Parcelable>(Intent.EXTRA_STREAM) as Uri?
                                val length = FileUtil.from(this, videoUri).length() / 1024 / 1024
                                if (length > 1000) {
                                    Toast.makeText(
                                        this, string.video_max_size_reached, Toast.LENGTH_SHORT
                                    ).show()
                                } else {
                                    val sharedVideoUri = intent.getParcelableExtra<Parcelable>(
                                        Intent.EXTRA_STREAM
                                    ).toString()
                                    Preference(applicationContext).savePref(
                                        Constants.SHAREDVIDEOPATH, sharedVideoUri
                                    )
                                }
                            } catch (e: IOException) {
                                val sharedVideoUri =
                                    intent.getParcelableExtra<Parcelable>(Intent.EXTRA_STREAM)
                                        .toString()
                                Preference(applicationContext).savePref(
                                    Constants.SHAREDVIDEOPATH, sharedVideoUri
                                )
                            }
                        }
                    }
                }
            } else {
                if (Intent.ACTION_SEND_MULTIPLE == action && type != null) {
                    val sharedImageList = ArrayList<String>()
                    if (intent.getParcelableArrayListExtra<Parcelable>(Intent.EXTRA_STREAM)!!.size < 5) {
                        for (i in intent.getParcelableArrayListExtra<Parcelable>(Intent.EXTRA_STREAM)!!.indices) {
                            sharedImageList.add(
                                intent.getParcelableArrayListExtra<Parcelable>(Intent.EXTRA_STREAM)!![i].toString()
                            )
                        }
                        var imageList: String? = null
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            imageList = java.lang.String.join(",", sharedImageList)
                        }
                        Preference(applicationContext).savePref(
                            Constants.SHAREDIMAGEPATH, imageList
                        )
                    } else Toast.makeText(this, string.upload_4_images_only, Toast.LENGTH_LONG)
                        .show()
                }
            }
            // check if the user is logged in
            if (Preference(applicationContext).getIntPref(Constants.LOGGEDIN) != 0 && Preference(
                    applicationContext
                ).getPref(Constants.USERID) != ""
            ) {
                if (!Preference(applicationContext).getPref(Constants.SHAREDTEXT).trim { it <= ' ' }
                        .isEmpty() || !Preference(applicationContext).getPref(Constants.SHAREDVIDEOPATH)
                        .trim { it <= ' ' }.isEmpty() || !Preference(applicationContext).getPref(
                        Constants.SHAREDIMAGEPATH
                    ).trim { it <= ' ' }.isEmpty()
                ) {
                    if (UserUtils.isGuestUser(this)) {
                        UserUtils.showConfirmation(this)
                    } else {
                        if (!Preference(applicationContext).getPref(Constants.SHAREDTEXT)
                                .trim { it <= ' ' }.isEmpty()
                        ) {
                            Log.d("dialogCall", "336")
                            showConfirmation(
                                Preference(
                                    applicationContext
                                ).getPref(Constants.SHAREDTEXT), getString(string.text_type)
                            )
                        } else {
                            if (!Preference(applicationContext).getPref(Constants.SHAREDIMAGEPATH)
                                    .trim { it <= ' ' }.isEmpty()
                            ) {
                                try {
                                    Log.d("dialogCall", "341")
                                    showConfirmation(
                                        intent.getParcelableArrayListExtra<Parcelable>(Intent.EXTRA_STREAM)!!.size.toString(),
                                        getString(string.image_type)
                                    )
                                } catch (ex: Exception) {
                                    Log.d("dialogCall", "345")
                                    showConfirmation(ONE, getString(string.image_type))
                                }
                            } else if (!Preference(applicationContext).getPref(Constants.SHAREDVIDEOPATH)
                                    .trim { it <= ' ' }.isEmpty()
                            ) {
                                Log.d("dialogCall", "349")
                                showConfirmation(ONE, getString(string.video_type))
                            }
                        }
                    }
                }
            } else {
                Toast.makeText(applicationContext, string.must_be_logged_in, Toast.LENGTH_SHORT)
                    .show()
                val intent = Intent(this, Login::class.java)
                startActivity(intent)
                finish()
            }
        } else {
            if (Preference(applicationContext).getIntPref(Constants.HOWTOUSE) == 0) copyUserCart("NEW") else copyUserCart(
                "OLD"
            )/*else {
                if (!new Preference(DashBoard.this).getPref(Constants.DEEPLINKPOSTID).equals(Constants.ZERO)) {
                    Toast.makeText(this,
                            String.format(getString(R.string.referred_string),
                                    new Preference(DashBoard.this).getPref(Constants.DEEPLINKUSERNAME)),
                            Toast.LENGTH_LONG).show();
                    Intent intent = new Intent(DashBoard.this, Comments.class);
                    intent.putExtra(POSTID, new Preference(DashBoard.this).getPref(Constants.DEEPLINKPOSTID));
                    startActivity(intent);
                } else {
                    if (!String.valueOf(new Preference(DashBoard.this).getIntPref(Constants.DEEPLINKTOPICID)).equals(Constants.ZERO)) {
                        new Preference(DashBoard.this).saveIntPref(Constants.TOPICID,
                                new Preference(DashBoard.this).getIntPref(Constants.DEEPLINKTOPICID));
                        new Preference(DashBoard.this).saveIntPref(Constants.TOPICCARTID,
                                new Preference(DashBoard.this).getIntPref(Constants.DEEPLINKTOPICID));
                        try {
                            reloadFeedList();
                            Tabselection(1);
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                }
                ActivityFragment.refresh = true;
                ListFragment.load = false;
                ProfileFragment.refresh = true;
                SendPostFragment.load = true;
                UserUtils.clearRefferalPrefs(DashBoard.this);
            }*/
        }
    }

    private fun copyUserCart(type: String) {
        try {
            val retrofitNetworkInterface = RetrofitClient.createService(
                RetrofitNetworkInterface::class.java
            )
            val jsonObject = JsonObject()
            jsonObject.addProperty("userFrom", Preference(this).getPref(Constants.REFFERERUSERID))
            jsonObject.addProperty("userTo", Preference(this).getPref(Constants.USERID))
            jsonObject.addProperty("postid", Preference(this).getPref(Constants.DEEPLINKPOSTID))
            jsonObject.addProperty("uType", type)
            val header: MutableMap<String, String> = HashMap()
            header["X-ACCESS-KEY"] = BuildConfig.APP_ID
            header["Token"] = Preference(applicationContext).getPref(Constants.token)
            val call = retrofitNetworkInterface.copyUserCarts(header, jsonObject)
            call.enqueue(object : Callback<CopyUserCartsModel?> {
                override fun onResponse(
                    call: Call<CopyUserCartsModel?>, response: Response<CopyUserCartsModel?>
                ) {
                    if (response.code() == 200) {
                        if (response.body() != null) {
                            if (response.body()!!.status == getString(string.success_status)) {
                                Toast.makeText(
                                    this@DashBoard, String.format(
                                        getString(string.referred_string),
                                        Preference(this@DashBoard).getPref(Constants.DEEPLINKUSERNAME)
                                    ), Toast.LENGTH_LONG
                                ).show()
                                Preference(this@DashBoard).saveIntPref(
                                    Constants.TOPICID, response.body()!!.data[0].tidto.toInt()
                                )
                                Preference(this@DashBoard).saveIntPref(
                                    Constants.TOPICCARTID, response.body()!!.data[0].tidto.toInt()
                                )
                                if (Preference(this@DashBoard).getPref(Constants.DEEPLINKPOSTID) != Constants.ZERO) {
                                    val intent = Intent(this@DashBoard, Comments::class.java)
                                    intent.putExtra(
                                        POSTID, Preference(this@DashBoard).getPref(
                                            Constants.DEEPLINKPOSTID
                                        )
                                    )
                                    startActivity(intent)
                                } else {
                                    try {
//                                        reloadFeedList()
//                                        Tabselection(0)
                                    } catch (e: Exception) {
                                        e.printStackTrace()
                                    }
                                }
                            } else Toast.makeText(
                                this@DashBoard,
                                getString(string.something_went_wrong),
                                Toast.LENGTH_SHORT
                            ).show()
                        }
                    } else Toast.makeText(
                        this@DashBoard, getString(string.something_went_wrong), Toast.LENGTH_SHORT
                    ).show()
                    ActivityFragment.refresh = true
                    ListFragment.load = false
                    ProfileFragment.refresh = true
                    SendPostFragment.load = true
                    //clear refferal preferences
                    UserUtils.clearRefferalPrefs(this@DashBoard)
                }

                override fun onFailure(call: Call<CopyUserCartsModel?>, t: Throwable) {
                    //clear refferal preferences
                    UserUtils.clearRefferalPrefs(this@DashBoard)
                    Toast.makeText(
                        this@DashBoard, getString(string.internal_error_occured), Toast.LENGTH_SHORT
                    ).show()
                }
            })
        } catch (e: Exception) {
            //clear refferal preferences
            UserUtils.clearRefferalPrefs(this)
            Toast.makeText(
                this@DashBoard, getString(string.internal_error_occured), Toast.LENGTH_SHORT
            ).show()
            e.printStackTrace()
        }
    }


    private fun showConfirmation(content: String, type: String) {
        val dialogBuilder = AlertDialog.Builder(this, style.MyCustomDialogTheme)
        val inflater = this.layoutInflater
        val dialogView = inflater.inflate(layout.confirm_dialog, null)
        dialogBuilder.setView(dialogView)
        val dialogText = dialogView.findViewById<TextView>(id.top_tv)
        val descText = dialogView.findViewById<TextView>(id.description_tv)
        val btnYes = dialogView.findViewById<Button>(id.btnyes)
        val btnCancel = dialogView.findViewById<Button>(id.btncancel)
        val alertDialog = dialogBuilder.create()
        if (type != getString(string.navigation)) {
            if (type == getString(string.text_type)) {
                dialogText.setText(string.dialog_title)
                descText.visibility = View.VISIBLE
                descText.text = content
            } else if (type == getString(string.image_type)) dialogText.text = String.format(
                getString(
                    string.share_content_for_dialog
                ),
                content,
                if (content.toInt() > 1) getString(string.images) else getString(string.image)
            ) else dialogText.text = String.format(
                getString(
                    string.share_content_for_dialog
                ), content, getString(string.type_video)
            )
            btnYes.setOnClickListener {
                val navController = findNavController(id.nav_host_fragment)
                navController.popBackStack(id.usersDiscussions, true)
                navController.navigate(id.sendPostFragment)
//                Preference(applicationContext).savePref(Constants.SHAREDVIDEOPATH, "")
//                Preference(applicationContext).savePref(Constants.SHAREDTEXT, "")
//                Preference(applicationContext).savePref(Constants.SHAREDIMAGEPATH, "")
                alertDialog.dismiss()
            }
            btnCancel.setOnClickListener {
                Preference(applicationContext).savePref(Constants.SHAREDVIDEOPATH, "")
                Preference(applicationContext).savePref(Constants.SHAREDTEXT, "")
                Preference(applicationContext).savePref(Constants.SHAREDIMAGEPATH, "")
//                (adapter!!.getItem(2) as SendPostFragment).resetPostHolder()
                alertDialog.cancel()
            }
        } else {
            dialogText.text = getString(string.discard_post_title)
            descText.visibility = View.VISIBLE
            descText.text = content
            btnYes.setOnClickListener {
                alertDialog.dismiss()
//                (adapter!!.getItem(2) as SendPostFragment).resetPostHolder()
            }
            btnCancel.setOnClickListener {
//                Tabselection(2)
                alertDialog.cancel()
            }
        }
        alertDialog.setCancelable(false)
        alertDialog.setCanceledOnTouchOutside(false)
        if (!alertDialog.isShowing) {
            alertDialog.show()
        }
    }


    @RequiresApi(api = Build.VERSION_CODES.O)
    public override fun onResume() {
        super.onResume()
//        checkAppIsUpdate()
//        checkIntent(652)
        checkNewAppVersionState();
        FeedFragment.imageOpen = false
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterInstallStateUpdListener();
        Preference(this).saveBooleanPref(Constants.IS_FROM_CREATE_TOPIC, false)
        Preference(this).saveIntPref(Constants.TOPICID, 1)
    }

    fun editPost(postid: Long) {
        SendPostFragment().editComment(postid)
    }

    fun saveLastPlatformOnServer() {
        val commonInterface = CommonInterface { response ->
            var status = ""
            try {
                status = JSONObject(response).getString("status")
            } catch (e: Exception) {
                e.printStackTrace()
            }
            if (status.equals(Constants.SUCCESS, ignoreCase = true)) {
                sendFcmTokenToServer(this@DashBoard)
            }
        }
        SaveLastPlatFormAsyncTask(
            this, commonInterface
        ).execute(sharedPref!!.getPref(Constants.USERID))
    }

    //    public void sendFcmTokenToServer(Context context) {
    //        checkFCMTOKEN();
    //        final String token = new Preference(this).getPref(Constants.FCM_TOKEN);
    //        CommonInterface commonInterface = new CommonInterface() {
    //            @Override
    //            public void OnCommonInterface(String response) {
    //                try {
    //                    String status = new JSONObject(response).getString("status");
    //                } catch (JSONException e) {
    //                    e.printStackTrace();
    //                }
    //            }
    //        };
    //        new SaveDeviceTokenAsyncTask(this, commonInterface).execute(token, sharedPref.getPref(Constants.USERID));
    //    }
    fun sendFcmTokenToServer(context: Context?) {
        checkFCMTOKEN()
        val token = Preference(this).getPref(Constants.FCM_TOKEN)
        Log.d("FCMToken is", token)
        val retrofitNetworkInterface = RetrofitClient.createService(
            RetrofitNetworkInterface::class.java
        )
        val jsonObject = JsonObject()
        jsonObject.addProperty("device_token", token)
        jsonObject.addProperty("device_uuid", sharedPref!!.getPref(Constants.USERID))
        val call = retrofitNetworkInterface.sendFcmTokenApiCall(jsonObject)
        call.enqueue(object : Callback<ResponseBody?> {
            override fun onResponse(call: Call<ResponseBody?>, response: Response<ResponseBody?>) {
                if (response.code() == 200) {
                }
            }

            override fun onFailure(call: Call<ResponseBody?>, t: Throwable) {}
        })
    }

    private fun checkFCMTOKEN() {
        FirebaseMessaging.getInstance().token.addOnCompleteListener(OnCompleteListener { task ->
            if (!task.isSuccessful) {
                return@OnCompleteListener
            }
            val token = task.result
            Log.d("fcmtokengenerate", "onComplete: $token")
            Preference(applicationContext).savePref(Constants.FCM_TOKEN, token)
        })
    }


    override fun onBackPressed() {
        if (back_pressed + 1500 > System.currentTimeMillis()) {
            super.onBackPressed()
        } else {
            this.toast("Press once again to exit!")
        }
        back_pressed = System.currentTimeMillis()
    }


    private fun showFreshContent(from: Int, increment: Int) {
        mainViewModel.getLatestKW(
            ShowFreshContentRequest(
                from,
                increment,
                Preference(applicationContext).getPref(Constants.USERID)
            )
        )
    }

    fun showFreshContentObserver() {
        mainViewModel.suggestWKResponseLiveData.observe(this) {
            when (it) {
                is NetworkResult.Success -> {
                    Log.d("data", "Data successfully fetched: ${it.data}")
                    profilePopupBinding.progress.gone()

                    it.data?.data?.forEach {
                        it?.ACTION = ""
                    }
                    if (!it.data?.data.isNullOrEmpty()) {
                        start = start + it.data?.data?.size!!

                        if (showFreshDialog) {
                            showDialog()
                        }
                    }

                    topicCartsModelArrayList?.addAll(it.data?.data as Collection<ShowFreshContentResponse.Data?>)
                    profilePopupAdapter?.updateList(topicCartsModelArrayList)
                    profilePopupAdapter?.notifyDataSetChanged()
                }

                is NetworkResult.Error -> {
                    applicationContext.toast(it.message.toString())
                }

                is NetworkResult.Loading -> {

                }

            }
        }
    }


//    private fun showDialog(list: ArrayList<ListLatestKeyword>) {
//        val bottomSheet = BottomSheetDialog(list)
//        if (list.size != 0) {
//            bottomSheet.show(
//                this.supportFragmentManager, "ModalBottomSheet"
//            )
//        }
//    }

    private fun checkLatestKeywordApiCall(): Boolean {
        date = SimpleDateFormat("dd-MM-yyyy", Locale.getDefault()).format(Date())
        Log.d("taggy", date.toString())
        storedDate = Preference(FacebookSdk.getApplicationContext()).getPref(Constants.date)
        return if ((storedDate == date)) {
            false
        } else true
    }

    fun checkCountryCode(): Boolean {
        val prevCode = Preference(FacebookSdk.getApplicationContext()).getPref(Constants.prevCode)
        val currCode =
            Preference(FacebookSdk.getApplicationContext()).getPref(Constants.COUNTRYCODE)
        if ((prevCode == currCode)) {
            return false
        }
        Preference(FacebookSdk.getApplicationContext()).savePref(Constants.prevCode, currCode)
        return true
    }

    private fun checkUser(): Boolean {
        val currentUser = Preference(applicationContext).getPref(Constants.USERNAME)
        val prevUser = Preference(FacebookSdk.getApplicationContext()).getPref(Constants.PREV_USER)
        Log.d("taggy", "currentUser->$currentUser  prevUser-->$prevUser")
        if ((currentUser == prevUser)) {
            return false
        }
        Preference(FacebookSdk.getApplicationContext()).savePref(Constants.PREV_USER, currentUser)
        return true
    }


//    private val latestKeyword: Unit
//        get() {
//            keywordscall = LatestKeyCall()
//            arrlistLatestKeywords = ArrayList()
//            keywordscall?.getLatestKeyWord(FacebookSdk.getApplicationContext())?.observe(
//                this
//            ) { listLatestKeywords ->
//                //                Log.d("taggy", listLatestKeywords.get(0).getKEYWORDS());
//                try {
//                    arrlistLatestKeywords?.addAll(listLatestKeywords)
//                    val mDate = listLatestKeywords[0].date
//                    Preference(FacebookSdk.getApplicationContext()).savePref(Constants.date, mDate)
//                    showDialog(arrlistLatestKeywords!!)
//                } catch (e: Exception) {
//                    e.fillInStackTrace()
//                }
//            }
//        }

    companion object {
        @JvmField
        var movedToActivity = false
        private const val REQ_CODE_VERSION_UPDATE = 530

        @JvmField
        var isFirstTimeLogin = false
        const val ONE = "1"
        private const val POSTID = "postid"

        @JvmField
        var selectTab = 0
        private const val REQUEST_CODE_FLEXIBLE_UPDATE = 100
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, intent: Intent?) {
        super.onActivityResult(requestCode, resultCode, intent)
        when (requestCode) {
            REQ_CODE_VERSION_UPDATE -> if (resultCode != Activity.RESULT_OK) { //RESULT_OK / RESULT_CANCELED / RESULT_IN_APP_UPDATE_FAILED
                Log.d("Update failed code", requestCode.toString())
                // If the update is cancelled or fails,
                // you can request to start the update again.
                unregisterInstallStateUpdListener()
            }
        }
    }

    private fun setupRemoteConfig() {
        remoteConfig = FirebaseRemoteConfig.getInstance()
        val configSettings = remoteConfigSettings {
            minimumFetchIntervalInSeconds = 0 // Set the fetch interval
        }
        remoteConfig.setConfigSettingsAsync(configSettings)

        fetchRemoteConfig()
    }

    private fun fetchRemoteConfig() {
        remoteConfig.fetchAndActivate()
            .addOnCompleteListener(this) { task ->
                if (task.isSuccessful) {
                    val latestVersion = remoteConfig.getString("force_update_version")
                    val updateTypeString = remoteConfig.getString("force_update_type")
                    val appUpdateType = parseUpdateType(updateTypeString)
                    Log.d("force_update_version", latestVersion)
                    checkForAppUpdate(latestVersion, appUpdateType)
                }
            }
    }

    private fun parseUpdateType(updateTypeString: String): Int {
        return when (updateTypeString.uppercase()) {
            "IMMEDIATE" -> AppUpdateType.IMMEDIATE
            "FLEXIBLE" -> AppUpdateType.FLEXIBLE
            else -> AppUpdateType.IMMEDIATE
        }
    }


    private fun checkForAppUpdate(latestVersion: String, appUpdateType: Int) {
        // Get the current app version
        val currentVersion = BuildConfig.VERSION_NAME

        // Compare versions
        if (currentVersion == latestVersion) {
            // An update is available
            appUpdateManager = AppUpdateManagerFactory.create(applicationContext)
            val appUpdateInfoTask: Task<AppUpdateInfo>? = appUpdateManager?.appUpdateInfo

            appUpdateInfoTask?.addOnSuccessListener { appUpdateInfo ->
                if (appUpdateInfo.updateAvailability() == UpdateAvailability.UPDATE_AVAILABLE &&
                    appUpdateInfo.isUpdateTypeAllowed(appUpdateType)
                ) {
                    if (appUpdateType == AppUpdateType.IMMEDIATE) {
                        startAppUpdateImmediate(appUpdateInfo)
                    } else if (appUpdateType == AppUpdateType.FLEXIBLE) {
                        startAppUpdateFlexible(appUpdateInfo)
                    }
                }
            }
        }
    }

    private fun startAppUpdateImmediate(appUpdateInfo: AppUpdateInfo) {
        try {
            appUpdateManager?.startUpdateFlow(
                appUpdateInfo,
                this,
                AppUpdateOptions.newBuilder(AppUpdateType.IMMEDIATE)
                    .setAllowAssetPackDeletion(true)
                    .build()
            )
        } catch (e: IntentSender.SendIntentException) {
            e.printStackTrace()
        }
    }

    private fun startAppUpdateFlexible(appUpdateInfo: AppUpdateInfo) {
        try {
            appUpdateManager?.startUpdateFlowForResult(
                appUpdateInfo,
                AppUpdateType.FLEXIBLE,
                this,
                REQUEST_CODE_FLEXIBLE_UPDATE
            )
            registerInstallStateUpdatedListener()
        } catch (e: IntentSender.SendIntentException) {
            e.printStackTrace()
        }
    }

    private fun registerInstallStateUpdatedListener() {
        installStateUpdatedListener = InstallStateUpdatedListener { state ->
            if (state.installStatus() == InstallStatus.DOWNLOADED) {
                showCompleteUpdateDialog()
            }
        }
        appUpdateManager?.registerListener(installStateUpdatedListener!!)
    }

    private fun showCompleteUpdateDialog() {
        AlertDialog.Builder(this)
            .setTitle("Update Available")
            .setMessage("An update has been downloaded. Restart to complete the update.")
            .setPositiveButton("Restart") { _, _ ->
                appUpdateManager?.completeUpdate()
            }
            .setCancelable(false)
            .show()
    }

//    private fun showCompleteUpdateSnackbar() {
//        Snackbar.make(
//            findViewById(android.R.id.content),
//            "An update has been downloaded. Restart to complete the update.",
//            Snackbar.LENGTH_INDEFINITE
//        ).setAction("Restart") {
//            appUpdateManager?.completeUpdate()
//        }.show()
//    }

    /**
     * Checks that the update is not stalled during 'onResume()'.
     * However, you should execute this check at all app entry points.
     */
    private fun checkNewAppVersionState() {
        appUpdateManager?.appUpdateInfo?.addOnSuccessListener { appUpdateInfo: AppUpdateInfo ->
            if (appUpdateInfo.updateAvailability() == UpdateAvailability.DEVELOPER_TRIGGERED_UPDATE_IN_PROGRESS) {
                startAppUpdateImmediate(appUpdateInfo)
            }
        }
    }

    /**
     * Unregister the install state listener for flexible updates.
     */
    private fun unregisterInstallStateUpdListener() {
        try {
            appUpdateManager?.unregisterListener(installStateUpdatedListener!!)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }


    private fun showDialog() {
        showFreshDialog = false
        isScrolling = false
        scrollLimit = true
//        topicCartsModelArrayList?.clear()

        if (::profilePopupDialog.isInitialized.not()) {
            profilePopupDialog = Dialog(this)
            profilePopupDialog.requestWindowFeature(Window.FEATURE_NO_TITLE)
            profilePopupDialog.window?.setBackgroundDrawableResource(android.R.color.transparent)
            profilePopupDialog.setContentView(profilePopupBinding.root)
        }
        setUpProfilePopupAdapter()
        linearLayoutManager =
            LinearLayoutManager(this, LinearLayoutManager.VERTICAL, false)
        profilePopupBinding.topicsRv.layoutManager = linearLayoutManager
        btnJoinDiscusion = profilePopupBinding.joinDiscusion
        btnJoinDiscusion?.background = resources.getDrawable(R.drawable.button_round_gray)
        btnJoinDiscusion?.isEnabled = false



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
                        showFreshContent(start, end)
                    }
                }
            }
        })

        profilePopupBinding.btnCancel.setOnClickListener {
            isSelectionModeActive = false

            if (isSomeThingSelected) {
                showPopup = false
                val topicPopup = Dialog(this)
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
                savetoCart()
            } else {
                Toast.makeText(this, "Please Select Something", Toast.LENGTH_SHORT).show()
            }
        }
//        showFreshContent(start, end)
        profilePopupDialog.window!!.setLayout(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )
        profilePopupDialog.show()
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

    private fun setUpProfilePopupAdapter() {
        profilePopupAdapter = ProfilePopupAdapter(this,this)
        { position, topicCartsModelArrayList1 ->
            topicCartsModelArrayList = topicCartsModelArrayList1
            if (isSomeThingSelected) {
                btnJoinDiscusion?.background =
                    ContextCompat.getDrawable(
                        this,
                        R.drawable.button_round_corner
                    )
                btnJoinDiscusion?.isEnabled = true
            } else {
                btnJoinDiscusion?.background =
                    ContextCompat.getDrawable(
                        this,
                        R.drawable.button_round_gray
                    )
                btnJoinDiscusion?.isEnabled = true
            }
        }

        profilePopupBinding.topicsRv.adapter = profilePopupAdapter

    }

    private fun savetoCart() {
        try {
            isSelectionModeActive = false
            if (isSomeThingSelected) {
                val jsonArray = JSONArray()
                for (i in topicCartsModelArrayList?.indices!!) {
                    if (topicCartsModelArrayList?.get(i)?.ACTION.equals("L", ignoreCase = true) ||
                        topicCartsModelArrayList?.get(i)?.ACTION.equals("H", ignoreCase = true)
                    ) {

                        val jsonObject = JSONObject()
                        jsonObject.put("CART", topicCartsModelArrayList?.get(i)?.ACTION)
                        jsonObject.put("KEYID", topicCartsModelArrayList?.get(i)?.KEYID)
                        jsonArray.put(jsonObject)
                    }
                }
                val retrofitNetworkInterface = RetrofitClient.createService(
                    RetrofitNetworkInterface::class.java
                )
                val saveCardsObject = JsonObject()
                saveCardsObject.addProperty(
                    "userid", Preference(
                        applicationContext
                    ).getPref(Constants.USERID)
                )
                val topicId =
                    topicCartsModelArrayList?.firstOrNull { it?.ACTION == "L" || it?.ACTION == "H" }?.TOPICID
                saveCardsObject.addProperty("topicid", topicId)
                saveCardsObject.addProperty("topiccarts", jsonArray.toString())
                val header: MutableMap<String, String> = HashMap()
                header["X-ACCESS-KEY"] = BuildConfig.APP_ID
                header["Token"] =
                    Preference(FacebookSdk.getApplicationContext()).getPref(Constants.token)
                val call = retrofitNetworkInterface.saveCards(header, saveCardsObject)
                call.enqueue(object : Callback<ResponseBody?> {

                    override fun onResponse(
                        call: Call<ResponseBody?>, response: Response<ResponseBody?>
                    ) {
                        if (response.code() == 200) {

                            if (response.body() != null) {
//                                Preference(applicationContext).saveIntPref(Constants.TOPICID, topicId)

                                profilePopupDialog.dismiss()
                                profilePopupBinding.progress.gone()

//                                getLikeMindedCount(
//                                    topicId.toString(),
//                                    Preference(activity).getPref(Constants.USERID),
//                                    who
//                                )
//                                DashBoard.isFirstTimeLogin = false
                            }
                        } else Toast.makeText(
                            applicationContext,
                            getString(R.string.something_went_wrong),
                            Toast.LENGTH_SHORT
                        ).show()
                    }

                    override fun onFailure(call: Call<ResponseBody?>, t: Throwable) {
                        Toast.makeText(
                            applicationContext,
                            getString(R.string.internal_error_occured),
                            Toast.LENGTH_SHORT
                        ).show()
                    }
                })
            } else {
                Toast.makeText(applicationContext, "Please Select Something", Toast.LENGTH_SHORT)
                    .show()
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onClick(position: Int) {
        TODO("Not yet implemented")
    }

}

