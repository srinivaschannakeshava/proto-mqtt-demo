REM Generate TypeScript code using ts-proto
npm install --save-dev ts-proto

protoc `
  --plugin=protoc-gen-ts_proto="D:\Learnings\proto-mqtt-demo\mqtt-angular\node_modules\.bin\protoc-gen-ts_proto.cmd" `
  --ts_proto_out=src/app/proto `
  --ts_proto_opt=esModuleInterop=true,importSuffix=.ts `
src/app/proto/simple.proto
