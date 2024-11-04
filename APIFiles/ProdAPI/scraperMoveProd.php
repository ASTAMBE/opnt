<?php
    include('../../config.prod/dbconnection.inc');
    include('../../config.prod/util.php');
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    header("X-ACCESS-KEY: J.4O8SGQFNM%ZJR't8wX99y5a=X0/F");
    /*-------------------------------------------Start GGGALL ----------------------------------*/
    $arr =array();
    $path1 = '../scraper/GGGALL/';
    $sql="";
    $scraperdata = fopen("scraperdata.txt", "w") or die("Unable to open scraper data file!");
    $scraperRecords = fopen("scraperRecords.txt", "a") or die("Unable to open scraper data file!");
    if ($handle = opendir($path1))
    {
        while (false !== ($file = readdir($handle))) 
        {
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
    if(!empty($sql)){
        fwrite($scraperdata, $sql);
        $today = date("mdY_Hi");  
        $str="\n \n GGGALL".$today." File data start from here \n \n";
        fwrite($scraperRecords, $str);
        fwrite($scraperRecords, $sql);
    }
    fclose($scraperdata);
    fclose($scraperRecords);

    /*-------------------------------------------End GGGALL ----------------------------------*/
    /*-------------------------------------------Start INDALL ----------------------------------*/

    $path1 = '../scraper/INDALL/';
    $sql="";
    $scraperdata = fopen("scraperdata.txt", "w") or die("Unable to open scraper data file!");
    $scraperRecords = fopen("scraperRecords.txt", "a") or die("Unable to open scraper data file!");
    if ($handle = opendir($path1))
    {
        while (false !== ($file = readdir($handle))) 
        {
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
    if(!empty($sql)){
        fwrite($scraperdata, $sql);
        $today = date("mdY_Hi");  
        $str="\n \n GGGALL".$today." File data start from here \n \n";
        fwrite($scraperRecords, $str);
        fwrite($scraperRecords, $sql);
    }
    fclose($scraperdata);
    fclose($scraperRecords);

    /*-------------------------------------------End INDALL ----------------------------------*/
    /*-------------------------------------------Start USAALL ----------------------------------*/

    $path1 = '../scraper/USAALL/';
    $sql="";
    $scraperdata = fopen("scraperdata.txt", "w") or die("Unable to open scraper data file!");
    $scraperRecords = fopen("scraperRecords.txt", "a") or die("Unable to open scraper data file!");
    if ($handle = opendir($path1))
    {
        while (false !== ($file = readdir($handle))) 
        {
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
    if(!empty($sql)){
        fwrite($scraperdata, $sql);
        $today = date("mdY_Hi");  
        $str="\n \n GGGALL".$today." File data start from here \n \n";
        fwrite($scraperRecords, $str);
        fwrite($scraperRecords, $sql);
    }
    fclose($scraperdata);
    fclose($scraperRecords);

    /*-------------------------------------------End USAALL ----------------------------------*/
    if(!empty($arr)){
        $time_stamp = date("mdY_Hi");
        $timestamp = "All".$time_stamp;
        $q = "call STP_MONITOR(\"$timestamp\")";
        $result = mysqli_query($db,$q);

        $rtn = array (
            "status"=> "200",
            "message"=>  "Success Scraper");
        http_response_code(200);
        print json_encode($rtn);
    }
    else{
        $rtn = array (
            "status"=> "200",
            "message"=>  "There is no sql files as of now.");
        http_response_code(200);
        print json_encode($rtn);
    }

 ?>
