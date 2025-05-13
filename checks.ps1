$reportPath = "C:\relatorio_workstations\Relatorio_Sistema.html"
$directoryPath = "C:\relatorio_workstations"
if(!(test-path $directoryPath) ){
    mkdir $directoryPath
}
$usuarios = Get-LocalUser | Select-Object Name, Enabled, LastLogon
$perfis = Get-ChildItem "C:\Users" -Directory | Select-Object Name, FullName, LastWriteTime
$serial = (Get-CimInstance -ClassName Win32_BIOS).SerialNumber
$sessoes = (query user) -join "<br>"

$programas = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* ,
                             HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* `
             -ErrorAction SilentlyContinue |
             Select-Object DisplayName

$ocsInstalado = $false
$crowdInstalado = $false
$ManageEngine = $false

foreach ($prog in $programas) {
    if ($prog.DisplayName -match "ocs") { $ocsInstalado = $true }
    if ($prog.DisplayName -match "crowdstrike") { $crowdInstalado = $true }
    if ($prog.DisplayName -match "ManageEngine") {$ManageEngine = $true}
}
$compInfo = Get-CimInstance -Class Win32_ComputerSystem
$nomeMaquina = $compInfo.Name
$dominio = $compInfo.Domain
$emDominio = if ($compInfo.PartOfDomain) { "Sim" } else { "Não (Grupo de Trabalho)" }
$fabricante = $compInfo.Manufacturer
$modelo = $compInfo.Model

$html = @"
<html>
<head>
    <title>Relatorio do Sistema</title>
    <style>
        body { font-family: Arial; margin: 20px; }
        h2 { background-color: #444; color: white; padding: 8px; }
        table { border-collapse: collapse; width: 100%; margin-bottom: 30px; }
        th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .mono { font-family: Consolas, monospace; white-space: pre-wrap; background-color: #f9f9f9; padding: 10px; }
    </style>
</head>
<body>

<h1>Relatorio do Sistema - $(Get-Date)</h1>

<h2>Informacoes da Maquina</h2>
<ul>
    <li><strong>Nome da Maquina:</strong> $nomeMaquina</li>
    <li><strong>Fabricante:</strong> $fabricante</li>
    <li><strong>Modelo:</strong> $modelo</li>
    <li><strong>Esta em Domínio:</strong> $emDominio</li>
    <li><strong>Dominio / Grupo de Trabalho:</strong> $dominio</li>
    <li><strong>Numero de Serie:</strong> $serial</li>
</ul>

<h2>Usuarios Locais</h2>
$( $usuarios | ConvertTo-Html -Fragment | Out-String )

<h2>Perfis em C:\Users</h2>
$( $perfis | ConvertTo-Html -Fragment | Out-String )

<h2>Sessoes de Usuario Ativas</h2>
<div class='mono'>$sessoes</div>

<h2>Softwares Especificos</h2>
<ul>
    <li><strong>OCS Inventory:</strong> $(if ($ocsInstalado) {'<span style="color:green;">Instalado</span>'} else {'<span style="color:red;">Nao encontrado</span>'})</li>
    <li><strong>CrowdStrike:</strong> $(if ($crowdInstalado) {'<span style="color:green;">Instalado</span>'} else {'<span style="color:red;">Nao encontrado</span>'})</li>
    <li><strong>ManageEngine:</strong> $(if ($ManageEngine) {'<span style="color:green;">Instalado</span>'} else {'<span style="color:red;">Nao encontrado</span>'})</li>
</ul>

</body>
</html>
"@

$html | Out-File -FilePath $reportPath -Encoding UTF8
Start-Process $reportPath
