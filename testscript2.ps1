[int]$maxRetries = 3;
# [string]$testSession = New-Guid;
# [int]$testRunNumber = 0;


Write-Host "PSScriptRoot $PSScriptRoot";

$inputTrx = "$PSScriptRoot\example_testResults.trx"; # hardcoded for testing

$logDirectoryRetries = Join-Path -Path $PSScriptRoot -ChildPath "RetryResults";
$logPath = "$logDirectoryRetries\retry.trx";
$loggerArg = "trx;LogFileName=$logPath";


# if failed > 0
# foreach test, N retries
# keep a list of all failed tests.


[xml]$xmlElm = Get-Content -Path $inputTrx
$outcome = $xmlElm.TestRun.ResultSummary.outcome;
Write-Host "Parsing TestRun '$inputTrx' Outcome: $outcome";

if ($outcome -eq "Failed")
{
    Write-Host "Detected TestRun failed, will retry tests $maxRetries times.";

    $results = $xmlElm.TestRun.Results.UnitTestResult
    Write-Host "TestResults: $($results.Count)";

    $testDefinitions = $xmlElm.TestRun.TestDefinitions.UnitTest;
    Write-Host "TestDefinitions: $($testDefinitions.Count)";

    foreach ($result in $results)
    {
        if ($result.outcome -eq "Failed")
        {
            Write-Host "- $($result.testId) $($result.testName) $($result.outcome)"

            $definition = $testDefinitions | Where-Object { $_.id -eq $result.testId}
            if ($null -eq $definition)
            {
                Write-Host "ERROR: TEST DEFINITION NOT FOUND";
            }

            Write-Host "  $($definition.TestMethod.codeBase) $($definition.TestMethod.className) $($definition.TestMethod.name)"

            # foreach max retries
            for($i=0;$i -le $maxRetries;$i++)
            {
                Write-Host "retry $i"

                dotnet test $($definition.TestMethod.codeBase) --logger $loggerArg --filter "ClassName=$($definition.TestMethod.className)&Name=$($definition.TestMethod.name)"

                [xml]$retryXml = Get-Content -Path $logPath
                $retryOutcome = $retryXml.TestRun.ResultSummary.outcome;
                Write-Host "Retry $retryOutcome"

                if ($retryOutcome -eq "Passed")
                {
                    Write-Host "Passed!"
                    break;
                }
            }
        }
    }

}


# $logPath = "$logDirectory\$($testSession)_$testRunNumber.trx";
# $loggerArg = "trx;LogFileName=$logPath";
# dotnet test $solutionPath --logger $loggerArg


# while ($testRunNumber -lt $maxRetries) {
#     # Cast Xml document to Object.
#     [xml]$xmlElm = Get-Content -Path $logPath
#     $outcome = $xmlElm.TestRun.ResultSummary.outcome;
#     Write-Host "TestRun: $testRunNumber Outcome: $outcome";

#     if ($outcome -eq "Failed") {
#         Write-Host "Failed Tests: " $xmlElm.TestRun.ResultSummary.Counters.failed;

#         $FailedTests = @();
#         ## looping through UnitTestResult with outcome="Failed"
#         $xmlElm.TestRun.Results.UnitTestResult | Where-Object outcome -eq 'Failed' |  ForEach-Object {
#             $FailedTests += $_.testName
#         }
    
#         $qualifiedFailedTestNames = @();
        
#         $FailedTests | ForEach-Object {
#             #Write-Host "-" $_
#             $qualifiedFailedTestNames += "Name=$_"
#         }

#         [string]$filterNames = [string]::Join("|",$qualifiedFailedTestNames)
        

#         $testRunNumber++;
#         $logPath = "$logDirectory\$($testSession)_$testRunNumber.trx";
#         $loggerArg = "trx;LogFileName=$logPath";
#         dotnet test $solutionPath --logger $loggerArg --filter $filterNames
#     }
#     else {
#         break;
#     }
# }
