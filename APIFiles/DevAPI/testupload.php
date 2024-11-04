    
<?php   

echo "program call";
 if(isset($_POST['avatar']['name']))
        {
echo "inside";
        $file_name = $_FILES['avatar']['name'];
        $file_name = time().'-'.preg_replace("/\s+/","_", $file_name);
        $file_tmpname = $_FILES['avatar']['tmp_name'];
        $file_size = $_FILES['avatar']['size'];
        $file_type = $_FILES['avatar']['type'];
        $file_ext =pathinfo($file_name, PATHINFO_EXTENSION);
        $final_file= "media/".$file_name;
        $upload =move_uploaded_file($file_tmpname, $final_file);
        if($upload) 
            {
echo "upload failed";
            $media__content="http://api.opinito.com/api.dev/".$final_file;
            $media_flag=TRUE;
            }
            else{
echo "upload success";
                $media__content="";
                $media_flag=FALSE;
            }
        }
        else{
echo "Get failed";
            $media__content="";
            $media_flag=TRUE;
        }
?>