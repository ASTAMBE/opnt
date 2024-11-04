<?php
include('includeHeader.inc.php');

$userid       = $_POST["userid"];
$deviceID     = $_POST["deviceID"];
$fcmToken     = $_POST["fcmToken"];
$deviceType   = $_POST["deviceType"];

$check = "SELECT * from `DEVICE_DATA_MASTER` WHERE `userid`= \"$userid\" and `deviceID` = \"$deviceID\"";
$getData = mysqli_query($db, $check);
if ($getData == TRUE) {
  while (($row = mysqli_fetch_assoc($getData))) {
    $json_arry[] =  $row;
  }
  if (!empty($json_arry)) {
    $update = "UPDATE `DEVICE_DATA_MASTER` SET `fcmToken` = \"$fcmToken\",`deviceType` = \"$deviceType\" WHERE `userid`= \"$userid\" and `deviceID` = \"$deviceID\"";

    $result = mysqli_query($db, $update);
    if ($result == TRUE) {
      $response = "{\"status\": \"success\"}";
    } else {
      $response = "{\"status\": \"error\"}";
    }
  } else {
    $insert = "INSERT INTO `DEVICE_DATA_MASTER` (`userid`, `deviceID`, `fcmToken`, `deviceType`) VALUES (\"$userid\", \"$deviceID\", \"$fcmToken\",\"$deviceType\")";
    $result = mysqli_query($db, $insert);
    if ($result == TRUE) {
      $response = "{\"status\": \"success\"}";
    } else {
      $response = "{\"status\": \"error\"}";
    }
  }
} else {
  $response = "{\"status\": \"error\"}";
  echo $r;
  die;
}

echo $response;
