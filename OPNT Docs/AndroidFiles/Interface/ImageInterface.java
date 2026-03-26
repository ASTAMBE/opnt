package com.opinito.social.Interface;

import android.net.Uri;

public interface ImageInterface {
    void removeImage(Uri imagePath, int position);

    void scrollImage(int position);
}
