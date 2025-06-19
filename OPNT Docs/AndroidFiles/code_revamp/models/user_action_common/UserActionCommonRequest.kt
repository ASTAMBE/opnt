package com.opinito.social.code_revamp.models.user_action_common

data class UserActionCommonRequest(
    val actionSource: String? = null,
    val actionType: String? = null,
    val sourceID: String? = null,
    val userid: String? = null
)