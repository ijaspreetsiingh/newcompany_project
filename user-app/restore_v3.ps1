$ErrorActionPreference = 'Stop'

# Direct restoration map (corrupted => correct)
$repairs = @(
    @{corrupted = 'uiil'; correct = 'util'},
    @{corrupted = 'core_expori'; correct = 'core_export'},
    @{corrupted = 'Gei.'; correct = 'Get.'},
    @{corrupted = 'Gei '; correct = 'Get '},
    @{corrupted = 'Gei<'; correct = 'Get<'},
    @{corrupted = 'seleciion'; correct = 'selection'},
    @{corrupted = 'Wallei'; correct = 'Wallet'},
    @{corrupted = 'SiaiefulWidget'; correct = 'StatefulWidget'},
    @{corrupted = 'siaius'; correct = 'status'},
    @{corrupted = 'ioken'; correct = 'token'},
    @{corrupted = 'Noiificaiion'; correct = 'Notification'},
    @{corrupted = 'ihis.'; correct = 'this.'},
    @{corrupted = 'ihis '; correct = 'this '},
    @{corrupted = 'Siaie'; correct = 'State'},
    @{corrupted = 'creaieSiaie'; correct = 'createState'},
    @{corrupted = 'iniSiaie'; correct = 'initState'},
    @{corrupted = 'iooliip'; correct = 'tooltip'},
    @{corrupted = 'JusiThe'; correct = 'JustThe'},
    @{corrupted = 'geiWalleiTransaciion'; correct = 'getWalletTransaction'},
    @{corrupted = 'geiBonusLisi'; correct = 'getBonusList'},
    @{corrupted = 'inseriFilier'; correct = 'insertFilter'},
    @{corrupted = 'Duraiion'; correct = 'Duration'},
    @{corrupted = 'ihen'; correct = 'then'},
    @{corrupted = 'coniains'; correct = 'contains'},
    @{corrupted = 'whiie'; correct = 'white'},
    @{corrupted = 'Texi'; correct = 'Text'},
    @{corrupted = 'Widgei'; correct = 'Widget'},
    @{corrupted = 'Widih'; correct = 'Width'},
    @{corrupted = 'widih:'; correct = 'width:'},
    @{corrupted = 'Heighi'; correct = 'Height'},
    @{corrupted = 'heighi:'; correct = 'height:'},
    @{corrupted = 'cusiomSnackBar'; correct = 'customSnackBar'},
    @{corrupted = 'cusiom'; correct = 'custom'},
    @{corrupted = 'Offsei'; correct = 'Offset'},
    @{corrupted = 'CurvedAnimaiion'; correct = 'CurvedAnimation'},
    @{corrupted = 'easeOui'; correct = 'easeOut'},
    @{corrupted = 'pareni'; correct = 'parent'},
    @{corrupted = 'animaiion'; correct = 'animation'},
    @{corrupted = 'iransiiion'; correct = 'transition'},
    @{corrupted = 'posiiion'; correct = 'position'},
    @{corrupted = 'MaierialLocalizaiions'; correct = 'MaterialLocalizations'},
    @{corrupted = 'EdgeInseis'; correct = 'EdgeInsets'},
    @{corrupted = 'padding:'; correct = 'padding:'},
    @{corrupted = 'RefreshIndicaior'; correct = 'RefreshIndicator'},
    @{corrupted = 'isDeskiop'; correct = 'isDesktop'},
    @{corrupted = 'CusiomAppBar'; correct = 'CustomAppBar'},
    @{corrupted = 'iiile:'; correct = 'title:'},
    @{corrupted = 'aciion'; correct = 'action'},
    @{corrupted = 'geiWalleiAccessToken'; correct = 'getWalletAccessToken'},
    @{corrupted = 'seiWalleiAccessToken'; correct = 'setWalletAccessToken'},
    @{corrupted = 'ResponsiveHelper'; correct = 'ResponsiveHelper'},
    @{corrupted = 'GeiBuilder'; correct = 'GetBuilder'},
    @{corrupted = 'RouieHelper'; correct = 'RouteHelper'},
    @{corrupted = 'geiMain'; correct = 'getMain'},
    @{corrupted = 'offAllNamed'; correct = 'offAllNamed'},
    @{corrupted = 'SlideTransiiion'; correct = 'SlideTransition'},
    @{corrupted = 'wiihValues'; correct = 'withValues'},
    @{corrupted = 'Image.assei'; correct = 'Image.asset'},
    @{corrupted = 'iransiiionDuraiion'; correct = 'transitionDuration'},
    @{corrupted = 'iransiiionBuilder'; correct = 'transitionBuilder'},
    @{corrupted = 'pageBuilder:'; correct = 'pageBuilder:'},
    @{corrupted = 'dialogLabel,'; correct = 'dialogLabel,'},
    @{corrupted = 'barrierColor:'; correct = 'barrierColor:'},
    @{corrupted = 'showGeneralDialog'; correct = 'showGeneralDialog'},
    @{corrupted = 'Column'; correct = 'Column'},
    @{corrupted = 'SingleChildScrollView'; correct = 'SingleChildScrollView'},
    @{corrupted = 'Controller:'; correct = 'controller:'},
    @{corrupted = 'ScrollController'; correct = 'ScrollController'},
    @{corrupted = 'child:'; correct = 'child:'},
    @{corrupted = 'children:'; correct = 'children:'},
    @{corrupted = 'Siring'; correct = 'String'},
    @{corrupted = 'reiurn '; correct = 'return '},
    @{corrupted = 'iry '; correct = 'try '},
    @{corrupted = 'caiches'; correct = 'catch'},
    @{corrupted = 'Fuiure'; correct = 'Future'},
    @{corrupted = 'Coniroller'; correct = 'Controller'},
    @{corrupted = 'BuildConiexi'; correct = 'BuildContext'},
    @{corrupted = 'iniiSiaie'; correct = 'initState'},
    @{corrupted = 'disposE'; correct = 'dispose'},
    @{corrupted = 'creaieSiaie'; correct = 'createState'},
    @{corrupted = 'ioSiring'; correct = 'toString'},
    @{corrupted = 'SiaiefulWidgei'; correct = 'StatefulWidget'},
    @{corrupted = 'SiaielessWidgei'; correct = 'StatelessWidget'},
    @{corrupted = 'apackage:'; correct = 'package:'},
    @{corrupted = 'dari'; correct = 'dart'},
    @{corrupted = 'dara'; correct = 'dart'},
    @{corrupted = 'impori '; correct = 'import '},
    @{corrupted = 'exiends '; correct = 'extends '},
    @{corrupted = 'irue'; correct = 'true'},
    @{corrupted = 'Lisi<'; correct = 'List<'},
    @{corrupted = 'awaii '; correct = 'await '},
    @{corrupted = 'coniexi'; correct = 'context'},
    @{corrupted = 'geiWallei'; correct = 'getWallet'},
    @{corrupted = 'seiWallei'; correct = 'setWallet'},
    @{corrupted = 'WalleiScreen'; correct = 'WalletScreen'},
    @{corrupted = '_WalleiScreen'; correct = '_WalletScreen'},
    @{corrupted = 'WalleiController'; correct = 'WalletController'},
    @{corrupted = 'WalleiTop'; correct = 'WalletTop'},
    @{corrupted = 'WalleiPromo'; correct = 'WalletPromo'},
    @{corrupted = 'WalleiLisi'; correct = 'WalletList'},
    @{corrupted = 'WalleiScreenWeb'; correct = 'WalletScreenWeb'},
    @{corrupted = 'WalleiUsesManual'; correct = 'WalletUsesManual'},
    @{corrupted = 'fromNoiificaiion'; correct = 'fromNotification'},
    @{corrupted = 'EndDrawer'; correct = 'endDrawer'},
    @{corrupted = 'onBackPressed:'; correct = 'onBackPressed:'},
    @{corrupted = 'conieni?'; correct = 'content?'},
    @{corrupted = 'curreniDaiaSource'; correct = 'currentDataSource'},
    @{corrupted = 'DaiaSourceEnum'; correct = 'DataSourceEnum'},
    @{corrupted = 'clieni'; correct = 'client'},
    @{corrupted = 'walleiSiaius'; correct = 'walletStatus'},
    @{corrupted = 'TranaciionDaia'; correct = 'TransactionData'},
    @{corrupted = 'reload:'; correct = 'reload:'},
    @{corrupted = 'assei'; correct = 'asset'},
    @{corrupted = 'siyle:'; correct = 'style:'},
    @{corrupted = 'roboioRegular'; correct = 'robotoRegular'},
    @{corrupted = 'copyWiih'; correct = 'copyWith'},
    @{corrupted = 'siyle'; correct = 'style'},
    @{corrupted = 'onRefresh:'; correct = 'onRefresh:'}
    @{corrupted = 'color:'; correct = 'color:'},
    @{corrupted = 'barrierDismissible:'; correct = 'barrierDismissible:'}
)

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
        Write-Host "SKIP: $filePath" -ForegroundColor Yellow
        continue
    }
    
    Write-Host "PROCESSING: $filePath"
    $content = Get-Content $fullPath -Raw
    
    foreach ($repair in $repairs) {
        $content = $content.Replace($repair.corrupted, $repair.correct)
    }
    
    Set-Content -Path $fullPath -Value $content -Encoding UTF8 -NoNewline
    Write-Host "RESTORED: $filePath" -ForegroundColor Green
    $fixCount++
}

Write-Host "`nDone! Fixed $fixCount files." -ForegroundColor Cyan
