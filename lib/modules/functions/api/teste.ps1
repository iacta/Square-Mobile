# Caminho do arquivo ZIP
$filePath = "./commit.zip"

# URL da API de commit
$commitUrl = "https://api.squarecloud.app/v2/apps/80424c4f467f402e8105e759810254ce/commit?restart=true"

# Token de Autorização
$authorizationToken = "858677648317481010-059a83a9d4bffc0561c0a667a130da456bb8453a36b5ae16512082094d32a57f"

# Cabeçalhos da Requisição
$headers = @{
    Authorization = $authorizationToken
    "Content-Type" = "application/json"
}

# Envia a Requisição de Commit
$response = Invoke-RestMethod -Uri $commitUrl -Method POST -Headers $headers -InFile $filePath

# Exibe a Resposta
Write-Host "Status Code: $($response.StatusCode)"
Write-Host "Resposta: $($response | ConvertTo-Json -Depth 5)"
