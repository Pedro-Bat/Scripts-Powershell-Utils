#-> Exportar Lista de nomes de máquinas e último login para arquivo CSV
$computers = (Get-ADComputer -Filter{Enabled -eq $True} -Properties sAMAccountName).sAMAccountName
$cabecalho = "NomeMáquina, UltimoLogin" |Out-File -FilePath "C:\all_Computers.csv" -Append
 foreach ($computer in $computers) {
        $nome = (Get-ADComputer -Identity $computer -Properties sAMAccountName).sAMAccountName
        $filetime = (Get-ADComputer -Identity $computer -Properties pwdLastSet).pwdLastSet
        $datetime = [datetime]::FromFileTime($filetime)
        $output = "$nome,$datetime" | Out-File -FilePath "C:\all_Computers.csv" -Append
 }
