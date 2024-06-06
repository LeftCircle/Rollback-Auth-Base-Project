TASKKILL /IM AuthenticationServer.exe /F
TASKKILL /IM GatewayServer.exe /F
TASKKILL /IM RogueRoyaleServer.exe /F

cd ./Executables
Start AuthenticationServer.exe
Start GatewayServer.exe

cd ../RogueRoyaleServer
Start RogueRoyaleServer.exe