#Script que le todas as pastas de um determinado diretorio e audita usuários e suas permissões sendo usuários locais ou de dominio e deixa num json.
#Os parametros -directory e -depth  podem não funcionar se o script estiver sendo executado como administrador

$diretorio = "caminho do diretorio"
$resultados = @{}

$pastas = Get-ChildItem -Path $diretorio -Directory #-recurse -depth <int>

foreach ($pasta in $pastas) {
    $acls = Get-Acl -Path $pasta.FullName | Select-Object -ExpandProperty Access

    foreach ($acl in $acls) {
        if ($acl.IdentityReference.Value -match "dominio") {
            
            $grupo = $acl.IdentityReference.Value.Split('\')[1]
            try{
            $membros = Get-ADGroupMember -Identity $grupo -Recursive | Where-Object { $_.objectClass -eq 'user' } | Select-Object -ExpandProperty Name
               }catch{
                   if (-not $resultados.ContainsKey($pasta.FullName)) {
                    $resultados[$pasta.FullName] = @()
                   }

                   $resultados[$pasta.FullName] += @{
                    Permissões = $acl.FileSystemRights.ToString()
                    Usuário = $grupo
                    Grupo = $null
                    }
                    
                    $membros = 'Null'
                }

            if($membros -ne 'Null'){   
                foreach ($membro in $membros) {
                    if (-not $resultados.ContainsKey($pasta.FullName)) {
                        $resultados[$pasta.FullName] = @()
                    }

                    $resultados[$pasta.FullName] += @{
                        Permissões = $acl.FileSystemRights.ToString()
                        Usuário = $membro
                        Grupo = $grupo
                    } 
                }
            }
        }
    }
}

$json = $resultados | ConvertTo-Json

$json | Out-File -FilePath 'caminho do output.permissions.json' -Encoding utf8
