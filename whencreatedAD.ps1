$dataInicio = "14/11/2023"
$dataFim = "22/11/2023"

# Converter as datas para o formato DateTime
$dataInicioObj = [DateTime]::ParseExact($dataInicio, "dd/MM/yyyy", $null)
$dataFimObj = [DateTime]::ParseExact($dataFim, "dd/MM/yyyy", $null)

# Buscar usuários criados dentro do intervalo de datas
Get-ADUser -Filter { whenCreated -ge $dataInicioObj -and whenCreated -le $dataFimObj } -Properties whenCreated | Select-Object Name, whenCreated