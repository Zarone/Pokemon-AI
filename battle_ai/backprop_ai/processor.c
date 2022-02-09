#include "lua.h"
#include "lauxlib.h"
#include "luaconf.h"
#include "mpack/mpack.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define LAYERS 4

#define L1 425
#define L2 100
#define L3 20 
#define L4 1

#if LAYERS == 3
struct Weights {
    double h_layer_1[L1][L2];
    double h_layer_2[L2][L3];
    double biases_1[L2];
    double biases_2[L3];
};
#elif LAYERS == 4
struct Weights {
    double h_layer_1[L1][L2];
    double h_layer_2[L2][L3];
    double h_layer_3[L3][L4];
    double biases_1[L2];
    double biases_2[L3];
    double biases_3[L4];
};
#endif

struct State {
    int game_data[L1]; // the input to the neural network
    char name[11];
};

struct Move {
    int moves[2]; // structured like [ player1move, player2move ]
    double estimate;
    int isMultiEvent; // whether or not there are mulitple possible outcomes after move
};

void parse_weights(mpack_reader_t* reader, int layer, struct Weights *weight_pointer, int indexes[3])
{
    mpack_tag_t tag = mpack_read_tag(reader);
    if (mpack_reader_error(reader) != mpack_ok){
        printf("error loading layer %i\n", layer);
        return;
    }

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


    #if LAYERS==3
    if (layer == 3){
        double val = mpack_tag_double_value(&tag);
        if (indexes[0] == 3){
            weight_pointer->h_layer_1[L1-indexes[1]][L2-indexes[2]] = val;
        }
        else if (indexes[0] == 2){
            weight_pointer->h_layer_2[L2-indexes[1]][L3-indexes[2]] = val;
        }
        else if (indexes[0] == 1){
            if (indexes[1] == 2){
                weight_pointer->biases_1[L2-indexes[2]] = val;
            } else if (indexes[1] == 1){
                weight_pointer->biases_2[L3-indexes[2]] = val;
            }
        } else {
            printf("wasn't 1 or 2 or 3, indexes[0] = %i", indexes[0]);
        }
    }
    #elif LAYERS==4
    if (layer == 3){
        double val = mpack_tag_double_value(&tag);
        if (indexes[0] == 4){
            weight_pointer->h_layer_1[L1-indexes[1]][L2-indexes[2]] = val;
        }
        else if (indexes[0] == 3){
            weight_pointer->h_layer_2[L2-indexes[1]][L3-indexes[2]] = val;
        }
        else if (indexes[0] == 2){
            weight_pointer->h_layer_3[L3-indexes[1]][L4-indexes[2]] = val;
        }
        else if (indexes[0] == 1){
            if (indexes[1] == 3){
                weight_pointer->biases_1[L2-indexes[2]] = val;
            } else if (indexes[1] == 2){
                weight_pointer->biases_2[L3-indexes[2]] = val;
            } else if (indexes[1] == 1){
                weight_pointer->biases_3[L4-indexes[2]] = val;
            }
        } else {
            printf("wasn't 1 or 2 or 3 or 4, indexes[0] = %i", indexes[0]);
        }
    }
    #endif
}

void print_weights(struct Weights *my_weights){
#if LAYERS == 3
    printf("weights[0][0][0] = %f\n", my_weights->h_layer_1[0][0]);
    printf("weights[0][0][1] = %f\n", my_weights->h_layer_1[0][1]);
    printf("weights[0][0][2] = %f\n", my_weights->h_layer_1[0][2]);
    printf("weights[0][0][3] = %f\n", my_weights->h_layer_1[0][3]);
    printf("weights[0][0][4] = %f\n", my_weights->h_layer_1[0][4]);
    printf("weights[0][0][5] = %f\n", my_weights->h_layer_1[0][5]);
    printf("weights[0][0][6] = %f\n", my_weights->h_layer_1[0][6]);
    printf("weights[0][0][7] = %f\n", my_weights->h_layer_1[0][7]);

    printf("weights[1][0][0] = %f\n", my_weights->h_layer_2[0][0]);
    printf("weights[1][1][0] = %f\n", my_weights->h_layer_2[1][0]);
    printf("weights[1][2][0] = %f\n", my_weights->h_layer_2[2][0]);
    printf("weights[1][3][0] = %f\n", my_weights->h_layer_2[3][0]);
    printf("weights[1][4][0] = %f\n", my_weights->h_layer_2[4][0]);
    printf("weights[1][5][0] = %f\n", my_weights->h_layer_2[5][0]);
    printf("weights[1][6][0] = %f\n", my_weights->h_layer_2[6][0]);
    printf("weights[1][7][0] = %f\n", my_weights->h_layer_2[7][0]);
    
    printf("biases[0][0] = %f\n", my_weights->biases_1[0]);
    printf("biases[0][1] = %f\n", my_weights->biases_1[1]);
    printf("biases[0][2] = %f\n", my_weights->biases_1[2]);
    printf("biases[0][3] = %f\n", my_weights->biases_1[3]);
    printf("biases[0][4] = %f\n", my_weights->biases_1[4]);
    printf("biases[0][5] = %f\n", my_weights->biases_1[5]);
    printf("biases[1][0] = %f\n", my_weights->biases_2[0]);
#elif LAYERS == 4
    printf("weights[0][0][0] = %f\n", my_weights->h_layer_1[0][0]);
    printf("weights[0][0][1] = %f\n", my_weights->h_layer_1[0][1]);
    printf("weights[0][0][2] = %f\n", my_weights->h_layer_1[0][2]);
    printf("weights[0][0][3] = %f\n", my_weights->h_layer_1[0][3]);
    printf("weights[0][0][4] = %f\n", my_weights->h_layer_1[0][4]);
    printf("weights[0][0][5] = %f\n", my_weights->h_layer_1[0][5]);
    printf("weights[0][0][6] = %f\n", my_weights->h_layer_1[0][6]);
    printf("weights[0][0][7] = %f\n", my_weights->h_layer_1[0][7]);

    printf("weights[1][0][0] = %f\n", my_weights->h_layer_2[0][0]);
    printf("weights[1][1][0] = %f\n", my_weights->h_layer_2[1][0]);
    printf("weights[1][2][0] = %f\n", my_weights->h_layer_2[2][0]);
    printf("weights[1][3][0] = %f\n", my_weights->h_layer_2[3][0]);
    printf("weights[1][4][0] = %f\n", my_weights->h_layer_2[4][0]);
    printf("weights[1][5][0] = %f\n", my_weights->h_layer_2[5][0]);
    printf("weights[1][6][0] = %f\n", my_weights->h_layer_2[6][0]);
    printf("weights[1][7][0] = %f\n", my_weights->h_layer_2[7][0]);
    
    printf("weights[2][0][0] = %f\n", my_weights->h_layer_3[0][0]);
    printf("weights[2][1][0] = %f\n", my_weights->h_layer_3[1][0]);
    printf("weights[2][2][0] = %f\n", my_weights->h_layer_3[2][0]);
    printf("weights[2][3][0] = %f\n", my_weights->h_layer_3[3][0]);
    printf("weights[2][4][0] = %f\n", my_weights->h_layer_3[4][0]);
    printf("weights[2][5][0] = %f\n", my_weights->h_layer_3[5][0]);
    printf("weights[2][6][0] = %f\n", my_weights->h_layer_3[6][0]);
    printf("weights[2][7][0] = %f\n", my_weights->h_layer_3[7][0]);

    printf("biases[0][0] = %f\n", my_weights->biases_1[0]);
    printf("biases[0][1] = %f\n", my_weights->biases_1[1]);
    printf("biases[0][2] = %f\n", my_weights->biases_1[2]);
    printf("biases[0][3] = %f\n", my_weights->biases_1[3]);
    printf("biases[0][4] = %f\n", my_weights->biases_1[4]);
    printf("biases[0][5] = %f\n", my_weights->biases_1[5]);
    printf("biases[1][0] = %f\n", my_weights->biases_2[0]);
#endif
}

int get_weights(struct Weights *my_weights){
    mpack_reader_t reader;
    mpack_reader_init_filename(&reader, "./battle_ai/backprop_ai/weights.txt");

    #if LAYERS == 3
    int blank_indexes[] = {0,0,0};
    #elif LAYERS == 4
    int blank_indexes[] = {0,0,0,0};
    #endif

    parse_weights(&reader, 0, my_weights, blank_indexes);
    
    mpack_error_t error = mpack_reader_destroy(&reader);
    if (error != mpack_ok){
        printf("error destorying reader: %s\n", mpack_error_to_string(error));
    }
    return error == mpack_ok;
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

void parse_inputs(mpack_reader_t* reader, int layer, struct State *inputs_pointer, int indexes[3]) 
{

    mpack_tag_t tag = mpack_read_tag(reader);
    if (mpack_reader_error(reader) != mpack_ok){
        printf("error in reader: %i\n", mpack_reader_error(reader));
        return;
    }
 
    if (layer == 3){
        struct State myState;
        parse_state(reader, &myState);

        // printf("switch data: %s\n", myState.name);
        // printf("inputs[0]: %i\n", myState.game_data[0]);
        // printf("inputs[1]: %i\n", myState.game_data[1]);
        // printf("inputs[2]: %i\n", myState.game_data[2]);

        int side1 = 10 - indexes[0];
        int side2 = 10 - indexes[1];
        int side3 = indexes[2];

        for (int i = 0; i < 11; i++){

            // sets the state[side1][side2][side3]
            (inputs_pointer+side1*10*25+side2*25+side3)->name[i] = myState.name[i];
        }

        for (int i = 0; i < L1; i++){
            (inputs_pointer+side1*10*25+side2*25+side3)->game_data[i] = myState.game_data[i];
        }

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
                newIndexes[2] = mpack_tag_array_count(&tag)-i;
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

// argument is pointer to first element of array
int get_inputs(struct State *my_states){
    mpack_reader_t reader;
    mpack_reader_init_filename(&reader, "./battle_ai/state_files/battleStatesFromShowdown.txt");

    int blank_indexes[] = {0,0,0};

    parse_inputs(&reader, 0, my_states, blank_indexes);

    return mpack_reader_destroy(&reader) == mpack_ok;
}

void print_inputs(struct State my_states){
    printf("name: %s\n", my_states.name);
    printf("data[0]: %i\n", my_states.game_data[0]);
    printf("data[1]: %i\n", my_states.game_data[1]);
    printf("data[2]: %i\n", my_states.game_data[2]);
    printf("data[3]: %i\n", my_states.game_data[3]);
    printf("data[4]: %i\n", my_states.game_data[4]);
}

double relu(double a){
    return (a > 0) ? a : 0;
}

double logistic(double a, double spread){
    return 1 / (1 + exp(-spread*(double)a));
}

double feedforward(struct Weights *my_weights, int (*inputs)[L1]){
    double activations_layer2[L2];

    // propagate into activations_layer2
    for (int i = 0; i < L2; i++){
        activations_layer2[i] = 0;
        for (int j = 0; j < L1; j++){
            activations_layer2[i] += (double)(*inputs)[j] * my_weights->h_layer_1[j][i];
        }
        activations_layer2[i] += my_weights->biases_1[i];
        activations_layer2[i] = relu(activations_layer2[i]);
    }
#if LAYERS == 3
    double activation_output = 0;

    // propagate into output layer
    for (int i = 0; i < L2; i++){
        activation_output += activations_layer2[i] * my_weights->h_layer_2[i][0];
    }
    activation_output += my_weights->biases_2[0];
    // activation_output = logistic(activation_output, 0.03);
    return activation_output;
#elif LAYERS == 4
    double activations_layer3[L3];

    // propagate into activations_layer3
    for (int i = 0; i < L3; i++){
        activations_layer3[i] = 0;
        for (int j = 0; j < L2; j++){
            activations_layer3[i] += activations_layer2[j] * my_weights->h_layer_2[j][i];
        }
        activations_layer3[i] += my_weights->biases_2[i];
        activations_layer3[i] = relu(activations_layer3[i]);
    }

    double activation_output = 0;

    // propagate into output layer
    for (int i = 0; i < L3; i++){
        activation_output += activations_layer2[i] * my_weights->h_layer_3[i][0];
    }
    activation_output += my_weights->biases_3[0];
    // activation_output = logistic(activation_output, 0.03);
    return activation_output;
#endif
}

int evaluate_moves(){

    struct State blank_state;
    blank_state.name[0] = '\0';

    struct State my_states[10][10][25] = {blank_state};
    get_inputs(&my_states[0][0][0]);
    struct Weights my_weights;
    get_weights(&my_weights);

    // print_weights(&my_weights);
    // print_inputs(my_states[0][0][0]);

    for (int i = 0; i < 10; i++){
        for (int j = 0; j < 10; j++){
            // for (int k = 0; k < 25; k++){
                if (my_states[i][j][0].name[0] != '\0'){

                    // "i" is player2's move
                    // "j" is player1's move
                    // printf("%i %i %i; name: %s\n", i, j, k, my_states[i][j][k].name);
                    // printf("feedforward output %i %i %i : %i\n", i, j, k, (int)round(feedforward(&my_weights, &(my_states[i][j][k].game_data))));
                    printf("feedforward output %i %i %i : %f\n", i, j, 0, feedforward(&my_weights, &(my_states[i][j][0].game_data)));
                }
            // }
        }
    }

    // printf("feedforward output: %f\n", feedforward(&my_weights, &(my_states[0][0][0].game_data)));
    // printf("feedforward output: %f\n", feedforward(&my_weights, &(my_states[0][1][0].game_data)));
    // printf("feedforward output: %f\n", feedforward(&my_weights, &(my_states[0][2][0].game_data)));
    // printf("feedforward output: %f\n", feedforward(&my_weights, &(my_states[0][3][0].game_data)));
    // printf("feedforward output: %f\n", feedforward(&my_weights, &(my_states[0][5][0].game_data)));

    return 1;
}

int get_move(lua_State *L){
    
    // gets rid of function args
    lua_settop(L, 0);
 
    // lua_pushstring(L, get_weights() == 1 ? "sucessfully returned from \"get_weights()\"" : "error in \"get_weights()\"");
    // lua_pushstring(L, get_inputs() == 1 ? "sucessfully returned from \"get_inputs()\"" : "error in \"get_inputs()\"");
    lua_pushstring(L, evaluate_moves() == 1 ? "sucessfully returned from \"evaluate_moves()\"" : "error in \"evaluate_moves()\"");

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