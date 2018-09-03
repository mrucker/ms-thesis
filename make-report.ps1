$study = 2

$Questionable_Experiments = Get-ChildItem ".\data\studies\$study\experiments\*.json" -recurse | get-content| convertfrom-json | ? { [int]$_.T_N -gt 100} | select 'Id', 'ParticipantId'

$Questional_Participant_Ids = $Questionable_Experiments | select -ExpandProperty 'ParticipantId' | Sort | Get-Unique
$Questional_Experiments_Ids = $Questionable_Experiments | select -ExpandProperty 'Id'            | Sort | Get-Unique

$2nd_Experiments = Get-ChildItem ".\data\studies\$study\experiments\*.json" -recurse | get-content | convertfrom-json | Group 'ParticipantId' | % { $_.Group | Sort InsertTimeStamp -Descending | Select -First 1 }
$1st_Experiments = Get-ChildItem ".\data\studies\$study\experiments\*.json" -recurse | get-content | convertfrom-json | Group 'ParticipantId' | % { $_.Group | Sort InsertTimeStamp | Select -First 1 }

$Questionable_Participant_JSON = $Questionable_Participant_Ids | % { Get-Content ".\data\studies\study_$study\Participants\$_.json" } | ConvertFrom-Json

$2nd_TN = Get-ChildItem ".\data\studies\$study\experiments\*.json" -recurse | get-content | convertfrom-json | Group 'ParticipantId' | % { $_.Group | Sort InsertTimeStamp -Descending | Select -First 1 } | ? {[bool]($_.PSobject.Properties.name -match "T_N")} | Select -ExpandProperty 'T_N'
$1st_TN = Get-ChildItem ".\data\studies\$study\experiments\*.json" -recurse | get-content | convertfrom-json | Group 'ParticipantId' | % { $_.Group | Sort InsertTimeStamp             | Select -First 1 } | ? {[bool]($_.PSobject.Properties.name -match "T_N")} | Select -ExpandProperty 'T_N'

#Second TN stats
Get-ChildItem ".\data\studies\$study\experiments\*.json" -recurse | get-content | convertfrom-json | Group 'ParticipantId' | % { $_.Group | Sort InsertTimeStamp -Descending | Select -First 1 } | ? {[bool]($_.PSobject.Properties.name -match "T_N")} | Select -ExpandProperty 'T_N' | Measure -Average -Maximum -Minimum
#First TN stats
Get-ChildItem ".\data\studies\$study\experiments\*.json" -recurse | get-content | convertfrom-json | Group 'ParticipantId' | % { $_.Group | Sort InsertTimeStamp             | Select -First 1 } | ? {[bool]($_.PSobject.Properties.name -match "T_N")} | Select -ExpandProperty 'T_N' | Measure -Average -Maximum -Minimum

#First_Time Stats

Get-ChildItem .\data\studies\study_2\participants\*.json -recurse | get-content| convertfrom-json