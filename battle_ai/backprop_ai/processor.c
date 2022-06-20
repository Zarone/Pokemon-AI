#include "lua.h"
#include "lauxlib.h"
#include "luaconf.h"
#include "mpack/mpack.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "helper/helper.h"
#include <string.h>
#include <pthread.h>
#include <Windows.h>
#include <unistd.h>
#include <time.h>
#include <stdbool.h>

#define LAYERS 7

#define L1 425
#define L2 400
#define L3 150 
#define L4 50
#define L5 20
#define L6 10
#define L7 1

// this effects the sigmoid curve for the
// feedforward algorithm
#define SPREAD 1

#define TRIM_P2 3
#define TRIM_P2_CATCH 1
#define TRIM_P1 4
#define TRIM_P1_CATCH 2

#define START_DEPTH 3
#define START_DEPTH_CATCH 4

#define MULTITHREADED true

struct Weights {
    double** weights[LAYERS-1];
    double* biases[LAYERS-1];
};

int getLayerSize(int layer){
    if (layer > LAYERS) {
        printf("out of layer bounds\n");
        return -1;
    }
    switch (layer){
        case 0:
            return L1;
            break;
        case 1:
            return L2;
            break;
        case 2:
            return L3;
            break;
        case 3:
            return L4;
            break;
        case 4:
            return L5;
            break;
        case 5:
            return L6;
            break;
        case 6:
            return L7;
            break;
        default:
            printf("triggered default in getLayerSize()\n");
            return -1;
            break;
    }
}

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

// this is the data we update everytime we run the neural network
struct BackpropData {
    double condition; // tallies how much the AI wants to go to the pokemon center
    double typeDesire[17]; // tallies how much the AI wants to catch pokemon of a certain type
};

pthread_mutex_t lock;
struct BackpropData lastBackpropBatch;

// this function prints directly to lua
// this is helpful because the emulator
// doesn't log output which came directly 
// from C. And I only declare it later for
// organizational purposes
void printLua_double(lua_State *L, const char *label, double value);
void printLua_string(lua_State *L, const char *label, const char *value);


// "struct Input" array merge sort functions

// adapted from GeeksForGeeks code, because
// I don't really feel like writing this
// extremely common sorting algorithm only to find a 
// bug and have to refactor it later
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

// "struct PartialMove" array merge sort functions
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

void print_weights(struct Weights *my_weights){
    
    for (int i = 0; i < LAYERS-1; i++){// i is the layer
        for (int j = 0; j < getLayerSize(i); j+=100){// j is the from node
            for (int k = 0; k < getLayerSize(i+1); k+=40){// k is the to node
                printf("weights[%i][%i][%i] = %f\n ", i, j, k, 
                    ((double*)(my_weights->weights[i]))[j*getLayerSize(i+1) + k]
                );
            }
        }
    }

    for (int i = 0; i < LAYERS-1; i++){
        for (int j = 0; j < getLayerSize(i+1); j+=20){
            printf("biases[%i][%i] = %f\n", i, j, 
                ((double*)(my_weights->weights[i]))[j] 
            );
        }
    }
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

    if (layer == 3){
        double val = mpack_tag_double_value(&tag);

        if (indexes[0] > 1){
            int thisLayer = LAYERS - indexes[0];
            int fromNode = getLayerSize(thisLayer)-indexes[1];
            int toNode = getLayerSize(thisLayer+1)-indexes[2];
            // printf("%i %i %i\n", thisLayer, fromNode, toNode);
            ((double*)(weight_pointer->weights[thisLayer]))[fromNode*getLayerSize(thisLayer+1) + toNode] = val;
        } else if (indexes[0] == 1){
            int thisLayer = LAYERS - indexes[1] - 1;
            int node = getLayerSize(thisLayer+1)-indexes[2];
            // printf("indexes: %i %i %i\n", indexes[0], indexes[1], indexes[2]);
            // printf("%i %i\n", thisLayer, node);
            ((double*)(weight_pointer->biases[thisLayer]))[node] = val;
        } else {
            printLua_double(L, "wasn't 1 or 2 or 3 or 4, indexes[0] = ", indexes[0]);
        }
    }

}

int get_weights(lua_State *L, struct Weights *my_weights){
    mpack_reader_t reader;
    mpack_reader_init_filename(&reader, "./battle_ai/backprop_ai/weights.txt");

    int blank_indexes[] = {0,0,0};

    for (int i = 0; i < LAYERS-1; i++){
        int fromLayerCount = getLayerSize(i);
        int toLayerCount = getLayerSize(i+1);
        my_weights->weights[i] = (double**)malloc(fromLayerCount * toLayerCount * sizeof(double));
        my_weights->biases[i] = (double*)malloc(toLayerCount * sizeof(double));
    }
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
        printf("Error activeP2 type, it's actually of type %s\n", mpack_type_to_string(mpack_tag_type(&activeP2)));
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
        printf("I've misunderstood encoreP1, it's actually of type %s\n", mpack_type_to_string(mpack_tag_type(&encoreP1)));
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
        printf("I've misunderstood encoreP2, it's actually of type %s\n", mpack_type_to_string(mpack_tag_type(&encoreP2)));
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
        printf("I've misunderstood disableP1, it's actually of type %s\n", mpack_type_to_string(mpack_tag_type(&disableP1)));
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
        printf("I've misunderstood disableP2, it's actually of type %s\n", mpack_type_to_string(mpack_tag_type(&disableP2)));
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
        printf("I've misunderstood secondaryP2, it's actually of type %s\n", mpack_type_to_string(mpack_tag_type(&secondaryP2)));
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
    pthread_mutex_lock(&lock);
    // printf("get input with key %i\n", currentKey);
    pthread_mutex_unlock(&lock);
    mpack_reader_t reader;
    char stringKey[3];
    sprintf(stringKey, "%d", currentKey);

    char filename[60] = "./battle_ai/state_files/battleStatesFromShowdown/";
    strcat(filename, stringKey);

    // pthread_mutex_lock(&lock);
    // printf("checking file path %s\n", filename);
    // printLua_string(L, "checking file path: ", filename);
    // pthread_mutex_unlock(&lock);

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


double logistic(double a){
    return 1 / (1 + exp(-SPREAD*(double)a));
}

double logistic_derivative(double a){
    return logistic(a)*(1-logistic(a));
}

bool checkWin(int (*inputs)[L1]){
    for (int i = 245; i < 425; i+=30){
        if ((double)(*inputs)[i] > 1){
            return false;
        }
    }
    return true;
}

bool checkLoss(int (*inputs)[L1]){
    for (int i = 65; i < 245; i+=30){
        if ((double)(*inputs)[i] > 1){
            return false;
        }
    }
    return true;
}

double feedforward(struct Weights *my_weights, int (*inputs)[L1], bool tallyBackprop){


    // the reason this checks for tally backprop is that if
    // we do want to backpropogate than we don't want to
    // return early

    bool didWin = checkWin(inputs);
    bool didLose = checkLoss(inputs);

    if (didWin && !tallyBackprop) return 1.0f;
    if (didLose && !tallyBackprop) return 0.0f;

    double* activationLayers[LAYERS-1]; // skip over input layer
    double* zLayers[LAYERS-1]; // skip over input layer
    activationLayers[0] = (double*)malloc(L2*sizeof(double));
    zLayers[0] = (double*)malloc(L2*sizeof(double));

    for (int i = 0; i < L2; i++){ // i is the toNode
        zLayers[0][i] = 0;
        for (int j = 0; j < L1; j++){ // j is the fromNode
            zLayers[0][i] += (*inputs)[j] * ((double*)(my_weights->weights[0]))[j*L2 + i];
        }
        zLayers[0][i] += my_weights->biases[0][i];
        activationLayers[0][i] = relu(zLayers[0][i]);
    }

    for (int i = 1; i < LAYERS-1; i++){
        
        int thisLayerCount = getLayerSize(i+1);
        int lastLayerCount = getLayerSize(i);

        // allocate mem for layer "i"
        activationLayers[i] = (double*)malloc(thisLayerCount*sizeof(double));
        zLayers[i] = (double*)malloc(thisLayerCount*sizeof(double));
        
        // prop from layer "i" to layer "i+1"
        for (int j = 0; j < thisLayerCount; j++){ // j is the toNode
            zLayers[i][j] = 0;
            for (int k = 0; k < lastLayerCount; k++){ // k is the fromNode
                zLayers[i][j] += activationLayers[i-1][k] * ((double*)(my_weights->weights[i]))[k*thisLayerCount + j];
            }
            
            zLayers[i][j] += ((double*)(my_weights->biases[i]))[j];
            activationLayers[i][j] = (i == LAYERS - 2) ? logistic( zLayers[i][j] ) : relu( zLayers[i][j] );
        }
    }


    if (tallyBackprop == 1){
        // backpropagate to find ideal changes to inputs

        // I'm also defining error as ( del V / del a ) where V 
        // is the very last activation and a is any given activation value

        double* errorLayers[LAYERS-1]; // excluding the output layer

        for (int i = 1; i < LAYERS; i++){
            
            int thisLayerCount = getLayerSize(LAYERS-1-i); 
            
            errorLayers[i-1] = (double*)malloc(thisLayerCount * sizeof(double));
            
            for (int j = 0; j < thisLayerCount; j++){
                errorLayers[i-1][j] = 0;
                int nextLayerCount = getLayerSize(LAYERS-i);
                for (int k = 0; k < nextLayerCount; k++){

                    double derivative1 = ((double*)(my_weights->weights[LAYERS-1-i]))[j*nextLayerCount + k];
                    double derivative2 = (i == 1) ? logistic_derivative( zLayers[LAYERS-1-i][k] ) : relu_derivative( zLayers[LAYERS-1-i][k] );
                    double derivative3 = (i == 1) ? 1 : errorLayers[i - 2][k];

                    errorLayers[i-1][j] += derivative1 * derivative2 * derivative3;
                }
            }
        }

        int playerPokemon = 0;
        double tempCondition = 0;

        for (int i = 65; i < 245; i+=30){
            // if there's a pokemon in this slot
            // printf("i = %i, max health: %i, health percent: %i\n", i, (*inputs)[i+1], (*inputs)[i]);
            if ((*inputs)[i+1] > 0){
                // printf("difference in hp %f\n", (*inputs)[i]-100.0f);
                playerPokemon += 1;
                tempCondition -= errorLayers[LAYERS-2][i]*((*inputs)[i]-100.0f);

                if (errorLayers[LAYERS-2][i+24] < 0) tempCondition -= errorLayers[LAYERS-2][i+24]*((*inputs)[i+24]);
                if (errorLayers[LAYERS-2][i+25] < 0) tempCondition -= errorLayers[LAYERS-2][i+25]*((*inputs)[i+25]);
                if (errorLayers[LAYERS-2][i+26] < 0) tempCondition -= errorLayers[LAYERS-2][i+26]*((*inputs)[i+26]);
                if (errorLayers[LAYERS-2][i+27] < 0) tempCondition -= errorLayers[LAYERS-2][i+27]*((*inputs)[i+27]);
                if (errorLayers[LAYERS-2][i+28] < 0) tempCondition -= errorLayers[LAYERS-2][i+28]*((*inputs)[i+28]);
                if (errorLayers[LAYERS-2][i+29] < 0) tempCondition -= errorLayers[LAYERS-2][i+29]*((*inputs)[i+29]);

            } else {
                for (int j = 7; j < 24; j++){
                    if (errorLayers[LAYERS-2][i+j]) lastBackpropBatch.typeDesire[j-7] -= errorLayers[LAYERS-2][i+j];
                }
            }
        }

        lastBackpropBatch.condition += tempCondition;
        // printf("tempCondition %f\n", tempCondition);

        for (int i = 0; i < LAYERS-1; i++){
            free(errorLayers[i]);
        }

    }

    for (int i = 0; i < LAYERS-2; i++){
        free(activationLayers[i]);
    }
    for (int i = 0; i < LAYERS-1; i++){
        free(zLayers[i]);
    }

    /*

        // this code, if implemented, would make the player tend towards attacking
        // when the enemy only has one pokemon remaining.

        // number of enemy pokemon not fainted
        int enemyNum = 6;
        
        for (int i = 245; i < 425; i+=30){
            if ((double)(*inputs)[i] < 1){
                enemyNum--;
            }
        }

        if (enemyNum == 1) {
            return activationLayers[LAYERS-2][0] + 0.3*(1 - ( (double)(*inputs)[245] / 100.0f));
        }
    */

   if (didWin) return 1.0f;
   if (didLose) return 0.0f;

    return activationLayers[LAYERS-2][0];

    
}

void frameSkip(lua_State *L){
    lua_call(L, 0, 0);
    lua_getglobal(L, "frame");
}

void load_showdown_state(struct State *state, int localKey, bool firstCall){

    // pthread_mutex_lock(&lock);
    // printf("save with key %i and state at %p\n", localKey, (void*)state);
    // pthread_mutex_unlock(&lock);

    // encode to memory buffer
    char* data;
    mpack_writer_t writer;
    size_t size;
    mpack_writer_init_growable(&writer, &data, &size);
    
    // this newGameData is needed because showdown expects the
    // pokemon in the same order as initialized
    int newGameData[L1];
    for (int i = 0; i < L1; i++){
        newGameData[i] = state->game_data[i];
    }

    if (!firstCall){
        if (state->activePokemonP1 != 0){
            for (int i = 65; i < 95; i++){
                // printf("set %i to %i of val %i\n", i, i+30*state->activePokemonP1, state->game_data[i+30*state->activePokemonP1]);
                newGameData[i] = state->game_data[i+30*state->activePokemonP1];
                newGameData[i+30*state->activePokemonP1] = state->game_data[i];
            }
        }

        if (state->activePokemonP2 != 0){
            for (int i = 245; i < 275; i++){
                newGameData[i] = state->game_data[i+30*state->activePokemonP2];
                newGameData[i+30*state->activePokemonP2] = state->game_data[i];
            }
        }
    }
    

    mpack_start_array(&writer, 10);

    mpack_start_array(&writer, L1);

    for (int i = 0; i < L1; i++){
        mpack_write_int(&writer, newGameData[i]);
        // printf("%i %i\n", i, newGameData[i]);
    }
    mpack_finish_array(&writer);

    mpack_write_str(&writer, "", strlen(""));
    // printf("%s\n", "");
    mpack_write_int(&writer, state->activePokemonP1);
    // printf("%i\n", state->activePokemonP1);
    mpack_write_int(&writer, state->activePokemonP2);
    // printf("%i\n", state->activePokemonP2);
    mpack_write_str(&writer, state->encoreMoveP1, strlen(state->encoreMoveP1));
    // printf("%s\n", state->encoreMoveP1);
    mpack_write_str(&writer, state->encoreMoveP2, strlen(state->encoreMoveP2));
    // printf("%s\n", state->encoreMoveP2);
    mpack_write_str(&writer, state->disableMoveP1, strlen(state->disableMoveP1));
    // printf("%s\n", state->disableMoveP1);
    mpack_write_str(&writer, state->disableMoveP2, strlen(state->disableMoveP2));
    // printf("%s\n", state->disableMoveP2);
    mpack_write_int(&writer, state->secondaryP1);
    // printf("%i\n", state->secondaryP1);
    mpack_write_int(&writer, state->secondaryP2);
    // printf("%i\n", state->secondaryP2);

    mpack_finish_array(&writer);
    
    // finish writing
    if (mpack_writer_destroy(&writer) != mpack_ok) {
        fprintf(stderr, "An error occurred encoding the data!\n");
        return;
    }

    char stringKey[4];
    sprintf(stringKey, "%d", localKey);
    
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

    // easiest to debug, but pulls up new window
    system(process);

    // doesn't render cmd window
    // STARTUPINFO si;
    // PROCESS_INFORMATION pi;

    // ZeroMemory(&si, sizeof(si));
    // si.cb = sizeof(si);
    // ZeroMemory(&pi, sizeof(pi));

    // if (CreateProcess(NULL, (LPSTR)process, NULL, NULL, FALSE, CREATE_NO_WINDOW, NULL, NULL, &si, &pi))
    // {
    //     WaitForSingleObject(pi.hProcess, INFINITE);
    //     CloseHandle(pi.hProcess);
    //     CloseHandle(pi.hThread);
    // } else {
    //     printf( "CreateProcess failed (%ld)\n", GetLastError() );
    // }

}

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
int matchesP1Catch(int move, struct PartialMove (*sortedMoveList)[11]){
    for (int i = 0; i < TRIM_P1_CATCH; i++){
        int index = 10-i;
        if ((*sortedMoveList)[index].move == move) return 1; 
    }
    return 0;
}
int matchesP2Catch(int move, struct PartialMove (*sortedMoveList)){
    // return move == (*sortedMoveList)[0].move || move == (*sortedMoveList)[1].move;
    
    for (int i = 0; i < TRIM_P2_CATCH; i++){
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
void *evaluate_move_catch(void *rawArgs);

// args->my_state is intented as a pointer to to State array of length 25
void *evaluate_switch(void *rawArgs){
    // printf("\nIn evaluate_switch, Depth: %i\n", depth);
    struct EvaluateArgs *args = (struct EvaluateArgs*)rawArgs;

    // if both players switched
    if ( args->my_state->secondaryP1 != 0 && args->my_state->secondaryP2 != 0 ){
        printf("thinks they both faint\n");

        double accumulativeP2[] = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0};
        int countP2[] = {0, 0, 0, 0, 0, 0};
        double allEstimates[25] = {0.0};

        for (int i = 0; i < 25; i++){
            if ( (*(args->my_state + i) ).name[0] != '\0' ) {
                // double thisEstimate = evaluate_move( L, (my_state + i), my_weights, depth-1 ).estimate;
                double thisEstimate = feedforward(args->my_weights, &((*(args->my_state + i)).game_data), false);
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
        pthread_mutex_lock(&lock);
        double accumulativeP1[] = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0};
        int countP1[] = {0, 0, 0, 0, 0, 0};

        for (int i = 0; i < 25; i++){
            // if the state occurs
            if ( (*(args->my_state + i) ).name[0] != '\0' ) {


                double thisEstimate = feedforward(args->my_weights, &((*(args->my_state + i)).game_data), false);
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

        pthread_mutex_unlock(&lock);
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
                    P1Moves[5].estimate = output.estimate;
                }
                // printf("in evaluate_switch, outputPtr %p\n", (void *)args->outputPtr);
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
                double thisEstimate = feedforward(args->my_weights, &((*(args->my_state + i)).game_data), false);
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
        // printLua_string(args->L, "", "");
        // printLua_string(args->L, "printArr_PartialMove: ", "");
        // printArr_PartialMove(args->L, P2Moves, 6);

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
                    printf("in evaluate_switch, calling evaluate_move with outputPtr %p\n", (void *)newArgs.outputPtr);

                    evaluate_move(&newArgs);
                    P2Moves[0].estimate = output.estimate;
                }
                *(args->outputPtr) = P2Moves[0];
                void *voidReturn;
                return voidReturn;
            }
        }
    }
    
    // printf("returned blank from evaluate_switch\n");
    return NULL;
}

volatile int key = 0;

// my_state is intended as a pointer to State object
void *evaluate_move(void *rawArgs){
        
    // printLua_double(L, "Initial State Value: ", feedforward(my_weights, &(my_state->game_data)));
    struct EvaluateArgs *args = (struct EvaluateArgs*)rawArgs;
    // print_weights(args->my_weights);

    if (args->depth != START_DEPTH){ pthread_mutex_lock(&lock); }
    key++;
    int thisKey = key;
    if (args->depth != START_DEPTH){ pthread_mutex_unlock(&lock); }
    
    load_showdown_state(args->my_state, thisKey, args->depth == START_DEPTH);

    struct State* my_states = (struct State*) malloc(10*10*25 * sizeof(struct State));

    get_inputs(args->L, my_states, thisKey);

    // the "inputs" here are states resulting from load_showdown_state
    
    // I pass in this reference here so that the "get_inputs" can figure out
    // where each element in the array is located

    struct Move allMoves[10][10];
    int totalStatesEvaluated = 0;

    for (int i = 0; i < 10; i++){
        for (int j = 0; j < 10; j++){

            double total_estimate = 0.0;

            for (int k = 0; k < 26; k++){

                // if state exists
                if ( (*(my_states + i*10*25 + j*25 + k) ).name[0] != '\0'){

                    // "i" is player2's move
                    // "j" is player1's move

                    double estimate = feedforward(args->my_weights, &((my_states + i*10*25 + j*25 + k)->game_data), args->depth == START_DEPTH);

                    total_estimate+=estimate;
                    totalStatesEvaluated++;
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

    if (args->depth == START_DEPTH){
        for (int l = 0; l < 17; l++){
            lastBackpropBatch.typeDesire[l] /= totalStatesEvaluated;
        }
        // printf("lastBackpropBatch.condition before cut %f\n", lastBackpropBatch.condition);
        lastBackpropBatch.condition /= totalStatesEvaluated;
        // printf("%i states\n", totalStatesEvaluated);
        // printf("lastBackpropBatch.condition after cut %f\n", lastBackpropBatch.condition);
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
            p1moves[j].estimate = -1;
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

    if (args->depth == 1 || p1moves[9].estimate == 1 || p1moves[9].estimate == 0){
        strcpy(p1moves[9].name, (*(my_states + 0*10*25 + p1moves[9].move*25 + 0) ).name);
        pthread_mutex_lock(&lock);
        *(args->outputPtr) = p1moves[9];

        // args->outputPtr->estimate = p1moves[9].estimate;
        // args->outputPtr->move = p1moves[9].move;
        // args->outputPtr->name = p1moves[9].name;
        // strcpy(args->outputPtr->name, p1moves[9].name);
     
        // printLua_double(args->L, "set estimate with key", thisKey);
        // printf("set estimate %f with key %i at address %p\n", p1moves[9].estimate, thisKey, (void *)(args->outputPtr));
        // frameSkip(args->L);
        pthread_mutex_unlock(&lock);
        free(my_states);

        // pthread_exit(0);
        return 0;
    } else {
        struct Move moves_filteredP1[TRIM_P1][TRIM_P2];

        int k = 0;
        for (int i = 0; i < 10; i++){
            if (matchesP1(i, &p1moves) == 1){
                for (int j = 0; j < TRIM_P2; j++){
                    // i is the player1 index on moves_filteredP2
                    // j is the player2 index on moves_filteredP1 and moves_filteredP2

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

        // struct PartialMove newEstimates[TRIM_P1][TRIM_P2];
        struct PartialMove* newEstimates = (struct PartialMove*)malloc(sizeof(struct PartialMove)*TRIM_P1*TRIM_P2);

        pthread_t threads[TRIM_P1][TRIM_P2];
        unsigned int argsSize = sizeof(struct EvaluateArgs);
        struct EvaluateArgs* allNewArgs = (struct EvaluateArgs*)malloc(argsSize * TRIM_P1 * TRIM_P2);

        int error;

        int isMultithreaded = MULTITHREADED && args->depth == START_DEPTH;

        for (int i = 0; i < TRIM_P1; i++){
            // double moveAverageP1 = 0.0;
            for (int j = 0; j < TRIM_P2; j++){
                // i is player 1 move
                // j is player 2 move

                (newEstimates+i*TRIM_P2+j)->estimate = -2;
                // printf("set estimate at %p to -2\n", (void *)(newEstimates+i*TRIM_P2+j));


                struct EvaluateArgs* newArgs = (struct EvaluateArgs*)(allNewArgs + TRIM_P2*i + j);
                if (moves_filteredP1[i][j].estimate == 1){
                    // strcpy( (my_states + moves_filteredP1[i][j].moves[1]*10*25 + moves_filteredP1[i][j].moves[0]*25)->name, (newEstimates+i*TRIM_P2+j)->name );
                    (newEstimates+i*TRIM_P2+j)->estimate = 1;
                } else if (moves_filteredP1[i][j].estimate == 0){
                    // strcpy( (my_states + moves_filteredP1[i][j].moves[1]*10*25 + moves_filteredP1[i][j].moves[0]*25)->name, (newEstimates+i*TRIM_P2+j)->name );
                    (newEstimates+i*TRIM_P2+j)->estimate = 0;
                } else if (moves_filteredP1[i][j].moves[0] == -1){
                    (newEstimates+i*TRIM_P2+j)->estimate = -1;
                    (newEstimates+i*TRIM_P2+j)->move = moves_filteredP1[i][j].moves[0];
                } else if (moves_filteredP1[i][j].isMultiEvent == 0){

                    newArgs->L = args->L;
                    newArgs->my_state = (my_states + moves_filteredP1[i][j].moves[1]*25*10 + moves_filteredP1[i][j].moves[0]*25 );
                    newArgs->my_weights = args->my_weights;
                    newArgs->depth = args->depth - 1;
                    // newArgs->outputPtr = &(newEstimates[i][j]);
                    newArgs->outputPtr = (newEstimates+i*TRIM_P2+j);
                    printf("call evaluate_move at %i %i, addr: %p, state ptr: %p\n", moves_filteredP1[i][j].moves[0], moves_filteredP1[i][j].moves[1], (void *)newArgs->outputPtr, (void *)newArgs->my_state);
                    

                    if (isMultithreaded){
                        error = pthread_create(&threads[i][j], NULL, evaluate_move, newArgs);
                        if (error != 0){
                            printLua_string(args->L, "Thread can't be created : ", strerror(error));
                        }
                    } else {
                        evaluate_move(newArgs);
                    }

                } else {
                    struct State* statePointer = (my_states + moves_filteredP1[i][j].moves[1]*25*10 + moves_filteredP1[i][j].moves[0]*25 );

                    newArgs->L = args->L;
                    newArgs->my_state = statePointer;
                    newArgs->my_weights = args->my_weights;
                    newArgs->depth = args->depth;
                    // newArgs->outputPtr = &(newEstimates[i][j]);
                    newArgs->outputPtr = (newEstimates+i*TRIM_P2+j);
                    
                    printf("call evaluate_switch at %i %i, addr: %p\n", moves_filteredP1[i][j].moves[0], moves_filteredP1[i][j].moves[1], (void *)newArgs->outputPtr);

                    if (isMultithreaded){
                        error = pthread_create(&threads[i][j], NULL, evaluate_switch, newArgs);
                        if (error != 0){
                            printLua_string(args->L, "Thread can't be created : ", strerror(error));
                        }
                    } else {
                        evaluate_switch(newArgs);
                    }



                }

            }

        }

        for (int i = 0; i < TRIM_P1; i++){
            double moveAverageP1 = 0.0;
            int count = 0;
            for (int j = 0; j < TRIM_P2; j++){
                if (isMultithreaded){
                    if (moves_filteredP1[i][j].moves[0] != -1 && moves_filteredP1[i][j].moves[1] != -1){
                        pthread_mutex_lock(&lock);
                        printLua_string(args->L, "", "");
                        printLua_double(args->L, "Changing move p1: ", moves_filteredP1[i][j].moves[0]);
                        printLua_double(args->L, "Changing move p2: ", moves_filteredP1[i][j].moves[1]);
                        printLua_double(args->L, "From: ", moves_filteredP1[i][j].estimate);
                        pthread_mutex_unlock(&lock);
                    }
                } 

                int k = 0;
                while((newEstimates+i*TRIM_P2+j)->estimate == -2){
                    if (k % 4 == 0) {
                        pthread_mutex_lock(&lock);
                        frameSkip(args->L);
                        printLua_double(args->L, "k: ", k);
                        pthread_mutex_unlock(&lock);
                    } else {
                        sleep(1);
                    }
                    k++;
                }
                if (isMultithreaded){
                    if (moves_filteredP1[i][j].moves[0] != -1 && moves_filteredP1[i][j].moves[1] != -1){
                        pthread_mutex_lock(&lock);
                        printLua_double(args->L, "To: ", (newEstimates+i*TRIM_P2+j)->estimate);
                        pthread_mutex_unlock(&lock);
                    }
                }
                if ((newEstimates+i*TRIM_P2+j)->estimate != -1){
                    count++;
                    moveAverageP1 += (newEstimates+i*TRIM_P2+j)->estimate;
                }
            }

            double thisMoveEstimate = moveAverageP1/(double)count;

            if (isMultithreaded) {
                if (moves_filteredP1[i][0].moves[0] != -1){
                    pthread_mutex_lock(&lock);
                    printLua_double(args->L, "Move: ", moves_filteredP1[i][0].moves[0]);
                    printLua_double(args->L, "Estimate: ", thisMoveEstimate);
                    pthread_mutex_unlock(&lock);
                }
            }
            
            if (thisMoveEstimate > bestMove.estimate){
                printf("count %i, moveAverageP1 %f\n", count, moveAverageP1);
                bestMove.estimate = thisMoveEstimate;
                bestMove.move = moves_filteredP1[i][0].moves[0];
                strcpy(bestMove.name, (*(my_states + 0*10*25 + moves_filteredP1[i][0].moves[0]*25 + 0) ).name);
            }
        }

        free(allNewArgs);
        free(my_states);
        *(args->outputPtr) = bestMove;
        return NULL;
    }


    printf("\nreturn blank\n");
    return NULL;
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

    return NULL;
}

double catchRate(int (*inputs)[L1]){

    // printf("hp %d\n", (*inputs)[245]);
    if ((*inputs)[245] == 0) return 0;
    
    float hpPercent = (*inputs)[245]/100.0f;
    // printf("hpPercent %f\n", hpPercent);

    float statusMult = 1;
    if ((*inputs)[269] == 1){
        statusMult = 1.5;
    } else if ((*inputs)[270] == 1){
        statusMult = 2.5;
    } else if ((*inputs)[271] == 1){
        statusMult = 1.5;
    } else if ((*inputs)[272] == 1 || (*inputs)[272] == 2){
        statusMult = 1.5;
    } else if ((*inputs)[273] == 1){
        statusMult = 2.5;
    }

    // printf("statusMult %f\n", statusMult);

    return (3.0f-2.0f*hpPercent)*statusMult/255.0f;
}

// args->my_state is intented as a pointer to to State array of length 25
void *evaluate_switch_catch(void *rawArgs){
    struct EvaluateArgs *args = (struct EvaluateArgs*)rawArgs;

    // pthread_mutex_lock(&lock);
    double accumulativeP1[] = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0};
    int countP1[] = {0, 0, 0, 0, 0, 0};

    for (int i = 0; i < 6; i++){
        // if the state occurs
        if ( (*(args->my_state + i) ).name[0] != '\0' ) {
            double thisEstimate = catchRate(&((*(args->my_state + i)).game_data));
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

    // pthread_mutex_unlock(&lock);
    for (int i = 0; i < 6; i++){
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

                evaluate_move_catch(&newArgs);
                P1Moves[5].estimate = output.estimate;
            }
            *(args->outputPtr) = P1Moves[5];
            
            return NULL;
        }
    }
    
    return NULL;
}

void *evaluate_move_catch(void *rawArgs){
    struct EvaluateArgs *args = (struct EvaluateArgs*)rawArgs;

    if (args->depth != START_DEPTH_CATCH){ pthread_mutex_lock(&lock); }
    key++;
    int thisKey = key;
    if (args->depth != START_DEPTH_CATCH){ pthread_mutex_unlock(&lock); }
    
    load_showdown_state(args->my_state, thisKey, args->depth == START_DEPTH_CATCH);

    struct State* my_states = (struct State*) malloc(10*10*25 * sizeof(struct State));

    get_inputs(args->L, my_states, thisKey);

    // the "inputs" here are states resulting from load_showdown_state
    
    // I pass in this reference here so that the "get_inputs" can figure out
    // where each element in the array is located

    struct Move allMoves[11][4];
    int totalStatesEvaluated = 0;

    for (int i = 0; i < 4; i++){
        for (int j = 0; j < 10; j++){

            double total_estimate = 0.0;

            for (int k = 0; k < 26; k++){

                // if state exists
                if ( (*(my_states + i*10*25 + j*25 + k) ).name[0] != '\0'){

                    // "i" is player2's move
                    // "j" is player1's move

                    double estimate = catchRate(&((my_states + i*10*25 + j*25 + k)->game_data));
                    // printf("%i %i catchrate: %f\n", j, i, estimate);

                    total_estimate+=estimate;
                    totalStatesEvaluated++;
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
        allMoves[10][i].isMultiEvent = 0;
        float baseCatchRate = catchRate( &(args->my_state)->game_data );
        allMoves[10][i].estimate = 1 - (1-baseCatchRate)*(1-baseCatchRate);
        allMoves[10][i].moves[0] = 10;
        allMoves[10][i].moves[1] = i;

    }

    struct PartialMove p2moves[4];
    for (int i = 0; i < 4; i++){
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

    mergeSort_PartialMove(p2moves, 0, 3);

    if (args->depth == START_DEPTH_CATCH) {
        printLua_string(args->L, "", "");
        printLua_string(args->L, "Sorted P2 Moves: ", "");
        printArr_PartialMove(args->L, p2moves, 4);
    }

    struct Move moves_filteredP2[11][TRIM_P2_CATCH];

    int k = 0;
    for (int j = 0; j < 10; j++){
        if (matchesP2Catch(j, &p2moves[0]) == 1){
            for (int i = 0; i < 11; i++){
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

    if (args->depth == START_DEPTH_CATCH) {
        printLua_string(args->L, "", "");
        printLua_string(args->L, "All moves after trim by P2: ", "");
        for (int i = 0; i < 11; i++){
            for (int j = 0; j < TRIM_P2_CATCH; j++){
                printLua_double(args->L, "move1: ", moves_filteredP2[i][j].moves[0]);
                printLua_double(args->L, "move2: ", moves_filteredP2[i][j].moves[1]);
                printLua_double(args->L, "estimate: ", moves_filteredP2[i][j].estimate);
            }
        }
    }
    
    struct PartialMove p1moves[11];
    
    for (int j = 0; j < 11; j++){
        double acculative_estimate = 0.0;
        int possibilities = 0;
        
        for (int i = 0; i < TRIM_P2_CATCH; i++){

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
            p1moves[j].estimate = -1;
        }

        p1moves[j].move = j;
    }

    mergeSort_PartialMove(p1moves, 0, 10);

    if (args->depth == START_DEPTH_CATCH){
        printLua_string(args->L, "", "");
        // printLua_double(L, "DEPTH: ", depth);
        printLua_string(args->L, "Sorted P1 Moves: ", "");
        printArr_PartialMove(args->L, p1moves, 11);
    }

    if (args->depth == 1){
        strcpy(p1moves[9].name, (*(my_states + 0*10*25 + p1moves[10].move*25 + 0) ).name);
        *(args->outputPtr) = p1moves[10];
        
        free(my_states);

        return NULL;
    } else {
        struct Move moves_filteredP1[TRIM_P1_CATCH][TRIM_P2_CATCH];

        int k = 0;
        for (int i = 0; i < 11; i++){
            // if it's in the top TRIM_P1_CATCH
            if (matchesP1Catch(i, &p1moves) == 1){
                for (int j = 0; j < TRIM_P2_CATCH; j++){
                    // i is the player1 index on moves_filteredP2
                    // j is the player2 index on moves_filteredP1 and moves_filteredP2

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

        // struct PartialMove newEstimates[TRIM_P1][TRIM_P2];
        struct PartialMove* newEstimates = (struct PartialMove*)malloc(sizeof(struct PartialMove)*TRIM_P1_CATCH*TRIM_P2_CATCH);

        pthread_t threads[TRIM_P1_CATCH][TRIM_P2_CATCH];
        unsigned int argsSize = sizeof(struct EvaluateArgs);
        struct EvaluateArgs* allNewArgs = (struct EvaluateArgs*)malloc(argsSize * TRIM_P1_CATCH * TRIM_P2_CATCH);

        int error;
        int isMultithreaded = MULTITHREADED && args->depth == START_DEPTH_CATCH;

        for (int i = 0; i < TRIM_P1_CATCH; i++){
            for (int j = 0; j < TRIM_P2_CATCH; j++){
                // i is player 1 move
                // j is player 2 move

                // just to give a default value, so that when I'm 
                // debugging I can tell that the value is unchanged
                (newEstimates+i*TRIM_P2_CATCH+j)->estimate = -2;

                struct EvaluateArgs* newArgs = (struct EvaluateArgs*)(allNewArgs + TRIM_P2_CATCH*i + j);
                if (moves_filteredP1[i][j].isMultiEvent == 0){

                    newArgs->L = args->L;
                    newArgs->my_state = (my_states + moves_filteredP1[i][j].moves[1]*25*10 + moves_filteredP1[i][j].moves[0]*25 );
                    newArgs->my_weights = args->my_weights;
                    newArgs->depth = args->depth - 1;
                    newArgs->outputPtr = (newEstimates+i*TRIM_P2_CATCH+j);
                    printf("call evaluate_move at %i %i, addr: %p, state ptr: %p\n", moves_filteredP1[i][j].moves[0], moves_filteredP1[i][j].moves[1], (void *)newArgs->outputPtr, (void *)newArgs->my_state);
                    

                    if (isMultithreaded){
                        error = pthread_create(&threads[i][j], NULL, evaluate_move_catch, newArgs);
                        if (error != 0){
                            printLua_string(args->L, "Thread can't be created : ", strerror(error));
                        }
                    } else {
                        evaluate_move_catch(newArgs);
                    }

                } else {
                    struct State* statePointer = (my_states + moves_filteredP1[i][j].moves[1]*25*10 + moves_filteredP1[i][j].moves[0]*25 );

                    newArgs->L = args->L;
                    newArgs->my_state = statePointer;
                    newArgs->my_weights = args->my_weights;
                    newArgs->depth = args->depth;
                    newArgs->outputPtr = (newEstimates+i*TRIM_P2_CATCH+j);
                    
                    printf("call evaluate_switch at %i %i, addr: %p\n", moves_filteredP1[i][j].moves[0], moves_filteredP1[i][j].moves[1], (void *)newArgs->outputPtr);

                    if (isMultithreaded){
                        error = pthread_create(&threads[i][j], NULL, evaluate_switch_catch, newArgs);
                        if (error != 0){
                            printLua_string(args->L, "Thread can't be created : ", strerror(error));
                        }
                    } else {
                        evaluate_switch_catch(newArgs);
                    }



                }
            }

        }

        for (int i = 0; i < TRIM_P1_CATCH; i++){
            double moveAverageP1 = 0.0;
            int count = 0;
            for (int j = 0; j < TRIM_P2_CATCH; j++){
                if (isMultithreaded){
                    pthread_mutex_lock(&lock);
                    printLua_string(args->L, "", "");
                    printLua_double(args->L, "Changing move p1: ", moves_filteredP1[i][j].moves[0]);
                    printLua_double(args->L, "Changing move p2: ", moves_filteredP1[i][j].moves[1]);
                    printLua_double(args->L, "From: ", moves_filteredP1[i][j].estimate);
                    pthread_mutex_unlock(&lock);
                }

                int k = 0;
                while((newEstimates+i*TRIM_P2_CATCH+j)->estimate == -2){
                    if (k % 4 == 0) {
                        if (isMultithreaded){
                            pthread_mutex_lock(&lock);
                            frameSkip(args->L);
                            printLua_double(args->L, "k: ", k);
                            // printf("k: %i, value: %f, at %p\n", k, (newEstimates+i*TRIM_P2+j)->estimate, (void *)(newEstimates+i*TRIM_P2+j) );
                            pthread_mutex_unlock(&lock);
                        }
                    } else {
                        sleep(1);
                    }
                    // printf("k: %i, at %p\n", k, (void *)(newEstimates+i*TRIM_P2+j));
                    k++;
                }
                
                if (isMultithreaded) pthread_mutex_lock(&lock);
                if (moves_filteredP1[i][j].moves[0] != -1){
                    count++;
                    if ( moves_filteredP1[i][j].moves[0] == 10 ){
                        double mergedEstimate = 1 - (1 - (newEstimates+i*TRIM_P2_CATCH+j)->estimate) * (1 - moves_filteredP1[i][j].estimate);
                        printf("merged components %f %f\n", (newEstimates+i*TRIM_P2_CATCH+j)->estimate , moves_filteredP1[i][j].estimate);
                        if (isMultithreaded) printLua_double(args->L, "To (merged): ", mergedEstimate);
                        moveAverageP1 += mergedEstimate;
                    } else {
                        if (isMultithreaded) printLua_double(args->L, "To: ", (newEstimates+i*TRIM_P2_CATCH+j)->estimate);
                        moveAverageP1 += (newEstimates+i*TRIM_P2_CATCH+j)->estimate;
                    }
                }
                if (isMultithreaded) pthread_mutex_unlock(&lock);

            }

            double thisMoveEstimate = moveAverageP1/(double)count;

            if (isMultithreaded){
                pthread_mutex_lock(&lock);
                printLua_double(args->L, "Move: ", moves_filteredP1[i][0].moves[0]);
                printLua_double(args->L, "Estimate: ", thisMoveEstimate);
                pthread_mutex_unlock(&lock);
            }
            
            if (thisMoveEstimate > bestMove.estimate){
                bestMove.estimate = thisMoveEstimate;
                bestMove.move = moves_filteredP1[i][0].moves[0];
                // strcpy(bestMove.name, (*(my_states + 0*10*25 + moves_filteredP1[i][0].moves[0]*25 + 0) ).name);
            }
        }

        free(allNewArgs);
        free(my_states);
        *(args->outputPtr) = bestMove;
        if (args->depth == START_DEPTH_CATCH) printf("\nreturned bestMove %i with estimate %f\n", args->outputPtr->move, args->outputPtr->estimate);
        return NULL;
    }

    printf("reached evaluate_move_catch\n");
    return NULL;
}

void run_evaluation(lua_State *L){
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
    // print_weights(&my_weights);
    // print_inputs(start_state, L);

    // struct State* my_states = (struct State*) malloc(10*10*25 * sizeof(struct State));
    // get_inputs(my_states);
    // print_inputs(*my_states);
    // free(my_states);

    key = 0;
    
    if (pthread_mutex_init(&lock, NULL) != 0) {
        printLua_string(L, "mutex init has failed", "");
        // return -1;
    }

    lastBackpropBatch.condition = 0;
    for (int i = 0; i < 17; i++){
        lastBackpropBatch.typeDesire[i] = 0;
    }

    struct PartialMove bestMove;

    struct EvaluateArgs args;
    args.L = L;
    args.my_state = &start_state;
    args.my_weights = &my_weights;
    args.depth = START_DEPTH;
    args.outputPtr = &bestMove;
    
    evaluate_move(&args);
    lua_settop(L, 0);
    lua_newtable(L);
    lua_pushinteger(L, bestMove.move);
    lua_setfield(L, -2, "move");
    lua_pushstring(L, bestMove.name);
    lua_setfield(L, -2, "name");
    
    
    // this is the "backprop information" used to decide
    // when to heal, which pokemon to catch, whether or not
    // we're underleveled, etc.
    
    lua_createtable(L, 17, 0);
    for(int i = 0; i < 17; i++){
        lua_pushnumber(L, lastBackpropBatch.typeDesire[i]);
        printf("type %i: %f\n", i, lastBackpropBatch.typeDesire[i]);
        lua_rawseti(L, -2, i+1);
    }
    lua_setfield(L, -2, "type_info");
    lua_pushnumber(L, lastBackpropBatch.condition);
    printf("condition: %f\n", lastBackpropBatch.condition);
    lua_setfield(L, -2, "condition");

    // deallocate memory from weights
    for (int i = 0; i < LAYERS-1; i++){
        free(my_weights.weights[i]);
        free(my_weights.biases[i]);
    }

    printf("returned bestMove %i with estimate %f\n", args.outputPtr->move, args.outputPtr->estimate);

    // return bestMove.move;
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
    args.depth = START_DEPTH+1;
    args.outputPtr = &bestSwitch;

    // if (pthread_mutex_init(&lock, NULL) != 0) {
    //     printLua_string(L, "mutex init has failed", "");
    //     return -1;
    // }
    evaluate_switch_from_partial_start(&args);
    for (int i = 0; i < LAYERS-1; i++){
        free(args.my_weights->weights[i]);
        free(args.my_weights->biases[i]);
    }
    // printf("Best Switch, estimate: %f, move: %i\n", bestSwitch.estimate, bestSwitch.move);

    printLua_double(L, "Best Switch: ", bestSwitch.move);

    return bestSwitch.move;
}

void run_evaluation_catch(lua_State *L){
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

    key = 0;
    
    if (pthread_mutex_init(&lock, NULL) != 0) {
        printLua_string(L, "mutex init has failed", "");
        // return -1;
    }

    struct PartialMove bestMove;

    struct EvaluateArgs args;
    args.L = L;
    args.my_state = &start_state;
    args.my_weights = &my_weights;
    args.depth = START_DEPTH_CATCH;
    args.outputPtr = &bestMove;
    
    evaluate_move_catch(&args);
    
    for (int i = 0; i < LAYERS-1; i++){
        free(args.my_weights->weights[i]);
        free(args.my_weights->biases[i]);
    }

    lua_settop(L, 0);
    lua_newtable(L);
    lua_pushinteger(L, bestMove.move);
    lua_setfield(L, -2, "move");
    lua_pushstring(L, bestMove.name);
    lua_setfield(L, -2, "name");

    // return bestMove.move;
}

// takes arguments [exec_showdown_state, state]
int get_move(lua_State *L){
    
    clock_t before = clock();
    run_evaluation(L);
    clock_t elapsed = clock() - before;
    int msec = elapsed * 1000 / CLOCKS_PER_SEC;
    printf("Time taken: %d seconds, %d milliseconds\n", msec/1000, msec%1000);
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

int get_move_catch(lua_State *L){
    
    run_evaluation_catch(L);

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
    // this code is functional in lua 5.4 but not (as I've learned) in lua 5.1

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
    lua_pushcfunction(L, get_move_catch);
    lua_setfield(L, -2, "get_move_catch");
    return 1;  // Number of Lua-facing return values on the Lua stack in L.
}