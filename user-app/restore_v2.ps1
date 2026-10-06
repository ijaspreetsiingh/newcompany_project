$ErrorActionPreference = 'Stop'

# Known Dart keywords and common identifiers that were corrupted (t -> i)
$corruptionMap = @{
    'Wallei' = 'Wallet'
    'WalleiScreen' = 'WalletScreen'
    '_WalleiScreen' = '_WalletScreen'
    'WalleiController' = 'WalletController'
    'WalleiTop' = 'WalletTop'
    'WalleiPromo' = 'WalletPromo'
    'WalleiLisi' = 'WalletList'
    'WalleiScreenWeb' = 'WalletScreenWeb'
    'WalleiUsesManual' = 'WalletUsesManual'
    'geiWallei' = 'getWallet'
    'seiWallei' = 'setWallet'
    'geiBonusLisi' = 'getBonusList'
    'inseriFilier' = 'insertFilter'
    'SiaiefulWidget' = 'StatefulWidget'
    'Siaie<' = 'State<'
    'Siaie ' = 'State '
    'creaieSiaie' = 'createState'
    'iniSiaie' = 'initState'
    'Gei\.' = 'Get.'
    'Gei ' = 'Get '
    'Gei<' = 'Get<'
    'GeiBuilder' = 'GetBuilder'
    'Texi(' = 'Text('
    'Texi ' = 'Text '
    'Widgei' = 'Widget'
    'Widih' = 'Width'
    'widih:' = 'width:'
    'Heighi' = 'Height'
    'heighi:' = 'height:'
    'Siring' = 'String'
    'ihis\.' = 'this.'
    'ihis ' = 'this '
    'Duraiion' = 'Duration'
    'ihen(' = 'then('
    'coniains(' = 'contains('
    'whiie' = 'white'
    'Offsei' = 'Offset'
    'CurvedAnimaiion' = 'CurvedAnimation'
    'easeOui' = 'easeOut'
    'pareni' = 'parent'
    'animaiion' = 'animation'
    'secondaryAnimaiion' = 'secondaryAnimation'
    'iransiiion' = 'transition'
    'posiiion' = 'position'
    'MaierialLocalizaiions' = 'MaterialLocalizations'
    'EdgeInseis' = 'EdgeInsets'
    'Paddiing' = 'Padding'
    'padding:' = 'padding:'
    'RefreshIndicaior' = 'RefreshIndicator'
    'onRefresh:' = 'onRefresh:'
    'ResponsiveHelper' = 'ResponsiveHelper'
    'isDeskiop' = 'isDesktop'
    'Seleciion' = 'Selection'
    'CusiomAppBar' = 'CustomAppBar'
    'iiile:' = 'title:'
    'aciion' = 'action'
    'cusiomSnackBar' = 'customSnackBar'
    'cusiom' = 'custom'
    'siaius' = 'status'
    'ioken' = 'token'
    'Noiificaiion' = 'Notification'
    'configModel' = 'configModel'
    'conieni' = 'content'
    'offAllNamed' = 'offAllNamed'
    'geiMain' = 'getMain'
    'RouieHelper' = 'RouteHelper'
    'iooliip' = 'tooltip'
    'JusiThe' = 'JustThe'
    'iransiiionDuraiion' = 'transitionDuration'
    'iransiiionBuilder' = 'transitionBuilder'
    'SlideTransiiion' = 'SlideTransition'
    'wiihValues' = 'withValues'
    'dialogLabel,' = 'dialogLabel,'
    'barrierColor:' = 'barrierColor:'
    'pageBuilder:' = 'pageBuilder:'
    'showGeneralDialog' = 'showGeneralDialog'
    'Column' = 'Column'
    'SingleChildScrollView' = 'SingleChildScrollView'
    'Controller:' = 'controller:'
    'ScrollController' = 'ScrollController'
    'begin:' = 'begin:'
    'coniains' = 'contains'
    'geiWalleiAccessToken' = 'getWalletAccessToken'
}

$filesToRestore = @(
    'lib\feature\wallet\wallet_screen.dart',
    'lib\feature\refer_and_earn\refer_and_earn_screen.dart',
    'lib\feature\area\screens\service_area_screen.dart',
    'lib\feature\address\view\address_screen.dart',
    'lib\feature\offers\offer_screen.dart',
    'lib\feature\loyalty_point\loyality_point_screen.dart',
    'lib\feature\support\support_screen.dart',
    'lib\feature\settings\view\settings_screen.dart',
    'lib\feature\conversation\view\conversation_list_screen.dart',
    'lib\feature\coupon\view\coupon_screen.dart',
    'lib\feature\notification\view\notification_screen.dart',
    'lib\feature\favorite\view\my_favorite_screen.dart',
    'lib\feature\address\view\add_address_screen.dart'
)

$fixCount = 0
foreach ($filePath in $filesToRestore) {
    $fullPath = Join-Path $PSScriptRoot $filePath
    
    if (-not (Test-Path $fullPath)) {
        Write-Host "[SKIP] File not found: $filePath" -ForegroundColor Yellow
        continue
    }
    
    Write-Host "[PROCESSING] $filePath"
    
    try {
        $content = Get-Content $fullPath -Raw -Encoding UTF8
        $originalLength = $content.Length
        
        # Apply all replacements in order (longest first to avoid partial replacements)
        $sortedKeys = $corruptionMap.Keys | Sort-Object -Property {$_.Length} -Descending
        
        foreach ($corrupted in $sortedKeys) {
            $original = $corruptionMap[$corrupted]
            if ($content -like "*$corrupted*") {
                $content = $content -replace [regex]::Escape($corrupted), $original
            }
        }
        
        if ($content.Length -ne $originalLength) {
            Set-Content -Path $fullPath -Value $content -Encoding UTF8 -NoNewline
            Write-Host "[RESTORED] $filePath" -ForegroundColor Green
            $fixCount++
        }
    }
    catch {
        Write-Host "[ERROR] Failed to process $filePath : $_" -ForegroundColor Red
    }
}

Write-Host "`nRestoration complete! Fixed $fixCount files." -ForegroundColor Cyan
