cd battle_ai ;
cd backprop_ai ;
cc -bundle -undefined dynamic_lookup -o "./build/processor.so" processor.c -Ilua_src;
cd ../../ ;
./battle_ai/showdown/build ;
lua ./battle_ai/battle_manager.lua