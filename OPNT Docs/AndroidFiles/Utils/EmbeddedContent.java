package com.opinito.social.Utils;

import android.net.Uri;
import android.util.Log;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class EmbeddedContent {

    public String getEmbeddedContent(String text) {

        // Check if the input is a URL
        Uri uri = Uri.parse(text);
        String host = uri.getHost();

        if (host != null) {
            // Removing "www." if present
            host = host.replaceFirst("^www\\.", "");

            // Split by dots and get the last two parts (e.g., cnn.com)
            String[] parts = host.split("\\.");
            int numParts = parts.length;
            if (numParts >= 2) {
                host = parts[numParts - 2] + "." + parts[numParts - 1];
            }

            Log.d("emb2",host);
            return host;
        }

        // If not a URL, return the input as it is (assuming it's plain text)
        return null;


    /*    ArrayList links = new ArrayList();
        String regex = "\\(?\\b(http://|www[.])[-A-Za-z0-9+&@#/%?=~_()|!:,.;]*[-A-Za-z0-9+&@#/%=~_()|]";
        Pattern p = Pattern.compile(regex);
        Matcher m = p.matcher(text);
        while (m.find()) {
            String urlStr = m.group();
            if (urlStr.startsWith("(") && urlStr.endsWith(")")) {
                urlStr = urlStr.substring(1, urlStr.length() - 1);
            }
            links.add(urlStr);
        }
        StringBuilder embeddedContent = new StringBuilder();
        if (links.size() > 0) {
            for (int i = 0; i < links.size(); i++) {
                embeddedContent.append(getBaseUrl(links.get(i).toString())).append(",");
            }
            embeddedContent = embeddedContent.deleteCharAt(embeddedContent.length() - 1);
        }
        return embeddedContent.toString();*/
    }

    private String getBaseUrl(String embeddedContent) {
        String protocol = "";
        String pathArray[] = embeddedContent.split( "/" );
        protocol = pathArray[0];
        return (protocol);
    }

    public ArrayList<String> getEmbeddedContentList(String text) {
        ArrayList links = new ArrayList();
        String regex = "\\(?\\b(http://|www[.])[-A-Za-z0-9+&@#/%?=~_()|!:,.;]*[-A-Za-z0-9+&@#/%=~_()|]";
        Pattern p = Pattern.compile(regex);
        Matcher m = p.matcher(text);
        while (m.find()) {
            String urlStr = m.group();
            if (urlStr.startsWith("(") && urlStr.endsWith(")")) {
                urlStr = urlStr.substring(1, urlStr.length() - 1);
            }
            links.add(urlStr);
        }
        return links;
    }

    public String getUrlForPreview(String text) {
        try {
            ArrayList links = new ArrayList();
            String regex = "\\(?\\b(http://|www[.])[-A-Za-z0-9+&@#/%?=~_()|!:,.;]*[-A-Za-z0-9+&@#/%=~_()|]";
            Pattern p = Pattern.compile(regex);
            Matcher m = p.matcher(text);
            while (m.find()) {
                String urlStr = m.group();
                if (urlStr.startsWith("(") && urlStr.endsWith(")")) {
                    urlStr = urlStr.substring(1, urlStr.length() - 1);
                }
                links.add(urlStr);
            }
            return links.get(0).toString();
        } catch (Exception e) {
            return "";
        }
    }
}
