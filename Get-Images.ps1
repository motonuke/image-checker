#Requires -Version 4

function Get-Attributes {

$com = (New-Object -ComObject Shell.Application).NameSpace('C:\')
for ($index = 1; $index -ne 400; $index++) {
    New-Object -TypeName PSCustomObject -Property @{
        IndexNumber = $Index
        Attribute = $com.GetDetailsOf($com,$index)
    } | Where-Object {$_.IndexNumber}
} 

}

function Get-Images {
<# 
 .SYNOPSIS
  Script to get image file information like 'DateTaken'

 .DESCRIPTION
  Script to get image file information like 'DateTaken'
  Script returns a PS object containing image file(s) information

 .PARAMETER Source
  Path to one or more folders where image files are located

 .PARAMETER Extension
  One or more image file extensions, such as .jpg and .gif
  If no extensions are specified, the script looks for .jpg and .gif 
  image files by default.

 .EXAMPLE
  Get-Images -Source E:\Pictures\001 -Extension .jpg
  This example will return information on image files with .jpg extension in the given folder and its subfolders

 .EXAMPLE
  Get-Images e:\pictures\001,e:\pictures\005 -Verbose
  This example gets image information on images files in the 2 specified folders, showing verbose messages during processing

 .EXAMPLE
  $Images = Get-Images e:\pictures\001,e:\pictures\005 | 
    Select Name,@{N='Size(KB)';E={[Math]::Round($_.Size/1KB,0)}},DateTaken,CameraMaker,Width,Height | Sort DateTaken -Descending
  $Images | Format-Table -AutoSize # Display on console
  $Images | Out-GridView # Disply on PowerShell_ISE gridview
  $Images | Export-CSV .\myimages.csv -NoType # Save to CSV

 .EXAMPLE
    # Move image files from $SourceFolders to year based folders under $RootFolder based on DateTaken
    $SourceFolders = @('e:\pictures\001','e:\pictures\005')
    $RootFolder    = 'd:\sandbox\pics'
    Get-Images $SourceFolders | % {
        $YearTaken = $_.DateTaken.Split('/')[2].Split(' ')[0]
        if (-not (Test-Path -Path "$RootFolder\$YearTaken")) { 
            "Creating folder '$RootFolder\$YearTaken'"
            New-Item -Path "$RootFolder\$YearTaken" -ItemType Directory -Force -Confirm:$false
        }
        "Moving image '$($_.Name)' from '$(Split-Path -Path $_.FullName )' to '$RootFolder\$YearTaken'"
        Move-Item -Path $_.FullName -Destination "$RootFolder\$YearTaken" -Force -Confirm:$false
    }

 .OUTPUTS
  Script will return an array of PS Objects, each has the following properties:
    Name         
    FullName      
    Size         
    Type         
    Extension     
    DateModified 
    DateCreated   
    DateAccessed  
    DateTaken   
    CameraModel  
    CameraMaker  
    BitDepth      
    HorizontalRes 
    VerticalRes 
    Width       
    Height        

 .LINK
  http://superwidgets.wordpress.com/category/powershell/
  http://superwidgets.wordpress.com/2014/08/15/powershell-script-to-get-detailed-image-file-information-such-as-datetaken/
  
 .NOTES
  Script by Sam Boutros
  v1.0 - 1/11/2015
  
  Modified by Motonuke
  -Added more default file extensions
  -File attributes are automatically detected and set, no longer hard coded based on OS. Legacy code still intact for reference.
  31-Jan-2019

#>

    [CmdletBinding()] 
    Param(
    [Parameter(Mandatory=$true,  Position=0)]
        [ValidateScript({ (Test-Path -Path $_) })]
        [String[]]$Source, 
    [Parameter(Mandatory=$false, Position=1)]
        [String[]]$Extension = @('.jpg','.gif','.jpeg','.png')
    )

     
    # Get folder list
    $Folders = @()
    # $Duration = Measure-Command { 
        # $Source | % { $Folders += (Get-ChildItem -Path $Source -Recurse -Directory -Force).FullName }
    # }
	$Duration = Measure-Command { 
	$Source | % { 
		$Subfolders = (Get-ChildItem -Path $Source -Recurse -Directory -Force).FullName 
		if ($Subfolders -ne $null)
		{
			$Folders += (Get-ChildItem -Path $Source -Recurse -Directory -Force).FullName 
		}
	}
}
    Write-Verbose "Got '$($Folders.Count)' folder(s) in $($Duration.Minutes):$($Duration.Seconds) mm:ss"
    $Folders += $Source

## Brute force file attribute code, not needed
	# $winver = [System.Environment]::OSVersion.Version
	# $attrib_ext = 157
	# $attrib_bitd = 167
	# $attrib_hres = 168
	# $attrib_vres = 170
	# $attrib_width = 169
	# $attrib_height = 171
	
	# if ($winver.major -eq 10 -and $winver.build -ge 16299) {
		# $attrib_ext = 159
		# $attrib_bitd = 169
		# $attrib_hres = 170
		# $attrib_vres = 172
		# $attrib_width = 171
		# $attrib_height = 173
		# }
		
## Setting File Object Attributes, these seem to vary between OS versions - TW
$names = @("file extension","bit depth","horizontal resolution","vertical resolution","width","height")
$attribs = Get-Attributes | where {$_.Attribute -in $names} | sort IndexNumber
$attrib_ext = $attribs[0].IndexNumber
$attrib_bitd = $attribs[1].IndexNumber
$attrib_hres = $attribs[2].IndexNumber
$attrib_width = $attribs[3].IndexNumber
$attrib_vres = $attribs[4].IndexNumber
$attrib_height = $attribs[5].IndexNumber

    $Images = @()
    $objShell  = New-Object -ComObject Shell.Application
    $Folders | % {

        $objFolder = $objShell.namespace($_)
        foreach ($File in $objFolder.items()) { 
			
            if ($objFolder.getDetailsOf($File, $attrib_ext) -in $Extension) {

                Write-Verbose "Processing file '$($File.Path)'"
                $Props = [ordered]@{
                    Name          = $File.Name
                    FullName      = $File.Path
                    Size          = $File.Size
                    Type          = $File.Type
                    Extension     = $objFolder.getDetailsOf($File,$attrib_ext)
                    DateCreated   = $objFolder.getDetailsOf($File,4)
                    DateModified  = $objFolder.getDetailsOf($File,3)
                    DateAccessed  = $objFolder.getDetailsOf($File,5)
                    DateTaken     = $objFolder.getDetailsOf($File,12)
                    CameraModel   = $objFolder.getDetailsOf($File,30)
                    CameraMaker   = $objFolder.getDetailsOf($File,32)
                    BitDepth      = [int]$objFolder.getDetailsOf($File,$attrib_bitd)
                    HorizontalRes = $objFolder.getDetailsOf($File,$attrib_hres)
                    VerticalRes   = $objFolder.getDetailsOf($File,$attrib_vres)
                    Width         = $objFolder.getDetailsOf($File,$attrib_width)
                    Height        = $objFolder.getDetailsOf($File,$attrib_height)
                }
                $Images += New-Object -TypeName psobject -Property $Props

            } # if $Extension

        } # foreach $File

    } # foreach $Folder
    $Images

} # function
