# proto-mqtt-demo — generate clients

```mermaid
flowchart LR
  A[proto/simple.proto] --> B{Generator scripts}
  B --> C[gen/java]
  B --> D[gen/python]
  B --> E[gen/ts] --> F[gen/js]
  B --> G[gen/angular]
  G --> H[mqtt-angular (example app)]
  subgraph Dev
    I[Dev Container]\n(ubuntu + protoc + node + python)
    I --> B
    I --> H
  end
```

This repository contains a minimal protobuf (`proto/simple.proto`) and helper scripts to generate client code for several languages. It also includes a small Angular example that connects to an MQTT broker.

Quick generate

- PowerShell (Windows):

```powershell
.\scripts\generate.ps1
```

- Bash (Linux / Dev Container):

```bash
./scripts/generate.sh
```

Dev Container

Open the repo in VS Code and choose "Reopen in Container" (Remote - Containers). The container installs protoc, Node, and Python and runs a post-create script that installs Node/Python deps useful for generation.

Angular demo

See `mqtt-angular/` for a minimal Angular app wired to an MQTT broker using `ngx-mqtt`.

Run it:

```bash
cd mqtt-angular
npm install
npm run start
```

Notes and next steps

- If you want I can run the generator inside the devcontainer and report the output (helpful to confirm plugins are installed).
- I can also add more diagrams or a step-by-step flow for building specific language clients.
# proto-mqtt-demo — generate clients

This repository contains `proto/simple.proto` and helper scripts to generate language-specific client stubs.

Summary
- Generate clients for Java, Python, TypeScript (Node), plain JS, and Angular-friendly TypeScript (ts-proto).
- Includes a Dev Container for Ubuntu that has protoc + node + python installed.
- Example Angular app that connects to an MQTT broker using `ngx-mqtt` in `mqtt-angular/`.

Quick generate (PowerShell)

```powershell
# from repo root
.\scripts\generate.ps1
```

Quick generate (Linux / Dev Container)

```bash
# from repo root
./scripts/generate.sh
```

Dev Container

Open this repository in VS Code and choose "Reopen in Container" (Remote - Containers). The container installs protoc, Node, and Python and runs `postCreate.sh` which installs project node/python deps for generation.

Angular example

See `mqtt-angular/` for a minimal Angular app that connects to a WebSocket MQTT broker (uses `ngx-mqtt`).

Run it:

```bash
cd mqtt-angular
npm install
npm run start
```

Dependencies per generator (Windows and Linux notes)

1) protoc (required for all generators)

System (Windows, admin) — Chocolatey:

```powershell
choco install protoc -y
protoc --version
```

Local (no-admin) — Windows PowerShell example:

```powershell
# from repo root
mkdir .\tools\protoc -Force
Invoke-WebRequest -Uri https://github.com/protocolbuffers/protobuf/releases/download/v23.4/protoc-23.4-win64.zip -OutFile .\tools\protoc\protoc.zip
Expand-Archive .\tools\protoc\protoc.zip -DestinationPath .\tools\protoc -Force
Remove-Item .\tools\protoc\protoc.zip
$env:Path = (Resolve-Path .\tools\protoc\bin).Path + ';' + $env:Path
protoc --version
```

Linux (Dev Container / Ubuntu):

protoc is installed in the provided devcontainer Dockerfile. On a native machine, download the Linux release zip from the protobuf releases page and extract to `/usr/local` or similar.

2) Java

- Install JDK (system). Generate Java classes with:

```powershell
protoc --proto_path=proto --java_out=gen/java proto/simple.proto
```

3) Python

Install runtime and generation tools:

```powershell
python -m pip install --user protobuf grpcio grpcio-tools
```

Then generate:

```powershell
protoc --proto_path=proto --python_out=gen/python proto/simple.proto
```

4) TypeScript / Node (ts-protoc-gen / grpc-tools)

Install locally in `gen/ts` (or repo root):

```powershell
cd gen/ts
npm install --save-dev ts-protoc-gen grpc-tools
npm run gen
```

5) Plain JavaScript

Uses protoc's JS plugin (installed with `grpc-tools`):

```powershell
cd gen/ts
npm install --save-dev grpc-tools
```

6) Angular-friendly TypeScript (ts-proto)

Install `ts-proto` and run the npm script in `gen/ts`:

```powershell
cd gen/ts
npm install --save-dev ts-proto
npm run gen:ts-proto
```

Common plugin notes

- Node-based protoc plugins install shims into `node_modules/.bin/` (Windows creates `.cmd` wrappers). The helper scripts detect and use those shims automatically.
- If the scripts report missing plugins, run the `npm install` commands above in `gen/ts`.

If you want, I can run the generator inside the devcontainer and report results (or install missing plugins locally). Tell me which you prefer.
# proto-mqtt-demo — generate clients

This repo contains `proto/simple.proto`. The `scripts/generate.ps1` helper will generate language-specific client stubs into `gen/`.

Prerequisites

- Install protoc (Protocol Buffers compiler) and put it on PATH: https://grpc.io/docs/protoc-installation/
- For gRPC plugins, install the language-specific generator plugins as needed.

Quick generate (PowerShell)

```powershell

Dependencies per generator

The following lists common dependencies and install commands for Windows (PowerShell). Choose system-wide (requires admin) or local installs.

1) protoc (required for all)

System (Chocolatey, admin):

```powershell
choco install protoc -y
protoc --version
```

Local (no admin):

```powershell
# from repo root
mkdir .\tools\protoc -Force
Invoke-WebRequest -Uri https://github.com/protocolbuffers/protobuf/releases/download/v23.4/protoc-23.4-win64.zip -OutFile .\tools\protoc\protoc.zip
Expand-Archive .\tools\protoc\protoc.zip -DestinationPath .\tools\protoc -Force
Remove-Item .\tools\protoc\protoc.zip
$env:Path = (Resolve-Path .\tools\protoc\bin).Path + ';' + $env:Path
protoc --version
```

2) Java (protobuf java classes)

System: install Java JDK and use protoc with `--java_out`.

3) Python

Install runtime and generation tools (pip):

```powershell
python -m pip install --user protobuf grpcio grpcio-tools
```

4) TypeScript / Node (ts-protoc-gen / grpc-tools)

```powershell
# from repo root
.\scripts\generate.ps1
```

Manual protoc examples

5) Plain JavaScript

Uses protoc's JS plugin (installed with grpc-tools):

```powershell

Java (basic Java protobuf classes):


6) Angular-friendly TypeScript (ts-proto)

Install `ts-proto` and run the provided script:

```powershell
```powershell
protoc --proto_path=proto --java_out=gen/java proto/simple.proto
```


Common plugin notes

- `protoc-gen-grpc-java` is typically distributed with gRPC Java artifacts or can be installed separately for generating gRPC service stubs in Java.
- `protoc-gen-ts_proto` and similar plugins live in `node_modules/.bin/` after `npm install`. Ensure you run the generation from the project root or from `gen/ts` so relative plugin paths resolve.

If you want, I can try to install missing tools locally (no admin) and run the generator for you — tell me which approach you prefer.
Python:

```powershell
protoc --proto_path=proto --python_out=gen/python proto/simple.proto
```

TypeScript (requires ts-protoc-gen):

```powershell
# Install locally: npm install --save-dev ts-protoc-gen grpc-tools
protoc --proto_path=proto --js_out=import_style=commonjs,binary:gen/ts --ts_out=service=grpc-node:gen/ts proto/simple.proto
```

Angular-friendly TypeScript (using ts-proto)

```powershell
# From repo root, in a node project where ts-proto is installed (or use the provided gen/ts package.json):
cd gen/ts; npm install
npm run gen:ts-proto
```

Notes

- For gRPC service stubs you may need additional plugins (eg. protoc-gen-grpc-java, grpc_python_plugin).
- See `gen/` for generated output after running the script.
