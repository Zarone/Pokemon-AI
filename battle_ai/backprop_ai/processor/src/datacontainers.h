#ifndef DATACONTAINERS_H
#define DATACONTAINERS_H

// this is the data we update everytime we run the neural network
struct BackpropData {
    double condition; // tallies how much the AI wants to go to the pokemon center
    double typeDesire[17]; // tallies how much the AI wants to catch pokemon of a certain type
};

#endif