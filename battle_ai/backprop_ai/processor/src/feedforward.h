#ifndef FEEDFOWARD_H
#define FEEDFORWARD_H
    #include "config.h"

    /**
     * @brief Calculates whether or not the player was won the game, 
     * given the current network input
     * 
     * @param inputs Pointer to the current network input
     * @return True if the player has won 
     */
    bool checkWin(int (*inputs)[L1]);

    /**
     * @brief Calculates whether or not the player has lost the game,
     * given the current network input
     * 
     * @param inputs Pointer to the current network input
     * @return True if the player has lost
     */
    bool checkLoss(int (*inputs)[L1]);


    /**
     * @brief 
     * 
     * @param my_weights 
     * @param tallyBackprop 
     * @param lastBackpropBatch 
     * @return double 
     */
    double feedforward(struct Weights *my_weights, int (*inputs)[L1], bool tallyBackprop, struct BackpropData *lastBackpropBatch);

#endif