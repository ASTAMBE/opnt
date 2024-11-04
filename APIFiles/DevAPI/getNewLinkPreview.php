<?php

    include('includeHeader.inc.php');
    
    // $sql = "CALL insertWebURL(\"https://partha.com/tech-policy/2018/06/dark-web-vendor-oxymonster-turns-out-to-be-a-frenchman-with-luscious-beard\",\"Dark Web vendor “OxyMonster” turns out to be a Frenchman with luscious beard\",\"Gal Vallerius and his beard now face 20 years in prison.\",\"https://cdn.partha.net/wp-content/uploads/2018/06/fl-1527767431-fulkpmwr16-snap-image-723x380.jpg\")";

    $sql = "CALL insertWebURL(\"https://www.cnn.com/2018/10/20/opinions/saudi-arabia-khashoggi-statement-robertson-intl/index.html\",\"Saudi\'s Khashoggi story is preposterous, but MBS will get a pass\",\"\",\"https://cdn.cnn.com/cnnnext/dam/assets/181019184616-jamal-khashoggi-carrera-censura-corte-real-principe-mohammed-bin-salman-periodista-obituario-pkg-00000710-super-tease.jpg\")";

    $json_arry = array();

    $result = mysqli_query($db,$sql);

    if($result == TRUE){
        while (($row = mysqli_fetch_assoc($result))){
            $json_arry[] =  $row;
        }  
        $r =  json_encode($json_arry);
        echo $r;
    }
    else{
         $response = "{\"status\": \"error\"}";
        echo $r;
    }


?>
