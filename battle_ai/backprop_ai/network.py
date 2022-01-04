import numpy as np
import random


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
    def SGD(self, training_data, epochs, per_batch, learning_rate, activation):
        # training_data is list of elements like (x, y),
        # where x is the input and y is the correct output

        for i in range(epochs):
            random.shuffle(training_data)
            mini_batches = [training_data[j:j+per_batch]
                            for j in range(0, len(training_data), per_batch)]
            for batch in mini_batches:
                self.train_batch(batch, learning_rate, activation)
        pass

    def train_batch(self, mini_batch, learning_rate, activation):
        x = np.asarray([_x for _x, _y in mini_batch]).transpose()
        y = np.asarray([_y for _x, _y in mini_batch]).transpose()

        nabla_b, nabla_w = None
        if activation == "relu":
            self.backprop(x, y)
        elif activation == "lrelu":
            self.backprop(x, y)
        elif activation == "tanh":
            self.backprop(x, y)

        self.weights = [w-(learning_rate/len(mini_batch))*nw for w, nw in zip(self.weights, nabla_w)]
        self.biases = [b-(learning_rate/len(mini_batch))*nb for b, nb in zip(self.biases, nabla_b)]


    def backprop(self, x, y, activation):
        nabla_b = [np.zeros(b.shape) for b in self.biases]
        nabla_w = [np.zeros(w.shape) for w in self.weights]

        zs = []
        activations = [x]
        activation = x
        for b, w in zip(self.biases, self.weights):
            z = np.dot(w, activation) + b
            zs.append(z)
            activation = activation(z)
            activations.append(activation)

net = Network([4, 4])
net.SGD(
    [
        [np.array([0, 0, 1, 2, 3]), np.array([0, 0, 0, 0, 0, 1])],
        [np.array([0, 0, 1, 2, 3]), np.array([0, 0, 0, 0, 0, 1])],
        [np.array([0, 0, 1, 2, 3]), np.array([0, 0, 0, 0, 0, 1])],
        [np.array([0, 0, 1, 2, 3]), np.array([0, 0, 0, 0, 0, 1])],
        [np.array([0, 0, 1, 2, 3]), np.array([0, 0, 0, 0, 0, 1])],
    ],
    1, 5, 0.03
)
