<?php

$curl = curl_init("http://nydel.sdf.org:9903/");
$result = curl_exec($curl);
$trimmed = substr("$result", 0, -1);
echo "$trimmed";

?>
