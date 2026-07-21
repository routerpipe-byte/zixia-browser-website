param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

function New-ContactSheet {
    param(
        [Parameter(Mandatory)] [string]$SourceDirectory,
        [Parameter(Mandatory)] [string]$OutputPath,
        [Parameter(Mandatory)] [string]$Title,
        [int]$Columns = 4,
        [int]$CellWidth = 330,
        [int]$CellHeight = 730
    )

    $files = Get-ChildItem -LiteralPath $SourceDirectory -File |
        Where-Object { $_.Extension -match '^\.(png|jpg|jpeg)$' -and $_.BaseName -match '^\d+$' } |
        Sort-Object { [int]$_.BaseName }

    if ($files.Count -eq 0) {
        throw "No numbered images found in $SourceDirectory"
    }

    $headerHeight = 90
    $padding = 16
    $rows = [Math]::Ceiling($files.Count / $Columns)
    $canvas = New-Object System.Drawing.Bitmap ($Columns * $CellWidth), ($headerHeight + $rows * $CellHeight)
    $graphics = [System.Drawing.Graphics]::FromImage($canvas)
    $graphics.Clear([System.Drawing.Color]::FromArgb(18, 14, 42))
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $titleFont = New-Object System.Drawing.Font('Microsoft YaHei UI', 26, [System.Drawing.FontStyle]::Bold)
    $labelFont = New-Object System.Drawing.Font('Microsoft YaHei UI', 16, [System.Drawing.FontStyle]::Bold)
    $whiteBrush = [System.Drawing.Brushes]::White

    try {
        $graphics.DrawString($Title, $titleFont, $whiteBrush, 20, 22)
        for ($index = 0; $index -lt $files.Count; $index++) {
            $row = [Math]::Floor($index / $Columns)
            $column = $index % $Columns
            $x = $column * $CellWidth + $padding
            $y = $headerHeight + $row * $CellHeight + 42
            $availableWidth = $CellWidth - 2 * $padding
            $availableHeight = $CellHeight - 70
            $source = [System.Drawing.Image]::FromFile($files[$index].FullName)
            try {
                $scale = [Math]::Min($availableWidth / $source.Width, $availableHeight / $source.Height)
                $width = [int]($source.Width * $scale)
                $height = [int]($source.Height * $scale)
                $drawX = $x + [int](($availableWidth - $width) / 2)
                $drawY = $y + [int](($availableHeight - $height) / 2)
                $graphics.FillRectangle([System.Drawing.Brushes]::White, $drawX - 2, $drawY - 2, $width + 4, $height + 4)
                $graphics.DrawImage($source, $drawX, $drawY, $width, $height)
                $graphics.DrawString($files[$index].BaseName, $labelFont, $whiteBrush, $x, $headerHeight + $row * $CellHeight + 8)
            }
            finally {
                $source.Dispose()
            }
        }

        $outputDirectory = Split-Path -Parent $OutputPath
        New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
        $canvas.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)
    }
    finally {
        $titleFont.Dispose()
        $labelFont.Dispose()
        $graphics.Dispose()
        $canvas.Dispose()
    }
}

$reviewDirectory = Join-Path $Root 'review\15.14.6'
New-ContactSheet -SourceDirectory (Join-Path $Root 'assets\screens') -OutputPath (Join-Path $reviewDirectory 'contact-phone-zh.jpg') -Title 'Phone - Chinese (11 images)'
New-ContactSheet -SourceDirectory (Join-Path $Root 'assets\screens-en') -OutputPath (Join-Path $reviewDirectory 'contact-phone-en.jpg') -Title 'Phone - English (11 images)'

Copy-Item -LiteralPath (Join-Path $Root 'assets\tablet-promo\contact-7-zh.jpg') -Destination (Join-Path $reviewDirectory 'contact-7-zh.jpg') -Force
Copy-Item -LiteralPath (Join-Path $Root 'assets\tablet-promo\contact-7-en.jpg') -Destination (Join-Path $reviewDirectory 'contact-7-en.jpg') -Force
Copy-Item -LiteralPath (Join-Path $Root 'assets\tablet-promo\contact-10-zh.jpg') -Destination (Join-Path $reviewDirectory 'contact-10-zh.jpg') -Force
Copy-Item -LiteralPath (Join-Path $Root 'assets\tablet-promo\contact-10-en.jpg') -Destination (Join-Path $reviewDirectory 'contact-10-en.jpg') -Force

Write-Output $reviewDirectory
