cls
@REM gcc -O2 -c -o "./battle_ai/backprop_ai/build/mpack.o" "./battle_ai/backprop_ai/mpack/mpack.c"
gcc -O2 -c -o "./battle_ai/backprop_ai/build/processor.o" "./battle_ai/backprop_ai/processor.c"
gcc -O -shared -o "./battle_ai/backprop_ai/build/processor.so" "./battle_ai/backprop_ai/build/mpack.o" "./battle_ai/backprop_ai/build/processor.o" -L"C:\Users\Zachary Alfano\Code\Pokemon Bot\battle_ai\backprop_ai\dll" -llua54
@REM node ./battle_ai/showdown/build
lua54 "./battle_ai/battle_manager.lua"