package com.opinito.social.Interface;

import com.opinito.social.BuildConfig;
import com.google.gson.JsonObject;
import com.opinito.social.Constants.Constants;
import com.opinito.social.Model.AllNWCountModel;
import com.opinito.social.Model.BaseResponse;
import com.opinito.social.Model.CheckUsernameRequest;
import com.opinito.social.Model.CommentCountModel;
import com.opinito.social.Model.CommentModel;
import com.opinito.social.Model.ConvertGuestUserModel;
import com.opinito.social.Model.ConvertGuestUserRequest;
import com.opinito.social.Model.CopyUserCartsModel;
import com.opinito.social.Model.DeleteUserModel;
import com.opinito.social.Model.FbUserModel;
import com.opinito.social.Model.GetPostModelNew;
import com.opinito.social.Model.GetUserActivityModel;
import com.opinito.social.Model.GoogleCreateUserModel;
import com.opinito.social.Model.GoogleSigninRequest;
import com.opinito.social.Model.CreateGuestLoginModel;
import com.opinito.social.Model.LatestKeywordDataClass;
import com.opinito.social.Model.LikeMindedBodyRequest;
import com.opinito.social.Model.LoveHatePostCountModel;
import com.opinito.social.Model.MindCountModel;
import com.opinito.social.Model.MultiSearchTopicModel;
import com.opinito.social.Model.NetworkDetailsModel;
import com.opinito.social.Model.NetworkNameModel;
import com.opinito.social.Model.PopupGetInitialKWS;
import com.opinito.social.Model.ProfileInterestsModel;
import com.opinito.social.Model.ProfileModel;
import com.opinito.social.Model.SearchPostsModel;
import com.opinito.social.Model.TopicCartsModel;
import com.opinito.social.Model.TopicsModel;
import com.opinito.social.Model.TopicsModelNew;
import com.opinito.social.Model.UserKOContent;

import java.util.List;
import java.util.Map;

import okhttp3.MultipartBody;
import okhttp3.RequestBody;
import okhttp3.ResponseBody;
import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.GET;
import retrofit2.http.HeaderMap;
import retrofit2.http.Headers;
import retrofit2.http.Multipart;
import retrofit2.http.POST;
import retrofit2.http.Part;
import retrofit2.http.Query;
import retrofit2.http.Path;



public interface RetrofitNetworkInterface {

//    @Headers({
//            "x-api-key:" + Constants.API_KEY,
//            "X-ACCESS-KEY:" + BuildConfig.APP_ID
//    })
    @POST(Constants.profile)
    Call<List<ProfileModel>> profile(@HeaderMap Map<String, String> header, @Body JsonObject jsonObject);

//    @Headers({
//            "x-api-key:" + Constants.API_KEY,
//            "X-ACCESS-KEY:" + BuildConfig.APP_ID
//    })
    @POST(Constants.likemindcount)
    Call<List<MindCountModel>> getMindedCount(@HeaderMap Map<String, String> header, @Body LikeMindedBodyRequest likeMindedBodyRequest);

//    @Headers({
//            "x-api-key:" + Constants.API_KEY,
//            "X-ACCESS-KEY:" + BuildConfig.APP_ID
//    })
    @POST(Constants.networkNamesByUsername)
    Call<List<NetworkNameModel>> networkNamesByUsername(@HeaderMap Map<String, String> header, @Body JsonObject jsonObject);

    @Headers({
            "x-api-key:" + Constants.API_KEY,
            "X-ACCESS-KEY:" + BuildConfig.APP_ID
    })
    @POST(Constants.convertGuestUserAppNew)
    Call<ConvertGuestUserModel> convertGuestUserGogFb(@Body ConvertGuestUserRequest convertGuestUserRequest);

    @Headers({
            "x-api-key:" + Constants.API_KEY,
            "X-ACCESS-KEY:" + BuildConfig.APP_ID
    })
    @POST(Constants.checkusername)
    Call<List<BaseResponse>> checkUsername(@Body CheckUsernameRequest checkUsernameRequest);

    @Multipart
//    @Headers({
//            "x-api-key:" + Constants.API_KEY,
//            "X-ACCESS-KEY:" + BuildConfig.APP_ID
//    })
    @POST(Constants.newPost)
    Call<BaseResponse> newPost(@HeaderMap Map<String, String> header, @Part("message") RequestBody message,
                               @Part("country_code") RequestBody countryCode,
                               @Part("embedded_flag") RequestBody embeddedFlag,
                               @Part("userid") RequestBody userId,
                               @Part("topicid") RequestBody topicId,
                               @Part List<MultipartBody.Part> avatar,
                               @Part("embedded_content") RequestBody embeddedContent);

    @Multipart
    @Headers({
            "x-api-key:" + Constants.API_KEY,
            "X-ACCESS-KEY:" + BuildConfig.APP_ID
    })
    @POST(Constants.updatePost)
    Call<BaseResponse> updatePost(@Part("message") RequestBody message,
                                  @Part("embedded_flag") RequestBody embeddedFlag,
                                  @Part("userid") RequestBody userId,
                                  @Part("post_id") RequestBody topicId,
                                  @Part List<MultipartBody.Part> avatar,
                                  @Part("embedded_content") RequestBody embeddedContent);

//    @Headers({
//            "x-api-key:" + Constants.API_KEY,
//            "X-ACCESS-KEY:" + BuildConfig.APP_ID
//    })
    @POST(Constants.getUserTopics)
    Call<List<TopicsModel>> getUserTopics(@HeaderMap Map<String, String> header, @Body JsonObject jsonObject);



    @POST(Constants.latestKeyword)
    Call<LatestKeywordDataClass> getLatestKeyword(@HeaderMap Map<String, String> header, @Body JsonObject jsonObject);




    @POST(Constants.getUserCarts)
    Call<TopicCartsModel> getUserCarts(@HeaderMap Map<String, String> header, @Body JsonObject pref);

//    @Headers({
//            "x-api-key:" + Constants.API_KEY,
//            "X-ACCESS-KEY:" + BuildConfig.APP_ID
//    })
//    @POST(Constants.searchTopic)
//    Call<List<SearchTopicCartsModel>> searchTopic(@Body JsonObject jsonObject);

    @GET("{ip}/country/")
    Call<ResponseBody> getCountryFromIpApi(@Path("ip") String ip);  // Using ipapi.co

    @GET(Constants.deleteComment )

    Call<ResponseBody> deleteCommentApiCalling(@HeaderMap  Map<String, String> header, @Query("userid") String userId , @Query("comment_id") String commentId  );


    @POST(Constants.searchMultipleTopic)
    Call<List<MultiSearchTopicModel>> searchTopic(@HeaderMap  Map<String, String> header,@Body JsonObject pref);

    @Multipart
//    @Headers({
//            "x-api-key:" + Constants.API_KEY,
//            "X-ACCESS-KEY:" + BuildConfig.APP_ID
//    })
    @POST(Constants.CommentOnPostNew)
    Call<BaseResponse> CommentOnPostNew(@HeaderMap Map<String, String> header,
                                        @Part("commentContent") RequestBody comments,
                                        @Part("userid") RequestBody userId,
                                        @Part("causePostID") RequestBody causePostID,
                                        @Part List<MultipartBody.Part> avatar,
                                        @Part("embedded_flag") RequestBody embeddedFlag,
                                        @Part("embedded_content") RequestBody embeddedContent);

    @Multipart
//    @Headers({
//            "x-api-key:" + Constants.API_KEY,
//            "X-ACCESS-KEY:" + BuildConfig.APP_ID
//    })
    @POST(Constants.newCommentOnComment)
    Call<BaseResponse> newCommentOnComment(@HeaderMap Map<String, String> header,
                                           @Part("commentContent") RequestBody comments,
                                           @Part("userid") RequestBody userId,
                                           @Part("causeCommentId") RequestBody causePostID,
                                           @Part List<MultipartBody.Part> avatar,
                                           @Part("embedded_flag") RequestBody embeddedFlag,
                                           @Part("embedded_content") RequestBody embeddedContent);

//    @Headers({
//            "x-api-key:" + Constants.API_KEY,
//            "X-ACCESS-KEY:" + BuildConfig.APP_ID
//    })
    @POST(Constants.commentsByPostNW)
    Call<CommentModel> commentsByPostNW(@HeaderMap Map<String, String> header, @Body JsonObject jsonObject);

//    @Headers({
//            "x-api-key:" + Constants.API_KEY,
//            "X-ACCESS-KEY:" + BuildConfig.APP_ID
//    })
    @POST(Constants.commentsByPostAnti)
    Call<CommentModel> commentsByPostAnti(@HeaderMap Map<String, String> header, @Body JsonObject jsonObject);

//    @Headers({
//            "x-api-key:" + Constants.API_KEY,
//            "X-ACCESS-KEY:" + BuildConfig.APP_ID
//    })
    @POST(Constants.KOUserCommon)
    Call<BaseResponse> KOUserCommon(@HeaderMap Map<String, String> header, @Body JsonObject jsonObject);

//    @Headers({
//            "x-api-key:" + Constants.API_KEY,
//            "X-ACCESS-KEY:" + BuildConfig.APP_ID
//    })
    @POST(Constants.userContentReport)
    Call<BaseResponse> userContentReport(@HeaderMap Map<String, String> header, @Body JsonObject jsonObject);

//    @Headers({
//            "x-api-key:" + Constants.API_KEY,
//            "X-ACCESS-KEY:" + BuildConfig.APP_ID
//    })
    @POST(Constants.getPostCounts)
    Call<AllNWCountModel> getPostCounts(@HeaderMap Map<String, String> header, @Body JsonObject jsonObject);

//    @Headers({
//            "x-api-key:" + Constants.API_KEY,
//            "X-ACCESS-KEY:" + BuildConfig.APP_ID
//    })
    @POST(Constants.getCommentCount)
    Call<CommentCountModel> getCommentCount(@HeaderMap Map<String, String> header, @Body JsonObject jsonObject);

    @Headers({
            "x-api-key:" + Constants.API_KEY,
            "X-ACCESS-KEY:" + BuildConfig.APP_ID
    })
    @POST(Constants.changeCountryCode)
    Call<BaseResponse> changeCountryCode(@HeaderMap Map<String, String> header, @Body JsonObject jsonObject);


    @POST(Constants.getTopics)
    Call<List<TopicsModelNew>> getTopics(@HeaderMap Map<String, String> header, @Body JsonObject jsonObject);

//    @Headers({
//            "x-api-key:" + Constants.API_KEY,
//            "X-ACCESS-KEY:" + BuildConfig.APP_ID
//    })
    @POST(Constants.getUserInterests)
    Call<ProfileInterestsModel> getUserInterests(@HeaderMap Map<String, String> header, @Body JsonObject jsonObject);

//    @Headers({
//            "x-api-key:" + Constants.API_KEY,
//            "X-ACCESS-KEY:" + BuildConfig.APP_ID
//    })
    @POST(Constants.saveUserCarts)
    Call<BaseResponse> saveUserInterests(@HeaderMap Map<String, String> header, @Body JsonObject jsonObject);

    @Headers({
            "x-api-key:" + Constants.API_KEY,
            "X-ACCESS-KEY:" + BuildConfig.APP_ID
    })
    @POST(Constants.getNetworkDetails)
    Call<List<NetworkDetailsModel>> getNetworkDetails(@Body JsonObject jsonObject);

//    @Headers({
//            "x-api-key:" + Constants.API_KEY,
//            "X-ACCESS-KEY:" + BuildConfig.APP_ID
//    })
    @POST(Constants.instreamNW)
    Call<ResponseBody> getInstreamNW(@HeaderMap Map<String, String> header, @Body JsonObject jsonObject);

//    @Headers({
//            "x-api-key:" + Constants.API_KEY,
//            "X-ACCESS-KEY:" + BuildConfig.APP_ID
//    })
    @POST(Constants.instreamAnti)
    Call<ResponseBody> getInstreamAnti(@HeaderMap Map<String, String> header, @Body JsonObject jsonObject);

    @POST(Constants.getDiscussionsNW)
    Call<ResponseBody> getUserDiscussionNW(@HeaderMap Map<String, String> header, @Body JsonObject jsonObject);


    @POST(Constants.getDiscussionsANTI)
    Call<ResponseBody> getUserDiscussionAnti(@HeaderMap Map<String, String> header, @Body JsonObject jsonObject);


    //    @Headers({
//            "x-api-key:" + Constants.API_KEY,
//            "X-ACCESS-KEY:" + BuildConfig.APP_ID
//    })
    @POST(Constants.profilePosts)
    Call<ResponseBody> profilePosts(@HeaderMap Map<String, String> header ,@Body JsonObject jsonObject);

//    @Headers({
//            "x-api-key:" + Constants.API_KEY,
//            "X-ACCESS-KEY:" + BuildConfig.APP_ID
//    })
    @POST(Constants.myCommentPosts)
    Call<ResponseBody> commentPosts(@HeaderMap Map<String, String> header, @Body JsonObject jsonObject);
//
//    @Headers({
//            "x-api-key:" + Constants.API_KEY,
//            "X-ACCESS-KEY:" + BuildConfig.APP_ID
//    })
    @POST(Constants.createKeyword)
    Call<ResponseBody> createKeyword(@HeaderMap Map<String, String> header, @Body JsonObject jsonObject);

//    @Headers({
//            "x-api-key:" + Constants.API_KEY,
//            "X-ACCESS-KEY:" + BuildConfig.APP_ID
//    })
    @POST(Constants.insertUserCartsByTopic)
    Call<ResponseBody> saveCards(@HeaderMap  Map<String, String> header, @Body JsonObject jsonObject);

//    @Headers({
//            "x-api-key:" + Constants.API_KEY,
//            "X-ACCESS-KEY:" + BuildConfig.APP_ID
//    })
    @POST(Constants.addSearchTopicToCart)
    Call<ResponseBody> addSearchTopicToCart(@HeaderMap Map<String, String> header, @Body JsonObject jsonObject);

    @Headers({
            "x-api-key:" + Constants.API_KEY,
            "X-ACCESS-KEY:" + BuildConfig.APP_ID
    })
    @POST(Constants.loginWithGoogleUser)
    Call<List<GoogleSigninRequest>> loginWithGoogleUser(@Body JsonObject jsonObject);

    @Headers({
            "x-api-key:" + Constants.API_KEY,
            "X-ACCESS-KEY:" + BuildConfig.APP_ID
    })
    @POST(Constants.loginWithFBUser)
    Call<List<FbUserModel>> loginWithFBUser(@Body JsonObject jsonObject);

    @Headers({
            "x-api-key:" + Constants.API_KEY,
            "X-ACCESS-KEY:" + BuildConfig.APP_ID
    })
    @POST(Constants.usernamelist)
    Call<List<FbUserModel>> usernamelist(@Body JsonObject jsonObject);

//    @Headers({
//            "x-api-key:" + Constants.API_KEY,
//            "X-ACCESS-KEY:" + BuildConfig.APP_ID
//    })
    @POST(Constants.copyUserCarts)
    Call<CopyUserCartsModel> copyUserCarts(@HeaderMap Map<String, String> header, @Body JsonObject jsonObject);

//    @Headers({
//            "x-api-key:" + Constants.API_KEY,
//            "X-ACCESS-KEY:" + BuildConfig.APP_ID
//    })
    @POST(Constants.getPostDetails)
    Call<GetPostModelNew> getPostDetails(@HeaderMap Map<String, String> header, @Body JsonObject jsonObject);

//    @Headers({
//            "x-api-key:" + Constants.API_KEY,
//            "X-ACCESS-KEY:" + BuildConfig.APP_ID
//    })
    @POST(Constants.userPostSearch)
    Call<SearchPostsModel> userPostSearch(@HeaderMap Map<String, String> header, @Body JsonObject jsonObject);

//    @Headers({
//            "x-api-key:" + Constants.API_KEY,
//            "X-ACCESS-KEY:" + BuildConfig.APP_ID
//    })
    @POST(Constants.whoLHMyPost)
    Call<LoveHatePostCountModel> whoLHMyPost(@HeaderMap Map<String, String> header, @Body JsonObject jsonObject);

//    @Headers({
//            "x-api-key:" + Constants.API_KEY,
//            "X-ACCESS-KEY:" + BuildConfig.APP_ID
//    })
    @POST(Constants.userKWReport)
    Call<BaseResponse> userKWReport(@HeaderMap Map<String, String> header, @Body JsonObject jsonObject);

//    @Headers({
//            "x-api-key:" + Constants.API_KEY,
//            "X-ACCESS-KEY:" + BuildConfig.APP_ID
//    })
    @POST(Constants.userActionCommon)
    Call<BaseResponse> userActionCommon(@HeaderMap Map<String, String> header, @Body JsonObject jsonObject);

//    @Headers({
//            "x-api-key:" + Constants.API_KEY,
//            "X-ACCESS-KEY:" + BuildConfig.APP_ID
//    })
   @POST(Constants.checkValidity)
   Call<ResponseBody> ValidateUserKeyWordApi(@HeaderMap Map<String, String> header, @Body JsonObject jsonObject);

    @POST(Constants.setUserChatFlag)
    Call<BaseResponse> setUserChatFlag(@HeaderMap Map<String, String> header, @Body JsonObject jsonObject);

    @Headers({
            "x-api-key:" + Constants.API_KEY,
            "X-ACCESS-KEY:" + BuildConfig.APP_ID
    })
    @POST(Constants.getUserActivity)
    Call<GetUserActivityModel> getUserActivity(@Body JsonObject jsonObject);

    @Headers({
            "x-api-key:" + Constants.API_KEY,
            "X-ACCESS-KEY:" + BuildConfig.APP_ID
    })
    @POST(Constants.getkocontent)
    Call<UserKOContent> getKOContent(@Body JsonObject jsonObject);

    @Headers({
            "x-api-key:" + Constants.API_KEY,
            "X-ACCESS-KEY:" + BuildConfig.APP_ID
    })
    @POST(Constants.suspendUser)
    Call<BaseResponse> suspendUser(@Body JsonObject jsonObject);

    @Headers({
            "X-ACCESS-KEY:" + BuildConfig.APP_ID
    })
    @POST(Constants.createGuestUserApp)
    Call<CreateGuestLoginModel> createGuestApiCalling(@Body JsonObject jsonObject);


    @Headers({
            "X-ACCESS-KEY:" + BuildConfig.APP_ID
    })
    @POST(Constants.loginGuestUserApp)
    Call<ResponseBody> GuestLoginApiCalling(@Body JsonObject jsonObject);

    @Headers({
            "X-ACCESS-KEY:" + BuildConfig.APP_ID
    })
    @POST(Constants.createUserGoogle)
    Call<GoogleCreateUserModel> createGoogleApiCalling(@Body JsonObject jsonObject);

    @Headers({
            "X-ACCESS-KEY:" + BuildConfig.APP_ID
    })
    @POST(Constants.createFBUser)
    Call<GoogleCreateUserModel> createFacebookApiCalling(@Body JsonObject jsonObject);

    @GET("https://api.opinito.com/api.dev/getCountryCodeFromIp.php")
    Call<JsonObject> getIpAddressCountryCodeApi(@Query("ip") String deviceIpAddress);

    @GET("https://api.ipify.org/?format=json")
    Call<JsonObject> getIpinJson();

    @POST(Constants.deletePost)
    Call<ResponseBody> deletePostApiCall(@HeaderMap Map<String, String> header, @Body JsonObject jsonObject);

    @Headers({
            "X-ACCESS-KEY:" + BuildConfig.APP_ID
    })
    @POST(Constants.app_send_token_url)
    Call<ResponseBody> sendFcmTokenApiCall(@Body JsonObject jsonObject);

    @POST(Constants.postBookmark)
    Call<ResponseBody> postBookmark(@HeaderMap Map<String, String> header ,@Body JsonObject jsonObject);

    @POST(Constants.removeBookmark)
    Call<ResponseBody> removeBookmark(@HeaderMap Map<String, String> header ,@Body JsonObject jsonObject);

    @POST(Constants.myActivity)
    Call<ProfileModel> MyActivity(@HeaderMap Map<String, String> header, @Body JsonObject jsonObject);

    @POST(Constants.myBookmark)
    Call<ResponseBody> MyBookmarks(@HeaderMap Map<String, String> header, @Body JsonObject jsonObject);

    @POST(Constants.getInitialKWS)
    Call <PopupGetInitialKWS> keyWordsPopup(@HeaderMap Map<String,String> header, @Body JsonObject jsonObject);

    @POST(Constants.deleteAccount)
    Call<DeleteUserModel>  deleteAccount(@HeaderMap Map<String,String> header, @Body JsonObject jsonObject);


}
