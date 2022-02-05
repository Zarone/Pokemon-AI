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

struct State {
    int game_data[L1]; // the input to the neural network
    char name[11];
};

void parse_weights(mpack_reader_t* reader, int layer, struct Weights *weight_pointer, int indexes[3]) 
{
    mpack_tag_t tag = mpack_read_tag(reader);
    if (mpack_reader_error(reader) != mpack_ok)
        return;
 
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
            parse_weights(reader, layer+1, weight_pointer, newIndexes );
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
}

int get_tree(){
    mpack_reader_t reader;
    mpack_reader_init_filename(&reader, "./battle_ai/backprop_ai/weights.txt");

    struct Weights my_weights;
    int blank_indexes[] = {0,0,0};

    parse_weights(&reader, 0, &my_weights, blank_indexes);

    return mpack_reader_destroy(&reader) == mpack_ok;
}

void parse_state(mpack_reader_t* reader, struct State *state){
    mpack_tag_t inputsTag = mpack_read_tag(reader);
    if (mpack_reader_error(reader) != mpack_ok){
        printf("error in reading inputsTag: %i\n", mpack_reader_error(reader));
        return;
    }
    if (mpack_tag_type(&inputsTag) == mpack_type_array){
        for (int i = 0; i < L1; i++){
            mpack_tag_t inputTag = mpack_read_tag(reader);
            state->game_data[i] = mpack_tag_int_value(&inputTag);
        }
        mpack_done_array(reader);
    } else {
        printf("I've misunderstood inputsTag, it's actually of type %s and has value %llu\n", mpack_type_to_string(mpack_tag_type(&inputsTag)), mpack_tag_uint_value(&inputsTag));
    }

    mpack_tag_t nameTag = mpack_read_tag(reader);
    if (mpack_reader_error(reader) != mpack_ok){
        printf("error in reading nameTag: %i\n", mpack_reader_error(reader));
        return;
    }
    if (mpack_tag_type(&nameTag) == mpack_type_str){
        char strBuffer[11];
        mpack_read_cstr(reader, strBuffer, mpack_tag_str_length(&nameTag)+1, mpack_tag_str_length(&nameTag));
        if (mpack_reader_error(reader) != mpack_ok){
           printf("error reading string in nameTag: %i\n", mpack_reader_error(reader));
        return;
    }
        for (int i = 0; i < 11; i++){
            state->name[i] = strBuffer[i];
        }
    } else {
        printf("I've misunderstood nameTag, it's actually of type %s and has value %llu\n", mpack_type_to_string(mpack_tag_type(&nameTag)), mpack_tag_uint_value(&nameTag));
    }
}

void parse_inputs(mpack_reader_t* reader, int layer, struct State (*inputs_pointer)[10][10][25], int indexes[3]) 
{
    printf("%i\n", layer);
    mpack_tag_t tag = mpack_read_tag(reader);
    if (mpack_reader_error(reader) != mpack_ok){
        printf("error in reader: %i\n", mpack_reader_error(reader));
        return;
    }
 
    if (layer == 3){
        struct State myState;
        parse_state(reader, &myState);
        printf("switch data: %s\n", myState.name);
        printf("inputs[0]: %i\n", myState.game_data[0]);
        printf("inputs[1]: %i\n", myState.game_data[1]);
        printf("inputs[2]: %i\n", myState.game_data[2]);
        mpack_done_array(reader);
    } else if (mpack_tag_type(&tag) == mpack_type_array) {
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
            parse_inputs(reader, layer+1, inputs_pointer, newIndexes );
            if (mpack_reader_error(reader) != mpack_ok){ // critical check!
                printf("error in mpack input: %u\n", (unsigned)mpack_reader_error(reader));
                break;
            }
        }
        mpack_done_array(reader);
    }
}

int get_inputs(){
    mpack_reader_t reader;
    mpack_reader_init_filename(&reader, "./battle_ai/state_files/battleStatesFromShowdown.txt");

    /*

    [
        [
            [ [ State, State ] ],
            [ [ State, State ] ],
            ... for each player 1 game action
        ],
        [
            [ [ State, State ] ],
            [ [ State, State ] ],
            ... for each player 1 game action
        ],
        ... for each player 2 game action
    ]

    */

    struct State myStates[10][10][25];
    int blank_indexes[] = {0,0,0};

    parse_inputs(&reader, 0, &myStates, blank_indexes);

    return mpack_reader_destroy(&reader) == mpack_ok;
}

int get_move(lua_State *L){
    
    // gets rid of function args
    lua_settop(L, 0);
 
    // lua_pushstring(L, get_tree() == 1 ? "sucessfully returned from \"get_tree()\"" : "error in \"get_tree()\"");
    lua_pushstring(L, get_inputs() == 1 ? "sucessfully returned from \"get_inputs()\"" : "error in \"get_inputs()\"");

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