package com.opinito.social.code_revamp.models.get_instream_nw

import com.opinito.social.Model.PostCellModel
import com.opinito.social.Model.PreviewModel
data class GetInstreamNwResponseItem(
    val DP_URL: String? = null,
    var HCOUNT: String? = null,
    var LCOUNT: String? = null,
    val MEDIA_CONTENT: String? = null,
    val MEDIA_FLAG: String? = null,
    var POST_ACTION_TYPE: String? = "",
    val POST_BY_USERID: String? = null,
    val POST_COMMENT_COUNT: String? = null,
    val POST_CONTENT: String? = null,
    val POST_DATETIME: String? = null,
    val POST_ID: String? = null,
    val TOPICID: String? = null,
    val TOTAL_NS: String? = null,
    val USERNAME: String? = null,
    val UU_ACTION: String? = null,
    var postCellModel: PostCellModel? = null,
    val previewModel: PreviewModel? = null,
    var BOOKMARK_FLAG: String? = ""
)