<?php
    /// Programmer Rohit Kansay // Antino Labs
 
    include('CreateConnection.php');
    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    header("X-ACCESS-KEY: J.4O8SGQFNM%ZJR't8wX99y5a=X0/F");
    $arr =array();
    //$fp1 = fopen("/Data.txt",'w') or die("Unable to open file Data.txt!");
    $path1 = '../scraper/GGGALL/';
    $path2 = '../scraper/INDALL/';
    $path3 = '../scraper/USAALL/';
    $sql="";
    $count=1;
    $scraperdata = fopen("scraperdata.txt", "w") or die("Unable to open scraper data file!");
    $scraperRecords = fopen("scraperRecords.txt", "a") or die("Unable to open scraper data file!");
// Directory one
if ($handle = opendir($path1))
{
    while (false !== ($file = readdir($handle))) 
    {
    	     ///filter for the . and .. basepath files
	         $basename = basename($file);
             if ($basename == '.' or $basename == '..' )
             continue;
             $Fpath=$path1 . $file;   //File location 
             $arr[]=$Fpath;  ///Record the todays file name and address
             $data = file_get_contents($Fpath);
             fwrite($scraperdata, $data);
             $sql= $sql.$data;
	}
			closedir($handle); 
}

// ///Directory two
if ($handle = opendir($path2))
{
    while (false !== ($file = readdir($handle))) 
    {
    	     ///filter for the . and .. basepath files
	         $basename = basename($file);
             if ($basename == '.' or $basename == '..' )
             continue;
             
             $Fpath=$path2 . $file; //File location 

             $arr[]=$Fpath;
             $data = file_get_contents($Fpath);
             fwrite($scraperdata, $data);
             $sql= $sql.$data;
	}
			closedir($handle); 
}
// //Directory three
if ($handle = opendir($path3))
{
    while (false !== ($file = readdir($handle))) 
    {
    	     ///filter for the . and .. basepath files
	         $basename = basename($file);
             if ($basename == '.' or $basename == '..' )
             continue;
             $Fpath=$path3 . $file;//File location 

             $arr[]=$Fpath;
             $data = file_get_contents($Fpath);
             fwrite($scraperdata, $data);
             $sql= $sql.$data;
	}
			closedir($handle); 
}
     /* getting concatinated data */
     if (empty($arr)) {
        $rtn = array (
			"status"=> "200",
			"message"=>  "There is no sql files as of now.");
        http_response_code(200);
        print json_encode($rtn);
   }else{
   $data1 = file_get_contents('scraperdata.txt');
   sleep(10);
    $today = date("mdY_Hi");  
    $str="\n \n ALL".$today." File data start from here \n \n";
    fwrite($scraperRecords, $str);
    fwrite($scraperRecords, $data1);
    /* execute multi query */
	if ($db->multi_query($data1)) {
        foreach($arr as $path)
        {
            if(is_file($path))
            {
               echo "Count =>  "; echo $count++; echo "=> "; echo $path; echo "\n";
            }
            unlink ($path);
        }
        fclose($scraperdata);
        fclose($scraperRecords);
		$rtn = array (
			"status"=> "200",
			"message"=>  "Success Scraper");
        http_response_code(200);
        print json_encode($rtn);
	}else{
	    $rtn = array (
	    	"status"=> "500",
	    	"error"=> "something wrong happened");
        http_response_code(500);
        print json_encode($rtn);
    }}

 ?>