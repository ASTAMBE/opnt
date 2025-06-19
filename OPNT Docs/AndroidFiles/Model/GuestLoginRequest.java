package com.opinito.social.Model;

/**
 * Created by bhaskar on 4/19/18.
 */

public class GuestLoginRequest {

    private String devicename;
    private String country_code;
    private String device_serial;

    public GuestLoginRequest(String devicename, String country_code, String device_serial) {
        this.devicename = devicename;
        this.country_code = country_code;
        this.device_serial = device_serial;
    }
}
