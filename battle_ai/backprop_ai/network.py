import numpy as np


class Network():
    def __init__(self, sizes):
        self.sizes = sizes
        self.init_weights()

    def init_weights(self):

        # uses guassian random distribution
        # weights with mean = 0, standard deviation = (1/sqrt(n))
        # biases with mean = 0, standard deviation = 1

        self.biases = [np.random.randn(y, 1) for y in self.sizes[1:]]
        self.weights = [np.random.randn(y, x)/np.sqrt(x)
                        for x, y in zip(self.sizes[:-1], self.sizes[1:])]

    # Stochastic Gradient Descent
    def SGD(self, training_data, epochs, per_batch): 
        # training_data is list of elements like (x, y),
        # where x is the input and y is the correct output
        
        # for each epoch
            # shuffle training data
            # get array of all batches
                # each batch is of a small section of the training data, 
                # each one with size "per_batch"
            # call self.train_batch(mini_batch)
        pass

    def train_batch(self, mini_batch):
        pass
        