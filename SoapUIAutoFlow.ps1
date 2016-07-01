# an example of automation flow of SoapUI and Fiddler
# Fidder as an proxy of Windows authentication. 

function FuncCheckService{
    param($ServiceName)
    $arrService = Get-Service -Name $ServiceName
    if ($arrService.Status -ne "Running"){
        Start-Service $ServiceName
        Write-Host "Starting " $ServiceName " service" 
        " ---------------------- " 
        " Service is now started"
    }
    if ($arrService.Status -eq "running"){ 
        Write-Host "$ServiceName service is already started"
    }
 }


$Testfolder = "C:\AutoTest\"
$ResultFolder = "C:\AutoTest\Result\"
$FiddlerExe = @"
"c:\Program Files (x86)\Fiddler2\Fiddler.exe"
"@

$FiddlerPath = "c:\Program Files (x86)\Fiddler2\"

$SoapUIexe = @"
"C:\Program Files\SmartBear\SoapUI-5.2.1\bin\SoapUI-5.2.1.exe"
"@

$SoapUIPath = "C:\Program Files\SmartBear\SoapUI-5.2.1\bin\"

$SoapUIBat = @"
"C:\Program Files\SmartBear\SoapUI-5.2.1\bin\testrunner.bat"
"@

$soapUILoadBat = @"
C:\Program Files\SmartBear\SoapUI-5.2.1\bin\loadtestrunner.bat
"@
$instpath = "C:\TestInstallation"

FuncCheckService SimCorpDimensionServiceAgentTF-AF

<#Start-Service SimCorpDimensionServiceAgentTF-AF
#Start-Sleep -s 60
#>

start-process -wait ($instpath + "SvcCtl.exe") -ArgumentList ("service start -id=000 -config=XXXXXXX")
start-process -wait ($instpath + "SvcCtl.exe") -ArgumentList ("service start -id=000 -config=XXXXXXX")
start-process -wait ($instpath + "SvcCtl.exe") -ArgumentList ("service start -id=000")
Start-Sleep -s 60



$Testfolder = "C:\AutoTest\"
$ResultFolder = "C:\AutoTest\Result\"
$FiddlerExe = @"
"c:\Program Files (x86)\Fiddler2\Fiddler.exe"
"@

$FiddlerPath = "c:\Program Files (x86)\Fiddler2\"

$SoapUIexe = @"
"C:\Program Files\SmartBear\SoapUI-5.2.1\bin\SoapUI-5.2.1.exe"
"@

$SoapUIPath = "C:\Program Files\SmartBear\SoapUI-5.2.1\bin\"

$SoapUIBat = @"
"C:\Program Files\SmartBear\SoapUI-5.2.1\bin\testrunner.bat"
"@

$soapUILoadBat = @"
C:\Program Files\SmartBear\SoapUI-5.2.1\bin\loadtestrunner.bat
"@
$instpath = "c:\TestInstallation"


<#Start-Service SimCorpDimensionServiceAgentTF-AF
#Start-Sleep -s 60
#>
start-process -wait ($instpath + "SvcCtl.exe") -ArgumentList ("service start -id=000 -config=XXXXX")
start-process -wait ($instpath + "SvcCtl.exe") -ArgumentList ("service start -id=001 -config=YYYYY")
start-process -wait ($instpath + "SvcCtl.exe") -ArgumentList ("service start -id=002")
Start-Sleep -s 120


#Kill Fiddler and SoapUI process
Stop-Process -processname Fiddler.exe
Stop-Process -processname SoapUI*



# Start Fiddler w/o script (Not used, use start SoapUI without proxy setting instead)
#Start-Process $FiddlerExe -ArgumentList ("-noscript")

# Run Test script
Write-Host "****  Run Test Suite 1 ******" 
cd F:\AutoTest\NoProxySetting\
StartProcess -wait $SoapUIBat -ArgumentList ("-tsoapui-settings.xml F:\SoapUI_Prj\REST-Project-2-soapui-project.xml") -RedirectStandardOutput($ResultFolder+ "Result1.txt")
cd $Testfolder## A hard code way
#& 'C:\Program Files\SmartBear\SoapUI-5.2.1\bin\testrunner.bat' -t"soapui-settings.xml" F:\SoapUI_Prj\REST-Project-2-soapui-project.xml > ($ResultFolder + "Result1.txt")
##Kill Fiddler 
#Stop-Process -processname Fiddler*

# Start Fiddler with Automatically Authentication
Write-Host "****  Start Fiddler with Automatically Authentication" 
Start-Process $FiddlerExe
Start-Sleep -s 5

# Run Testscript
Write-Host "****  Run Test Suite 2 ******" 
Start-Process -wait $SoapUIBat -ArgumentList ("F:\SoapUI_Prj\REST-Project-3-soapui-project.xml") -RedirectStandardOutput($ResultFolder+ "Result2.txt")
#Run LoadTest
Write-Host "***  Run Load Test 1"
Start-Process -wait $soapUILoadBat -ArgumentList ("-s`"Get Data From Root`" -c`"GET data from Root`" -l`"LoadTest 10 Thread`" F:\SoapUI_Prj\REST-Project-3-soapui-project.xml") -RedirectStandardOutput($ResultFolder+ "LoadTest1.txt")
Start-Process -wait $soapUILoadBat -ArgumentList ("-s`"Get Data From Root`" -c`"GET data from Root`" -l`"LoadTest 100 Thread`" F\SoapUI_Prj\REST-Project-3-soapui-project.xml") -RedirectStandardOutput($ResultFolder+ "LoadTest2.txt")
#Quit Fiddler
#Stop-Process -processname Fiddler*
Start-Process -wait ($FiddlerPath + "ExecAction.exe") -ArgumentList("quit")



#Generate Report
<#  C# application way
Start-Process -wait ($ResultFolder+"GenerateWebAPIReport.ps1") -ArgumentList ($ResultFolder+"Result1.txt `"`" -json")
Start-Process -wait ($ResultFolder+"GenerateWebAPIReport.ps1") -ArgumentList ($ResultFolder+"Result2.txt `"`" -json")
Start-Process -wait ($ResultFolder+"GenerateWebAPIReport.ps1") -ArgumentList ($ResultFolder+"LoadTest1.txt `"`" -json")
Start-Process -wait ($ResultFolder+"GenerateWebAPIReport.ps1") -ArgumentList ($ResultFolder+"LoadTest2.txt `"`" -json")
#>

$command= $ResultFolder + "GenerateWebAPIReport.ps1" + " " +$ResultFolder+"Result1.txt `"`" -json"
iex $command
$command= $ResultFolder + "GenerateWebAPIReport.ps1" + " " +$ResultFolder+"Result2.txt `"`" -json"
iex $command
$command= $ResultFolder + "GenerateWebAPIReport.ps1" + " " +$ResultFolder+"LoadTest1.txt `"`" -json"
iex $command
$command= $ResultFolder + "GenerateWebAPIReport.ps1" + " " +$ResultFolder+"LoadTest2.txt `"`" -json"
iex $command



#$arguments = @(
#    "$ResultFolder\Result1.txt `"`" -json",
#    "$ResultFolder\Result2.txt `"`" -json",  
#    "$ResultFolder\LoadTest1.txt `"`" -json",
#    "$ResultFolder\LoadTest2.txt `"`" -json" 
# )


#foreach ($a in $arguments) {
#    Write-Host $a
#    & $command -ArgumentList $a
#}


#$arguments | foreach {    
#   iex $command $_
#}
 

