#Script para criar ou para cada empresa terceira que os usuários seguirem o padrão de usuário empresa.primeironome

#OU onde os usuários terceiros se encontram
$ou = ""
$usuarios = (get-aduser -Filter{enabled -eq $true} -SearchBase $ou).Samaccountname

$empresas = @()

foreach($usuario in $usuarios){
    $partes = $usuario.split(".")
    $nomeempresa = $partes[0]
    $empresas += $nomeempresa
    }

$empresas = $empresas | Select-Object -Unique

foreach($empresa in $empresas){
    New-ADOrganizationalUnit -Name $empresa -Path $ou
    write-Host "OU criada $empresa"
}