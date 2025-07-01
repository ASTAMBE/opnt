package com.opinito.social.code_revamp.models.user_interests.response

data class UserInterestsResponse(
    val `data`: List<Data?>? = null,
    val status: String? = null
)

data class SaveAllUserInterestsResponse(
    val status: String? = null
)