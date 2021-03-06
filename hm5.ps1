
function RemItem{
param($word_to_remove,`
       $input_file,
       $out_file )

$CheckPathInput = Test-Path $input_file
$CheckPathOut = Test-Path $out_file


if ($CheckPathInput -eq $false){
    Write-Host "Create file"
    New-Item -Path $input_file -ItemType 'file'
}
if ($CheckPathOut -eq $false){
    Write-Host "Create file"
    New-Item -Path $out_file -ItemType 'file'
}

$get_cont = Get-Content $input_file
$out_content = Get-Content $out_file


foreach ($line in $get_cont){

    foreach ($string in $line)
    {
    $string_array_tmp=''

        foreach ($word in $string.Split()){

        if ($word -eq $word_to_remove){
            Write-Host 'delete word'
        }

        else{
        $string_array_tmp = $string_array_tmp + $word+' '
        }

            Write-Host  $string_array_tmp
        }


' ' | Out-File -FilePath $out_file -Encoding Unicode -Append
$string_array_tmp | Out-File -FilePath $out_file -Encoding Unicode -Append



    }
}

$get_new_cont = Get-Content $out_file
$get_new_cont | Set-Content -Path  $input_file -Encoding Unicode

@(gc $input_file) -match '\S'  | out-file $out_file

$get_new_cont = Get-Content $out_file
$get_new_cont | Set-Content -Path  $input_file -Encoding Unicode

Write-Host "Open File: $input_file"
}

#RemoveItem -word_to_remove 'test' -input_file "D:\new_item2.txt" -out_file "D:\tmp2.txt"


#open XML file, replace specified node with new one with the same name but with another set of properties
function CreateNodeXML{

$XmlFileContent = [xml](Get-Content "D:\ScriptsPS\day two\Web.config")

$ParrentNode = $XmlFileContent.SelectSingleNode("/configuration/configSections")
$OldNode = $XmlFileContent.SelectNodes("/configuration/configSections/section") | where { $_.name -eq  "Monitoring" }

$NewNode = $XmlFileContent.CreateElement('section')
$NewNode.SetAttribute('name', 'Monitoring')
$NewNode.SetAttribute('type', "Another_Property")


$ParrentNode.ReplaceChild($newNode, $oldNode)

$XmlFileContent.Save("D:\ScriptsPS\day two\Web.config")

}


function CreateLogFile{
[cmdletbinding()]
param(
[ValidatePattern('^.*\.(log)$')][string]$LogPath
)

$CheckPath = Test-Path $LogPath

if ($CheckPath -eq $false){
    Write-Host "Create file"
    New-Item -Path $LogPath -ItemType 'file'
}
}

function MangeRemoteServices{

[cmdletbinding()]
param(

[ValidatePattern('^[a-zA-Z0-9-]{1,15}.[a-z]{1,2}.[a-z]{1,3}$')][string]$DomainComputer,
[ValidateSet("stop","start","restart", IgnoreCase = $true)][string]$JobService,
[string]$ServiceName,
[Parameter(ValueFromPipeline=$true)][string][string]$LogPath = "C:\Error.log"
)
$tStamp = Get-Date -format yyyy-MM-dd_HH:mm:ss
if ($LogPath.Length -gt 0){
    CreateLogFile $LogPath
}
     Try
         {
             Write-Host -foregroundcolor Green "Process on host: "$DomainComputer
             
              Invoke-Command -ComputerName $DomainComputer -ScriptBlock { Get-Service | Where-Object { $_.Name -match $ServiceName }} -ErrorAction Stop
             #Invoke-Command -ComputerName $Computer -ScriptBlock { stop-service $ServiceName } -ErrorAction Stop
          } 
      Catch [System.Management.Automation.Remoting.PSRemotingTransportException]
         {
             $ErrorMessage = $_.Exception.Message
             Write-Host $ErrorMessage
             Add-Content -Path $LogPath –Value $DomainComputer
             Add-Content -Path $LogPath -Value $ErrorMessage  
             $error.Count   
         }

         Try
         {

             if ($JobService -like 'start'){
                 Get-Service -Name $ServiceName -ComputerName $DomainComputer | Start-Service -ErrorAction Stop
                 write-host -foregroundcolor Green "Start service: $ServiceName" 
             }
             elseif ($JobService -like 'stop'){
                 Get-Service -Name $ServiceName -ComputerName $DomainComputer | Stop-Service -ErrorAction Stop
                 write-host -foregroundcolor Red "Stop service: $ServiceName"
             }
                 elseif ($JobService -like 'restart'){
                 Get-Service -Name $ServiceName -ComputerName $DomainComputer | Restart-Service -ErrorAction Stop
                 write-host -foregroundcolor Yellow "Stop service: $ServiceName"
             }
         
            }
               Catch 
         {
            
             $ErrorMessage = $_.Exception.Message
             Write-Host $ErrorMessage
             Add-Content -Path $LogPath –Value $DomainComputer
             Add-Content -Path $LogPath -Value $tStamp,$ErrorMessage  
             $error.Count   
         }
 
  
}