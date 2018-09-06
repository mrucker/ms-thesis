$study = 2

$2nd_Experiments = Get-ChildItem ".\data\studies\$study\experiments\*.json" -recurse | get-content | convertfrom-json | Group 'ParticipantId' | % { $_.Group | Sort InsertTimeStamp -Descending | Select -First 1 }
$1st_Experiments = Get-ChildItem ".\data\studies\$study\experiments\*.json" -recurse | get-content | convertfrom-json | Group 'ParticipantId' | % { $_.Group | Sort InsertTimeStamp             | Select -First 1 }

$Questionable_Participant_JSON = $Questionable_Participant_Ids | % { Get-Content ".\data\studies\study_$study\Participants\$_.json" } | ConvertFrom-Json

$2nd_TN = Get-ChildItem ".\data\studies\$study\experiments\*.json" -recurse | get-content | convertfrom-json | Group 'ParticipantId' | % { $_.Group | Sort InsertTimeStamp -Descending | Select -First 1 } | ? {[bool]($_.PSobject.Properties.name -match "T_N")} | Select -ExpandProperty 'T_N'
$1st_TN = Get-ChildItem ".\data\studies\$study\experiments\*.json" -recurse | get-content | convertfrom-json | Group 'ParticipantId' | % { $_.Group | Sort InsertTimeStamp             | Select -First 1 } | ? {[bool]($_.PSobject.Properties.name -match "T_N")} | Select -ExpandProperty 'T_N'

Get-ChildItem .\data\studies\study_2\participants\*.json -recurse | get-content| convertfrom-json