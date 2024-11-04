 <?php
  include ('dbconnection.inc');

          $topicid = $_GET['topicid'];
  
          if (!$topicid || $topicid == ""){
                   $response = "{\"status\": \"error\"}";
                  die($response);
           }
          else{
                  $json_arry = array();
                  $q = "SELECT KEYID, KEYWORDS FROM OPN_P_KW WHERE TOPICID = \"$topicid\" ORDER BY IRANK;" ;
                  $result = mysqli_query($db,$q);
                  if($result == TRUE){
                  while (($row = mysqli_fetch_array($result))){
                          $json_arry[] =  $row;
                   }
                  $r =  json_encode($json_arry);
                  echo $r;
                  }
                  else{
                  $response = "{\"status\": \"error\"}";
                  echo $r;
                  }
          }
  
  
  ?>
