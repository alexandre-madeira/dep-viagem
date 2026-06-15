# P06 — Atualizar senha do painel financeiro DPV
# Preencha NOVA_SENHA antes de rodar
# Rodar em PowerShell local (nao compartilhar o valor no chat)

$NOVA_SENHA = "SUBSTITUIR_AQUI"   # <-- editar aqui antes de rodar

# ── lê JWT do settings.json ──────────────────────────────────────────
$s   = Get-Content "$env:USERPROFILE\.claude\settings.json" | ConvertFrom-Json
$key = $s.mcpServers.n8n.headers.Authorization -replace "Bearer ", ""
$hdr = @{ "X-N8N-API-KEY" = $key; "Content-Type" = "application/json" }
$base = "https://n8n.solucaomadeira.com/api/v1"

# ── busca workflow atual ──────────────────────────────────────────────
$wf = (Invoke-WebRequest "$base/workflows/fRA3D3njIJOWmtqU" -Headers $hdr -UseBasicParsing).Content | ConvertFrom-Json

# ── localiza e altera o nó de autenticação ───────────────────────────
$node = $wf.nodes | Where-Object { $_.name -like "*Autenticacao*" }
$node.parameters.conditions.conditions[0].rightValue = $NOVA_SENHA

# ── monta body e envia PUT ────────────────────────────────────────────
$body = [ordered]@{
    name        = $wf.name
    nodes       = $wf.nodes
    connections = $wf.connections
    settings    = @{ executionOrder = $wf.settings.executionOrder }
    staticData  = $null
} | ConvertTo-Json -Depth 30 -Compress

$resp = Invoke-WebRequest "$base/workflows/fRA3D3njIJOWmtqU" -Method PUT -Headers $hdr -Body $body -UseBasicParsing
"Status: $($resp.StatusCode)"

# ── confirma que o campo foi gravado ─────────────────────────────────
$updated = ($resp.Content | ConvertFrom-Json).nodes | Where-Object { $_.name -like "*Autenticacao*" }
$salva   = $updated.parameters.conditions.conditions[0].rightValue
if ($salva -eq $NOVA_SENHA) {
    Write-Host "SUCESSO — senha atualizada no workflow" -ForegroundColor Green
} else {
    Write-Host "ATENCAO — valor gravado: $salva" -ForegroundColor Yellow
}
