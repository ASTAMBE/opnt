package com.opinito.social.Utils;

import android.content.Context;

import com.opinito.social.R;

public class ColorChange {

    public Context context;

    public ColorChange(Context context){
        this.context = context;
    }

    public int colorChange(String selected) {
        int color = 0;
        switch (selected) {
            case "a":
                color = context.getResources().getColor(R.color.a);
                break;

            case "b":
                color = context.getResources().getColor(R.color.b);
                break;

            case "c":
                color = context.getResources().getColor(R.color.c);
                break;

            case "d":
                color = context.getResources().getColor(R.color.d);
                break;

            case "e":
                color = context.getResources().getColor(R.color.e);
                break;

            case "f":
                color = context.getResources().getColor(R.color.f);
                break;

            case "g":
                color = context.getResources().getColor(R.color.g);
                break;

            case "h":
                color = context.getResources().getColor(R.color.h);
                break;

            case "i":
                color = context.getResources().getColor(R.color.i);
                break;

            case "j":
                color = context.getResources().getColor(R.color.j);
                break;

            case "k":
                color = context.getResources().getColor(R.color.k);
                break;

            case "l":
                color = context.getResources().getColor(R.color.l);
                break;

            case "m":
                color = context.getResources().getColor(R.color.m);
                break;

            case "n":
                color = context.getResources().getColor(R.color.n);
                break;

            case "o":
                color = context.getResources().getColor(R.color.o);
                break;

            case "p":
                color = context.getResources().getColor(R.color.p);
                break;

            case "q":
                color = context.getResources().getColor(R.color.q);
                break;

            case "r":
                color = context.getResources().getColor(R.color.r);
                break;

            case "s":
                color = context.getResources().getColor(R.color.s);
                break;

            case "t":
                color = context.getResources().getColor(R.color.t);
                break;

            case "u":
                color = context.getResources().getColor(R.color.u);
                break;

            case "v":
                color = context.getResources().getColor(R.color.v);
                break;

            case "w":
                color = context.getResources().getColor(R.color.w);
                break;

            case "x":
                color = context.getResources().getColor(R.color.x);
                break;

            case "y":
                color = context.getResources().getColor(R.color.y);
                break;

            case "z":
                color = context.getResources().getColor(R.color.z);
                break;
        }

        return color;
    }

    public static int getDrawable(String topicName) {
        if (topicName.toLowerCase().contains("sports")
                || topicName.toLowerCase().contains("games")) {
            return R.drawable.sports_tab;
        } else if (topicName.toLowerCase().contains("science")
                || topicName.toLowerCase().contains("tech")) {
            return R.drawable.science_tab;
        } else if (topicName.toLowerCase().contains("politics")) {
            return R.drawable.politics_tab;
        } else if (topicName.toLowerCase().contains("life")) {
            return R.drawable.life_tab;
        } else if (topicName.toLowerCase().contains("economy")) {
            return R.drawable.economy_tab;
        } else if (topicName.toLowerCase().contains("films")) {
            return R.drawable.ic_movies;
        } else if (topicName.toLowerCase().contains("misc")) {
            return R.drawable.miscellaneous_tab;
//        } else if (topicName.toLowerCase().contains("shoes")) {
//            return R.drawable.shoes_gray;
        } else if (topicName.toLowerCase().contains("religion")) {
            return R.drawable.religion_tab;
        } else if (topicName.toLowerCase().contains("celebrities")) {
            return R.drawable.celebrity_tab;
        } else if (topicName.toLowerCase().contains("trending")) {
            return R.drawable.trending_tab;
        } else if (topicName.toLowerCase().contains("health")) {
            return R.drawable.ic_health;
        } else {
            return R.drawable.media_tab;
        }
    }

    public static int getDrawableTiles(String topicName) {
        if (topicName.toLowerCase().contains("sports")
                || topicName.toLowerCase().contains("games")) {
            return R.drawable.sports;
        } else if (topicName.toLowerCase().contains("science")
                || topicName.toLowerCase().contains("tech")) {
            return R.drawable.science;
        } else if (topicName.toLowerCase().contains("politics")) {
            return R.drawable.politics;
        } else if (topicName.toLowerCase().contains("life")) {
            return R.drawable.life;
        } else if (topicName.toLowerCase().contains("economy")) {
            return R.drawable.economy;
        } else if (topicName.toLowerCase().contains("films")) {
            return R.drawable.ic_movies;
        } else if (topicName.toLowerCase().contains("misc")) {
            return R.drawable.miscelaneous;
//        } else if (topicName.toLowerCase().contains("shoes")) {
//            return R.drawable.shoes_gray;
        } else if (topicName.toLowerCase().contains("religion")) {
            return R.drawable.religion;
        } else if (topicName.toLowerCase().contains("celebrities")) {
            return R.drawable.celebrity;
        } else if (topicName.toLowerCase().contains("trending")) {
            return R.drawable.trending;
        } else if (topicName.toLowerCase().contains("health")) {
            return R.drawable.ic_health;
        } else {
            return R.drawable.media;
        }
    }

    public static int getDrawableTilesUnselected(String topicName) {
        if (topicName.toLowerCase().contains("sports")
                || topicName.toLowerCase().contains("games")) {
            return R.drawable.sports_unselected;
        } else if (topicName.toLowerCase().contains("science")
                || topicName.toLowerCase().contains("tech")) {
            return R.drawable.science_unselected;
        } else if (topicName.toLowerCase().contains("politics")) {
            return R.drawable.politics_unselected;
        } else if (topicName.toLowerCase().contains("life")) {
            return R.drawable.life_unselected;
        } else if (topicName.toLowerCase().contains("economy")) {
            return R.drawable.economy_unselected;
        } else if (topicName.toLowerCase().contains("films")) {
            return R.drawable.ic_movies;
        } else if (topicName.toLowerCase().contains("misc")) {
            return R.drawable.miscelaneous_unselected;
//        } else if (topicName.toLowerCase().contains("shoes")) {
//            return R.drawable.shoes_gray;
        } else if (topicName.toLowerCase().contains("religion")) {
            return R.drawable.religion_unselected;
        } else if (topicName.toLowerCase().contains("celebrities")) {
            return R.drawable.celebrity_unselected;
        } else if (topicName.toLowerCase().contains("trending")) {
            return R.drawable.trending_unselected;
        } else if (topicName.toLowerCase().contains("health")) {
            return R.drawable.ic_health;
        } else {
            return R.drawable.media_unselected;
        }
    }
}
