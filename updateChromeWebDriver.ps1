function Unzip($zipfile, $outdir)
{
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $archive = [System.IO.Compression.ZipFile]::OpenRead($zipfile)
    foreach ($entry in $archive.Entries)
    {
        $entryTargetFilePath = [System.IO.Path]::Combine($outdir, $entry.FullName)
        $entryDir = [System.IO.Path]::GetDirectoryName($entryTargetFilePath)
        
        #Ensure the directory of the archive entry exists
        if(!(Test-Path $entryDir )){
            New-Item -ItemType Directory -Path $entryDir | Out-Null 
        }
        
        #If the entry is not a directory entry, then extract entry
        if(!$entryTargetFilePath.EndsWith("\")){
            [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $entryTargetFilePath, $true);
        }
    }
}
$driverDir = $args[0]
$ChromePath = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
$chromeVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($ChromePath).ProductVersion
$chromeVersion = $chromeVersion.Split('.')[0]

$w = Invoke-WebRequest -Uri "https://chromedriver.chromium.org/"
$searchString = "https://chromedriver.storage.googleapis.com/index.html?path=" + $chromeVersion + ".*"
$resourceLink = $w.Links | select href | where href -like $searchString
$latestStable = $resourceLink[0].href.split('=')[-1].replace('/','')
$chromeDriverURL32 = "https://chromedriver.storage.googleapis.com/" + $latestStable + "/chromedriver_win32.zip"
$chromeDriverURL64 = "https://chromedriver.storage.googleapis.com/" + $latestStable + "/chromedriver_win64.zip"

$w2 = Invoke-WebRequest -Uri $chromeDriverURL32
if ($w2.StatusCode -eq 200) { 
   Invoke-WebRequest -Uri $chromeDriverURL32 -OutFile "chromedriver.zip" 
   Unzip -zipfile $PSScriptRoot\chromedriver.zip -outdir $PSScriptRoot\chromedriver
   }
else {
   Invoke-WebRequest -Uri $chromeDriverURL64 -OutFile "chromedriver.zip" 
   Unzip -zipfile $PSScriptRoot\chromedriver.zip -outdir $PSScriptRoot\chromedriver
}
Copy-Item $PSScriptRoot\chromedriver\chromedriver.exe $driverDir\chromedriver.exe