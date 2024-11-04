<?php
include('includeHeader.inc.php');
require __DIR__ . '/vendor/autoload.php';
use LinkPreview\LinkPreview;

$url = $postData['url'];

// procedure to check
$sql = "CALL checkURL(\"$url\")";
$response = mysqli_query($db,$sql);

$json_array = array();

if($response == TRUE) {
	$num_rows = $response->num_rows;

	if($num_rows == 0) {
		
        // Free result set
        $response->close();
        $db->next_result();

		$linkPreview = new LinkPreview($url);
		$parsed = $linkPreview->getParsed();

		$url          = $parsed['general']->getUrl();
		$title        = $parsed['general']->getTitle();
		$description  = $parsed['general']->getDescription();
		$imageUrl     = $parsed['general']->getImage();

		$sql = "CALL insertWebURL(\"$url\",\"$title\",\"$description\",\"$imageUrl\");";
		$result = mysqli_query($db,$sql);

		if($result == FALSE){
			$response = "{\"status\": \"error\"}";
			die($response);
		}

		$data['WEB_URL']         = $url;
		$data['URL_TITLE']       = $title ;
		$data['URL_DESCRIPTION'] = $description;
		$data['IMAGE_URL']       = $imageUrl ;

        echo json_encode($data);

	} else {

        while ($db_obj = $response->fetch_object()) {
            $json_array[] = object_to_array($db_obj);
        }

        echo json_encode($json_array);
    }

}

function object_to_array($data) {
	if (is_array($data) || is_object($data)) {
		$result = array();
		foreach ($data as $key => $value) {
			$result[$key] = object_to_array($value);
		}
		return $result;
	}
	return $data;
}
?>