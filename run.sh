# cd battle_ai ;
# cd backprop_ai ;
# cc -bundle -undefined dynamic_lookup -o "./build/processor.so" "./mpack/mpack.c" processor.c -Ilua_src;
# cd ../../ ;
# ./battle_ai/showdown/build ;
# lua ./battle_ai/battle_manager.lua

cd battle_ai ;
cd backprop_ai ;
cc -bundle -undefined dynamic_lookup -o "./build/processor.so" "./mpack/mpack.c" processor.c -Ilua_src;
cd ../../ ;
./battle_ai/showdown/build ;
lua showdown_battle.lua