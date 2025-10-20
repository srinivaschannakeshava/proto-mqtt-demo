# generate.ps1
# PowerShell helper to generate language bindings from proto files.
# Run from repository root: .\scripts\generate.ps1

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$repoRoot = Resolve-Path (Join-Path $scriptRoot '..')
$protoDir = Join-Path $repoRoot 'proto'
$outRoot = Join-Path $repoRoot 'gen'
$protoFile = Join-Path $protoDir 'simple.proto'

Write-Host "Proto dir: $protoDir"
Write-Host "Output root: $outRoot"

if (-not (Test-Path $protoFile)) {
    Write-Host "ERROR: Proto file not found: $protoFile" -ForegroundColor Red
    exit 1
}

function Ensure-Dir($d) {
    if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d | Out-Null }
}

# Look for plugin shims in node_modules/.bin (prefers .cmd on Windows) or on PATH
function Find-Plugin($name) {
    $candidates = @()
    $nmBin = Join-Path $repoRoot 'node_modules' | Join-Path -ChildPath '.bin'
    $candidates += Join-Path $nmBin "$name.cmd"
    $candidates += Join-Path $nmBin $name
    try { $cmd = Get-Command $name -ErrorAction Stop; $candidates += $cmd.Source } catch {}

    foreach ($c in $candidates) {
        if ([string]::IsNullOrEmpty($c)) { continue }
        if (Test-Path $c) { return (Resolve-Path $c).Path }
    }
    return $null
}

Ensure-Dir (Join-Path $outRoot 'java')
Ensure-Dir (Join-Path $outRoot 'python')
Ensure-Dir (Join-Path $outRoot 'ts')
Ensure-Dir (Join-Path $outRoot 'js')
Ensure-Dir (Join-Path $outRoot 'angular')

# Run protoc from repository root so --proto_path matches the file layout
$cwd = Get-Location
Set-Location $repoRoot
try {
    $relProtoPath = 'proto'
    $relProtoFile = 'proto/simple.proto'

    Write-Host "Generating Java (requires protoc). Output: gen/java"
    protoc --proto_path=$relProtoPath --java_out=gen/java $relProtoFile

    Write-Host "Generating Python (requires protoc). Output: gen/python"
    protoc --proto_path=$relProtoPath --python_out=gen/python $relProtoFile

    # TypeScript via ts-protoc-gen
    $tsPlugin = Find-Plugin 'protoc-gen-ts'
    if ($tsPlugin) {
        Write-Host "Found ts plugin: $tsPlugin; Generating TypeScript to gen/ts"
        protoc --plugin=protoc-gen-ts=$tsPlugin --proto_path=$relProtoPath --js_out=import_style=commonjs, binary:gen/ts --ts_out=service=grpc-node:gen/ts $relProtoFile
    }
    else {
        Write-Host "Skipping TypeScript generation (ts-protoc-gen missing). Install with: npm install --save-dev ts-protoc-gen grpc-tools" -ForegroundColor Yellow
    }

    # Plain JavaScript (needs protoc-gen-js or grpc-tools)
    $jsPlugin = Find-Plugin 'protoc-gen-js'
    if ($jsPlugin) {
        Write-Host "Found js plugin: $jsPlugin; Generating plain JS to gen/js"
        protoc --plugin=protoc-gen-js=$jsPlugin --proto_path=$relProtoPath --js_out=import_style=commonjs, binary:gen/js $relProtoFile
    }
    else {
        Write-Host "Skipping plain JS generation (protoc-gen-js missing). Install grpc-tools or ensure protoc supports js_out." -ForegroundColor Yellow
    }

    # ts-proto (Angular-friendly) generation
    $tsProtoPlugin = Find-Plugin 'protoc-gen-ts_proto'
    if ($tsProtoPlugin) {
        Write-Host "Found ts-proto plugin: $tsProtoPlugin; Generating Angular-friendly TS to gen/angular"
        # protoc --plugin=protoc-gen-ts_proto=$tsProtoPlugin --proto_path=$relProtoPath --ts_proto_out=gen/angular $relProtoFile
        protoc --plugin=protoc-gen-ts_proto="D:\Learnings\proto-mqtt-demo\mqtt-angular\node_modules\.bin\protoc-gen-ts_proto.cmd" `
            --ts_proto_out=src/app/proto `
            --ts_proto_opt=esModuleInterop=true, importSuffix=.ts `
            src/app/proto/simple.proto
    }
    else {
        Write-Host "Skipping ts-proto generation (protoc-gen-ts_proto missing). Install with: npm install --save-dev ts-proto" -ForegroundColor Yellow
    }

}
finally {
    Set-Location $cwd
}

Write-Host "Done. If plugins are missing, see README.md for install notes."
# generate.ps1
# PowerShell helper to generate language bindings from proto files.
# Run from repository root: .\scripts\generate.ps1

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$repoRoot = Resolve-Path (Join-Path $scriptRoot '..')
$protoDir = Join-Path $repoRoot 'proto'
$outRoot = Join-Path $repoRoot 'gen'
$protoFile = Join-Path $protoDir 'simple.proto'

Write-Host "Proto dir: $protoDir"
Write-Host "Output root: $outRoot"

if (-not (Test-Path $protoFile)) {
    Write-Host "ERROR: Proto file not found: $protoFile" -ForegroundColor Red
    exit 1
}

# Java (requires protoc and protoc-gen-grpc-java in PATH)
$javaOut = Join-Path $outRoot 'java'
Write-Host "Generating Java to $javaOut"
protoc --proto_path=$protoDir --java_out=$javaOut $protoFile

# Python (requires protoc; for gRPC also install grpcio-tools and grpc_python_plugin)
$pythonOut = Join-Path $outRoot 'python'
Write-Host "Generating Python to $pythonOut"
protoc --proto_path=$protoDir --python_out=$pythonOut $protoFile

# TypeScript (uses ts-protoc-gen / grpc-tools) - generates .js + .d.ts into gen/ts
$tsOut = Join-Path $outRoot 'ts'
Write-Host "Generating TypeScript (JS + .d.ts) to $tsOut"
protoc --proto_path=$protoDir --js_out=import_style=commonjs, binary:$tsOut --ts_out=service=grpc-node:$tsOut $protoFile

# Plain JavaScript output (separate folder) - keep a clean JS-only generation
$jsOut = Join-Path $outRoot 'js'
Write-Host "Generating plain JavaScript to $jsOut"
protoc --proto_path=$protoDir --js_out=import_style=commonjs, binary:$jsOut $protoFile

# Angular-friendly TypeScript using ts-proto (generates idiomatic TS types and services)
$angularOut = Join-Path $outRoot 'angular'
Write-Host "Generating Angular-friendly TypeScript (ts-proto) to $angularOut"
# ts-proto is a plugin for protoc: protoc-gen-ts_proto
protoc --proto_path=$protoDir --plugin=protoc-gen-ts_proto=./node_modules/.bin/protoc-gen-ts_proto --ts_proto_out=$angularOut $protoFile

Write-Host "Done. If plugins are missing, see README.md for install notes."
