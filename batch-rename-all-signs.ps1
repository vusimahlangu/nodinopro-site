# COMPREHENSIVE ROAD SIGN RENAMING SCRIPT
# This will rename ALL 421 road signs based on the CSV plan
param(
    [string]$MappingFile = "complete-road-signs-renaming-plan.csv"
)
Write-Host "🚀 STARTING COMPREHENSIVE ROAD SIGN RENAMING" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green
# Check if mapping file exists
if (-not (Test-Path $MappingFile)) {
    Write-Host "❌ ERROR: Mapping file not found: $MappingFile" -ForegroundColor Red
    Write-Host "Please create the renaming plan using the complete-review-all-signs.html page" -ForegroundColor Yellow
    exit 1
}
# Read mapping
$Mappings = Import-Csv $MappingFile
Write-Host "📋 Loaded renaming plan for $($Mappings.Count) signs" -ForegroundColor Cyan
# Track changes
$RenamedCount = 0
$SkippedCount = 0
$Errors = @()
foreach ($Map in $Mappings) {
    $CurrentFile = $Map.CurrentFilename
    $NewFile = $Map.NewFilename
    $Category = $Map.Category
    $Status = $Map.Status
    # Skip if no change needed
    if ($CurrentFile -eq $NewFile -or [string]::IsNullOrWhiteSpace($NewFile)) {
        Write-Host "⏭️  SKIPPED: $CurrentFile" -ForegroundColor Gray
        $SkippedCount++
        continue
    }
    # Ensure .png extension
    if (-not $NewFile.EndsWith('.png')) {
        $NewFile += '.png'
    }
    # Rename the file
    $CurrentPath = "assets\images\road-signs\$CurrentFile"
    $NewPath = "assets\images\road-signs\$NewFile"
    if (Test-Path $CurrentPath) {
        try {
            Rename-Item -Path $CurrentPath -NewName $NewFile -ErrorAction Stop
            Write-Host "✅ RENAMED: $CurrentFile -> $NewFile ($Category)" -ForegroundColor Green
            $RenamedCount++
        }
        catch {
            Write-Host "❌ ERROR renaming $CurrentFile : $($_.Exception.Message)" -ForegroundColor Red
            $Errors += "Failed to rename $CurrentFile : $($_.Exception.Message)"
        }
    } else {
        Write-Host "❌ FILE NOT FOUND: $CurrentFile" -ForegroundColor Red
        $Errors += "File not found: $CurrentFile"
    }
}
# Summary
Write-Host "`n📊 RENAMING SUMMARY:" -ForegroundColor Cyan
Write-Host "==================" -ForegroundColor Cyan
Write-Host "✅ Successfully renamed: $RenamedCount signs" -ForegroundColor Green
Write-Host "⏭️  Skipped (no change): $SkippedCount signs" -ForegroundColor Gray
Write-Host "❌ Errors: $($Errors.Count)" -ForegroundColor Red
if ($Errors.Count -gt 0) {
    Write-Host "`n🚨 ERRORS:" -ForegroundColor Red
    $Errors | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
}
Write-Host "`n🎉 RENAMING COMPLETE!" -ForegroundColor Green
Write-Host "Next: Update HTML files and deploy to GitHub" -ForegroundColor Yellow
