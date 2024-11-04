<?php

 include('includeHeader.inc.php');

 $q = "call topics();";
 $result = mysqli_query($db,$q);
 while (($row = mysqli_fetch_array($result)))
    {
        $json_arry[] =  $row;
    }
 $r =  json_encode($json_arry);
 echo $r ;

?>
