cls
@REM gcc -O2 -c -o "./battle_ai/backprop_ai/build/mpack.o" "./battle_ai/backprop_ai/mpack/mpack.c"
gcc -O2 -c -o "./battle_ai/backprop_ai/build/processor.o" "./battle_ai/backprop_ai/processor.c" -I"./battle_ai/backprop_ai/lua51"
gcc -O -shared -o "./battle_ai/backprop_ai/build/processor.so" "./battle_ai/backprop_ai/build/mpack.o" "./battle_ai/backprop_ai/build/processor.o" -L".\battle_ai\backprop_ai\dll" -llua5.1 -pthread
node ./battle_ai/showdown/build
lua5.1 "./battle_ai/battle_manager.lua" "debug"