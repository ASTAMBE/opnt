package com.opinito.social.Model;

import java.io.Serializable;

/**
 * Created by bhaskar on 1/6/18.
 */

public class PreviewModel implements Serializable {
    String PREVIEW_TITLE;
    String PREVIEW_DESCRIPTION;
    String PREVIEW_URL;

    public String getPREVIEW_TITLE() {
        return PREVIEW_TITLE;
    }

    public void setPREVIEW_TITLE(String PREVIEW_TITLE) {
        this.PREVIEW_TITLE = PREVIEW_TITLE;
    }

    public String getPREVIEW_DESCRIPTION() {
        return PREVIEW_DESCRIPTION;
    }

    public void setPREVIEW_DESCRIPTION(String PREVIEW_DESCRIPTION) {
        this.PREVIEW_DESCRIPTION = PREVIEW_DESCRIPTION;
    }

    public String getPREVIEW_URL() {
        return PREVIEW_URL;
    }

    public void setPREVIEW_URL(String PREVIEW_URL) {
        this.PREVIEW_URL = PREVIEW_URL;
    }


}
