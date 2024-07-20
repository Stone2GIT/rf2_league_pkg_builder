<!DOCTYPE html>
<html>
<body>

<?php  
function getDirs($path){  
    // avoid . and .. being listed as an option in pull down while scanning $path
    $contents=array_diff(scandir($path), array('..', '.'));  

    // create an array with the scanned directory names
    $dirs = array();  

    foreach($contents as $content){  
	// only add to array if it is not a file ...
        if(!is_file($content)){  
            $dirs[] = $content;  
        }  
    }  

    // return the array
    return $dirs;  
}  
?>  

<form action="upload.php" method="post" enctype="multipart/form-data">

  Select skin to upload (.dds and .json files are allowed):
<br>
<br>
  <label for="skin_file">Choose alt.dds file:</label>
  <input type="file" name="ddsToUpload" id="fileToUpload" accept=".dds">

<br>
  <label for="json_file">Choose alt.json file:</label>
  <input type="file" name="jsonToUpload" id="fileToUpload" accept=".json">
<br>
  <label for="region_file">Choose alt_region.dds file:</label>
  <input type="file" name="regionToUpload" id="fileToUpload" accept=".dds">
<br>
  <label for="startnumber">Enter startnumber (with leading zero!):</label>
  <input type="text" name="startNumber" id="startNumber">
<br>

  <label for="selected_vehicle">Choose your car:</label>
	<select name="selected_vehicle">  
		<?php   
		$vehicle_folders = "vehicles";
		foreach(getDirs($vehicle_folders) as $vehicle)  
			{  
			echo '<option class="'.$vehicle_folders.'">'. $vehicle . '</option>';  
			}   
		?>
	</select>
<br>
<br>
	<input type="submit" value="Upload skin files">
</form>

</body>
</html>
