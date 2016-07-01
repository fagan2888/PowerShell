#Read the SoapUI Log file, and generate the result in JSON format

$resultfile = $args[0]
$reportfile = @"
C:\AutoTest\Result\Report.txt
"@

$writejson = $false
if ($args.Count -eq 2) {
    $reportfile = $args[1]
} elseif ($args.Count -eq 3) {
    if (![string]::IsNullOrEmpty($args[1])) {
        $reportfile = $args[1]
    }    
    if ($args[2] -eq "-json") {
        $writejson = $true
    }
}



$result = Get-Content($resultfile)
$rpt = New-Object Report
$report = New-Object “System.Collections.Generic.List[$rpt]”


$content = ""

$p1 = @"
(.+)(INFO\s+\[SoapUITestCaseRunner\]\s+Running\s+SoapUI\s+testcase\s+\[)(.+)(\])(.*)
"@
$p2 = @"
(.+)(ERROR\s+\[SoapUITestCaseRunner\]\s+ASSERTION\s+FAILED\s+\-\>)(.+)
"@

$p3 = @"
(.+)(INFO\s+\[SoapUITestCaseRunner\]\s+Finished\s+running\s+SoapUI\s+testcase\s+\[)(.+)(\].+status\:\s*)(.+)
"@

$p4 = @"
(.+)(INFO\s+\[SoapUILoadTestRunner\]\s+LoadTest\s+\[)(.+)(\].+status\s*)(.+)
"@

foreach ($line in $result) { 

    $m1 = [regex]::Match($line, $p1, @('IgnoreCase'))
    $m2 = [regex]::Match($line, $p2, @('IgnoreCase'))
    $m3 = [regex]::Match($line, $p3, @('IgnoreCase'))
    $m4 = [regex]::Match($line, $p4, @('IgnoreCase'))
        
    if ($m1.Success) {
        $rpt.Testcase = $m1.Groups[3].Value        
    } elseif($m2.Success) {
        if (![string]::IsNullOrEmpty($rpt.AssertionMessage)) {
            $rpt.AssertionMessage = $rpt.AssertionMessage + ";" + $m2.Groups[3].Value
        } else {
            $rpt.AssertionMessage = $m2.Groups[3].Value
        }
    } elseif($m3.Success) {
        $rpt.Result = $m3.Groups[5].Value        
        $report.Add($rpt)
        $rpt = New-Object Report
    } elseif ($m4.Success) {                    
        $rpt.Testcase = "`[LoadTest`]" + $m4.Groups[3].Value;       
        $rpt.Result = $m4.Groups[5].Value;
        $report.Add($rpt);
        $rpt = New-Object Report
   }  

 }

 
    $jsonDataList = New-Object “System.Collections.Generic.List[System.Object]"
    
    foreach ($r in $report) {    
        $content = $content + $r.CreateReportString();        
        <#
        $jsonData = New-Object {                    
                    $Date = $c,
                    $Time = $r.Time,
                    $Testcase = $r.Testcase,
                    $Result = $r.Result,
                    $AssertionMessage = $r.AssertionMessage
                }; 
        #>

        $jsonData = New-Object –TypeName PSObject
        $jsonData | Add-Member  –MemberType NoteProperty –Name Date –Value $r.Date
        $jsonData | Add-Member  –MemberType NoteProperty –Name Time –Value $r.Time
        $jsonData | Add-Member  –MemberType NoteProperty –Name Testcase –Value $r.Testcase
        $jsonData | Add-Member  –MemberType NoteProperty –Name Result –Value $r.Result
        $jsonData | Add-Member  –MemberType NoteProperty –Name AssertionMessage –Value $r.AssertionMessage



        #$js = [System.Web.Script.Serialization]::JavaScriptSerializer().Serialize($jsonData)
        
        
         
        $jsonDataList.Add($jsonData);          
        
        
    }            

    
    
    $json = ConvertTo-Json($jsonDataList)
   
    


    if ($writejson) {        
        WriteReportToText $reportfile $content $resultfile $json
    } else {    
        WriteReportToText $reportfile $content $resultfile
    } 
