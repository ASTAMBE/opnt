package com.opinito.social.Model;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import java.util.List;


public class IpGeoLocationApiModel {

    @SerializedName("continent")
    @Expose
    private String continent;
    @SerializedName("address_format")
    @Expose
    private String addressFormat;
    @SerializedName("alpha2")
    @Expose
    private String alpha2;
    @SerializedName("alpha3")
    @Expose
    private String alpha3;
    @SerializedName("country_code")
    @Expose
    private String countryCode;
    @SerializedName("international_prefix")
    @Expose
    private String internationalPrefix;
    @SerializedName("ioc")
    @Expose
    private String ioc;
    @SerializedName("gec")
    @Expose
    private String gec;
    @SerializedName("name")
    @Expose
    private String name;
    @SerializedName("national_destination_code_lengths")
    @Expose
    private List<Integer> nationalDestinationCodeLengths = null;
    @SerializedName("national_number_lengths")
    @Expose
    private List<Integer> nationalNumberLengths = null;
    @SerializedName("national_prefix")
    @Expose
    private String nationalPrefix;
    @SerializedName("number")
    @Expose
    private String number;
    @SerializedName("region")
    @Expose
    private String region;
    @SerializedName("subregion")
    @Expose
    private String subregion;
    @SerializedName("world_region")
    @Expose
    private String worldRegion;
    @SerializedName("un_locode")
    @Expose
    private String unLocode;
    @SerializedName("nationality")
    @Expose
    private String nationality;
    @SerializedName("postal_code")
    @Expose
    private Boolean postalCode;
    @SerializedName("unofficial_names")
    @Expose
    private List<String> unofficialNames = null;
    @SerializedName("languages_official")
    @Expose
    private List<String> languagesOfficial = null;
    @SerializedName("languages_spoken")
    @Expose
    private List<String> languagesSpoken = null;
    @SerializedName("geo")
    @Expose
    private Geo geo;
    @SerializedName("currency_code")
    @Expose
    private String currencyCode;
    @SerializedName("start_of_week")
    @Expose
    private String startOfWeek;

    public String getContinent() {
        return continent;
    }

    public void setContinent(String continent) {
        this.continent = continent;
    }

    public String getAddressFormat() {
        return addressFormat;
    }

    public void setAddressFormat(String addressFormat) {
        this.addressFormat = addressFormat;
    }

    public String getAlpha2() {
        return alpha2;
    }

    public void setAlpha2(String alpha2) {
        this.alpha2 = alpha2;
    }

    public String getAlpha3() {
        return alpha3;
    }

    public void setAlpha3(String alpha3) {
        this.alpha3 = alpha3;
    }

    public String getCountryCode() {
        return countryCode;
    }

    public void setCountryCode(String countryCode) {
        this.countryCode = countryCode;
    }

    public String getInternationalPrefix() {
        return internationalPrefix;
    }

    public void setInternationalPrefix(String internationalPrefix) {
        this.internationalPrefix = internationalPrefix;
    }

    public String getIoc() {
        return ioc;
    }

    public void setIoc(String ioc) {
        this.ioc = ioc;
    }

    public String getGec() {
        return gec;
    }

    public void setGec(String gec) {
        this.gec = gec;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public List<Integer> getNationalDestinationCodeLengths() {
        return nationalDestinationCodeLengths;
    }

    public void setNationalDestinationCodeLengths(List<Integer> nationalDestinationCodeLengths) {
        this.nationalDestinationCodeLengths = nationalDestinationCodeLengths;
    }

    public List<Integer> getNationalNumberLengths() {
        return nationalNumberLengths;
    }

    public void setNationalNumberLengths(List<Integer> nationalNumberLengths) {
        this.nationalNumberLengths = nationalNumberLengths;
    }

    public String getNationalPrefix() {
        return nationalPrefix;
    }

    public void setNationalPrefix(String nationalPrefix) {
        this.nationalPrefix = nationalPrefix;
    }

    public String getNumber() {
        return number;
    }

    public void setNumber(String number) {
        this.number = number;
    }

    public String getRegion() {
        return region;
    }

    public void setRegion(String region) {
        this.region = region;
    }

    public String getSubregion() {
        return subregion;
    }

    public void setSubregion(String subregion) {
        this.subregion = subregion;
    }

    public String getWorldRegion() {
        return worldRegion;
    }

    public void setWorldRegion(String worldRegion) {
        this.worldRegion = worldRegion;
    }

    public String getUnLocode() {
        return unLocode;
    }

    public void setUnLocode(String unLocode) {
        this.unLocode = unLocode;
    }

    public String getNationality() {
        return nationality;
    }

    public void setNationality(String nationality) {
        this.nationality = nationality;
    }

    public Boolean getPostalCode() {
        return postalCode;
    }

    public void setPostalCode(Boolean postalCode) {
        this.postalCode = postalCode;
    }

    public List<String> getUnofficialNames() {
        return unofficialNames;
    }

    public void setUnofficialNames(List<String> unofficialNames) {
        this.unofficialNames = unofficialNames;
    }

    public List<String> getLanguagesOfficial() {
        return languagesOfficial;
    }

    public void setLanguagesOfficial(List<String> languagesOfficial) {
        this.languagesOfficial = languagesOfficial;
    }

    public List<String> getLanguagesSpoken() {
        return languagesSpoken;
    }

    public void setLanguagesSpoken(List<String> languagesSpoken) {
        this.languagesSpoken = languagesSpoken;
    }

    public Geo getGeo() {
        return geo;
    }

    public void setGeo(Geo geo) {
        this.geo = geo;
    }

    public String getCurrencyCode() {
        return currencyCode;
    }

    public void setCurrencyCode(String currencyCode) {
        this.currencyCode = currencyCode;
    }

    public String getStartOfWeek() {
        return startOfWeek;
    }

    public void setStartOfWeek(String startOfWeek) {
        this.startOfWeek = startOfWeek;
    }
    public class Northeast {

        @SerializedName("lat")
        @Expose
        private Double lat;
        @SerializedName("lng")
        @Expose
        private Double lng;

        public Double getLat() {
            return lat;
        }

        public void setLat(Double lat) {
            this.lat = lat;
        }

        public Double getLng() {
            return lng;
        }

        public void setLng(Double lng) {
            this.lng = lng;
        }

    }

    public class Southwest {

        @SerializedName("lat")
        @Expose
        private Double lat;
        @SerializedName("lng")
        @Expose
        private Double lng;

        public Double getLat() {
            return lat;
        }

        public void setLat(Double lat) {
            this.lat = lat;
        }

        public Double getLng() {
            return lng;
        }

        public void setLng(Double lng) {
            this.lng = lng;
        }

}
    public class Bounds {

        @SerializedName("northeast")
        @Expose
        private Northeast northeast;
        @SerializedName("southwest")
        @Expose
        private Southwest southwest;

        public Northeast getNortheast() {
            return northeast;
        }

        public void setNortheast(Northeast northeast) {
            this.northeast = northeast;
        }

        public Southwest getSouthwest() {
            return southwest;
        }

        public void setSouthwest(Southwest southwest) {
            this.southwest = southwest;
        }

    }
    public class Geo {

        @SerializedName("latitude")
        @Expose
        private Double latitude;
        @SerializedName("latitude_dec")
        @Expose
        private String latitudeDec;
        @SerializedName("longitude")
        @Expose
        private Double longitude;
        @SerializedName("longitude_dec")
        @Expose
        private String longitudeDec;
        @SerializedName("max_latitude")
        @Expose
        private Double maxLatitude;
        @SerializedName("max_longitude")
        @Expose
        private Double maxLongitude;
        @SerializedName("min_latitude")
        @Expose
        private Double minLatitude;
        @SerializedName("min_longitude")
        @Expose
        private Double minLongitude;
        @SerializedName("bounds")
        @Expose
        private Bounds bounds;

        public Double getLatitude() {
            return latitude;
        }

        public void setLatitude(Double latitude) {
            this.latitude = latitude;
        }

        public String getLatitudeDec() {
            return latitudeDec;
        }

        public void setLatitudeDec(String latitudeDec) {
            this.latitudeDec = latitudeDec;
        }

        public Double getLongitude() {
            return longitude;
        }

        public void setLongitude(Double longitude) {
            this.longitude = longitude;
        }

        public String getLongitudeDec() {
            return longitudeDec;
        }

        public void setLongitudeDec(String longitudeDec) {
            this.longitudeDec = longitudeDec;
        }

        public Double getMaxLatitude() {
            return maxLatitude;
        }

        public void setMaxLatitude(Double maxLatitude) {
            this.maxLatitude = maxLatitude;
        }

        public Double getMaxLongitude() {
            return maxLongitude;
        }

        public void setMaxLongitude(Double maxLongitude) {
            this.maxLongitude = maxLongitude;
        }

        public Double getMinLatitude() {
            return minLatitude;
        }

        public void setMinLatitude(Double minLatitude) {
            this.minLatitude = minLatitude;
        }

        public Double getMinLongitude() {
            return minLongitude;
        }

        public void setMinLongitude(Double minLongitude) {
            this.minLongitude = minLongitude;
        }

        public Bounds getBounds() {
            return bounds;
        }

        public void setBounds(Bounds bounds) {
            this.bounds = bounds;
        }

    }


}