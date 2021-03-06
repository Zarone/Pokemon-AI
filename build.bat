cls

gcc -O2 -c ^
    "./battle_ai/backprop_ai/processor/dep/mpack/mpack.c"^
    -o "./battle_ai/backprop_ai/processor/build/mpack.o" 

gcc -O2 -c^
    "./battle_ai/backprop_ai/processor/src/main.c" ^
    -o "./battle_ai/backprop_ai/processor/build/processor.o" ^
    -I "./battle_ai/backprop_ai/processor/dep/lua51" ^
    -I "./battle_ai/backprop_ai/processor/dep" ^
    -Wall -Wextra -pedantic-errors

gcc -O2 -c^
    "./battle_ai/backprop_ai/processor/src/feedforward.c" ^
    -o "./battle_ai/backprop_ai/processor/build/feedforward.o" ^
    -Wall -Wextra -pedantic-errors


gcc -O2 -c^
    "./battle_ai/backprop_ai/processor/src/weightmanager.c" ^
    -o "./battle_ai/backprop_ai/processor/build/weightmanager.o" ^
    -Wall -Wextra -pedantic-errors

gcc -O -shared ^
    "./battle_ai/backprop_ai/processor/build/mpack.o" ^
    "./battle_ai/backprop_ai/processor/build/processor.o" ^
    "./battle_ai/backprop_ai/processor/build/feedforward.o" ^
    "./battle_ai/backprop_ai/processor/build/weightmanager.o" ^
    -o "./battle_ai/backprop_ai/processor/build/processor.so" ^
    -L ".\battle_ai\backprop_ai\processor\dep\dll" ^
    -l "lua5.1" ^
    -pthread


node ./battle_ai/showdown/build