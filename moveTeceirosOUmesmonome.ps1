#Após a criação das OU para os terceiros esse script move os usuários com o mesmo nome para a OU determinada
$ou = ""
$usuarios = get-aduser -Filter{enabled -eq $true} -SearchBase $ou

foreach($usuario in $usuarios){
    $nomeempresa = $usuario.SamAccountname.Split(".")[0]
    $OUdestino = "OU=$nomeempresa,"
    Move-ADObject -Identity $usuario -TargetPath $OUdestino
    write-host "$($usuario.Samaccountname) movido para $OUdestino"
}
