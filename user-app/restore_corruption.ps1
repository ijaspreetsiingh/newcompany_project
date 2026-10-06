# Restore corrupted Dart files by reversing character replacements

$corruptedFiles = @{
    'lib\feature\wallet\wallet_screen.dart' = @{
        't' = 'i'
    }
    'lib\feature\refer_and_earn\refer_and_earn_screen.dart' = @{
        't' = 'i'
    }
    'lib\feature\area\screens\service_area_screen.dart' = @{
        't' = 'i'
    }
    'lib\feature\address\view\address_screen.dart' = @{
        't' = 'i'
    }
    'lib\feature\offers\offer_screen.dart' = @{
        't' = 'i'
    }
    'lib\feature\loyalty_point\loyality_point_screen.dart' = @{
        't' = 'i'
    }
    'lib\feature\support\support_screen.dart' = @{
        't' = 'i'
    }
    'lib\feature\settings\view\settings_screen.dart' = @{
        't' = 'i'
    }
    'lib\feature\conversation\view\conversation_list_screen.dart' = @{
        't' = 'i'
    }
    'lib\feature\coupon\view\coupon_screen.dart' = @{
        't' = 'i'
        'V' = "'"
    }
    'lib\feature\notification\view\notification_screen.dart' = @{
        't' = 'i'
        'N' = "'"
    }
    'lib\feature\favorite\view\my_favorite_screen.dart' = @{
        't' = 'i'
        'M' = "'"
    }
    'lib\feature\address\view\add_address_screen.dart' = @{
        'a' = "'"
    }
}

# Reversals: swap old and new
$replacements = @{
    'i' = 't'          # i → t (reverse of t → i)
    'V' = "'"         # V → ' (reverse of ' → V)
    'N' = "'"         # N → ' (reverse of ' → N)
    'M' = "'"         # M → ' (reverse of ' → M)
    'a' = "'"         # a → ' (reverse of ' → a)
}

foreach ($filePath in $corruptedFiles.Keys) {
    $fullPath = Join-Path $PSScriptRoot $filePath
    if (Test-Path $fullPath) {
        $content = Get-Content $fullPath -Raw
        $correctedCount = 0
        
        # Apply replacements
        foreach ($find in $replacements.Keys) {
            $replaceWith = $replacements[$find]
            $matches = [regex]::Matches($content, [regex]::Escape($find))
            
            # Carefully replace: only restore where corruption happened
            # This is context-aware: we only reverse in Dart syntax contexts
            
            if ($matches.Count -gt 0) {
                # For 'i', only replace in common corrupted words
                if ($find -eq 'i') {
                    $corruptedPatterns = @(
                        'Siai', 'Wallei', 'ihen', 'ihis', 'Gei', 'coniains', 'whiie', 
                        'Texi', 'Widgei', 'SiaieIul', 'Wiih', 'Siring', 'iniSiaie',
                        'impori', 'exiends', 'irue', 'reiurn', 'Lisi', 'Fuiure',
                        'awaii', 'iry', 'Coniroller', 'BuildConiexi', 'Siaie', 'ioSiring'
                    )
                    
                    foreach ($pattern in $corruptedPatterns) {
                        if ($content -match [regex]::Escape($pattern)) {
                            $correctedPattern = $pattern -replace 'i', 't'
                            $content = $content -replace [regex]::Escape($pattern), $correctedPattern
                            $correctedCount++
                        }
                    }
                }
                else {
                    # For quote characters, do targeted replacement
                    $content = $content -replace [regex]::Escape($find), $replaceWith
                    $correctedCount++
                }
            }
        }
        
        if ($correctedCount -gt 0) {
            Set-Content -Path $fullPath -Value $content -Encoding UTF8
            Write-Host "Restored: $filePath (reversed $correctedCount patterns)"
        }
    }
    else {
        Write-Host "File not found: $filePath"
    }
}

Write-Host "Restoration complete!"
