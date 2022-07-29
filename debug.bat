cls
@REM gcc -O2 -c -o "./battle_ai/backprop_ai/processor/build/mpack.o" "./battle_ai/backprop_ai/mpack/mpack.c"
gcc -O2 -c -o "./battle_ai/backprop_ai/processor/build/processor.o" "./battle_ai/backprop_ai/processor.c" -I"./battle_ai/backprop_ai/processor/lua51" -Wall -Wextra -pedantic-errors
gcc -O -shared -o "./battle_ai/backprop_ai/processor/build/processor.so" "./battle_ai/backprop_ai/processor/build/mpack.o" "./battle_ai/backprop_ai/processor/build/processor.o" -L".\battle_ai\backprop_ai\processor\dll" -llua5.1 -pthread
node ./battle_ai/showdown/build
lua5.1 "./battle_ai/battle_manager.lua" "debug"