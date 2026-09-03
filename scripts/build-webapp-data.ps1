#Requires -Version 7
<#
.SYNOPSIS
  data/timetable.json + data/meal.json 을 "output/data4.html"(학교 웹앱 .dc.html) 안의
  <script id="neis-snapshot"> 스냅샷(마커 사이)에 주입한다.
  이 스냅샷이 앱의 기본 데이터이고, 실행 시 NEIS 실시간 조회로 갱신된다.
.EXAMPLE
  pwsh scripts/fetch-neis.ps1        # 먼저 데이터 받기(인증키 필요)
  pwsh scripts/build-webapp-data.ps1 # 스냅샷 주입
#>
[CmdletBinding()]
param(
  [string]$DataDir = (Join-Path $PSScriptRoot '..' 'data'),
  [string]$Target  = (Join-Path $PSScriptRoot '..' 'output' 'data4.html')
)
$ErrorActionPreference = 'Stop'

function Load($name) {
  $p = Join-Path $DataDir $name
  if (-not (Test-Path $p)) { throw "$p 없음 — 먼저 pwsh scripts/fetch-neis.ps1 실행" }
  Get-Content -Raw -Path $p -Encoding utf8 | ConvertFrom-Json
}
$ttJson   = Load 'timetable.json'
$mealJson = Load 'meal.json'

# --- 급식: { 'YYYY-MM-DD': { items:[{name,al}], kcal, type } }  (중식 우선) ---
$meal = [ordered]@{}
foreach ($d in $mealJson.days.PSObject.Properties.Name) {
  $entries = @($mealJson.days.$d)
  $pick = ($entries | Where-Object { $_.type -eq '중식' } | Select-Object -First 1)
  if (-not $pick) { $pick = $entries[0] }
  if (-not $pick) { continue }
  $meal[$d] = [ordered]@{
    items = @($pick.dishes | ForEach-Object { [ordered]@{ name = $_.name; al = @($_.allergens) } })
    kcal  = [int]$pick.kcal
    type  = $pick.type
  }
}

$snapshot = [ordered]@{
  generatedAt = $ttJson.generatedAt
  school      = $ttJson.school
  timetable   = $ttJson.classes    # { grade: { class: { 'YYYY-MM-DD': { periods:[...] } | { holiday } } } }
  meal        = $meal
}
$json = $snapshot | ConvertTo-Json -Depth 20 -Compress

$html = Get-Content -Raw -Path $Target -Encoding utf8
$pattern = '(?s)/\*NEIS_SNAPSHOT_START\*/.*?/\*NEIS_SNAPSHOT_END\*/'
if ($html -notmatch $pattern) { throw "$Target 에 NEIS_SNAPSHOT 마커가 없습니다." }
$repl = '/*NEIS_SNAPSHOT_START*/' + $json + '/*NEIS_SNAPSHOT_END*/'
$html = [regex]::Replace($html, $pattern, { param($m) $repl })
Set-Content -Path $Target -Value $html -Encoding utf8 -NoNewline

Write-Host ("스냅샷 주입 완료 -> {0}" -f (Resolve-Path $Target).Path)
Write-Host ("  시간표 학년 {0}개 · 급식 {1}일 · JSON {2:N0} bytes" -f `
  @($ttJson.classes.PSObject.Properties).Count, $meal.Count, $json.Length)
