<?php

// simple script for uploading skins and handle them
//
// 07/2024 Dietmar Stein, info@simracingjustfair.org
//
// NOTE: needs to be run on Windows because of execuiting powershell script

// basically we would agree to the upload
//
$uploadOk = 1;

// vehicle name, startnumber and what folder the files to upload to
//
$target_vehicle = strtolower($_POST["selected_vehicle"]);
$target_dir = "vehicles/".$target_vehicle."/";
$target_start_number = $_POST["startNumber"];

// uploaded files ...
//
$dds_file_upload = strtolower($target_dir . basename($_FILES["ddsToUpload"]["name"]));
$json_file_upload = strtolower($target_dir . basename($_FILES["jsonToUpload"]["name"]));
$region_file_upload = strtolower($target_dir . basename($_FILES["regionToUpload"]["name"]));

// determine mime type - for dds is does not help, because dds are recognized as common binary streams (octet-stream)
// 
//$dds_file_type = mime_content_type($dds_file_upload);
//echo "dds type: ".$dds_file_type."<br>";

// determine the file extension
//
$imageDDSType = strtolower(pathinfo($dds_file_upload,PATHINFO_EXTENSION));
$imageJSONType = strtolower(pathinfo($json_file_upload,PATHINFO_EXTENSION));
$imageREGIONType = strtolower(pathinfo($region_file_upload,PATHINFO_EXTENSION));

// allow dds and json only
//
if($imageJSONType != "json" && $imageDDSType != "dds" && $imageREGIONType != "dds") {
  echo "Bitte nur .dds und .json Dateien hochladen.<br>Please upload .dds and .json files only.<br>";
  $uploadOk = 0;
}

// filenames we expect of file to be uploaded
//
$target_dds_filename = $target_dir."alt".$target_start_number.".dds";
$target_json_filename = $target_dir."alt".$target_start_number.".json";
$target_region_filename = $target_dir."alt".$target_start_number."_region.dds";

// check them expected filenames
//
if($dds_file_upload != $target_dds_filename && $json_file_upload != $target_json_filename && $region_file_upload != $target_region_filename) {
  echo "Datei und Startnummer stimmen nicht überein.<br>Filename(s) and startnumber do not match.";
  $uploadOk = 0;
}


// Check if $uploadOk is set to 0 by an error
//
if ($uploadOk == 0) {
  echo "Datei(en) wurde nicht hochgeladen.<br>File(s) was (were) not uploaded.";

// if everything is ok, try to upload files
//
} else {
  if (move_uploaded_file($_FILES["ddsToUpload"]["tmp_name"], $dds_file_upload) && move_uploaded_file($_FILES["jsonToUpload"]["tmp_name"], $json_file_upload) && move_uploaded_file($_FILES["regionToUpload"]["tmp_name"], $region_file_upload));
	echo "Dateien wurden hochgeladen. RFCMP fuer ". $target_vehicle ." wird erzeugt.<br>Files have been uploaded. RFCMP for ". $target_vehicle ." will be generated.<br>";

	// define the env for running powershell script
	//
	$psPath = "powershell.exe";
	$psDIR = "C:\\nginx\\html\\";
	$psScript = "rf2_league_pkg_builder.ps1 ".$target_vehicle;
	$runScript = $psDIR. $psScript;
	$runCMD = $psPath." ".$runScript." 2>&1"; 

	// run the script
	//
	exec( $runCMD,$out,$ret);

	// print out the output of the powershell script
	// 
	echo "<pre>";
	print_r($out);
	echo "<br><br>";
	echo "</pre>";


	// generate download links for / of content folder
	//
	if ($handle = opendir('./content')) {
		$thelist = "";
		while (false !== ($file = readdir($handle))) {
			if ($file != "." && $file != "..") {
				$thelist .= '<li><a href="content\\'.$file.'">'.$file.'</a></li>';
      		}
    			}
    	closedir($handle);
  	//}

  // print out the list
  //
  echo "RFCMPs to download: <br>". $thelist;

  } else {
    echo "Fehler beim Upload der Dateien.<br>Error uploading files.";
  }
}

?>

