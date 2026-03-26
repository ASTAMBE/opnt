<?php

 include ('dbconnection.inc');

 $json_arry = array();
 $q = "select * from OPN_TOPICS" ;
 $result = mysqli_query($db,$q);
 while (($row = mysqli_fetch_array($result)))
    {
        $json_arry[] =  $row;
    }



 $r =  json_encode($json_arry);

 echo $r ;


?>
