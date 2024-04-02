
#-> Traz se a herança está ativada ou não
$outfile = "C:\statushierarquia.txt"
$users = Get-ADUser -Filter *
foreach ($user in $users) {
    $adObjectDN = $user.DistinguishedName
    $acl = Get-Acl -Path ("AD:\" + $adObjectDN)
    if ($acl.AreAccessRulesProtected) {
        Add-Content -Path $outfile -Value "$adObjectDN : Herança está desativada"
    } else {
        Add-Content -Path $outfile -Value "$adObjectDN : Herança está ativada"
    }
}