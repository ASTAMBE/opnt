<?php
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    header("X-ACCESS-KEY: 57P79st3f8uNaG359hB2109vwIE0lx2k");
    /*-------------------------------------------Start GGGALL ----------------------------------*/
    $arr =array();
    $path1 = '../scraper/GGGALL/';
    if ($handle = opendir($path1))
    {
        while (false !== ($file = readdir($handle))) 
        {
            $basename = basename($file);
            if ($basename == '.' or $basename == '..' )
                continue;
            $Fpath=$path1 . $file; 
            $arr[]=$Fpath; 
        }
        closedir($handle); 
    }

    /*-------------------------------------------End GGGALL ----------------------------------*/
    /*-------------------------------------------Start INDALL ----------------------------------*/
    echo date('d-m-Y H:i:s', time());
    $path1 = '../scraper/INDALL/';
    if ($handle = opendir($path1))
    {
        while (false !== ($file = readdir($handle))) 
        {
            $basename = basename($file);
            if ($basename == '.' or $basename == '..' )
                continue;
            $Fpath=$path1 . $file; 
            $arr[]=$Fpath;  
        }
        closedir($handle); 
    }

    /*-------------------------------------------End INDALL ----------------------------------*/
    /*-------------------------------------------Start USAALL ----------------------------------*/

    $path1 = '../scraper/USAALL/';
    if ($handle = opendir($path1))
    {
        while (false !== ($file = readdir($handle))) 
        {
            $basename = basename($file);
            if ($basename == '.' or $basename == '..' )
                continue;
            $Fpath=$path1 . $file; 
            $arr[]=$Fpath;  
        }
        closedir($handle); 
    }

    /*-------------------------------------------End USAALL ----------------------------------*/
    if(!empty($arr)){
        foreach($arr as $path){ 
            unlink ($path);
        }
        $rtn = array (
            "status"=> "200",
            "message"=>  "Scraper File Removed");
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
