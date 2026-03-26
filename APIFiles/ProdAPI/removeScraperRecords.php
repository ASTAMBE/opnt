<?php
$rows = file("scraperRecords.txt");    
$date = new DateTime('7 days ago');
$sevenDaysAgo=$date->format('mdY');
foreach($rows as $key => $row) {
    if(stripos(trim($row),$sevenDaysAgo)) {
        break;
    }
    else
    {
    unset($rows[$key]);   
    }
    
}

if(file_put_contents("scraperRecordsCopy.txt", implode(" ", $rows)))
{

    if (!copy("scraperRecordsCopy.txt", "scraperRecords.txt")) {
    echo "File cannot be copied! \n";
    }
    else {
        echo "Data Removed Successfully!";
        $file_handle = fopen('scraperRecordsCopy.txt', 'w');
        fwrite($file_handle, " ");
        fclose($file_handle);
    }

}

?>