Get-Content c:\academy\1.txt
Get-Content c:\academy\1.txt | foreach { 
  $_ -replace 'WARNING', 'ERROR'
} | set-content C:\academy\2.txt
Get-Content c:\academy\2.txt
