[int]$maxRetries = 3;
[string]$testSession = New-Guid;
[int]$testRunNumber = 0;

$logDirectory = "C:\Users\Mothr\source\repos\UnitTestsCli\TestResults\";
$solutionPath = "C:\Users\Mothr\source\repos\UnitTestsCli\UnitTestsCli.sln";



$logPath = "$logDirectory\$($testSession)_$testRunNumber.trx";
$loggerArg = "trx;LogFileName=$logPath";
dotnet test $solutionPath --logger $loggerArg


while ($testRunNumber -lt $maxRetries) {
    # Cast Xml document to Object.
    [xml]$xmlElm = Get-Content -Path $logPath
    $outcome = $xmlElm.TestRun.ResultSummary.outcome;
    Write-Host "TestRun: $testRunNumber Outcome: $outcome";

    if ($outcome -eq "Failed") {
        Write-Host "Failed Tests: " $xmlElm.TestRun.ResultSummary.Counters.failed;

        $FailedTests = @();
        ## looping through UnitTestResult with outcome="Failed"
        $xmlElm.TestRun.Results.UnitTestResult | Where-Object outcome -eq 'Failed' |  ForEach-Object {
            $FailedTests += $_.testName
        }
    
        $qualifiedFailedTestNames = @();
        
        $FailedTests | ForEach-Object {
            #Write-Host "-" $_
            $qualifiedFailedTestNames += "Name=$_"
        }

        [string]$filterNames = [string]::Join("|",$qualifiedFailedTestNames)
        

        $testRunNumber++;
        $logPath = "$logDirectory\$($testSession)_$testRunNumber.trx";
        $loggerArg = "trx;LogFileName=$logPath";
        dotnet test $solutionPath --logger $loggerArg --filter $filterNames
    }
    else {
        break;
    }
}
