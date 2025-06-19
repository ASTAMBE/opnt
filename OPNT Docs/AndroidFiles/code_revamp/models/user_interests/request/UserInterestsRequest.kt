package com.opinito.social.code_revamp.models.user_interests.request

data class UserInterestsRequest(
    val userid: String? = null
)



data class SaveAllUserInterestsRequest(
    val topicid: String? = null,
    val userid: String? = null
)