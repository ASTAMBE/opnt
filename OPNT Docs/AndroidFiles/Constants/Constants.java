package com.opinito.social.Constants;

/**
 * Updated by Ashish on 08/22/2020.
 */
public interface Constants {

    String from = "0";

    String to = "20";

    String IND = "IND";
    //Date format - DD/MM/YYYY
    String DATEOFEXPIRATION = "";
    String API_KEY = "yjnX5DWi1yKAlKmi2JU28RXVRg15vwffaID70w4o";
    String CONVERTED = "0";
    String DEVICENAME = "devicename";
    String UUID = "uuid";
    String PREFERENCE = "preference";
    String OLDONTOP = "OLDONTOP";
    String NEWONTOP = "NEWONTOP";
    String SORTORDER = "sortorder";

    String USERID = "userid";

    String token = "token";
    String KEY_LOGIN_TIME = "LoginTime";

    String TOPICID = "topicid";
    String ISCHATENABLED = "ischatenabled";
    String DEEPLINKTOPICID = "deeplinktopicid";
    String DEEPLINKCOUNTRYCODE = "deeplinkcountrycode";
    String DEEPLINKUSERNAME = "deeplinkusername";
    String DEEPLINKPOSTID = "deeplinkpostid";
    String ISDEEPLINK = "isdeeplink";
    String REFFERERUSERID = "reffereruserid";
    String TOPICCARTID = "topiccartid";
    String TOPICCARTIDTHREAD = "topiccartid";
    String COUNTRYCODE = "countrycode";
    String LOGGEDIN = "loggedin";
    String USERNAME = "username";
    String PROVIDERTYPE = "providertype";
    String ISFB = "ISFB";
    String GUESTUSER = "GUESTUSER";
    String ONE = "1";
    String ZERO = "0";
    String GUESTUSERCOUNTRY = "GUESTUSERCOUNTRY";
    String URL_TO_LOAD = "URL_TO_LOAD";
    String HOWTOUSE = "howtouse";
    String KEYWORD_DESCRIPTION = "keyworddescription";
    String KEYWORD = "keyword";
    String KEYWORD_TOPIC_ID = "keyword_topic_id";
    String IS_FROM_CREATE_TOPIC = "is_from_create_topic";
    String PROFILEIMAGE = "profileurl";
    String preference = "preference";
    String userLogin = "userLoginApp.php";
    String checkusername = "checkusername.php";
    String convertGuestUserAppNew = "convertGuestUserAppNew.php";
    String likemindcount = "likemindcount.php";
    String createFBUser = "createFBUserTokenApp.php";
    String getUserActivity = "getuseractivity.php";
    String getUserTopics = "getUserTopics.php";
    String isPreviouslyLoggedIn = "";
    String instream = "instreamNW.php";
//    String instreamNW = "getPostsByUserNameNW042021.php";
//    String instreamAnti = "getPostsByUserNameANTI042021.php";
    String instreamNW = "getInstreamNW.php";
    String instreamAnti = "getInstreamANTI.php";

    String getDiscussionsANTI = "getDiscussionsANTI.php";
    String getDiscussionsNW = "getDiscussionsNW.php";

    String instreamNameNW = "getPostsByUserNameNW042021.php";

    String instreamNameANTI = "getPostsByUserNameANTI042021.php";
    String profile = "profile.php";
    String newPost = "newPostWithMedia.php";
    String networkNamesByUsername = "networkNamesByUsername.php";
    String getNetworkDetails = "getNetworkDetails.php";
    String profilePosts = "profilePostsWithMedia.php";
    String insertUserCartsByTopic = "insertUserCartsByTopic.php";
    String getPostDetails = "getPostDetails.php";
//    String editComment = "editComment.php";
    String CommentOnPostNew = "CommentOnPostNew.php";
    String newCommentOnComment = "newCommentOnComment.php";
    String deleteComment = "deleteComment.php";
    String deletePost = "deletePost.php";
    String loginWithFBUser = "loginWithFBUserApp.php";
    String usernamelist = "usernamelist.php";
    String updatePost = "updatePost.php";
    String createGuestUserApp = "createGuestUserApp.php";
    String loginGuestUserApp = "loginGuestUserApp.php";
    String PLATFORM_VALUE = "android";
    String app_send_token_url = "saveDeviceToken.php";
    String app_save_last_platform_url = "saveLastPlatform.php";
    String getTopics = "getCartTopics.php";
    String getUserInterests = "getUserInterests.php";
    String searchTopic = "searchkeyword.php";
    String searchMultipleTopic = "searchMultiTopic.php";
    String addSearchTopicToCart = "addSearchKwToCart.php";
    String userPostSearch = "userPostSearch.php";
    String checkValidity = "checkNewKwOK.php";
    String checkLinkPreviewUrl = "scrape_checkurl.php";
    String createUserGoogle = "createGoogleUserTokenApp.php";
    String loginWithGoogleUser = "loginWithGoogleUserApp.php";
    String postLinkPreview = "insertWebURLData.php";
    String createKeyword = "createSearchKW.php";
    String SUCCESS = "success";
    String SHAREDTEXT = "sharedtext";
    String SHAREDIMAGEPATH = "sharedimagepath";
    String SHAREDVIDEOPATH = "sharedvideopath";
    String REFFERED = "false";
    String getPostCounts = "getPostCounts.php";
    String KOUserCommon = "KOUserCommon.php";
    String userContentReport = "userContentReport.php";
    String commentsByPostNW = "commentsByPostNW.php";
    String commentsByPostAnti = "commentsByPostANTI.php";
    String getCommentCount = "getCommentCount.php";
    String myCommentPosts = "myCommentPosts.php";
    String changeCountryCode = "changeCountryCode.php";
    String getUserCarts = "getUserCarts.php";
    String saveUserCarts = "saveUserInterests.php";
    String copyUserCarts = "copyUserCarts.php";
    String whoLHMyPost = "whoLHMyPost.php";
    String userKWReport = "userKWReport.php";
    String FCM_TOKEN = "fcm_token";
    String userActionCommon = "userActionCommon.php";
    String setUserChatFlag = "setUserChatFlag.php";
    String getkocontent = "getkocontent.php";
    String suspendUser = "suspendUser.php";
    String NOTIFPOSTID = "notifpostid";
    String NOTIFUSERNAME = "notifusername";
    String createGoogleUserApp = "createGoogleUserTokenApp.php" ;
    String SERVER_URL = "https://dev-api.opinito.com/api.dev/" ;
    String postBookmark = "postBookmark.php" ;
    String removeBookmark = "removeBookmark.php" ;
    String myBookmark = "myBookmarks.php" ;
    String myActivity = "myActivity.php";
    String date="latestKeyworddate";
    String latestKeyword = "suggestKW.php";
    String getCountrycode="getCountryCodeFromIp.php";
    String prevCode="prevCode";

    String PREV_USER ="prevUserId" ;

    String getInitialKWS = "showInitialDiscussions.php";
    String deleteAccount = "deleteUserByUsername.php";
    String showFreshContent = "showFreshContent.php";
}
