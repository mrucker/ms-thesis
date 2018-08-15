write-host "minifying..." -foregroundcolor green
Get-ChildItem code\experiment\dev\assets\*.js         -recurse                                | get-content | uglifyjs > code\experiment\prod\assets.js
Get-ChildItem code\experiment\dev\assets\*.css        -recurse                                | get-content            > code\experiment\prod\assets.css
Get-ChildItem code\experiment\dev\libraries\*.js      -recurse                                | get-content | uglifyjs > code\experiment\prod\libraries.js
Get-ChildItem code\experiment\dev\libraries\*.css     -recurse                                | get-content            > code\experiment\prod\libraries.css
Get-ChildItem code\experiment\dev\perf\assets\*.js    -recurse                                | get-content | uglifyjs > code\experiment\prod\perf.assets.js
Get-ChildItem code\experiment\dev\perf\libraries\*.js -recurse | Sort-Object Name -Descending | get-content            > code\experiment\prod\perf.libraries.js
Get-ChildItem code\experiment\dev\perf\*.css          -recurse                                | get-content            > code\experiment\prod\perf.css

write-host "copying..." -foregroundcolor green
Copy-Item -force -recurse "code\experiment\dev\assets\imgs\" -Destination "code\experiment\prod\assets\"

$src = "code\experiment\prod";
$dst = "s3://thesis.markrucker.net";

#--size-only

write-host "compressing..." -foregroundcolor green
gci "$src\*.js"              | % { write-host "$($_.Name) to $($_.Name).gzip"; 7z a "$src\$($_.Name).gzip" "$($_.FullName)" -tgzip -mx9 -bso0 }
gci "$src\*.css"             | % { write-host "$($_.Name) to $($_.Name).gzip"; 7z a "$src\$($_.Name).gzip" "$($_.FullName)" -tgzip -mx9 -bso0 }
gci "$src\assets\imgs\*.png" | % { write-host "$($_.Name) to $($_.Name).gzip"; 7z a "$src\assets\imgs\$($_.Name).gzip" "$($_.FullName)" -tgzip -mx9 -bso0 }

write-host "renaming..." -foregroundcolor green
gci "$src\*.gzip" -recurse | % { write-host "$($_.Name) to $($_.Name.Substring(0,$_.Name.Length-5))"; mv "$($_.FullName)" "$($_.FullName.Substring(0,$_.FullName.Length-5))" -force }

write-host "sync css..." -foregroundcolor green
aws s3 sync "$src" "$dst" --exclude "*" --include "*.css"  --delete --cache-control no-cache --content-encoding "gzip" --content-type "text/css"

write-host "sync js..." -foregroundcolor green
aws s3 sync "$src" "$dst" --exclude "*" --include "*.js"   --delete --cache-control no-cache --content-encoding "gzip" --content-type "application/javascript"

write-host "sync png..." -foregroundcolor green
aws s3 sync "$src\assets\imgs\" "$dst/assets/imgs/" --exclude "*" --include "*.png" --delete --cache-control no-cache --content-encoding "gzip" --content-type "image/png"

write-host "sync html..." -foregroundcolor green
aws s3 sync "$src" "$dst" --exclude "*" --include "*.html" --delete --cache-control no-cache #--content-encoding "gzip" --content-type "text/html"

