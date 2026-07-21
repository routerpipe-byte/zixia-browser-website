$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$sourcePath = Join-Path $root 'assets\screens\2.jpg'
$targetPath = Join-Path $root 'assets\screens\3.jpg'
$temporaryPath = Join-Path $root 'assets\screens\3.fixed.jpg'

$source = [System.Drawing.Bitmap]::FromFile($sourcePath)
$target = [System.Drawing.Bitmap]::FromFile($targetPath)
$result = New-Object System.Drawing.Bitmap $target.Width, $target.Height
$graphics = [System.Drawing.Graphics]::FromImage($result)
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

try {
    $graphics.DrawImageUnscaled($target, 0, 0)

    # Reuse the Zixia home-page address field from screenshot 2 so the settings
    # promo no longer displays a third-party URL. The rest of the footer remains
    # untouched, preserving the original device frame and controls.
    $sourceRect = New-Object System.Drawing.Rectangle 100, 1235, 462, 88
    $destinationRect = New-Object System.Drawing.Rectangle 100, 1235, 462, 88
    $graphics.DrawImage($source, $destinationRect, $sourceRect, [System.Drawing.GraphicsUnit]::Pixel)

    # Screenshot 3 has a dimmed page behind the settings sheet.
    $dimPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $dimPath.StartFigure()
    $dimPath.AddLine(100, 1235, 562, 1235)
    $dimPath.AddLine(562, 1235, 562, 1297)
    $dimPath.AddArc(512, 1272, 50, 50, 0, 90)
    $dimPath.AddLine(537, 1322, 125, 1322)
    $dimPath.AddArc(100, 1272, 50, 50, 90, 90)
    $dimPath.CloseFigure()

    $dimBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(93, 0, 0, 0))
    try {
        $graphics.FillPath($dimBrush, $dimPath)
    }
    finally {
        $dimBrush.Dispose()
        $dimPath.Dispose()
    }

    $qualityEncoder = [System.Drawing.Imaging.Encoder]::Quality
    $encoderParameters = New-Object System.Drawing.Imaging.EncoderParameters 1
    $encoderParameters.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter $qualityEncoder, ([long]95)
    $jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object MimeType -eq 'image/jpeg'
    $result.Save($temporaryPath, $jpegCodec, $encoderParameters)
    $encoderParameters.Dispose()
}
finally {
    $graphics.Dispose()
    $result.Dispose()
    $target.Dispose()
    $source.Dispose()
}

Move-Item -LiteralPath $temporaryPath -Destination $targetPath -Force
Write-Output $targetPath
