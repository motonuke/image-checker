# Source Files
$procs = "Get-Images.ps1"


#Source File Check
write-host
foreach ($fc in $procs) {
$tp = Test-Path $fc
if (!$tp) {write-host;write-host "REQUIRED source file not found - $fc. Cannot proceed..." -f red;write-host;exit} 
else {write-host "Required Source File located - $fc." -f green}
}

# Source files
. ".\$procs"

# Variable setup
$vcount = 0
$hcount = 0

$tmp = "C:\Users\USERNAME\Pictures\Wallpapers\Tmp"
$vertical = "C:\Users\USERNAME\Pictures\Wallpapers\Vertical"
$horizontal = "C:\Users\USERNAME\Pictures\Wallpapers\Horizontal"
if ($args[0]) {$path = $args[0]} else {$path = $tmp}
# $path
write-host "Getting Image Info..." -f green
$images  = get-images -source $path

write-host "Moving Images..." -f green
foreach ($image in $images) {
# Cleaup output for proper comparison
$image.height = $image.height.SubString(1)
$image.height = $image.height.Trim(" pixels")
$image.width = $image.width.SubString(1)
$image.width = $image.width.Trim(" pixels")
$ratio = ($image.height-$image.width)
# write-host "The image ratio is - "$ratio"" -f yellow
if ($ratio -ge 1) {
	write-host "Found Vertical Image - "$image.name - $image.height x $image.width""
	move-item -path $image.fullname -destination $vertical -erroraction silentlycontinue
	$vcount++
	} 
if ($ratio -lt 1) {
	write-host "Found Horizontal Image - "$image.name - $image.height x $image.width""
	move-item -path $image.fullname -destination $horizontal -erroraction silentlycontinue
	$hcount++
	}
}

Write-host "`nI found $vcount Vertical files..." -f green
Write-host "`nI found $hcount Horizontal files...`n" -f green

# Cleanup files in Tmp Folder
write-host "Cleaning up files in tmp folder that remain (duplicates)" -f yellow
if ($path -eq $tmp) {
write-host "Found normal 'tmp' working folder, performing cleanup" -f yellow
$files  = get-childitem $path
foreach ($file in $files) {remove-item $file.VersionInfo.FileName}
} else {write-host "Non 'tmp' working directory specified, skipping cleaup" -f yellow}

# Sync files to Google Drive folder
write-host "Syncing files to Google Drive for backup" -f yellow
sleep 2
 .\sync.bat
