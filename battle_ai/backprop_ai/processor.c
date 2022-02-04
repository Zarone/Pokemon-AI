#include "lua.h"
#include "lauxlib.h"
#include "luaconf.h"
#include "mpack/mpack.h"
#include <stdio.h>

struct Weights {
    double h_layer_1[407][100];
    double h_layer_2[100][1];
};

static char *readcontent(const char *filename)
{
    char *fcontent = NULL;
    int fsize = 0;
    FILE *fp;

    fp = fopen(filename, "r");
    if(fp) {
        fseek(fp, 0, SEEK_END);
        fsize = ftell(fp);
        rewind(fp);

        fcontent = (char*) malloc(sizeof(char) * fsize);
        fread(fcontent, 1, fsize, fp);

        fclose(fp);
    }
    return fcontent;
}

double get_value(mpack_tag_t *tag){
    return mpack_tag_double_value(tag);
}

void parse_element(mpack_reader_t* reader, int layer, struct Weights *weight_pointer,
    int indexes[3]) 
{
    mpack_tag_t tag = mpack_read_tag(reader);
    if (mpack_reader_error(reader) != mpack_ok)
        return;
 
    // double tag_value = get_value(&tag);
 
    if (mpack_tag_type(&tag) == mpack_type_array) {
        uint32_t count = mpack_tag_array_count(&tag);
        // if (layer == 0){
        //     double layer1[407][100];
        //     double layer2[100][1];
        int newIndexes[] = {0, 0, 0};
        for (uint32_t i = count; i > 0; --i) {
            // printf("layer: %i, i: %i   ", layer, i);
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
        // }
        mpack_done_array(reader);
    }

    if (layer == 3){
        if (indexes[0] == 2){
            weight_pointer->h_layer_1[407-indexes[1]][100-indexes[2]] = get_value(&tag);
        }
        else if (indexes[0] == 1){
            weight_pointer->h_layer_2[100-indexes[1]][1-indexes[2]] = get_value(&tag);
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

int getTree(){

    mpack_reader_t reader;
    mpack_reader_init_filename(&reader, "./battle_ai/backprop_ai/weights.txt");

    struct Weights myWeights;
    int indexes[] = {0,0,0};

    parse_element(&reader, 0, &myWeights, indexes);

    // for (int i = 0; i < 100; i++){
    //     printf("myWeights.h_layer_1[0][%i]: %f\n", i, myWeights.h_layer_1[0][i]);
    // }

    return mpack_reader_destroy(&reader) == mpack_ok;
}

int get_move(lua_State *L){
    
    // gets rid of function args
    lua_settop(L, 0);
 
    lua_pushstring(L, getTree() == 1 ? "sucessfully returned from \"getTree()\"" : "error in \"getTree()\"");

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