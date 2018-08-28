$maxDate = Get-ChildItem .\data\entries\participants\*.json -recurse | get-content| convertfrom-json | sort 'InsertTimeStamp' | select -ExpandProperty 'InsertTimeStamp' -Last 1

node './data/queries/update_ptc_exp_obs_entries.js' './data/entries/' $maxDate