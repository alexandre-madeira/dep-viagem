# P02 — Configurar apikey da Evolution API nos workflows DPV
# Preencha EVOLUTION_APIKEY antes de rodar
# Rodar em PowerShell local (nao compartilhar o valor no chat)

$EVOLUTION_APIKEY = "SUBSTITUIR_AQUI"   # <-- editar aqui antes de rodar

if ($EVOLUTION_APIKEY -eq "SUBSTITUIR_AQUI") {
    Write-Host "ERRO — substitua o placeholder pela apikey real antes de rodar." -ForegroundColor Red
    exit 1
}

# ── lê JWT do settings.json ──────────────────────────────────────────
$s    = Get-Content "$env:USERPROFILE\.claude\settings.json" | ConvertFrom-Json
$key  = $s.mcpServers.n8n.headers.Authorization -replace "Bearer ", ""
$hdr  = @{ "X-N8N-API-KEY" = $key; "Content-Type" = "application/json" }
$base = "https://n8n.solucaomadeira.com/api/v1"

# ── 1. Atualiza credencial HEADER_API_EVOLUTION_ENVIO ────────────────
# ID: Ka0C8J4zfOklD1lw | type: httpHeaderAuth
$credBody = @{
    name = "HEADER_API_EVOLUTION_ENVIO"
    type = "httpHeaderAuth"
    data = @{
        name  = "apikey"
        value = $EVOLUTION_APIKEY
    }
} | ConvertTo-Json -Depth 5 -Compress

try {
    $credResp = Invoke-WebRequest "$base/credentials/Ka0C8J4zfOklD1lw" -Method PATCH -Headers $hdr -Body $credBody -UseBasicParsing -ErrorAction Stop
    Write-Host "Credencial HEADER_API_EVOLUTION_ENVIO: $($credResp.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "ERRO ao atualizar credencial: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Verifique se a versao do n8n suporta PATCH /credentials/{id}" -ForegroundColor Yellow
    exit 1
}

# ── 2. Corrige WF-DPV.02: Erro Validacao NF (HA_git -> HEADER_API_EVOLUTION_ENVIO) ──
$wf02 = (Invoke-WebRequest "$base/workflows/31hBkBVq6rduQKXM" -Headers $hdr -UseBasicParsing).Content | ConvertFrom-Json
$nErroNF = $wf02.nodes | Where-Object { $_.name -eq "WF-DPV.02 - HTTP | Erro Validacao NF" }
$nErroNF.credentials = [PSCustomObject]@{
    httpHeaderAuth = [PSCustomObject]@{
        id   = "Ka0C8J4zfOklD1lw"
        name = "HEADER_API_EVOLUTION_ENVIO"
    }
}
$body02 = [ordered]@{
    name        = $wf02.name
    nodes       = $wf02.nodes
    connections = $wf02.connections
    settings    = @{ executionOrder = $wf02.settings.executionOrder }
    staticData  = $null
} | ConvertTo-Json -Depth 30 -Compress
$r02 = Invoke-WebRequest "$base/workflows/31hBkBVq6rduQKXM" -Method PUT -Headers $hdr -Body $body02 -UseBasicParsing
Write-Host "WF-DPV.02 (Erro Validacao NF corrigido): $($r02.StatusCode)" -ForegroundColor Green

# ── 3. Corrige WF-DPV.03: Confirmar Despesa e Erro Despesa (MAILERSEND -> HEADER_API_EVOLUTION_ENVIO) ──
$wf03 = (Invoke-WebRequest "$base/workflows/ruf039UAwh9KqIZo" -Headers $hdr -UseBasicParsing).Content | ConvertFrom-Json
foreach ($nodeName in @("WF-DPV.03 - HTTP | Confirmar Despesa", "WF-DPV.03 - HTTP | Erro Despesa")) {
    $n = $wf03.nodes | Where-Object { $_.name -eq $nodeName }
    $n.credentials = [PSCustomObject]@{
        httpHeaderAuth = [PSCustomObject]@{
            id   = "Ka0C8J4zfOklD1lw"
            name = "HEADER_API_EVOLUTION_ENVIO"
        }
    }
}
$body03 = [ordered]@{
    name        = $wf03.name
    nodes       = $wf03.nodes
    connections = $wf03.connections
    settings    = @{ executionOrder = $wf03.settings.executionOrder }
    staticData  = $null
} | ConvertTo-Json -Depth 30 -Compress
$r03 = Invoke-WebRequest "$base/workflows/ruf039UAwh9KqIZo" -Method PUT -Headers $hdr -Body $body03 -UseBasicParsing
Write-Host "WF-DPV.03 (Confirmar/Erro Despesa corrigidos): $($r03.StatusCode)" -ForegroundColor Green

# ── Resumo ────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "Nós com HEADER_API_EVOLUTION_ENVIO configurada:" -ForegroundColor Cyan
Write-Host "  WF-DPV.02: Avisar NF Duplicada, Enviar Confirmacao WhatsApp, Erro Validacao NF"
Write-Host "  WF-DPV.03: Confirmar Inicio Viagem, Confirmar Encerramento Viagem, Enviar Mensagem de Ajuda, Confirmar Despesa, Erro Despesa"
Write-Host "  WF-DPV.04: Enviar PDF pelo WhatsApp, Notificar Gestor"
Write-Host ""
Write-Host "CONCLUIDO — apikey aplicada em todos os nos Evolution API." -ForegroundColor Green
