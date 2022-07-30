#ifndef FEEDFOWARD_H
#define FEEDFORWARD_H

#include "config.h"

/**
 * @brief Affects the sigmoid curve for the neural network output.
 * 
 */
#define SPREAD 0.05


/**
 * @brief Mathematical helper function for feedforward.
 * 
 * @param a Function input
 * @return double 
 */
double relu(double a);

/**
 * @brief Gives derivative for ReLu function. 
 * 
 * @param a Function input
 * @return double 
 */
double relu_derivative(double a);

/**
 * @brief Mathematical helper function for feedforward.
 * 
 * @param a Function input
 * @return double 
 */
double logistic(double a);

/**
 * @brief Gives derivative for the Sigmoid (logistic) function.
 * 
 * @param a Function input
 * @return double 
 */
double logistic_derivative(double a);

/**
 * @brief Calculates whether or not the player was won the game, 
 * given the current network input.
 * 
 * @param inputs Pointer to the current network input
 * @return True if the player has won 
 */
bool checkWin(int (*inputs)[L1]);

/**
 * @brief Calculates whether or not the player has lost the game,
 * given the current network input.
 * 
 * @param inputs Pointer to the current network input
 * @return True if the player has lost
 */
bool checkLoss(int (*inputs)[L1]);


/**
 * @brief Runs input through neural network using feedforward algorithm.
 * 
 * @param my_weights Weights of neural netowrk
 * @param inputs Pointer to the input layer of the neural network
 * @param tallyBackprop Whether or not to add backpropagation data to the "lastBackpropBatch" argument 
 * @param lastBackpropBatch 
 * @return double 
 */
double feedforward(struct Weights *my_weights, int (*inputs)[L1], bool tallyBackprop, struct BackpropData *lastBackpropBatch);

#endif