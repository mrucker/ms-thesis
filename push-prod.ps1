#Build

Get-ChildItem code\experiment\html\dev\assets\*.js  -recurse    | get-content | uglifyjs > code\experiment\html\prod\assets.js
Get-ChildItem code\experiment\html\dev\assets\*.css -recurse    | get-content            > code\experiment\html\prod\assets.css

Get-ChildItem code\experiment\html\dev\libraries\*.js -recurse  | get-content | uglifyjs > code\experiment\html\prod\libraries.js
Get-ChildItem code\experiment\html\dev\libraries\*.css -recurse | get-content            > code\experiment\html\prod\libraries.css

$src = "code\experiment\html\prod";
$dst = "s3://thesis.markrucker.net/";

write-host "compressing..." -foregroundcolor green
gci "$src\*.js"   | % { write-host "$($_.Name) to $($_.Name).gzip"; 7z a "$src\$($_.Name).gzip" "$src\$($_.Name)" -tgzip -mx9 -bso0 }
gci "$src\*.css"  | % { write-host "$($_.Name) to $($_.Name).gzip"; 7z a "$src\$($_.Name).gzip" "$src\$($_.Name)" -tgzip -mx9 -bso0 }
#gci "$src\*.html" | % { write-host "$($_.Name) to $($_.Name).gzip"; 7z a "$src\$($_.Name).gzip" "$src\$($_.Name)" -tgzip -mx9 -bso0 }

write-host "renaming..." -foregroundcolor green
gci "$src\*.gzip" | % { write-host "$($_.Name) to $($_.Name.Substring(0,$_.Name.Length-5))"; mv "$src\$($_.Name)" "$src\$($_.Name.Substring(0,$_.Name.Length-5))" -force }

write-host "sync css..." -foregroundcolor green
aws s3 sync "$src" "$dst" --size-only --exclude "*" --include "*.css"  --delete --cache-control no-cache --content-encoding "gzip" --content-type "text/css"

write-host "sync js..." -foregroundcolor green
aws s3 sync "$src" "$dst" --size-only --exclude "*" --include "*.js"   --delete --cache-control no-cache --content-encoding "gzip" --content-type "application/javascript"

write-host "sync html..." -foregroundcolor green
aws s3 sync "$src" "$dst" --size-only --exclude "*" --include "*.html" --delete --cache-control no-cache --content-encoding "gzip" --content-type "text/html"

write-host "sync all other files..." -foregroundcolor green
aws s3 sync "$src" "$dst" --size-only --delete