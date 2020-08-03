#This script is a modification of an original script designed by Steve Campbell and provided by PowerBI.tips
#It creates a copy of existing PBIX file with everything related to Data Model intact, but removes all presentation layer (i.e. all visuals and report pages)
#BE WARNED this will alter Power BI files so please make sure you know what you are doing, and always back up your files!
#This is not supported by Microsoft and changes to future file structures could cause this code to break


#Choose pbix funtions
Function Source-Filename($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "PBIX (*.pbix)| *.pbix"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}

Function Target-FileName($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "PBIX (*.pbix)| *.pbix"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}


#Error check function
function IsFileLocked([string]$filePath){
    Rename-Item $filePath $filePath -ErrorVariable errs -ErrorAction SilentlyContinue
    return ($errs.Count -ne 0)
}


#Function to Modify files
Function Modify-PBIX([string]$inputpath, [string[]]$filestoremove){

    #Make temp folder
    $temppth = $env:TEMP  + "\PBI TEMP"
    If(!(test-path $temppth))
    {New-Item -ItemType Directory -Force -Path $temppth}

    #Unpackage pbix
    $zipfile = ($inputpath).Substring(0,($inputpath).Length-4) + "zip"
    Rename-Item -Path $inputpath -NewName  $zipfile
              
    #Initialise object
    $ShellApp = New-Object -COM 'Shell.Application'
    $InputZipFile = $ShellApp.NameSpace( $zipfile )

    #Move files to temp
    foreach ($fn in $filestoremove){ 
       $InputZipFile.Items() | ? {  ($_.Name -eq $fn) }  | % {
       $ShellApp.NameSpace($temppth).MoveHere($_)   }  
    }
    
    #Delete temp
    Remove-Item ($temppth) -Recurse
    
    #Repackage 
    Rename-Item -Path $zipfile -NewName $inputpath  
}




#Choose files and check for errors
try {$SourceFilePath = Source-Filename}
catch { "Incompatible File" }


If([string]::IsNullOrEmpty($SourceFilePath )){            
    exit } 

elseif ( IsFileLocked($SourceFilePath) ){
    exit } 

try {$TargetFilePath = Target-FileName}
catch { "Incompatible File" }

If([string]::IsNullOrEmpty($TargetFilePath )){            
    exit } 


#Run Script
else{    

    #set variables
    $modelfiles   = @( 'SecurityBindings', 'Report')
    
    #Copy files
    Copy-Item $SourceFilePath -Destination $TargetFilePath

    #modify files
    Modify-PBIX $TargetFilePath $modelfiles
    
}


