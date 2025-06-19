package com.opinito.social.Model;

/**
 * Created by bhaskar on 1/29/18.
 */
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class ImageUtil {
        private Pattern pattern;
        private Matcher matcher;

        private static final String IMAGE_PATTERN =
                "([^\\s]+(\\.(?i)(jpg|png|gif|bmp))$)";

        public ImageUtil(){
            pattern = Pattern.compile(IMAGE_PATTERN);
        }

        /**
         * Validate image with regular expression
         * @param image image for validation
         * @return true valid image, false invalid image
         */
        public boolean validate(final String image){

            matcher = pattern.matcher(image);
            return matcher.matches();
        }

}
