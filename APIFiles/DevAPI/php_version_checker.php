<?php
$directory = getcwd(); // Get the current directory
$files = scandir($directory); // Get all files in the directory

foreach ($files as $file) {
    if (is_file($file) && pathinfo($file, PATHINFO_EXTENSION) === 'php') {
        $content = file_get_contents($file); // Get the content of each PHP file
        
        // Use regular expressions to find the PHP version
        preg_match('/PHP\s?(\d+\.\d+\.\d+)/i', $content, $matches);
        
        if (isset($matches[1])) {
            echo "PHP version in file $file: " . $matches[1] . "\n";
        } else {
            echo "No PHP version found in file $file\n";
        }
    }
}
?>

