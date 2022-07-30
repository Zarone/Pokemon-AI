#ifndef WEIGHTMANAGER_H
#define WEIGHTMANAGER_H
    
#include "config.h"

int getLayerSize(int layer);

struct Weights {
    double** weights[LAYERS-1];
    double* biases[LAYERS-1];
};

#endif