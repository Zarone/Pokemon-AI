#include "lua.h"
#include "lauxlib.h"
#include "luaconf.h"
#include "mpack/mpack.h"
#include <stdio.h>

#define L1 425
#define L2 100
#define L3 1 

struct Weights {
    double h_layer_1[L1][L2];
    double h_layer_2[L2][L3];
};

void parse_element(mpack_reader_t* reader, int layer, struct Weights *weight_pointer,
    int indexes[3]) 
{
    mpack_tag_t tag = mpack_read_tag(reader);
    if (mpack_reader_error(reader) != mpack_ok)
        return;
 
    // double tag_value = get_value(&tag);
 
    if (mpack_tag_type(&tag) == mpack_type_array) {
        uint32_t count = mpack_tag_array_count(&tag);
        int newIndexes[] = {0, 0, 0};
        for (uint32_t i = count; i > 0; --i) {
            if (layer == 0){
                newIndexes[0] = i;
            } else if (layer == 1){
                newIndexes[0] = indexes[0];
                newIndexes[1] = i;
            } else if (layer == 2){
                newIndexes[0] = indexes[0];
                newIndexes[1] = indexes[1];
                newIndexes[2] = i;
            }
            parse_element(reader, layer+1, weight_pointer, newIndexes );
            if (mpack_reader_error(reader) != mpack_ok){ // critical check!
                printf("error in mpack: %u\n", (unsigned)mpack_reader_error(reader));
                break;
            }
        }
        mpack_done_array(reader);
    }

    if (layer == 3){
        if (indexes[0] == 2){
            weight_pointer->h_layer_1[L1-indexes[1]][L2-indexes[2]] = mpack_tag_double_value(&tag);
        }
        else if (indexes[0] == 1){
            weight_pointer->h_layer_2[L2-indexes[1]][L3-indexes[2]] = mpack_tag_double_value(&tag);
        }
    }

    // if (mpack_tag_type(&tag) == mpack_type_map) {
    //     for (uint32_t i = mpack_tag_map_count(&tag); i > 0; --i) {
    //         parse_element(reader, depth + 1);
    //         parse_element(reader, depth + 1);
    //         if (mpack_reader_error(reader) != mpack_ok) // critical check!
    //             break;
    //     }
    //     mpack_done_map(reader);
    // }
}

int get_tree(){

    mpack_reader_t reader;
    mpack_reader_init_filename(&reader, "./battle_ai/backprop_ai/weights.txt");

    struct Weights my_weights;
    int blank_indexes[] = {0,0,0};

    parse_element(&reader, 0, &my_weights, blank_indexes);

    return mpack_reader_destroy(&reader) == mpack_ok;
}

int get_move(lua_State *L){
    
    // gets rid of function args
    lua_settop(L, 0);
 
    lua_pushstring(L, get_tree() == 1 ? "sucessfully returned from \"getTree()\"" : "error in \"getTree()\"");

    return 1;

}

int luaopen_processor(lua_State *L){
  luaL_Reg fns[] = {
    {"get_move", get_move},
    {NULL, NULL}
  };
  luaL_newlib(L, fns);
  return 1;  // Number of Lua-facing return values on the Lua stack in L.
}