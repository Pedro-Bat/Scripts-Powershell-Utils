#Script que gera um json com a hierarquia de cargos de uma activedirectory baseado na propriedade manager do active directory, faz a busca com um script de árvore sendo a raiz o cargo mais alto da empresa CEO ou dono da empresa.
#O Json que será gerado também pode ser utilizado com o .js do diretório FoldersPermissions.ps1 basta trocar o nome do arquivo no arquivo .html

function Get-Hierarchy {
    param (
        [Parameter(Mandatory=$true)]
        [string]$UserDistinguishedName
    )

    $usersWithThisManager = Get-ADUser -Filter{manager -eq $UserDistinguishedName} -SearchBase $ou 

    $hierarchy = @()

    foreach ($user in $usersWithThisManager) {
        $hierarchy += [PSCustomObject]@{
            'User' = $user.SamAccountName;
            'Subordinates' = Get-Hierarchy -UserDistinguishedName $user.DistinguishedName
        }
    }

    return $hierarchy
}

$root = Get-ADUser -Identity nomeCEO
$hierarchy = [PSCustomObject]@{
    'User' = $root.SamAccountName;
    'Subordinates' = Get-Hierarchy -UserDistinguishedName $root.DistinguishedName
}

$hierarchy | ConvertTo-Json -Depth 10 | Out-File 'hierarchy.json'
