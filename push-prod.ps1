Get-ChildItem code\experiment\html\dev\assets\*.js  -recurse   | get-content | uglifyjs > code\experiment\html\prod\assets.js
Get-ChildItem code\experiment\html\dev\assets\*.css -recurse   | get-content            > code\experiment\html\prod\assets.css
Get-ChildItem code\experiment\html\dev\libraries\*.js -recurse | get-content | uglifyjs > code\experiment\html\prod\libraries.js

aws s3 sync code\experiment\html\prod s3://thesis.markrucker.net/ --delete