param(
    [string]$OutputDirectory = "$PSScriptRoot/releases"
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression

$source = Join-Path $PSScriptRoot 'modules/stable'
$name = 'S23U-Fullscreen-AOD-OneUI8-30Hz-Stable-v2.1.0.zip'
$destination = Join-Path $OutputDirectory $name
$files = @(
    'customize.sh',
    'module.prop',
    'system/product/overlay/S23UAodDozeMapOverlay/S23UAodDozeMapOverlay.apk'
)
$fixedTimestamp = [DateTimeOffset]::new(2026, 7, 30, 0, 0, 0, [TimeSpan]::Zero)

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null

foreach ($relativePath in $files) {
    $sourceFile = Join-Path $source ($relativePath -replace '/', [IO.Path]::DirectorySeparatorChar)
    if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
        throw "Missing module file: $relativePath"
    }
}

if (Test-Path -LiteralPath $destination) {
    Remove-Item -LiteralPath $destination
}

$fileStream = [IO.File]::Open($destination, [IO.FileMode]::CreateNew)
try {
    $archive = [IO.Compression.ZipArchive]::new($fileStream, [IO.Compression.ZipArchiveMode]::Create, $false)
    try {
        foreach ($relativePath in $files) {
            $sourceFile = Join-Path $source ($relativePath -replace '/', [IO.Path]::DirectorySeparatorChar)
            $entry = $archive.CreateEntry($relativePath, [IO.Compression.CompressionLevel]::Optimal)
            $entry.LastWriteTime = $fixedTimestamp
            $input = [IO.File]::OpenRead($sourceFile)
            $output = $entry.Open()
            try {
                $input.CopyTo($output)
            } finally {
                $output.Dispose()
                $input.Dispose()
            }
        }
    } finally {
        $archive.Dispose()
    }
} finally {
    $fileStream.Dispose()
}

Get-FileHash -Algorithm SHA256 -LiteralPath $destination
