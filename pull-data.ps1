param([string]$study)

$maxDate = Get-ChildItem ".\data\studies\$study\participants\*.json" -recurse | get-content| convertfrom-json | sort 'InsertTimeStamp' | select -ExpandProperty 'InsertTimeStamp' -Last 1

if(!$maxDate) {
	$maxDate = '1970-01-01T00:00:00.000Z';
}

write-host "updating for study $($study) after $($maxDate)"

node './data/queries/update_ptc_exp_obs_entries.js' "./data/studies/$study/" $maxDate $study