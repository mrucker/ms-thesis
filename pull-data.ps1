$maxDate = Get-ChildItem .\data\entries\study_2\participants\*.json -recurse | get-content| convertfrom-json | sort 'InsertTimeStamp' | select -ExpandProperty 'InsertTimeStamp' -Last 1
$studyId = 2

write-host "updating for study $($studyId) after $($maxDate)"

node './data/queries/update_ptc_exp_obs_entries.js' './data/entries/study_2/' $maxDate $studyId