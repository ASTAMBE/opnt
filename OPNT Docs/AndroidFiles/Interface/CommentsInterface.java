package com.opinito.social.Interface;

import com.opinito.social.Model.CommentModel;

import java.util.List;

public interface CommentsInterface {
    void removeUser(String KOtype, String commentId);
    void postDetail(CommentModel.Data commentModelArrayList, String type);
    void deletePost(String commentId);
}
