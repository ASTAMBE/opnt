package com.opinito.social.code_revamp.network_layer

import com.opinito.social.Constants.Constants
import com.opinito.social.code_revamp.models.change_country_code.ChangeCountryCodeRequest
import com.opinito.social.code_revamp.models.change_country_code.ChangeCountryCodeResponse
import com.opinito.social.code_revamp.models.delete_post.DeletePostRequest
import com.opinito.social.code_revamp.models.delete_post.DeletePostResponse
import com.opinito.social.code_revamp.models.delete_user.DeleteUserRequest
import com.opinito.social.code_revamp.models.delete_user.DeleteUserResponse
import com.opinito.social.code_revamp.models.getUserCarts.GetUserCartsRequest
import com.opinito.social.code_revamp.models.getUserCarts.GetUserCartsResponse
import com.opinito.social.code_revamp.models.get_discussions_nw.GetDiscussionsNwRequest
import com.opinito.social.code_revamp.models.get_discussions_nw.GetDiscussionsNwResponse
import com.opinito.social.code_revamp.models.get_instream_nw.GetInstreamNwRequest
import com.opinito.social.code_revamp.models.get_instream_nw.GetInstreamNwResponse
import com.opinito.social.code_revamp.models.get_post_counts.GetPostCountsRequest
import com.opinito.social.code_revamp.models.get_post_counts.GetPostCountsResponse
import com.opinito.social.code_revamp.models.get_user_topics.GetUserTopicRequest
import com.opinito.social.code_revamp.models.get_user_topics.GetUserTopicResponse
import com.opinito.social.code_revamp.models.inset_user_cart_by_topic.InsertUserCartByTopicRequest
import com.opinito.social.code_revamp.models.inset_user_cart_by_topic.InsertUserCartByTopicResponse
import com.opinito.social.code_revamp.models.post_bookmark.PostBookmarkRequest
import com.opinito.social.code_revamp.models.post_bookmark.PostBookmarkResponse
import com.opinito.social.code_revamp.models.remove_bookmark.RemoveBookmarkRequest
import com.opinito.social.code_revamp.models.remove_bookmark.RemoveBookmarkResponse
import com.opinito.social.code_revamp.models.showFreshContent.ShowFreshContentRequest
import com.opinito.social.code_revamp.models.showFreshContent.ShowFreshContentResponse
import com.opinito.social.code_revamp.models.showInitialDiscussions.ShowInitialDiscussionsRequest
import com.opinito.social.code_revamp.models.showInitialDiscussions.ShowInitialDiscussionsResponse
import com.opinito.social.code_revamp.models.suggest_kw.SuggestKWRequest
import com.opinito.social.code_revamp.models.suggest_kw.SuggestKWResponse
import com.opinito.social.code_revamp.models.user_action_common.UserActionCommonRequest
import com.opinito.social.code_revamp.models.user_action_common.UserActionCommonResponse
import com.opinito.social.code_revamp.models.user_interests.request.SaveAllUserInterestsRequest
import com.opinito.social.code_revamp.models.user_interests.request.UserInterestsRequest
import com.opinito.social.code_revamp.models.user_interests.response.SaveAllUserInterestsResponse
import com.opinito.social.code_revamp.models.user_interests.response.UserInterestsResponse
import retrofit2.Response
import retrofit2.http.Body
import retrofit2.http.Header
import retrofit2.http.POST

interface UserAPI {
    @POST("getUserInterests.php")
    suspend fun userInterests(
        @Header("Token") token: String,
        @Header("X-ACCESS-KEY") xKey: String, @Body userRequest: UserInterestsRequest
    ): Response<UserInterestsResponse>

    @POST("insertUserCartsByTopic.php")
    suspend fun insertUserCartByTopic(
        @Header("Token") token: String,
        @Header("X-ACCESS-KEY") xKey: String,
        @Body userCartByTopicRequest: InsertUserCartByTopicRequest
    ): Response<InsertUserCartByTopicResponse>

    @POST("changeCountryCode.php")
    suspend fun changeCountryCode(
        @Header("Token") token: String,
        @Header("X-ACCESS-KEY") xKey: String,
        @Body changeCountryCodeRequest: ChangeCountryCodeRequest
    ): Response<ChangeCountryCodeResponse>

    @POST("showInitialDiscussions.php")
    suspend fun showInitialDiscussions(
        @Header("Token") token: String,
        @Header("X-ACCESS-KEY") xKey: String,
        @Body showInitialDiscussionsRequest: ShowInitialDiscussionsRequest
    ): Response<ShowInitialDiscussionsResponse>

    @POST("userActionCommon.php")
    suspend fun userActionCommon(
        @Header("Token") token: String,
        @Header("X-ACCESS-KEY") xKey: String, @Body userActionCommonRequest: UserActionCommonRequest
    ): Response<UserActionCommonResponse>

    @POST("getUserTopics.php")
    suspend fun getUserTopics(
        @Header("Token") token: String,
        @Header("X-ACCESS-KEY") xKey: String, @Body getUserTopicRequest: GetUserTopicRequest
    ): Response<GetUserTopicResponse>

    @POST("deletePost.php")
    suspend fun deletePost(
        @Header("Token") token: String,
        @Header("X-ACCESS-KEY") xKey: String, @Body deletePostRequest: DeletePostRequest
    ): Response<DeletePostResponse>

    @POST("getPostCounts.php")
    suspend fun getPostCounts(
        @Header("Token") token: String,
        @Header("X-ACCESS-KEY") xKey: String, @Body getPostCountsRequest: GetPostCountsRequest
    ): Response<GetPostCountsResponse>

    @POST("postBookmark.php")
    suspend fun postBookmark(
        @Header("Token") token: String,
        @Header("X-ACCESS-KEY") xKey: String, @Body postBookmarkRequest: PostBookmarkRequest
    ): Response<PostBookmarkResponse>

    @POST("removeBookmark.php")
    suspend fun removeBookmark(@Body removeBookmarkRequest: RemoveBookmarkRequest): Response<RemoveBookmarkResponse>

    @POST("getInstreamNW.php")
    suspend fun getInstreamNw(
        @Header("Token") token: String,
        @Header("X-ACCESS-KEY") xKey: String, @Body getInstreamNwRequest: GetInstreamNwRequest
    ): Response<GetInstreamNwResponse>

    @POST("getDiscussionsNW.php")
    suspend fun getDiscussionNw(
        @Header("Token") token: String,
        @Header("X-ACCESS-KEY") xKey: String, @Body getDiscussionsNwRequest: GetDiscussionsNwRequest
    ): Response<GetDiscussionsNwResponse>

    @POST("getInstreamANTI.php")
    suspend fun getInstreamAnti(
        @Header("Token") token: String,
        @Header("X-ACCESS-KEY") xKey: String, @Body getInstreamNwRequest: GetInstreamNwRequest
    ): Response<GetInstreamNwResponse>

    @POST("getDiscussionsANTI.php")
    suspend fun getDiscussionAnti(
        @Header("Token") token: String,
        @Header("X-ACCESS-KEY") xKey: String, @Body getDiscussionsNwRequest: GetDiscussionsNwRequest
    ): Response<GetDiscussionsNwResponse>

    @POST("getUserCarts.php")
    suspend fun getUserCarts(
        @Header("Token") token: String,
        @Header("X-ACCESS-KEY") xKey: String, @Body getUserCartsRequest: GetUserCartsRequest
    ): Response<GetUserCartsResponse>

    @POST("suggestKW.php")
    suspend fun suggestKW(
        @Header("Token") token: String,
        @Header("X-ACCESS-KEY") xKey: String, @Body suggestKWRequest: SuggestKWRequest
    ): Response<ShowFreshContentResponse>

    @POST("deleteUserByUsername.php")
    suspend fun deleteUser(
        @Header("Token") token: String,
        @Header("X-ACCESS-KEY") xKey: String, @Body userRequest: DeleteUserRequest
    ): Response<DeleteUserResponse>


    @POST(Constants.saveUserCarts)
    suspend fun saveAllInterests(
        @Header("Token") token: String,
        @Header("X-ACCESS-KEY") xKey: String, @Body userRequest: SaveAllUserInterestsRequest
    ): Response<SaveAllUserInterestsResponse>


    @POST(Constants.showFreshContent)
    suspend fun showFreshContent(
        @Header("Token") token: String,
        @Header("X-ACCESS-KEY") xKey: String,
        @Body showFreshContentRequest: ShowFreshContentRequest
    ): Response<ShowFreshContentResponse>
}

