package com.opinito.social.Utils;

import android.content.Context;
import android.os.Build;
import android.text.format.DateFormat;
import android.util.Log;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.Instant;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;
import java.util.TimeZone;
import java.util.logging.Level;
import java.util.logging.Logger;

public class TimeUtils {

    public String timeAgo(String dateTime) {
        long timeInMillis = convertDateToMillis(convertUtcToLocal(dateTime));
        long cur_time = (Calendar.getInstance().getTimeInMillis()) / 1000;
        long time_elapsed = cur_time - timeInMillis / 1000;

        long seconds = time_elapsed;
        int minutes = Math.round(time_elapsed / 60);
        int hours = Math.round(time_elapsed / 3600);
        int days = Math.round(time_elapsed / 86400);
        int weeks = Math.round(time_elapsed / 604800);
        int months = Math.round(time_elapsed / 2600640);
        int years = Math.round(time_elapsed / 31207680);

        Log.e("time_elapsed:", String.valueOf(time_elapsed));

        // Seconds
        if (seconds <= 60) {
            return "just now";
        }
        //Minutes
        else if (minutes <= 60) {
            if (minutes == 1) {
                return "1 minute ago";
            } else {
                return minutes + " minutes ago";
            }
        }
        //Hours
        else if (hours <= 24) {
            if (hours == 1) {
                return "an hour ago";
            } else {
                return hours + " hrs ago";
            }
        }
        //Days
        else if (days <= 7) {
            if (days == 1) {
                return "yesterday";
            } else {
                return days + " days ago";
            }
        }
        //Weeks
        else if (weeks <= 4.3) {
            if (weeks == 1) {
                return "a week ago";
            } else {
                return weeks + " weeks ago";
            }
        }
        //Months
        else if (months <= 12) {
            if (months == 1) {
                return "a month ago";
            } else {
                return months + " months ago";
            }
        }
        //Years
        else {
            if (years == 1) {
                return "1 year ago";
            } else {
                return years + " years ago";
            }
        }
    }

    public String convertdate(String deliveryDate) {
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            Date date = sdf.parse(deliveryDate);
//            sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            return timeAgo(sdf.format(date));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "";
    }

    public String convertdateWithOutTime(String deliveryDate) {
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            Date date = sdf.parse(deliveryDate);
            sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            return timeAgo(sdf.format(date));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "";
    }

    private long convertDateToMillis(String dateTime) {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault());
        Date date = null;
        try {
            date = sdf.parse(dateTime);
        } catch (ParseException e) {
            e.printStackTrace();
        }
        return date.getTime();
    }

    private String convertUtcToLocal(String dateTime) {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault());
        sdf.setTimeZone(TimeZone.getTimeZone("UTC"));
        Date date = null;
        try {
            date = sdf.parse(dateTime);
        } catch (ParseException e) {
            e.printStackTrace();
        }

        sdf.setTimeZone(TimeZone.getDefault());
        return sdf.format(date);
    }

    public String time(String UTCTime, Context context) {
        String date = "";
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault());
            sdf.setTimeZone(TimeZone.getTimeZone("UTC"));
            Date parsedDate = sdf.parse(UTCTime);
            if (!DateFormat.is24HourFormat(context)) {
                SimpleDateFormat simpleDateFormat = new SimpleDateFormat("dd MMM yyyy, hh:mm a");
                simpleDateFormat.setTimeZone(TimeZone.getDefault());
                date = simpleDateFormat.format(parsedDate);
            } else {
                SimpleDateFormat simpleDateFormat = new SimpleDateFormat("dd MMM yyyy, HH:mm ");
                simpleDateFormat.setTimeZone(TimeZone.getDefault());
                date = simpleDateFormat.format(parsedDate);
            }
        } catch (ParseException e) {
            e.printStackTrace();
        }
        return date;
    }

    public String getCureentUTCTime() {
        final SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        sdf.setTimeZone(TimeZone.getTimeZone("UTC"));
        return sdf.format(new Date());
    }
}

