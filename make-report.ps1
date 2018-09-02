$Study = 2

$Questionable_Experiments = Get-ChildItem ".\data\entries\study_$Study\experiments\*.json" -recurse | get-content| convertfrom-json | ? { [int]$_.T_N -gt 100} | select 'Id', 'ParticipantId'

$Questional_Participant_Ids = $Questionable_Experiments | select -ExpandProperty 'ParticipantId' | Sort | Get-Unique
$Questional_Experiments_Ids = $Questionable_Experiments | select -ExpandProperty 'Id'            | Sort | Get-Unique

$Second_Experiments = Get-ChildItem ".\data\entries\study_$Study\experiments\*.json" -recurse | get-content | convertfrom-json | Group 'ParticipantId' | % { $_.Group | Sort InsertTimeStamp -Descending | Select -First 1 }
$First_Experiments = Get-ChildItem ".\data\entries\study_$Study\experiments\*.json" -recurse | get-content | convertfrom-json | Group 'ParticipantId' | % { $_.Group | Sort InsertTimeStamp | Select -First 1 }

$Questionable_Participant_JSON = $Questionable_Participant_Ids | % { Get-Content ".\data\entries\study_$Study\Participants\$_.json" } | ConvertFrom-Json

$2nd_TN = Get-ChildItem ".\data\entries\study_$Study\experiments\*.json" -recurse | get-content | convertfrom-json | Group 'ParticipantId' | % { $_.Group | Sort InsertTimeStamp -Descending | Select -First 1 } | ? {[bool]($_.PSobject.Properties.name -match "T_N")} | Select -ExpandProperty 'T_N'
$1st_TN = Get-ChildItem ".\data\entries\study_$Study\experiments\*.json" -recurse | get-content | convertfrom-json | Group 'ParticipantId' | % { $_.Group | Sort InsertTimeStamp             | Select -First 1 } | ? {[bool]($_.PSobject.Properties.name -match "T_N")} | Select -ExpandProperty 'T_N'

#Second TN stats
Get-ChildItem ".\data\entries\study_$Study\experiments\*.json" -recurse | get-content | convertfrom-json | Group 'ParticipantId' | % { $_.Group | Sort InsertTimeStamp -Descending | Select -First 1 } | ? {[bool]($_.PSobject.Properties.name -match "T_N")} | Select -ExpandProperty 'T_N' | Measure -Average -Maximum -Minimum
#First TN stats
Get-ChildItem ".\data\entries\study_$Study\experiments\*.json" -recurse | get-content | convertfrom-json | Group 'ParticipantId' | % { $_.Group | Sort InsertTimeStamp             | Select -First 1 } | ? {[bool]($_.PSobject.Properties.name -match "T_N")} | Select -ExpandProperty 'T_N' | Measure -Average -Maximum -Minimum

Get-ChildItem .\data\entries\study_2\participants\*.json -recurse | get-content| convertfrom-json