<?php
    include('../../config.dev/dbconnection.inc');
    include('../../config.dev/util.php');
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    header("X-ACCESS-KEY: 57P79st3f8uNaG359hB2109vwIE0lx2k");
    /*-------------------------------------------Start GGGALL ----------------------------------*/
    $arr =array();
    $path1 = '../scraper/GGGALL/';
    $sql="";
    if ($handle = opendir($path1))
    {
        while (false !== ($file = readdir($handle)))
        {
	    echo $file . "\n";
            $basename = basename($file);
            if ($basename == '.' or $basename == '..' )
                continue;

            $Fpath=$path1 . $file; 
            $arr[]=$Fpath;  ///Record the todays file name and address
            $sql .= file_get_contents($Fpath);
        }

        if(!empty($sql)){
            if (!$db->multi_query($sql)) {
                echo "Multi query failed: (" . $db->errno . ") " . $db->error;
            }
            do {
                if ($res = $db->store_result()) {
                    $res->free();
                }
            } while ($db->more_results() && $db->next_result());
        }
        closedir($handle); 
    }

    /*-------------------------------------------End GGGALL ----------------------------------*/
    /*-------------------------------------------Start INDALL ----------------------------------*/

    $path1 = '../scraper/INDALL/';
    $sql="";
    if ($handle = opendir($path1))
    {
        while (false !== ($file = readdir($handle))) 
        {
	    echo $file . "\n"; 
            $basename = basename($file);
            if ($basename == '.' or $basename == '..' )
                continue;
            $Fpath=$path1 . $file; 
            $arr[]=$Fpath;  ///Record the todays file name and address
            $sql .= file_get_contents($Fpath);
        }
        if(!empty($sql)){
            if (!$db->multi_query($sql)) {
                echo "Multi query failed: (" . $db->errno . ") " . $db->error;
            }
            do {
                if ($res = $db->store_result()) {
                    $res->free();
                }
            } while ($db->more_results() && $db->next_result());
        }
        closedir($handle); 
    }

    /*-------------------------------------------End INDALL ----------------------------------*/
    /*-------------------------------------------Start USAALL ----------------------------------*/

    $path1 = '../scraper/USAALL/';
    $sql="";
    if ($handle = opendir($path1))
    {
        while (false !== ($file = readdir($handle))) 
        {
	    echo $file . "\n";
            $basename = basename($file);
            if ($basename == '.' or $basename == '..' )
                continue;
            $Fpath=$path1 . $file; 
            $arr[]=$Fpath;  ///Record the todays file name and address
            $sql .= file_get_contents($Fpath);
        }
        if(!empty($sql)){
            if (!$db->multi_query($sql)) {
                echo "Multi query failed: (" . $db->errno . ") " . $db->error;
            }
            do {
                if ($res = $db->store_result()) {
                    $res->free();
                }
            } while ($db->more_results() && $db->next_result());
        }
        closedir($handle); 
    }

    /*-------------------------------------------End USAALL ----------------------------------*/
    if(!empty($arr)){
        $time_stamp = date("mdY_Hi");
        $timestamp = "All".$time_stamp;
        $q = "call STP_MONITOR()";
        $result = mysqli_query($db,$q);

        $rtn = array (
            "status"=> "200",
            "message"=>  "Success Scraper");
        http_response_code(200);
        print json_encode($rtn);
	//print json_encode($rtn);
    }

 ?>

