# Comprehensive Dart file corruption fixer
# Run from project root: powershell -ExecutionPolicy Bypass -File fix_corruption.ps1

$dartFiles = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" -File

# Define all replacements as tuples
$replacements = @(
    # Import corrections
    @('.darta', '.dart'),
    @('.dartV', '.dart'),
    @('import package:', 'import ''package:'),
    
    # Character corruptions (from previous PowerShell issues)
    @('ihis', 'this'),
    @('cenier', 'center'),
    @('wiih', 'with'),
    @('Siaie', 'State'),
    @('gei', 'get'),
    @('iype', 'type'),
    @('foniSize', 'fontSize'),
    @('radiusExiraLarge', 'radiusExtraLarge'),
    @('radiusLarge', 'radiusLarge'),
    
    # Design system typos
    @('NesiInk', 'NestInk'),
    @('NestInk\.sofi', 'NestInk.soft'),
    @('nesi_screens_kii', 'nest_screens_kit'),
    @('design_sysiem', 'design_system'),
    
    # Widget name corruptions
    @('CusiomPopWidget', 'CustomPopWidget'),
    @('AddressSeleciionDrawer', 'AddressSelectionDrawer'),
    @('CustomWIdget', 'CustomWidget'),
    @('custom_pop_Widget', 'custom_pop_widget'),
    
    # Method name corruptions
    @('ioNamed', 'toNamed'),
    @('ioUpperCase', 'toUpperCase'),
    @('seiState', 'setState'),
    @('prini', 'print'),
    @('updaie', 'update'),
    @('ioial', 'total'),
    
    # Property name corruptions
    @('noiificaiions', 'notifications'),
    @('noiificaiion', 'notification'),
    @('feaiure', 'feature'),
    @('Widgets', 'widgets'),
    @('horizonial', 'horizontal'),
    @('symmeiric', 'symmetric'),
    @('iapTargeiSize', 'tapTargetSize'),
    @('MaierialTapTargeiSize', 'MaterialTapTargetSize'),
    @('shrinkWrap', 'shrinkWrap'),
    @('isBackBuiionExisi', 'isBackButtonExist'),
    @('TextBuiion', 'TextButton'),
    @('ini', 'int'),
    @('iype', 'type'),
    
    # String value corruptions
    @('"noiificaiions"', '"notifications"'),
    @('"NAll noiificaiions marked as readN"', '"All notifications marked as read"'),
    @('ToasierMessageType', 'ToastMessageType'),
    @('ir', 'tr')
)

Write-Host "Starting Dart file corruption fixes..." -ForegroundColor Cyan
$fixedCount = 0

foreach ($file in $dartFiles) {
    try {
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
        
        if (-not $content) {
            continue
        }
        
        $originalContent = $content
        
        foreach ($replacement in $replacements) {
            $from = $replacement[0]
            $to = $replacement[1]
            $content = $content -replace [regex]::Escape($from), $to
        }
        
        if ($content -ne $originalContent) {
            Set-Content -Path $file.FullName -Value $content -Encoding UTF8
            $fixedCount++
            Write-Host "Fixed: $($file.FullName)" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "Error processing $($file.FullName): $_" -ForegroundColor Red
    }
}

Write-Host "`nTotal files fixed: $fixedCount" -ForegroundColor Cyan
