#include <stdio.h>
#include "config.h"
#include "weightmanager.h"


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
        case 7:
            return L8;
            break;
        // case 8:
            // return L9;
            // break;
        default:
            printf("triggered default in getLayerSize()\n");
            return -1;
            break;
    }
}