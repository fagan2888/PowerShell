# This Script need powershell 5.0
# A small powershell class. Use to report, write the JSON to a text file. 

if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Host "Need Powershell version 5" 
    exit
}

class Report {
        [string] $Date =[DateTime]::Today.Date.ToShortDateString()
        [string] $Time = [DateTime]::Now.ToShortTimeString()
        [string] $Testcase = ""
        [string] $AssertionMessage = ""
        [string] $Result = ""

        [string] CreateReportString(){
            #return [String]::Format("{0} {1}\t{2}\t\t\t{3}\t\t\t{4}\r\n", $this.Date, $this.Time, $this.Testcase, $this.Result, $this.AssertionMessage)            
            return [String]::Format("{0} {1}`t{2}`t`t`t{3}`t`t`t{4}`r`n", $this.Date, $this.Time, $this.Testcase, $this.Result, $this.AssertionMessage)            
        }
}

Function WriteReportToText([string]$reportfile, [string]$content,[string]$resultfile,[string]$json=""){     
    if (![System.IO.File]::Exists($reportfile)) {
        [System.IO.StreamWriter] $swNew = [System.IO.File]::CreateText($reportfile)
        $swNew.WriteLine($content)
        $swNew.Close()            
    } else {
        [System.IO.StreamWriter] $swAppend = [System.IO.File]::AppendText($reportfile)
        $swAppend.WriteLine($content)
        $swAppend.Close()
    }

    $jsonfile = $resultfile.Substring(0, $resultfile.Length-4) + "-" + [DateTime]::Now.ToString("yyyy-MM-dd-HH-mm-ss") + ".json"
     if (![System.IO.File]::Exists($jsonfile)) {
        # Create a file to write to.
        [System.IO.StreamWriter] $swNew = [System.IO.File]::CreateText($jsonfile)
        $swNew.WriteLine($json);
        $swNew.Close();
     } else {
        throw new Exception("File already exist!");
     } 
}
