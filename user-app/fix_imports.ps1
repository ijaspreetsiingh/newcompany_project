# Fix remaining import and syntax issues
$dartFiles = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" -File

Write-Host "Fixing remaining import quotes and typos..." -ForegroundColor Cyan

$fixedCount = 0

foreach ($file in $dartFiles) {
    try {
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
        
        if (-not $content) {
            continue
        }
        
        $originalContent = $content
        
        # Fix unclosed import quotes
        $content = $content -replace "import 'package:([^']+);$", "import 'package:`$1';"
        $content = $content -replace "^import 'package:([^\n';]+)(?<!');", "import 'package:`$1';"
        
        # Fix more typos
        $content = $content -replace 'requtred', 'required'
        
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
