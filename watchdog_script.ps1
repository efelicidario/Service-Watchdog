# watchdog.ps1
# by Tyler Felicidario
# 28 June 2022
# 
# A script that starts a service if stopped, frequently reassuring
# that the service remains up and running.
# 


# Global variables
$logFile = '.\log.txt'
$timeout = 60
$serviceName = 'Rubrik Backup Service'
$arrService = Get-Service -Name $serviceName

# Write-Log function writes to log.txt
Function Write-Log {
    Param (
        [string]
        $logString
        )
    Add-content $logFile -value "$timeStamp - $logString"
}

Function Write-Email {
    Param (
        [Parameter(mandatory = $true)]
        [string]
        $body
    )

    # Objects for what makes parts of an email: 
    # sender, recipient, subject, body
    $emailFrom = "Tyler_the_Watchdog@quidel.com"
    $emailTo = "Tyler.felicidario@quidel.com"
    $subject = "Watchdog - $serviceName"

    # SMTP
    # server, port, client
    $SMTPserver = "relay.quidel.com"
    $SMTPport = "25"
    $SMTPclient = New-Object Net.Mail.SmtpClient($SMTPserver, $SMTPport)
    $SMTPclient.EnableSsl = $false

    $SMTPClient.Send($emailFrom, $emailTo, $subject, $body)
}


# while loop
while (1) {
    # Refresh
    $arrService.Refresh()
    # if the service status is 'Running',
    # write to console and log
    if ($arrService.Status -eq 'Running') {
        # $timeStamp adds date and time information to log messages
        $timeStamp = (Get-Date).toString('yyyy/MM/dd HH:mm:ss')
        Write-Host 'Service is running.'
    }
    # otherwise, start the service,
    # write to console and log
    else {
        # $timeStamp adds date and time information to log messages
        $timeStamp = (Get-Date).toString('yyyy/MM/dd HH:mm:ss')
        Start-Service $serviceName
        $message = "$timeStamp - Service '$serviceName' is being restarted."
        Write-Host $message
        Write-Log $message
        Write-Email $message
    }
    Start-Sleep -seconds $timeout
}
