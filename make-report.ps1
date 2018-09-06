param([string]$study)

if(!$study) {
	write-host "You must indicate which study you want to report on.";
	return;
}

if(! (test-path ".\data\studies\$study\") ) {
	write-host "Sorry. We were unable to find the data for study '$study'";
	return;
}

$participants = Get-ChildItem ".\data\studies\$study\participants\*.json" -recurse | get-content| convertfrom-json
$experiments  = Get-ChildItem ".\data\studies\$study\experiments\*.json"  -recurse | get-content| convertfrom-json

$participant_hash = $participants | % { @{"$($_.id)" = $_ } }

#touch statistics between all experiments for a participant
$participant_experiment_stats = $experiments | Group 'ParticipantId' | Select `
	 @{Name="E_CNT"      ;Expression={ $_.Count } } `
	,@{Name="P_ID"       ;Expression={ $_.Name } } `
	,@{Name="AVG_T"      ;Expression={ $_.Group | Measure 'T_N' -Average | select -ExpandProperty 'Average' }} `
	,@{Name="ONE_T"      ;Expression={ $_.Group | Sort InsertTimeStamp             | Select -First 1 -ExpandProperty 'T_N' }} `
	,@{Name="TWO_T"      ;Expression={ $_.Group | Sort InsertTimeStamp -Descending | Select -First 1 -ExpandProperty 'T_N' }} `
	,@{Name="ONE_O"      ;Expression={ $_.Group | Sort InsertTimeStamp             | Select -First 1 -ExpandProperty 'O_N' }} `
	,@{Name="TWO_O"      ;Expression={ $_.Group | Sort InsertTimeStamp -Descending | Select -First 1 -ExpandProperty 'O_N' }} `
	,@{Name="ONE_E"      ;Expression={ $_.Group | Sort InsertTimeStamp             | Select -First 1 -ExpandProperty 'Id' }} `
	,@{Name="TWO_E"      ;Expression={ $_.Group | Sort InsertTimeStamp -Descending | Select -First 1 -ExpandProperty 'Id' }} `
	,@{Name="Resolution" ;Expression={ $_.Group | select -First 1 -ExpandProperty 'Resolution' }} `
	,@{Name="Area"       ;Expression={($_.Group | select -First 1 -ExpandProperty 'Resolution' | select -First 1) * ($_.Group | select -First 1 -ExpandProperty 'Resolution' | select -Last 1) } }

$participant_experiment_stats = $participant_experiment_stats | % { $_ | Add-Member @{"Machine"=($participant_hash.$($_.P_ID)).Machine} -PassThru }
$participant_experiment_stats = $participant_experiment_stats | % { $_ | Add-Member @{"Age"=($participant_hash.$($_.P_ID)).Age}  -PassThru }
$participant_experiment_stats = $participant_experiment_stats | % { $_ | Add-Member @{"First"=($participant_hash.$($_.P_ID)).First} -PassThru }
$participant_experiment_stats = $participant_experiment_stats | % { $_ | Add-Member @{"Input"=($participant_hash.$($_.P_ID)).Device} -PassThru }
$participant_experiment_stats = $participant_experiment_stats | % { $_ | Add-Member @{"Browser"=($participant_hash.$($_.P_ID)).Browser} -PassThru }
$participant_experiment_stats = $participant_experiment_stats | % { $_ | Add-Member @{"System"=($participant_hash.$($_.P_ID)).System} -PassThru }

#$avg_machine_area_hash = $participant_experiment_stats | group 'Machine' | select Name, @{Name='Area_AVG';Expression={ $_.Group | sort 'Area' | select -skip 1 | sort 'Area' -Descending | select -skip 1 | Measure 'Area' -average | select -expandproperty 'average' }} | % { @{$_.Name = [math]::Round($_.Area_AVG) } }
#$participant_experiment_stats = $participant_experiment_stats | % { $_ | Add-Member @{"Area_AVG"=($avg_machine_area_hash.$($_.Machine))} -PassThru }

$participant_experiment_stats | sort 'AVG_T' | format-table 'AVG_T', 'ONE_T', 'TWO_T', 'E_CNT', 'ONE_E', 'TWO_E', 'Area', 'Machine', 'Age', 'First', 'Input'	| Out-String |% {Write-Host $_}

$participant_experiment_stats