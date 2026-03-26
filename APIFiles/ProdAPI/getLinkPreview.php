<?php

include('includeHeader.inc.php');
print_r($_REQUEST);
$url = $postData['url'];

//require __DIR__ . '/vendor/autoload.php';

use LinkPreview\LinkPreview;

echo $url;

$linkPreview = new LinkPreview('http://github.com');
echo 'linkPreview';

$parsed = $linkPreview->getParsed();

echo 'completed';

foreach ($parsed as $parserName => $link) {
    echo $parserName . PHP_EOL . PHP_EOL;

    echo $link->getUrl() . PHP_EOL;
    echo $link->getRealUrl() . PHP_EOL;
    echo $link->getTitle() . PHP_EOL;
    echo $link->getDescription() . PHP_EOL;
    echo $link->getImage() . PHP_EOL;
    print_r($link->getPictures());
}



function extract_url_data($url){

    /*
    if(!filter_var($url, FILTER_VALIDATE_URL)) {
        echo($url.' is not a valid URL !!!!');
        die;
    }
    */
    echo $url;
    $linkPreview = new LinkPreview($url);
    $parsed = $linkPreview->getParsed();

    return $parsed;
}

function insert_procedure($db, $parsed){

    // query to insert
    $sql = 'INSERT INTO link_preview (WEB_URL,URL_TITLE,URL_DESCRIPTION,IMAGE_URL) VALuES ('.
        '"'.$parsed['general']->getUrl().'",'.
        '"'.mysqli_real_escape_string($db,$parsed['general']->getTitle()).'",'.
        '"'.mysqli_real_escape_string($db,$parsed['general']->getDescription()).'",'.
        '"'.$parsed['general']->getImage().'"'.
    ');';

    mysqli_query($db,$sql);
}

function check_procedure($url){

    // query to retrieve
    $sql = 'SELECT * FROM link_preview WHERE WEB_URL LIKE "'.$url.'"';


    $result = mysqli_query($db,$sql);



    if ((mysqli_num_rows($result) > 0) || !is_null($result)) {
        $data = mysqli_fetch_assoc($result);
        return $data;
    } else {
        return null;
    }
}


$data=check_procedure($url);

if(is_null($data=check_procedure($url))){

    $parsed = extract_url_data($url);

    insert_procedure($db, $parsed);

    $data['WEB_URL']         = $parsed['general']->getUrl();
    $data['URL_TITLE']       = mysqli_real_escape_string($db,$parsed['general']->getTitle());
    $data['URL_DESCRIPTION'] = mysqli_real_escape_string($db,$parsed['general']->getDescription());
    $data['IMAGE_URL']       = $parsed['general']->getImage();
}

echo json_encode($data);

?>
