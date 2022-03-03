#include "lua.h"
#include "lauxlib.h"
#include "luaconf.h"
#include "mpack/mpack.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "helper/helper.h"
#include <string.h>
// #include <pthread.h>

#define LAYERS 4

#define L1 425
#define L2 200
#define L3 100 
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
    char name[20];
    int activePokemonP1;
    int activePokemonP2;
    char encoreMoveP1[20];
    char encoreMoveP2[20];
    char disableMoveP1[20];
    char disableMoveP2[20];
    int secondaryP1;
    int secondaryP2;
};

struct Move {
    int moves[2]; // structured like [ player1move, player2move ]
    double estimate; // the estimated winrate given this move is made
    int isMultiEvent; // whether or not there are mulitple possible outcomes after move
};

struct PartialMove {
    double estimate;
    int move;
    char name[20];
};

// this struct is for storing the "impact" of a single input
struct Input {
    char name[20];

    // this is for ∂V/∂a where V is whether
    // or not player 1 won, and a is this given input
    double val;


    // this is the value of that input
    double input_val;
};



// this function prints directly to lua
// this is helpful because the emulator
// doesn't log output which came directly 
// from C. And I only declare it later for
// organizational purposes
void printLua_double(lua_State *L, const char *label, double value);
void printLua_string(lua_State *L, const char *label, const char *value);

// "struct Input" array merge sort functions

void merge(struct Input arr[], int l, int m, int r) 
{ 
    int i, j, k; 
    int n1 = m - l + 1; 
    int n2 =  r - m; 
    struct Input L[n1], R[n2]; 
    for (i = 0; i < n1; i++) {
        for (int inc = 0; inc < 20; inc++){
            L[i].name[inc] = arr[l + i].name[inc]; 
        }
        L[i].val = arr[l+i].val;
        L[i].input_val = arr[l+i].input_val;
    }
    for (j = 0; j < n2; j++) {

        for (int inc = 0; inc < 20; inc++){
            R[j].name[inc] = arr[m + 1 + j].name[inc]; 
        }
        R[j].val = arr[m + 1 + j].val;
        R[j].input_val = arr[m + 1 + j].input_val;
    }
    i = 0; 
    j = 0; 
    k = l; 
    while (i < n1 && j < n2) { 
        if (L[i].val <= R[j].val){ 
            for (int inc = 0; inc < 20; inc++){
                arr[k].name[inc] = L[i].name[inc];
            }
            arr[k].val = L[i].val;
            arr[k].input_val = L[i].input_val;
            i++; 
        } 
        else { 
            for (int inc = 0; inc < 20; inc++){
                arr[k].name[inc] = R[j].name[inc];
            }
            arr[k].val = R[j].val;
            arr[k].input_val = R[j].input_val;
            j++; 
        } 
        k++; 
    } 
    while (i < n1) { 
        for (int inc = 0; inc < 20; inc++){
            arr[k].name[inc] = L[i].name[inc];
        }
        arr[k].val = L[i].val;
        arr[k].input_val = L[i].input_val;
        i++; 
        k++; 
    } 
    while (j < n2) { 
        for (int inc = 0; inc < 20; inc++){
            arr[k].name[inc] = R[j].name[inc];
        }
        arr[k].val = R[j].val;; 
        arr[k].input_val = R[j].input_val;; 
        j++; 
        k++; 
    } 
}

void mergeSort(struct Input arr[], int l, int r) 
{ 
    if (l < r) 
    { 
        int m = l+(r-l)/2; 
        mergeSort(arr, l, m); 
        mergeSort(arr, m+1, r); 
        merge(arr, l, m, r); 
    } 
} 

void printErrors(struct Input A[], int size, int top) 
{ 
    printf("\n"); 
    for (int i = 0; i < top; i++) {
        printf("name: %s, val: %f, inputVal: %f\n", A[i].name, A[i].val, A[i].input_val); 
    }
    for (int i = size-1; i > size-1-top; i--) {
        printf("name: %s, val: %f, inputVal: %f\n", A[i].name, A[i].val, A[i].input_val); 
    }
}

void printAllErrors(struct Input A[], int size) 
{ 
    printf("\n"); 
    for (int i = 0; i < size; i++) {
        printf("name: %s, val: %f, inputVal: %f\n", A[i].name, A[i].val, A[i].input_val); 
    }
}


void merge_PartialMove(struct PartialMove arr[], int l, int m, int r) 
{ 
    int i, j, k; 
    int n1 = m - l + 1; 
    int n2 =  r - m; 
    struct PartialMove L[n1], R[n2]; 
    for (i = 0; i < n1; i++) {
        // for (int inc = 0; inc < 20; inc++){
        //     L[i].name[inc] = arr[l + i].name[inc]; 
        // }
        // L[i].val = arr[l+i].val;
        // L[i].input_val = arr[l+i].input_val;

        L[i].estimate = arr[l+i].estimate;
        L[i].move = arr[l+i].move;
    }
    for (j = 0; j < n2; j++) {

        // for (int inc = 0; inc < 20; inc++){
        //     R[j].name[inc] = arr[m + 1 + j].name[inc]; 
        // }
        // R[j].val = arr[m + 1 + j].val;
        // R[j].input_val = arr[m + 1 + j].input_val;

        R[j].estimate = arr[m + 1 + j].estimate;
        R[j].move = arr[m + 1 + j].move;
    }
    i = 0; 
    j = 0; 
    k = l; 
    while (i < n1 && j < n2) { 
        if (L[i].estimate <= R[j].estimate){ 
            // for (int inc = 0; inc < 20; inc++){
            //     arr[k].name[inc] = L[i].name[inc];
            // }
            // arr[k].val = L[i].val;
            // arr[k].input_val = L[i].input_val;

            arr[k].estimate = L[i].estimate;
            arr[k].move = L[i].move;
            i++; 
        } 
        else { 
            // for (int inc = 0; inc < 20; inc++){
            //     arr[k].name[inc] = R[j].name[inc];
            // }
            // arr[k].val = R[j].val;
            // arr[k].input_val = R[j].input_val;
            arr[k].estimate = R[j].estimate;
            arr[k].move = R[j].move;
            j++; 
        } 
        k++; 
    } 
    while (i < n1) { 
        // for (int inc = 0; inc < 20; inc++){
        //     arr[k].name[inc] = L[i].name[inc];
        // }
        // arr[k].val = L[i].val;
        // arr[k].input_val = L[i].input_val;
        arr[k].estimate = L[i].estimate;
        arr[k].move = L[i].move;
        i++; 
        k++; 
    } 
    while (j < n2) { 
        // for (int inc = 0; inc < 20; inc++){
        //     arr[k].name[inc] = R[j].name[inc];
        // }
        // arr[k].val = R[j].val;
        // arr[k].input_val = R[j].input_val;
        arr[k].estimate = R[j].estimate;
        arr[k].move = R[j].move;
        j++; 
        k++; 
    } 
}

void mergeSort_PartialMove(struct PartialMove arr[], int l, int r) 
{ 
    if (l < r) 
    { 
        int m = l+(r-l)/2; 
        mergeSort_PartialMove(arr, l, m); 
        mergeSort_PartialMove(arr, m+1, r); 
        merge_PartialMove(arr, l, m, r); 
    } 
} 

void printArr_PartialMove(lua_State *L, struct PartialMove A[], int size) 
{ 
    for (int i = 0; i < size; i++) {
        // printf("estimate: %f, move: %d\n", A[i].estimate, A[i].move); 
        printLua_double(L, "Move: ", A[i].move);
        printLua_double(L, "Estimate: ", A[i].estimate);
    }
}

// print functions for debugging

void print_weights(struct Weights *my_weights, lua_State *L){
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
    // printf("weights[0][0][0] = %f\n", my_weights->h_layer_1[0][0]);
    // printf("weights[0][0][1] = %f\n", my_weights->h_layer_1[0][1]);
    // printf("weights[0][0][2] = %f\n", my_weights->h_layer_1[0][2]);
    // printf("weights[0][0][3] = %f\n", my_weights->h_layer_1[0][3]);
    // printf("weights[0][0][4] = %f\n", my_weights->h_layer_1[0][4]);
    // printf("weights[0][0][5] = %f\n", my_weights->h_layer_1[0][5]);
    // printf("weights[0][0][6] = %f\n", my_weights->h_layer_1[0][6]);
    // printf("weights[0][0][7] = %f\n", my_weights->h_layer_1[0][7]);

    // printf("weights[1][0][0] = %f\n", my_weights->h_layer_2[0][0]);
    // printf("weights[1][1][0] = %f\n", my_weights->h_layer_2[1][0]);
    // printf("weights[1][2][0] = %f\n", my_weights->h_layer_2[2][0]);
    // printf("weights[1][3][0] = %f\n", my_weights->h_layer_2[3][0]);
    // printf("weights[1][4][0] = %f\n", my_weights->h_layer_2[4][0]);
    // printf("weights[1][5][0] = %f\n", my_weights->h_layer_2[5][0]);
    // printf("weights[1][6][0] = %f\n", my_weights->h_layer_2[6][0]);
    // printf("weights[1][7][0] = %f\n", my_weights->h_layer_2[7][0]);
    
    // printf("weights[2][0][0] = %f\n", my_weights->h_layer_3[0][0]);
    // printf("weights[2][1][0] = %f\n", my_weights->h_layer_3[1][0]);
    // printf("weights[2][2][0] = %f\n", my_weights->h_layer_3[2][0]);
    // printf("weights[2][3][0] = %f\n", my_weights->h_layer_3[3][0]);
    // printf("weights[2][4][0] = %f\n", my_weights->h_layer_3[4][0]);
    // printf("weights[2][5][0] = %f\n", my_weights->h_layer_3[5][0]);
    // printf("weights[2][6][0] = %f\n", my_weights->h_layer_3[6][0]);
    // printf("weights[2][7][0] = %f\n", my_weights->h_layer_3[7][0]);

    // printf("biases[0][0] = %f\n", my_weights->biases_1[0]);
    // printf("biases[0][1] = %f\n", my_weights->biases_1[1]);
    // printf("biases[0][2] = %f\n", my_weights->biases_1[2]);
    // printf("biases[0][3] = %f\n", my_weights->biases_1[3]);
    // printf("biases[0][4] = %f\n", my_weights->biases_1[4]);
    // printf("biases[0][5] = %f\n", my_weights->biases_1[5]);
    // printf("biases[1][0] = %f\n", my_weights->biases_2[0]);

    printLua_double(L, "weights[0][0][0] = ", my_weights->h_layer_1[0][0]);
    printLua_double(L, "weights[0][0][1] = ", my_weights->h_layer_1[0][1]);
    printLua_double(L, "weights[0][0][2] = ", my_weights->h_layer_1[0][2]);
    printLua_double(L, "weights[0][0][3] = ", my_weights->h_layer_1[0][3]);
    printLua_double(L, "weights[0][0][4] = ", my_weights->h_layer_1[0][4]);
    printLua_double(L, "weights[0][0][5] = ", my_weights->h_layer_1[0][5]);
    printLua_double(L, "weights[0][0][6] = ", my_weights->h_layer_1[0][6]);
    printLua_double(L, "weights[0][0][7] = ", my_weights->h_layer_1[0][7]);

    printLua_double(L, "weights[1][0][0] = ", my_weights->h_layer_2[0][0]);
    printLua_double(L, "weights[1][1][0] = ", my_weights->h_layer_2[1][0]);
    printLua_double(L, "weights[1][2][0] = ", my_weights->h_layer_2[2][0]);
    printLua_double(L, "weights[1][3][0] = ", my_weights->h_layer_2[3][0]);
    printLua_double(L, "weights[1][4][0] = ", my_weights->h_layer_2[4][0]);
    printLua_double(L, "weights[1][5][0] = ", my_weights->h_layer_2[5][0]);
    printLua_double(L, "weights[1][6][0] = ", my_weights->h_layer_2[6][0]);
    printLua_double(L, "weights[1][7][0] = ", my_weights->h_layer_2[7][0]);
    
    printLua_double(L, "weights[2][0][0] = ", my_weights->h_layer_3[0][0]);
    printLua_double(L, "weights[2][1][0] = ", my_weights->h_layer_3[1][0]);
    printLua_double(L, "weights[2][2][0] = ", my_weights->h_layer_3[2][0]);
    printLua_double(L, "weights[2][3][0] = ", my_weights->h_layer_3[3][0]);
    printLua_double(L, "weights[2][4][0] = ", my_weights->h_layer_3[4][0]);
    printLua_double(L, "weights[2][5][0] = ", my_weights->h_layer_3[5][0]);
    printLua_double(L, "weights[2][6][0] = ", my_weights->h_layer_3[6][0]);
    printLua_double(L, "weights[2][7][0] = ", my_weights->h_layer_3[7][0]);

    printLua_double(L, "biases[0][0] = ", my_weights->biases_1[0]);
    printLua_double(L, "biases[0][1] = ", my_weights->biases_1[1]);
    printLua_double(L, "biases[0][2] = ", my_weights->biases_1[2]);
    printLua_double(L, "biases[0][3] = ", my_weights->biases_1[3]);
    printLua_double(L, "biases[0][4] = ", my_weights->biases_1[4]);
    printLua_double(L, "biases[0][5] = ", my_weights->biases_1[5]);
    printLua_double(L, "biases[1][0] = ", my_weights->biases_2[0]);
#endif
}

void print_inputs(struct State my_states, lua_State *L){
    printLua_string(L, "name: ", my_states.name);
    printLua_double(L, "data[0]: ", my_states.game_data[0]);
    printLua_double(L, "data[1]: ", my_states.game_data[1]);
    printLua_double(L, "data[2]: ", my_states.game_data[2]);
    printLua_double(L, "data[3]: ", my_states.game_data[3]);
    printLua_double(L, "data[4]: ", my_states.game_data[4]);
    printLua_double(L, "data[5]: ", my_states.game_data[5]);
    printLua_double(L, "data[6]: ", my_states.game_data[6]);
    printLua_double(L, "data[7]: ", my_states.game_data[7]);
    printLua_double(L, "data[8]: ", my_states.game_data[8]);
    printLua_double(L, "data[9]: ", my_states.game_data[9]);
    printLua_double(L, "data[10]: ", my_states.game_data[10]);
    printLua_double(L, "data[11]: ", my_states.game_data[11]);
    printLua_double(L, "data[12]: ", my_states.game_data[12]);
    printLua_double(L, "data[13]: ", my_states.game_data[13]);
    printLua_double(L, "data[14]: ", my_states.game_data[14]);
    printLua_double(L, "data[15]: ", my_states.game_data[15]);
    printLua_double(L, "data[16]: ", my_states.game_data[16]);
    printLua_double(L, "data[65]: ", my_states.game_data[65]);
    printLua_double(L, "data[95]: ", my_states.game_data[95]);
    printLua_double(L, "activeP1: ", my_states.activePokemonP1);
    printLua_double(L, "activeP2: ", my_states.activePokemonP2);
    printLua_double(L, "secondaryP1: ", my_states.secondaryP1);
    printLua_double(L, "secondaryP2: ", my_states.secondaryP2);
    printLua_string(L, "encoreP1: ", my_states.encoreMoveP1);
    printLua_string(L, "encoreP2: ", my_states.encoreMoveP2);
    printLua_string(L, "disableP1: ", my_states.disableMoveP1);
    printLua_string(L, "disableP2: ", my_states.disableMoveP2);
}

void parse_weights(lua_State *L, mpack_reader_t* reader, int layer, struct Weights *weight_pointer, int indexes[3])
{
    mpack_tag_t tag = mpack_read_tag(reader);
    if (mpack_reader_error(reader) != mpack_ok){
        printLua_double(L, "error loading layer ", layer);
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
            parse_weights(L, reader, layer+1, weight_pointer, newIndexes );
            if (mpack_reader_error(reader) != mpack_ok){ // critical check!
                printLua_double(L, "error in mpack: %u\n", (unsigned)mpack_reader_error(reader));
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
            printLua_double(L, "wasn't 1 or 2 or 3 or 4, indexes[0] = ", indexes[0]);
        }
    }
    #endif
}

int get_weights(lua_State *L, struct Weights *my_weights){
    mpack_reader_t reader;
    mpack_reader_init_filename(&reader, "./battle_ai/backprop_ai/weights.txt");

    int blank_indexes[] = {0,0,0};

    parse_weights(L, &reader, 0, my_weights, blank_indexes);
    
    mpack_error_t error = mpack_reader_destroy(&reader);
    if (error != mpack_ok){
        printLua_string(L, "error destorying reader: ", mpack_error_to_string(error));
    }
    return error == mpack_ok;
}

void parse_state(lua_State *L, mpack_reader_t* reader, struct State *state){

    mpack_tag_t inputsTag = mpack_read_tag(reader);
    if (mpack_reader_error(reader) != mpack_ok){
        printLua_double(L, "error in reading inputsTag: ", mpack_reader_error(reader));
        return;
    }
    if (mpack_tag_type(&inputsTag) == mpack_type_array){
        for (int i = 0; i < L1; i++){
            mpack_tag_t inputTag = mpack_read_tag(reader);

            state->game_data[i] = mpack_tag_int_value(&inputTag);

            // printf("state[%i] = %i\n", i, state->game_data[i]);
        }
        mpack_done_array(reader);
    } else {
        printLua_string(L, "inputsTag of type ", mpack_type_to_string(mpack_tag_type(&inputsTag)));
        printLua_double(L, "inputsTag of value ", mpack_tag_double_value(&inputsTag));
    }


    mpack_tag_t nameTag = mpack_read_tag(reader);
    if (mpack_reader_error(reader) != mpack_ok){
        printLua_double(L, "error in reading nameTag: ", reader->error);
        return;
    }
    if (mpack_tag_type(&nameTag) == mpack_type_str){
        char strBuffer[20];
        mpack_read_cstr(reader, strBuffer, mpack_tag_str_length(&nameTag)+1, mpack_tag_str_length(&nameTag));
        if (mpack_reader_error(reader) != mpack_ok){
            printLua_double(L, "error reading string in nameTag: ", mpack_reader_error(reader));
            return;
        }
        for (int i = 0; i < 20; i++){
            state->name[i] = strBuffer[i];
        }
        // printf("name: %s\n", state->name);
    } else {
        printLua_string(L, "nameTag of type ", mpack_type_to_string(mpack_tag_type(&nameTag)));
        printLua_double(L, "nameTag of value ", mpack_tag_uint_value(&nameTag));
        
    }

    mpack_tag_t activeP1 = mpack_read_tag(reader);

    if ( reader->error && mpack_ok && mpack_reader_error(reader) != mpack_ok){
        printLua_double(L, "error reading activeP1: ", mpack_reader_error(reader));
        return;
    }
    if (mpack_tag_type(&activeP1) == mpack_type_uint){
        if ( reader->error && mpack_ok && mpack_reader_error(reader) != mpack_ok){
            printLua_double(L, "error reading string in activeP1: ",  (*reader).error);
            return;
        }
        unsigned int tag_value = mpack_tag_uint_value(&activeP1);
        state->activePokemonP1 = tag_value;
        // printf("activeP1: %i\n", state->activePokemonP1);

    } else {
        printLua_string(L, "activeP1 of type ", mpack_type_to_string(mpack_tag_type(&activeP1)));
    }

    mpack_tag_t activeP2 = mpack_read_tag(reader);
    if (mpack_reader_error(reader) != mpack_ok){
        printLua_double(L, "error in reading activeP2: ", mpack_reader_error(reader));
        return;
    }
    if (mpack_tag_type(&activeP2) == mpack_type_uint){
        if (mpack_reader_error(reader) != mpack_ok){
            printLua_double(L, "error reading string in activeP2: ", mpack_reader_error(reader));
            return;
        }
        unsigned int tag_value = mpack_tag_uint_value(&activeP2);
        state->activePokemonP2 = tag_value;
        // printf("activeP2: %i\n", state->activePokemonP2);
    } else {
        printf("I've misunderstood activeP2, it's actually of type %s and has value %llu\n", mpack_type_to_string(mpack_tag_type(&activeP2)), mpack_tag_uint_value(&activeP2));
    }

    mpack_tag_t encoreP1 = mpack_read_tag(reader);
    if (mpack_reader_error(reader) != mpack_ok){
        printf("error in reading encoreP1: %i\n", mpack_reader_error(reader));
        return;
    }
    if (mpack_tag_type(&encoreP1) == mpack_type_str){
        char strBuffer[20];
        mpack_read_cstr(reader, strBuffer, mpack_tag_str_length(&encoreP1)+1, mpack_tag_str_length(&encoreP1));
        if (mpack_reader_error(reader) != mpack_ok){
            printf("error reading string in encoreP1: %i\n", mpack_reader_error(reader));
            return;
        }
        for (int i = 0; i < 20; i++){
            state->encoreMoveP1[i] = strBuffer[i];
        }
        // printf("encoreP1: %s\n", state->encoreMoveP1);
    } else {
        printf("I've misunderstood encoreP1, it's actually of type %s and has value %llu\n", mpack_type_to_string(mpack_tag_type(&encoreP1)), mpack_tag_uint_value(&encoreP1));
    }

    mpack_tag_t encoreP2 = mpack_read_tag(reader);
    if (mpack_reader_error(reader) != mpack_ok){
        printf("error in reading encoreP2: %i\n", mpack_reader_error(reader));
        return;
    }
    if (mpack_tag_type(&encoreP2) == mpack_type_str){
        char strBuffer[20];
        mpack_read_cstr(reader, strBuffer, mpack_tag_str_length(&encoreP2)+1, mpack_tag_str_length(&encoreP2));
        if (mpack_reader_error(reader) != mpack_ok){
            printf("error reading string in encoreP2: %i\n", mpack_reader_error(reader));
            return;
        }
        for (int i = 0; i < 20; i++){
            state->encoreMoveP2[i] = strBuffer[i];
        }
        // printf("encoreP2: %s\n", state->encoreMoveP2);
    } else {
        printf("I've misunderstood encoreP2, it's actually of type %s and has value %llu\n", mpack_type_to_string(mpack_tag_type(&encoreP2)), mpack_tag_uint_value(&encoreP2));
    }


    mpack_tag_t disableP1 = mpack_read_tag(reader);
    if (mpack_reader_error(reader) != mpack_ok){
        printf("error in reading disableP1: %i\n", mpack_reader_error(reader));
        return;
    }
    if (mpack_tag_type(&disableP1) == mpack_type_str){
        char strBuffer[20];
        mpack_read_cstr(reader, strBuffer, mpack_tag_str_length(&disableP1)+1, mpack_tag_str_length(&disableP1));
        if (mpack_reader_error(reader) != mpack_ok){
            printf("error reading string in disableP1: %i\n", mpack_reader_error(reader));
            return;
        }
        for (int i = 0; i < 20; i++){
            state->disableMoveP1[i] = strBuffer[i];
        }
        // printf("disableP1: %s\n", state->encoreMoveP2);
    } else {
        printf("I've misunderstood disableP1, it's actually of type %s and has value %llu\n", mpack_type_to_string(mpack_tag_type(&disableP1)), mpack_tag_uint_value(&disableP1));
    }

    mpack_tag_t disableP2 = mpack_read_tag(reader);
    if (mpack_reader_error(reader) != mpack_ok){
        printf("error in reading disableP2: %i\n", mpack_reader_error(reader));
        return;
    }
    if (mpack_tag_type(&disableP2) == mpack_type_str){
        char strBuffer[20];
        mpack_read_cstr(reader, strBuffer, mpack_tag_str_length(&disableP2)+1, mpack_tag_str_length(&disableP2));
        if (mpack_reader_error(reader) != mpack_ok){
            printf("error reading string in disableP2: %i\n", mpack_reader_error(reader));
            return;
        }
        for (int i = 0; i < 20; i++){
            state->disableMoveP2[i] = strBuffer[i];
        }
        // printf("disableP2: %s\n", state->encoreMoveP2);
    } else {
        printf("I've misunderstood disableP2, it's actually of type %s and has value %llu\n", mpack_type_to_string(mpack_tag_type(&disableP2)), mpack_tag_uint_value(&disableP2));
    }

    mpack_tag_t secondaryP1 = mpack_read_tag(reader);
    if (mpack_reader_error(reader) != mpack_ok){
        printLua_double(L, "error in reading secondaryP1: ", mpack_reader_error(reader));
        return;
    }
    if (mpack_tag_type(&secondaryP1) == mpack_type_uint){
        if (mpack_reader_error(reader) != mpack_ok){
            printLua_double(L, "error reading string in secondaryP1: ", mpack_reader_error(reader));
            return;
        }
        unsigned int tag_value = mpack_tag_uint_value(&secondaryP1);
        state->secondaryP1 = tag_value;
        // printLua_double(L, "secondaryP1 set to: ", state->secondaryP1);

    } else {
        printLua_string(L, "secondaryP1 of type ", mpack_type_to_string(mpack_tag_type(&secondaryP1)));
    }

    mpack_tag_t secondaryP2 = mpack_read_tag(reader);
    if (mpack_reader_error(reader) != mpack_ok){
        printf("error in reading secondaryP2: %i\n", mpack_reader_error(reader));
        return;
    }
    if (mpack_tag_type(&activeP2) == mpack_type_uint){
        if (mpack_reader_error(reader) != mpack_ok){
            printf("error reading string in secondaryP2: %i\n", mpack_reader_error(reader));
            return;
        }
        unsigned int tag_value = mpack_tag_uint_value(&secondaryP2);
        state->secondaryP2 = tag_value;
        // printf("secondaryP2: %i\n", state->secondaryP2);
    } else {
        printf("I've misunderstood secondaryP2, it's actually of type %s and has value %llu\n", mpack_type_to_string(mpack_tag_type(&secondaryP2)), mpack_tag_uint_value(&secondaryP2));
    }
}

void parse_inputs(lua_State *L, mpack_reader_t* reader, int layer, struct State *inputs_pointer, int indexes[3]) 
{
    mpack_tag_t tag = mpack_read_tag(reader);
    if (mpack_reader_error(reader) != mpack_ok){
        printf("error in reader (parse_inputs): %i\n", mpack_reader_error(reader));
        return;
    }
 
    if (layer == 3){
        struct State myState;
        parse_state(L, reader, &myState);


        // printf("switch data: %s\n", myState.name);
        // printf("inputs[0]: %i\n", myState.game_data[0]);
        // printf("inputs[1]: %i\n", myState.game_data[1]);
        // printf("inputs[2]: %i\n", myState.game_data[2]);

        int side1 = 10 - indexes[0];
        int side2 = 10 - indexes[1];
        int side3 = indexes[2];

        // printLua_double(L, "side1: ", side1);
        // printLua_double(L, "side2: ", side2);
        // printLua_double(L, "side3: ", side3);
        // printLua_double(L, "inputs[0]", myState.game_data[0]);
        // printLua_double(L, "inputs[1]", myState.game_data[1]);
        // printLua_double(L, "inputs[2]", myState.game_data[2]);
        // printLua_double(L, "inputs[3]", myState.game_data[3]);
        // printLua_double(L, "inputs[4]", myState.game_data[4]);
        // printLua_string(L, "switch data: ", myState.name);

        for (int i = 0; i < 20; i++){

            // sets the state[side1][side2][side3]
            (inputs_pointer+side1*10*25+side2*25+side3)->name[i] = myState.name[i];
        }

        for (int i = 0; i < 20; i++){

            // sets the state[side1][side2][side3]
            (inputs_pointer+side1*10*25+side2*25+side3)->encoreMoveP1[i] = myState.encoreMoveP1[i];
            (inputs_pointer+side1*10*25+side2*25+side3)->encoreMoveP2[i] = myState.encoreMoveP2[i];
            (inputs_pointer+side1*10*25+side2*25+side3)->disableMoveP1[i] = myState.disableMoveP1[i];
            (inputs_pointer+side1*10*25+side2*25+side3)->disableMoveP2[i] = myState.disableMoveP2[i];
        }

        for (int i = 0; i < L1; i++){
            (inputs_pointer+side1*10*25+side2*25+side3)->game_data[i] = myState.game_data[i];
        }

        (inputs_pointer+side1*10*25+side2*25+side3)->activePokemonP1 = myState.activePokemonP1;
        (inputs_pointer+side1*10*25+side2*25+side3)->activePokemonP2 = myState.activePokemonP2;

        (inputs_pointer+side1*10*25+side2*25+side3)->secondaryP1 = myState.secondaryP1;
        (inputs_pointer+side1*10*25+side2*25+side3)->secondaryP2 = myState.secondaryP2;

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
            parse_inputs(L, reader, layer+1, inputs_pointer, newIndexes );
            if (mpack_reader_error(reader) != mpack_ok){ // critical check!
                printf("error in mpack input: %u\n", (unsigned)mpack_reader_error(reader));
                break;
            }
        }
        mpack_done_array(reader);
    }

}

// argument is pointer to first element of array
int get_inputs(lua_State *L, struct State *my_states, int currentKey){
    mpack_reader_t reader;
    char stringKey[3];
    sprintf(stringKey, "%d", currentKey);

    char filename[60] = "./battle_ai/state_files/battleStatesFromShowdown/";
    strcat(filename, stringKey);
    printLua_string(L, "checking file path: ", filename);
    mpack_reader_init_filename(&reader, filename);

    if (mpack_reader_error(&reader) != mpack_ok){
        printf("error initialing reader: %i\n", mpack_reader_error(&reader));
        return -1;
    }

    int blank_indexes[] = {0,0,0};

    parse_inputs(L, &reader, 0, my_states, blank_indexes);

    return mpack_reader_destroy(&reader) == mpack_ok;
}



// neural network stuff

double relu(double a){
    return (a > 0) ? a : 0;
}

double relu_derivative(double a){
    return (a > 0) ? 1 : 0;
}

#define SPREAD 0.2

double logistic(double a){
    return 1 / (1 + exp(-SPREAD*(double)a));
}

double logistic_derivative(double a){
    return logistic(a)*(1-logistic(a));
}

double feedforward(struct Weights *my_weights, int (*inputs)[L1]){
    double activations_layer2[L2];
    double z_layer2[L2];

    // propagate into activations_layer2
    for (int i = 0; i < L2; i++){
        z_layer2[i] = 0;
        for (int j = 0; j < L1; j++){
            z_layer2[i] += (double)(*inputs)[j] * my_weights->h_layer_1[j][i];
        }
        z_layer2[i] += my_weights->biases_1[i];
        activations_layer2[i] = relu(z_layer2[i]);
    }
#if LAYERS == 3
    double activation_output = 0;

    // propagate into output layer
    for (int i = 0; i < L2; i++){
        activation_output += activations_layer2[i] * my_weights->h_layer_2[i][0];
    }
    activation_output += my_weights->biases_2[0];
    // activation_output = logistic(activation_output, 1);
    return activation_output;
#elif LAYERS == 4
    double activations_layer3[L3];
    double z_layer3[L3];

    // propagate into activations_layer3
    for (int i = 0; i < L3; i++){
        z_layer3[i] = 0;
        for (int j = 0; j < L2; j++){
            z_layer3[i] += activations_layer2[j] * my_weights->h_layer_2[j][i];
        }
        z_layer3[i] += my_weights->biases_2[i];
        activations_layer3[i] = relu(z_layer3[i]);
    }

    double activation_layer4 = 0;
    double z_layer4 = 0;

    // propagate into output layer
    for (int i = 0; i < L3; i++){
        z_layer4 += activations_layer3[i] * my_weights->h_layer_3[i][0];
    }
    z_layer4 += my_weights->biases_3[0];
    // activation_layer4 = logistic(z_layer4);
    activation_layer4 = logistic(z_layer4);


    // backpropagate to find ideal changes to inputs
    
    // I'm also defining error as ( del V / del a ) where V 
    // is the very last activation and a is any given activation value

    double error_layer3[L3];
    for (int i = 0; i < L3; i++){ 
        error_layer3[i] = my_weights->h_layer_3[i][0] * logistic_derivative(z_layer4);
    }

    double error_layer2[L2] = {0};
    for (int i = 0; i < L2; i++){
        for (int j = 0; j < L3; j++){
            error_layer2[i] += my_weights->h_layer_2[i][j] * relu_derivative(z_layer3[j]) * error_layer3[j];
        }
    }

    struct Input blank_input;
    blank_input.val = 0;
    blank_input.name[0] = '\n';
    struct Input error_layer1[L1] = { blank_input };
    for (int i = 0; i < L1; i++){
        for (int k = 0; k < 20; k++){
            error_layer1[i].name[k] = network_mapping[i][k];
        }
        for (int j = 0; j < L2; j++){
            error_layer1[i].val += my_weights->h_layer_1[i][j] * relu_derivative(z_layer2[j]) * error_layer2[j];
        }
        error_layer1[i].input_val = (double)(*inputs)[i];
        error_layer1[i].val *= error_layer1[i].input_val;
    }

    // mergeSort(error_layer1, 0, L1-1);
    // printErrors(error_layer1, L1, 1);
    // printAllErrors(error_layer1, L1);


    return activation_layer4;
#endif
}

void load_showdown_state(lua_State *L, struct State *state, int key){

    // instead of doing this, i can probably execute this whole thing in C
    
    // original Lua Code
    /*
    stateFile = io.open("./battle_ai/state_files/battleStateForShowdown/"..key, "w")
    stateFile:write(
        json.encode({state, "", activeP1, activeP2, encoreP1, encoreP2, disabledP1, disabledP2, secP1, secP2})
    )
    stateFile:close()

    showdown_init = "node ./battle_ai/showdown/pokemon-showdown simulate-battle -"..key
                
    -- print("running ", showdown_init )
    instance.ps_stream = io.popen(showdown_init, "w")
    instance.ps_stream:close()
    print("Stream Closed")    
    emu.frameadvance()  
    */

   // potential C Code
   

    // encode to memory buffer
    char* data;
    mpack_writer_t writer;
    size_t size;
    mpack_writer_init_growable(&writer, &data, &size);
    
    mpack_start_array(&writer, 10);

    mpack_start_array(&writer, 425);

    for (int i = 0; i < 425; i++){
        mpack_write_int(&writer, state->game_data[i]);
    }
    mpack_finish_array(&writer);

    mpack_write_str(&writer, "", 1);
    mpack_write_uint(&writer, state->activePokemonP1);
    mpack_write_uint(&writer, state->activePokemonP2);
    mpack_write_str(&writer, state->encoreMoveP1, strlen(state->encoreMoveP1));
    mpack_write_str(&writer, state->encoreMoveP2, strlen(state->encoreMoveP2));
    mpack_write_str(&writer, state->disableMoveP1, strlen(state->disableMoveP1));
    mpack_write_str(&writer, state->disableMoveP2, strlen(state->disableMoveP2));
    mpack_write_uint(&writer, state->secondaryP1);
    mpack_write_uint(&writer, state->secondaryP2);

    mpack_finish_array(&writer);
    
    // finish writing
    if (mpack_writer_destroy(&writer) != mpack_ok) {
        fprintf(stderr, "An error occurred encoding the data!\n");
        return;
    }

    char stringKey[3];
    sprintf(stringKey, "%d", key);
    
    char directory[] = "./battle_ai/state_files/battleStateForShowdown/";
    strcat(directory, stringKey);
    FILE * fp;
    fp = fopen(directory, "w");

    if(fp == NULL) {
        printf("file can't be opened\n");
        exit(1);
    }
    // fprintf(fp, "data");
    fwrite(data, size, 1, fp);
    fclose(fp);
   
    char process[] = "node ./battle_ai/showdown/pokemon-showdown simulate-battle -";
    strcat(process, stringKey);
    system(process);
    lua_call(L, 0, 0);
    lua_getglobal(L, "frame");
   
    // lua_createtable(L, L1, 0);

    // // stack
    // // [ exec_showdown_state, {} ]

    // for (int i = 0; i < L1; i++){

    //     lua_pushinteger(L, i+1);
    //     // stack
    //     // [ exec_showdown_state, {}, i+1 ]

    //     lua_pushinteger(L, state->game_data[i]);
    //     // stack
    //     // [ exec_showdown_state, {}, i+1, state->game_data[i] ]

    //     lua_settable(L, -3);
    
    // }


    // // stack
    // // [ exec_showdown_state, { ... } ]

    // lua_pushinteger(L, state->activePokemonP1);
    // lua_pushinteger(L, state->activePokemonP2);
    // lua_pushstring(L, state->encoreMoveP1);
    // lua_pushstring(L, state->encoreMoveP2);
    // lua_pushstring(L, state->disableMoveP1);
    // lua_pushstring(L, state->disableMoveP2);
    // lua_pushinteger(L, state->secondaryP1);
    // lua_pushinteger(L, state->secondaryP2);
    // lua_pushinteger(L, key);

    // lua_call(L, 10, 0);
    // lua_getglobal(L, "exec_showdown_state");

}


#define TRIM_P2 3
#define TRIM_P1 5
int matchesP1(int move, struct PartialMove (*sortedMoveList)[10]){
    // return move == (*sortedMoveList)[9].move || move == (*sortedMoveList)[8].move;
    
    for (int i = 0; i < TRIM_P1; i++){
        int index = 9-i;
        if ((*sortedMoveList)[index].move == move) return 1; 
    }
    return 0;
}
int matchesP2(int move, struct PartialMove (*sortedMoveList)){
    // return move == (*sortedMoveList)[0].move || move == (*sortedMoveList)[1].move;
    
    for (int i = 0; i < TRIM_P2; i++){
        if ( (*(sortedMoveList+i)).move == move) return 1; 
    }
    return 0;
}

struct EvaluateArgs {
    lua_State *L;
    struct State *my_state;
    struct Weights *my_weights;
    int depth;
    struct PartialMove* outputPtr;
};

// void evaluate_move(lua_State *L, struct State *my_state, struct Weights *my_weights, int depth, struct PartialMove* outputPtr);
void *evaluate_move(void *rawArgs);

#define START_DEPTH 2

// my_state is intented as a pointer to to State array of length 25
void *evaluate_switch(void *rawArgs){
    
    // printf("\nIn evaluate_switch, Depth: %i\n", depth);
    struct EvaluateArgs *args = (struct EvaluateArgs*)rawArgs;

    // if both players switched
    if ( args->my_state->secondaryP1 != 0 && args->my_state->secondaryP2 != 0 ){

        double accumulativeP2[] = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0};
        int countP2[] = {0, 0, 0, 0, 0, 0};
        double allEstimates[25] = {0.0};

        for (int i = 0; i < 25; i++){
            if ( (*(args->my_state + i) ).name[0] != '\0' ) {
                // double thisEstimate = evaluate_move( L, (my_state + i), my_weights, depth-1 ).estimate;
                double thisEstimate = feedforward(args->my_weights, &((*(args->my_state + i)).game_data));
                allEstimates[i] = thisEstimate;
                accumulativeP2[(*(args->my_state + i) ).secondaryP2 - 5] += thisEstimate;
                countP2[(*(args->my_state + i) ).secondaryP2 - 5]+=1;
            } else {
                break;
            }
        }

        struct PartialMove P2Moves[6];
        for (int i = 0; i < 6; i++){
            P2Moves[i].move = i;
            if (countP2[i] > 0){
                P2Moves[i].estimate = accumulativeP2[i] / countP2[i];
            } else {
                P2Moves[i].estimate = 1.0;
            }
        }

        mergeSort_PartialMove(P2Moves, 0, 5);
        
        double accumulativeP1[] = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0};
        int countP1[] = {0, 0, 0, 0, 0, 0};

        for (int i = 0; i < 25; i++){
            if ( (*(args->my_state + i) ).name[0] != '\0' ) {
                if ( matchesP2( (*(args->my_state + i)).secondaryP2, &P2Moves[0] ) ){
                    double thisEstimate = allEstimates[i];
                    accumulativeP1[(*(args->my_state + i) ).secondaryP1 - 5] += thisEstimate;
                    countP1[(*(args->my_state + i) ).secondaryP1 - 5]+=1;
                }
            } else {
                break;
            }
        }

        int bestMove = 0;
        double bestAverage = 0.0;

        for (int i = 0; i < 6; i++){
            double newEstimate = accumulativeP1[i] / countP1[i];
            if (newEstimate > bestAverage){
                bestAverage = newEstimate;
                bestMove = i;
            }
        }

        for (int i = 0; i < 25; i++){

            // secondaryP1 is in range [5, 10]
            // bestMove is in range [0, 5]
            // P2Moves[0].move is in range [0, 5]
            if ((*(args->my_state + i)).secondaryP1 == bestMove+5 && (*(args->my_state + i)).secondaryP1 == P2Moves[0].move){
                P2Moves[0].move += 4;
                if (args->depth != 1) {
                    struct PartialMove output;

                    struct EvaluateArgs newArgs;
                    newArgs.L = args->L;
                    newArgs.my_state = args->my_state + i;
                    newArgs.my_weights = args->my_weights;
                    newArgs.depth = args->depth-1;
                    newArgs.outputPtr = &output;

                    evaluate_move(&newArgs);
                    P2Moves->estimate = output.estimate;
                }
                *(args->outputPtr) = P2Moves[0];
                void *voidReturn;
                return voidReturn;
            }
        }

    } 
    // if only player 1 has a forced switch
    else if ((*(args->my_state)).secondaryP1 != 0){
        double accumulativeP1[] = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0};
        int countP1[] = {0, 0, 0, 0, 0, 0};

        for (int i = 0; i < 25; i++){
            // if the state occurs
            if ( (*(args->my_state + i) ).name[0] != '\0' ) {


                double thisEstimate = feedforward(args->my_weights, &((*(args->my_state + i)).game_data));
                accumulativeP1[(*(args->my_state + i) ).secondaryP1 - 5] += thisEstimate;
                countP1[(*(args->my_state + i) ).secondaryP1 - 5]+=1;
            } else {
                break;
            }
        }

        struct PartialMove P1Moves[6];
        for (int i = 0; i < 6; i++){
            P1Moves[i].move = i;
            if (countP1[i] > 0){
                P1Moves[i].estimate = accumulativeP1[i] / countP1[i];
            } else {
                // printLua_double(L, "set to zero: ", i);
                P1Moves[i].estimate = 0.0;
            }
        }

        mergeSort_PartialMove(P1Moves, 0, 5);
        // printLua_string(L, "", "");
        // printLua_string(L, "5 Moves inside of evaluate switch", "");
        // printArr_PartialMove(L, P1Moves, 6);

        for (int i = 0; i < 25; i++){
            if ((*(args->my_state + i)).secondaryP1 == P1Moves[5].move+5){
                P1Moves[5].move += 4;
                if (args->depth != 1) {
                    struct PartialMove output;

                    struct EvaluateArgs newArgs;
                    newArgs.L = args->L;
                    newArgs.my_state = args->my_state + i;
                    newArgs.my_weights = args->my_weights;
                    newArgs.depth = args->depth-1;
                    newArgs.outputPtr = &output;

                    evaluate_move(&newArgs);
                    P1Moves->estimate = output.estimate;
                }
                *(args->outputPtr) = P1Moves[5];
                
                void *voidReturn;
                return voidReturn;
            }
        }
    }
    // if only player 2 chooses, they choose the worst option for player 1
    else if ((*(args->my_state)).secondaryP2 != 0){
        double accumulativeP2[] = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0};
        int countP2[] = {0, 0, 0, 0, 0, 0};

        for (int i = 0; i < 25; i++){
            if ( (*(args->my_state + i) ).name[0] != '\0' ) {
                // double thisEstimate = evaluate_move( L, (my_state + i), my_weights, depth-1 ).estimate;
                double thisEstimate = feedforward(args->my_weights, &((*(args->my_state + i)).game_data));
                accumulativeP2[(*(args->my_state + i) ).secondaryP2 - 5] += thisEstimate;
                countP2[(*(args->my_state + i) ).secondaryP2 - 5]+=1;
            } else {
                break;
            }
        }

        struct PartialMove P2Moves[6];
        for (int i = 0; i < 6; i++){
            P2Moves[i].move = i;
            if (countP2[i] > 0){
                P2Moves[i].estimate = accumulativeP2[i] / countP2[i];
            } else {
                P2Moves[i].estimate = 1.0;
            }
        }

        mergeSort_PartialMove(P2Moves, 0, 5);
        printLua_string(args->L, "", "");
        printLua_string(args->L, "printArr_PartialMove: ", "");
        printArr_PartialMove(args->L, P2Moves, 6);

        for (int i = 0; i < 25; i++){
            if ((*(args->my_state + i)).secondaryP2 == P2Moves[0].move+5){
                P2Moves[0].move += 4;
                if (args->depth != 1) {
                    struct PartialMove output;

                    struct EvaluateArgs newArgs;
                    newArgs.L = args->L;
                    newArgs.my_state = args->my_state + i;
                    newArgs.my_weights = args->my_weights;
                    newArgs.depth = args->depth-1;
                    newArgs.outputPtr = &output;

                    evaluate_move(&newArgs );
                    P2Moves->estimate = output.estimate;
                }
                *(args->outputPtr) = P2Moves[0];
                void *voidReturn;
                return voidReturn;
            }
        }
    }
    
    printf("returned blank from evaluate_switch\n");
    void *voidReturn;
    return voidReturn;
}

volatile int key = 0;
// pthread_mutex_t lock;

// my_state is intended as a pointer to State object
void *evaluate_move(void *rawArgs ){
        
    // printLua_double(L, "Initial State Value: ", feedforward(my_weights, &(my_state->game_data)));
    struct EvaluateArgs *args = (struct EvaluateArgs*)rawArgs;

    // pthread_mutex_lock(&lock);
    key++;
    int thisKey = key;
    // pthread_mutex_unlock(&lock);
    
    load_showdown_state(args->L, args->my_state, key);

    struct State* my_states = (struct State*) malloc(10*10*25 * sizeof(struct State));

    get_inputs(args->L, my_states, thisKey);


    // the "inputs" here are states resulting from load_showdown_state
    
    // I pass in this reference here so that the "get_inputs" can figure out
    // where each element in the array is located

    struct Move allMoves[10][10];

    for (int i = 0; i < 10; i++){
        for (int j = 0; j < 10; j++){
            double total_estimate = 0.0;

            for (int k = 0; k < 26; k++){

                // if state exists
                if ( (*(my_states + i*10*25 + j*25 + k) ).name[0] != '\0'){

                    // "i" is player2's move
                    // "j" is player1's move

                    double estimate = feedforward(args->my_weights, &((my_states + i*10*25 + j*25 + k)->game_data) );
                    total_estimate+=estimate;
                    // printLua_string(L, "", "");
                    // printLua_double(L, "Player 1 Move: ", j);
                    // printLua_double(L, "Player 2 Move: ", i);
                    // printLua_double(L, "Outcome #: ", k);
                    // printLua_double(L, "Estimate: ", estimate);

                } else {
                    if (k > 0){
                        struct Move thisMove;
                        thisMove.estimate = total_estimate / k;
                        thisMove.isMultiEvent = (k>1) ? 1 : 0;
                        thisMove.moves[0] = j;
                        thisMove.moves[1] = i;
                        allMoves[j][i] = thisMove;
                    } else {
                        allMoves[j][i].moves[0] = -1;
                    }
                    break;

                }
            }
        }
    }


    struct PartialMove p2moves[10];
    for (int i = 0; i < 10; i++){
        double acculative_estimate = 0.0;
        int possibilities = 0;
        
        for (int j = 0; j < 10; j++){

            // "i" represents player2move
            // "j" represents player1move
            
            // if this move combination occured
            if (allMoves[j][i].moves[0] != -1){
                possibilities+=1;
                acculative_estimate+=allMoves[j][i].estimate;
            }

        }

        if (possibilities > 0){
            p2moves[i].estimate = acculative_estimate/(double)possibilities;
        } else {
            p2moves[i].estimate = 1;
        }
            
        p2moves[i].move = i;
    }

    mergeSort_PartialMove(p2moves, 0, 9);

    if (args->depth == START_DEPTH) {
        printLua_string(args->L, "", "");
        // printLua_double(L, "DEPTH: ", depth);
        printLua_string(args->L, "Sorted P2 Moves: ", "");
        printArr_PartialMove(args->L, p2moves, 10);
    }

    struct Move moves_filteredP2[10][TRIM_P2];

    int k = 0;
    for (int j = 0; j < 10; j++){
        if (matchesP2(j, &p2moves[0]) == 1){
            for (int i = 0; i < 10; i++){
                // j is player2 move
                // i is player1 move
                
                // allMoves is indexes by [player1move][player2move]
                moves_filteredP2[i][k].estimate = allMoves[i][j].estimate;
                moves_filteredP2[i][k].isMultiEvent = allMoves[i][j].isMultiEvent;
                moves_filteredP2[i][k].moves[0] = allMoves[i][j].moves[0];
                moves_filteredP2[i][k].moves[1] = allMoves[i][j].moves[1];

            }
            k++;
        }
    }

    if (args->depth == START_DEPTH) {
        printLua_string(args->L, "", "");
        printLua_string(args->L, "All moves after trim by P2: ", "");
        for (int i = 0; i < 10; i++){
            for (int j = 0; j < TRIM_P2; j++){
                // printf("i: %i, j: %i, move1: %i, move2: %i, estimate: %f, isMulti: %i\n", i, j, moves_filteredP2[i][j].moves[0], moves_filteredP2[i][j].moves[1], moves_filteredP2[i][j].estimate, moves_filteredP2[i][j].isMultiEvent);
                // printLua_double(L, "i: ", i);
                // printLua_double(L, "j: ", j);
                printLua_double(args->L, "move1: ", moves_filteredP2[i][j].moves[0]);
                printLua_double(args->L, "move2: ", moves_filteredP2[i][j].moves[1]);
                printLua_double(args->L, "estimate: ", moves_filteredP2[i][j].estimate);

                // printf("i: %i, j: %i, move1: %i, move2: %i, estimate: %f, isMulti: %i\n", i, j, moves_filteredP2[i][j].moves[0], moves_filteredP2[i][j].moves[1], moves_filteredP2[i][j].estimate, moves_filteredP2[i][j].isMultiEvent);
            }
        }
    }

    struct PartialMove p1moves[10];
    for (int j = 0; j < 10; j++){
        double acculative_estimate = 0.0;
        int possibilities = 0;
        
        for (int i = 0; i < TRIM_P2; i++){

            // "i" represents player2move
            // "j" represents player1move
            
            // if this move combination occured
            if (moves_filteredP2[j][i].moves[0] != -1){
                possibilities+=1;
                acculative_estimate+=moves_filteredP2[j][i].estimate;
            }

        }

        if (possibilities > 0){
            p1moves[j].estimate = acculative_estimate/(double)possibilities;
        } else {
            p1moves[j].estimate = 0;
        }

        p1moves[j].move = j;
    }
    mergeSort_PartialMove(p1moves, 0, 9);

    if (args->depth == START_DEPTH){
        printLua_string(args->L, "", "");
        // printLua_double(L, "DEPTH: ", depth);
        printLua_string(args->L, "Sorted P1 Moves: ", "");
        printArr_PartialMove(args->L, p1moves, 10);
    }

    if (args->depth == 1){
        strcpy(p1moves[9].name, (*(my_states + 0*10*25 + p1moves[9].move*25 + 0) ).name);
        *(args->outputPtr) = p1moves[9];
        void *voidReturn;
        return voidReturn;
    } else {
        
        struct Move moves_filteredP1[TRIM_P1][TRIM_P2];

        int k = 0;
        for (int i = 0; i < 10; i++){
            if (matchesP1(i, &p1moves) == 1){
                for (int j = 0; j < TRIM_P2; j++){
                    // i is the player1 index on moves_filteredP2
                    // j is the player2 index on moves_filteredP2 and moves_filteredP2

                    // k is the player1 index on moves_filteredP1
                    
                    // moves_filteredP2 is indexes by [player1move][player2move]
                    moves_filteredP1[k][j].estimate = moves_filteredP2[i][j].estimate;
                    moves_filteredP1[k][j].isMultiEvent = moves_filteredP2[i][j].isMultiEvent;
                    moves_filteredP1[k][j].moves[0] = moves_filteredP2[i][j].moves[0];
                    moves_filteredP1[k][j].moves[1] = moves_filteredP2[i][j].moves[1];

                }
                k++;
            }
        }

        struct PartialMove bestMove;
        bestMove.estimate = 0.0;

        struct PartialMove newEstimates[TRIM_P1][TRIM_P2];

        // pthread_t threads[TRIM_P1][TRIM_P2];

        int error;

        for (int i = 0; i < TRIM_P1; i++){
            // double moveAverageP1 = 0.0;
            for (int j = 0; j < TRIM_P2; j++){
                // i is player 1 move
                // j is player 2 move


                if (moves_filteredP1[i][j].isMultiEvent == 0){
                    printLua_string(args->L, "", "" );
                    printLua_double(args->L, "Start Evaluate Move On p1: ", moves_filteredP1[i][j].moves[0]);
                    printLua_double(args->L, "Start Evaluate Move On p2: ", moves_filteredP1[i][j].moves[1]);

                    struct EvaluateArgs newArgs;
                    newArgs.L = args->L;
                    newArgs.my_state = (my_states + moves_filteredP1[i][j].moves[1]*25*10 + moves_filteredP1[i][j].moves[0]*25 );
                    newArgs.my_weights = args->my_weights;
                    newArgs.depth = args->depth - 1;
                    newArgs.outputPtr = &(newEstimates[i][j]);
                    
                    evaluate_move(&newArgs);

                    // error = pthread_create(&threads[i][j], NULL, evaluate_move, (void *)&newArgs);
                    // if (error != 0)
                    //     printLua_string(args->L, "Thread can't be created : ", strerror(error));

                } else {
                    struct State* statePointer = (my_states + moves_filteredP1[i][j].moves[1]*25*10 + moves_filteredP1[i][j].moves[0]*25 );
                    printLua_string(args->L, "", "" );
                    printLua_double(args->L, "Start Evaluate Switch On p1: ", moves_filteredP1[i][j].moves[0]);
                    printLua_double(args->L, "Start Evaluate Switch On p2: ", moves_filteredP1[i][j].moves[1]);
                    
                    struct EvaluateArgs newArgs;
                    newArgs.L = args->L;
                    newArgs.my_state = statePointer;
                    newArgs.my_weights = args->my_weights;
                    newArgs.depth = args->depth;
                    newArgs.outputPtr = &(newEstimates[i][j]);
                    
                    evaluate_switch(&newArgs);

                    // error = pthread_create(&threads[i][j], NULL, evaluate_switch, (void *)&newArgs);
                    // if (error != 0)
                    //     printLua_string(args->L, "Thread can't be created : ", strerror(error));


                }

            }

        }
        for (int i = 0; i < TRIM_P1; i++){
            double moveAverageP1 = 0.0;
            for (int j = 0; j < TRIM_P2; j++){
                printLua_string(args->L, "", "");
                printLua_double(args->L, "Changing move p1: ", moves_filteredP1[i][j].moves[0]);
                printLua_double(args->L, "Changing move p2: ", moves_filteredP1[i][j].moves[1]);
                printLua_double(args->L, "From: ", moves_filteredP1[i][j].estimate);
                // pthread_join(threads[i][j], NULL);
                printLua_double(args->L, "To: ", newEstimates[i][j].estimate);
                moveAverageP1 += newEstimates[i][j].estimate;
            }
            printLua_string(args->L, "", "");
            printLua_double(args->L, "Move: ", moves_filteredP1[i][0].moves[0]);
            printLua_double(args->L, "Estimate: ", moveAverageP1/(double)TRIM_P2);
            if (moveAverageP1/(double)TRIM_P2 > bestMove.estimate){
                bestMove.estimate = moveAverageP1/(double)TRIM_P2;
                bestMove.move = moves_filteredP1[i][0].moves[0];
                strcpy(bestMove.name, (*(my_states + 0*10*25 + moves_filteredP1[i][0].moves[0]*25 + 0) ).name);
            }
        }
        free(my_states);
        // printf("\nreturned bestMove\n");
        *(args->outputPtr) = bestMove;
        void *voidReturn;
        return voidReturn;
    }


    printf("\nreturn blank\n");
    void *voidReturn;
    return voidReturn;
}

// *my_state is a point to a single incomplete state, and
// by incomplete I mean it's taken at a point where the active
// pokemon is fainted
void *evaluate_switch_from_partial_start(void *rawArgs){
    struct EvaluateArgs *args = (struct EvaluateArgs*)rawArgs;
    int activePokemon[30] = {0};    
    struct State possibleStates[25];

    for (int i = 65; i < 95; i++){
        activePokemon[i-65] = (*(args->my_state)).game_data[i];
    }

    for (int i = 0; i < 25; i++){
        struct State blank_state;
        blank_state.name[0] = '\0';
        possibleStates[i] = blank_state;
    }

    int index = 0;
    for (int i = 0; i < 6; i++){

        printLua_double(args->L, "i: ", i);
        printLua_double(args->L, "HP Active Slot: ", (*(args->my_state)).game_data[65+30*i]);
        if ((*(args->my_state)).game_data[65+30*i] == 0) continue;

        // secondaryP2 is in range [5, 10]
        possibleStates[index].secondaryP1 = i+5;

        possibleStates[index].activePokemonP2 = (*(args->my_state)).activePokemonP2;
        possibleStates[index].name[0] = 'N';
        possibleStates[index].name[1] = '/';
        possibleStates[index].name[2] = 'A';
        
        // I might need to add some way to track activePokemon1, IDK yet
        if (i == (*(args->my_state)).activePokemonP1){
            possibleStates[index].activePokemonP1 = 0;
        } else {
            possibleStates[index].activePokemonP1 = i;
        }
        strcpy(possibleStates[index].disableMoveP1, (*(args->my_state)).disableMoveP1);
        strcpy(possibleStates[index].disableMoveP2, (*(args->my_state)).disableMoveP2);
        strcpy(possibleStates[index].encoreMoveP1, (*(args->my_state)).encoreMoveP1);
        strcpy(possibleStates[index].encoreMoveP2, (*(args->my_state)).encoreMoveP2);
        
        // copy non-pokemon data from state
        for (int j = 0; j < 65; j++){
            possibleStates[index].game_data[j] = (*(args->my_state)).game_data[j];
        }

        // copy data from the pokemon you're switching to
        // into the active

        // for example, let's say you switch to slot 2,
        // that would be in data range [95, 125),
        // so you'd copy that data range in data range [65, 95)
        for (int j = 65+30*i; j < 95+30*i; j++){
            // copy active data into the slot you're switching to
            possibleStates[index].game_data[j-30*i] = (*(args->my_state)).game_data[j];

            // now copy stored active pokemon data into range of slot your switched out of
            possibleStates[index].game_data[j] = activePokemon[j-65-30*i];
            // secondaryP1 is in range [5, 10]
        }

        // copy remaining pokemon data
        for (int j = 95; j < 65+30*i; j++){
            // printLua_double(L, "i: ", i);
            // printLua_double(L, "j: ", j);
            // printLua_double(L, "data: ", (*my_state).game_data[j]);
            possibleStates[index].game_data[j] = (*(args->my_state)).game_data[j];
        }
        for (int j = 95+30*i; j < 425; j++){
            // printLua_double(L, "i: ", i);
            // printLua_double(L, "j: ", j);
            // printLua_double(L, "data: ", (*my_state).game_data[j]);
            possibleStates[index].game_data[j] = (*(args->my_state)).game_data[j];
        }
        index++;
    }

    struct EvaluateArgs newArgs;
    newArgs.L = args->L;
    newArgs.my_state = &possibleStates[0];
    newArgs.my_weights = args->my_weights;
    newArgs.depth = args->depth;
    newArgs.outputPtr = args->outputPtr;

    evaluate_switch(&newArgs);
}

int run_evaluation(lua_State *L){
    // all this stack manipulation is just to cleanup
    // the stack and get relevant data into "start_state"


    // stack: [ exec_showdown_state, state ]

    struct State start_state;

    lua_rawgeti(L, -1, 2);
    // stack: [ exec_showdown_state, state, switch_info ]

    strcpy(start_state.name, lua_tostring(L, -1));
    
    lua_remove(L, -1);
    // stack: [ exec_showdown_state, state ]

    lua_rawgeti(L, -1, 3);
    // stack: [ exec_showdown_state, state, activeInfoP1 ]

    start_state.activePokemonP1 = lua_tointeger(L, -1);
    
    lua_remove(L, -1);
    // stack: [ exec_showdown_state, state ]

    lua_rawgeti(L, -1, 4);
    // stack: [ exec_showdown_state, state, activeInfoP2 ]

    start_state.activePokemonP2 = lua_tointeger(L, -1);
    
    lua_remove(L, -1);
    // stack: [ exec_showdown_state, state ]

    lua_rawgeti(L, -1, 5);
    // stack: [ exec_showdown_state, state, encoreP1 ]

    strcpy(start_state.encoreMoveP1, lua_tostring(L, -1));
    
    lua_remove(L, -1);
    // stack: [ exec_showdown_state, state ]

    lua_rawgeti(L, -1, 6);
    // stack: [ exec_showdown_state, state, encoreP2 ]

    strcpy(start_state.encoreMoveP2, lua_tostring(L, -1));
    
    lua_remove(L, -1);
    // stack: [ exec_showdown_state, state ]

    lua_rawgeti(L, -1, 7);
    // stack: [ exec_showdown_state, state, disableP1 ]

    strcpy(start_state.disableMoveP1, lua_tostring(L, -1));
    
    lua_remove(L, -1);
    // stack: [ exec_showdown_state, state ]

    lua_rawgeti(L, -1, 8);
    // stack: [ exec_showdown_state, state, disableP2 ]

    strcpy(start_state.disableMoveP2, lua_tostring(L, -1));
 
    lua_remove(L, -1);
    // stack: [ exec_showdown_state, state ]

    lua_rawgeti(L, -1, 1);
    // stack: [ exec_showdown_state, state, inputs ]

    for (int i = 0; i < L1; i++){
        lua_rawgeti(L, -1, i+1);
        // stack: [ exec_showdown_state, state, inputs, thisInput ]
        
        start_state.game_data[i] = lua_tointeger(L, -1);
        // printLua(L, "i: ", i);
        // printLua(L, "Game State: ", start_state.game_data[i]);

        lua_remove(L, -1);
        // stack: [ exec_showdown_state, state, inputs ]
    }

    lua_remove(L, -1);
    // stack: [ exec_showdown_state, state ]

    lua_remove(L, -1);
    // stack: [ exec_showdown_state ]

    struct Weights my_weights;
    get_weights(L, &my_weights);
    // print_weights(&my_weights, L);
    // print_inputs(start_state, L);

    // struct State* my_states = (struct State*) malloc(10*10*25 * sizeof(struct State));
    // get_inputs(my_states);
    // print_inputs(*my_states);
    // free(my_states);

    struct PartialMove bestMove;

    struct EvaluateArgs args;
    args.L = L;
    args.my_state = &start_state;
    args.my_weights = &my_weights;
    args.depth = START_DEPTH;
    args.outputPtr = &bestMove;

    key = 0;
    
    // if (pthread_mutex_init(&lock, NULL) != 0) {
    //     printLua_string(L, "mutex init has failed", "");
    //     return -1;
    // }
    evaluate_move(&args);
    // printLua_double(L, "Best Move: ", (double)bestMove.move);
    lua_settop(L, 0);
    // lua_createtable(L);
    lua_newtable(L);
    lua_pushinteger(L, bestMove.move);
    lua_setfield(L, -2, "move");
    lua_pushstring(L, bestMove.name);
    lua_setfield(L, -2, "name");

    return bestMove.move;
}

int run_evaluation_switch(lua_State *L){
    // all this stack manipulation is just to cleanup
    // the stack and get relevant data into "start_state"


    // stack: [ exec_showdown_state, state ]

    struct State start_state;

    lua_rawgeti(L, -1, 2);
    // stack: [ exec_showdown_state, state, switch_info ]

    strcpy(start_state.name, lua_tostring(L, -1));
    
    lua_remove(L, -1);
    // stack: [ exec_showdown_state, state ]

    lua_rawgeti(L, -1, 3);
    // stack: [ exec_showdown_state, state, activeInfoP1 ]

    start_state.activePokemonP1 = lua_tointeger(L, -1);
    
    lua_remove(L, -1);
    // stack: [ exec_showdown_state, state ]

    lua_rawgeti(L, -1, 4);
    // stack: [ exec_showdown_state, state, activeInfoP2 ]

    start_state.activePokemonP2 = lua_tointeger(L, -1);
    
    lua_remove(L, -1);
    // stack: [ exec_showdown_state, state ]

    lua_rawgeti(L, -1, 5);
    // stack: [ exec_showdown_state, state, encoreP1 ]

    strcpy(start_state.encoreMoveP1, lua_tostring(L, -1));
    
    lua_remove(L, -1);
    // stack: [ exec_showdown_state, state ]

    lua_rawgeti(L, -1, 6);
    // stack: [ exec_showdown_state, state, encoreP2 ]

    strcpy(start_state.encoreMoveP2, lua_tostring(L, -1));
    
    lua_remove(L, -1);
    // stack: [ exec_showdown_state, state ]

    lua_rawgeti(L, -1, 7);
    // stack: [ exec_showdown_state, state, disableP1 ]

    strcpy(start_state.disableMoveP1, lua_tostring(L, -1));
    
    lua_remove(L, -1);
    // stack: [ exec_showdown_state, state ]

    lua_rawgeti(L, -1, 8);
    // stack: [ exec_showdown_state, state, disableP2 ]

    strcpy(start_state.disableMoveP2, lua_tostring(L, -1));
 
    lua_remove(L, -1);
    // stack: [ exec_showdown_state, state ]

    lua_rawgeti(L, -1, 1);
    // stack: [ exec_showdown_state, state, inputs ]

    for (int i = 0; i < L1; i++){
        lua_rawgeti(L, -1, i+1);
        // stack: [ exec_showdown_state, state, inputs, thisInput ]
        
        start_state.game_data[i] = lua_tointeger(L, -1);

        lua_remove(L, -1);
        // stack: [ exec_showdown_state, state, inputs ]
    }

    lua_remove(L, -1);
    // stack: [ exec_showdown_state, state ]

    lua_remove(L, -1);
    // stack: [ exec_showdown_state ]

    struct Weights my_weights;
    get_weights(L, &my_weights);
    
    struct PartialMove bestSwitch;

    struct EvaluateArgs args;
    args.L = L;
    args.my_state = &start_state;
    args.my_weights = &my_weights;
    args.depth = 1;
    args.outputPtr = &bestSwitch;

    evaluate_switch_from_partial_start(&args);
    // printf("Best Switch, estimate: %f, move: %i\n", bestSwitch.estimate, bestSwitch.move);

    printLua_double(L, "Best Switch: ", bestSwitch.move);

    return bestSwitch.move;
}

// takes arguments [exec_showdown_state, state]
int get_move(lua_State *L){
    
    int res = run_evaluation(L);
    // lua_settop(L, 0);
    // lua_pushnumber(L, res);

    return 1;
}

// takes arguments [exec_showdown_state, state]
int get_switch(lua_State *L){
    int res = run_evaluation_switch(L);
    lua_settop(L, 0);
    lua_pushnumber(L, res);

    return 1;
}

void printLua_double(lua_State *L, const char *label, double value){
    lua_getglobal(L, "print");
    lua_pushstring(L, label);
    lua_pushnumber(L, value);
    lua_call(L, 2, 0);
}

void printLua_string(lua_State *L, const char *label, const char *value){
    lua_getglobal(L, "print");
    lua_pushstring(L, label);
    lua_pushstring(L, value);
    lua_call(L, 2, 0);
}

int luaopen_processor(lua_State *L){
    // this code is functional in lua 5.4 but not (as I've learned) lua 5.1
    //   luaL_Reg fns[] = {
    //     {"get_move", get_move},
    //     {"get_switch", get_switch},
    //     {NULL, NULL}
    //   };
    //   luaL_newlib(L, fns);
    lua_newtable(L);
    lua_pushcfunction(L, get_move);
    lua_setfield(L, -2, "get_move");
    lua_pushcfunction(L, get_switch);
    lua_setfield(L, -2, "get_switch");
    return 1;  // Number of Lua-facing return values on the Lua stack in L.
}