# Application to reset Citrix Receiver on a device
# Written by Joshua Woleben
# Written 2/4/19

# Variable declarations
$global:workstation = "localhost"

# GUI Code
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        Title="[Send Receiver Reset]" Height="500" Width="450" MinHeight="500" MinWidth="400" ResizeMode="CanResizeWithGrip">
    <StackPanel>
        <Button x:Name="SetWorkstation" Content="[Set Workstation]" Margin="10,10,10,0" VerticalAlignment="Top" Height="25"/>
        <Label x:Name="CurrentWorkstation" Content="Current Workstation: localhost"/>
        <Label x:Name="WorkstationTextLabel" Content="Enter Workstation Name here:"/>
        <TextBox x:Name="WorkstationName" MinHeight = "12"/>
        <Button x:Name="SendReceiverReset" Content="[Send Receiver Reset]" Margin="10,10,10,0" VerticalAlignment="Top" Height="25"/>
    </StackPanel>
</Window>
'@
 
$global:Form = ""
# XAML Launcher
$reader=(New-Object System.Xml.XmlNodeReader $xaml) 
try{$global:Form=[Windows.Markup.XamlReader]::Load( $reader )}
catch{Write-Host "Unable to load Windows.Markup.XamlReader. Some possible causes for this problem include: .NET Framework is missing PowerShell must be launched with PowerShell -sta, invalid XAML code was encountered."; break}
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name ($_.Name) -Value $global:Form.FindName($_.Name)}

# Set up controls

$ReceiverResetButton = $global:Form.FindName('SendReceiverReset')
$global:workstationNameTextBox = $global:Form.FindName('WorkstationName')
$SetWorkstationButton = $global:Form.FindName('SetWorkstation')
$CurrentWorkstationLabel = $global:Form.FindName('CurrentWorkstation')


# If button clicked, kick off Receiver reset
$ReceiverResetButton.Add_Click({
    Write-Host ("Send Receiver Reset sent for " + $global:workstation)
    $remoteSession = New-PSSession -ComputerName $global:workstation
    Invoke-Command -Session $remoteSession -ScriptBlock { Start-Process -FilePath "C:\Program Files\Citrix\ICA Client\SelfServicePlugin\CleanUp.exe" -ArgumentList "/silent","-cleanUser" }
    Remove-PSSession $remoteSession
    Write-Host "Reset completed."
    $global:Form.Close()
})

# Set workstation to send signal to
$SetWorkstationButton.Add_Click({
    $global:workstation = $workstationNameTextBox.Text
    $CurrentWorkstationLabel.Content = ("Current Workstation: " + $global:workstation)
    Write-Host ("Target Workstation set to " + $global:workstation)

})


$global:Form.Add_Loaded({
    $global:Form.Title = "Reset Citrix Receiver Interface"
})
# Show GUI
$global:Form.ShowDialog() | out-null