$specificUsbSerialNumber = "5CC73EBA"

$watcher = New-Object System.Management.ManagementEventWatcher
$query = "SELECT * FROM __InstanceCreationEvent WITHIN 2 WHERE TargetInstance ISA 'Win32_LogicalDisk'"
$watcher.Query = New-Object System.Management.EventQuery($query)

$action = {
  $driveLetter = $Event.SourceEventArgs.NewEvent.TargetInstance.DeviceID
  $serialNumber = (Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='$driveLetter'").VolumeSerialNumber
  if ($serialNumber -eq $specificUsbSerialNumber) {
    $videoPath = Join-Path -Path $driveLetter -ChildPath "chipi.mp4"
    if (Test-Path $videoPath) {
      Write-Host "Specific USB Drive Inserted"
      Show-Menu -VideoPath $videoPath
    } else {
      [System.Windows.Forms.MessageBox]::Show("chipi.mp4 not found on the USB Drive.")
    }
  }
}

Function Show-Menu {
  param(
    [string]$VideoPath
  )

  Add-Type -AssemblyName System.Windows.Forms
  $form = New-Object System.Windows.Forms.Form
  $form.Text = 'USB Menu'
  $form.Size = New-Object System.Drawing.Size(300,200)
  
  $playButton = New-Object System.Windows.Forms.Button
  $playButton.Text = 'chipi chipi'
  $playButton.Location = New-Object System.Drawing.Point(50,50)
  $playButton.Size = New-Object System.Drawing.Size(200,40)
  $playButton.Add_Click({
    Start-Process $VideoPath
    $form.Close()
  })
  $form.Controls.Add($playButton)

  $exitButton = New-Object System.Windows.Forms.Button
  $exitButton.Text = 'Exit'
  $exitButton.Location = New-Object System.Drawing.Point(50,100)
  $exitButton.Size = New-Object System.Drawing.Size(200,40)
  $exitButton.Add_Click({ $form.Close() })
  $form.Controls.Add($exitButton)

  $form.ShowDialog()
}

Register-ObjectEvent -InputObject $watcher -EventName EventArrived -Action $action
$watcher.Start()

while ($true) { Start-Sleep -Seconds 2 }
