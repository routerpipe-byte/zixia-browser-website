$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$reviewRoot = Join-Path $root 'review\15.14.6\play-upload'

function Copy-Selection {
    param(
        [Parameter(Mandatory)] [string]$Source,
        [Parameter(Mandatory)] [string]$Destination,
        [Parameter(Mandatory)] [int[]]$Numbers
    )

    New-Item -ItemType Directory -Force -Path $Destination | Out-Null
    Get-ChildItem -LiteralPath $Destination -File | Remove-Item -Force
    for ($index = 0; $index -lt $Numbers.Count; $index++) {
        $number = $Numbers[$index]
        $sourceFile = Get-ChildItem -LiteralPath $Source -File |
            Where-Object { $_.BaseName -eq "$number" -or $_.BaseName -eq ('{0:D2}' -f $number) } |
            Select-Object -First 1
        if (-not $sourceFile) {
            throw "Missing image $number in $Source"
        }
        $destinationName = '{0:D2}-{1}' -f ($index + 1), $sourceFile.Name
        Copy-Item -LiteralPath $sourceFile.FullName -Destination (Join-Path $Destination $destinationName) -Force
    }
}

# Google Play accepts at most eight screenshots for each device type. These
# selections keep the broadest consumer-facing feature coverage while the full
# eleven-image masters remain in their original directories.
Copy-Selection -Source (Join-Path $root 'assets\screens') -Destination (Join-Path $reviewRoot 'phone\zh') -Numbers 1,2,4,6,7,9,10,11
Copy-Selection -Source (Join-Path $root 'assets\screens-en') -Destination (Join-Path $reviewRoot 'phone\en') -Numbers 1,2,4,5,7,8,9,10
Copy-Selection -Source (Join-Path $root 'assets\tablet-promo\7\zh') -Destination (Join-Path $reviewRoot '7-inch\zh') -Numbers 1,2,4,6,7,9,10,11
Copy-Selection -Source (Join-Path $root 'assets\tablet-promo\7\en') -Destination (Join-Path $reviewRoot '7-inch\en') -Numbers 1,2,4,6,7,9,10,11
Copy-Selection -Source (Join-Path $root 'assets\tablet-promo\10\zh') -Destination (Join-Path $reviewRoot '10-inch\zh') -Numbers 1,2,4,6,7,9,10,11
Copy-Selection -Source (Join-Path $root 'assets\tablet-promo\10\en') -Destination (Join-Path $reviewRoot '10-inch\en') -Numbers 1,2,4,6,7,9,10,11

$featureDirectory = Join-Path $reviewRoot 'feature-graphics'
New-Item -ItemType Directory -Force -Path $featureDirectory | Out-Null
Copy-Item -LiteralPath (Join-Path $root 'assets\feature-graphic-zh-cn-1024x500.png') -Destination (Join-Path $featureDirectory 'feature-graphic-zh-cn-1024x500.png') -Force
Copy-Item -LiteralPath (Join-Path $root 'assets\feature-graphic-en-1024x500.png') -Destination (Join-Path $featureDirectory 'feature-graphic-en-1024x500.png') -Force

Write-Output $reviewRoot
