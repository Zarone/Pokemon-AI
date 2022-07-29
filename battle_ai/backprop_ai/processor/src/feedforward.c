#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include "config.h"
#include "datacontainers.h"
#include "feedforward.h"

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

double feedforward(struct Weights *my_weights, int (*inputs)[L1], bool tallyBackprop, struct BackpropData *lastBackpropBatch){

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

    
    printf("Inputs[65] = %i\n", (*inputs)[65]);
    printf("Inputs[95] = %i\n", (*inputs)[95]);
    printf("Inputs[125] = %i\n", (*inputs)[125]);
    printf("Inputs[155] = %i\n", (*inputs)[155]);
    printf("Inputs[185] = %i\n", (*inputs)[185]);
    printf("Inputs[215] = %i\n", (*inputs)[215]);

    printf("Inputs[245] = %i\n", (*inputs)[245]);
    printf("Inputs[275] = %i\n", (*inputs)[275]);
    printf("Inputs[305] = %i\n", (*inputs)[305]);
    printf("Inputs[335] = %i\n", (*inputs)[335]);
    printf("Inputs[365] = %i\n", (*inputs)[365]);
    printf("Inputs[395] = %i\n", (*inputs)[395]);

    

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

        double tempCondition = 0;

        for (int i = 65; i < 245; i+=30){
            // if there's a pokemon in this slot
            if ((*inputs)[i+1] > 0){
                tempCondition -= errorLayers[LAYERS-2][i]*((*inputs)[i]-100.0f);
                // printf("health %i, errorLayers[LAYERS-2][%i] * 100 000 000 = %f\n", (*inputs)[i], i, errorLayers[LAYERS-2][i] * 100000000);

                if (errorLayers[LAYERS-2][i+24] < 0) tempCondition -= errorLayers[LAYERS-2][i+24]*((*inputs)[i+24]);
                if (errorLayers[LAYERS-2][i+25] < 0) tempCondition -= errorLayers[LAYERS-2][i+25]*((*inputs)[i+25]);
                if (errorLayers[LAYERS-2][i+26] < 0) tempCondition -= errorLayers[LAYERS-2][i+26]*((*inputs)[i+26]);
                if (errorLayers[LAYERS-2][i+27] < 0) tempCondition -= errorLayers[LAYERS-2][i+27]*((*inputs)[i+27]);
                if (errorLayers[LAYERS-2][i+28] < 0) tempCondition -= errorLayers[LAYERS-2][i+28]*((*inputs)[i+28]);
                if (errorLayers[LAYERS-2][i+29] < 0) tempCondition -= errorLayers[LAYERS-2][i+29]*((*inputs)[i+29]);

            } else {
                for (int j = 7; j < 24; j++){
                    if (errorLayers[LAYERS-2][i+j]) lastBackpropBatch->typeDesire[j-7] -= errorLayers[LAYERS-2][i+j];
                }
            }
        }

        lastBackpropBatch->condition += tempCondition;
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