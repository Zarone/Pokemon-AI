import msgpack
from sklearn.neural_network import MLPClassifier
import numpy as np

import const

weight_text = open("../weights.txt", "rb")
weight_bytes = weight_text.read()
weight_text.close()

weights = msgpack.unpackb(weight_bytes)

print(len(weights))
print(len(weights[len(weights)-1]))

clf = MLPClassifier(random_state=1, max_iter=1, hidden_layer_sizes=const.layers_tuple, tol=1E-6).fit( [[0 for i in range(425)]] , [1] )

max = len(const.layers_tuple)+1
for i in range(max):
    clf.coefs_[i] = np.array(weights[i])
    clf.intercepts_[i] = np.array(weights[max][i])

network_input = [0 for i in range(425)]

def reset_inputs():
    network_input[65] = 100
    network_input[95] = 100
    network_input[125] = 100
    network_input[155] = 100
    network_input[185] = 100
    network_input[215] = 100

    network_input[245] = 100
    network_input[275] = 100
    network_input[305] = 100
    network_input[335] = 100
    network_input[365] = 100
    network_input[395] = 100

    network_input[94] = 1
    network_input[124] = 1
    network_input[154] = 1
    network_input[184] = 1
    network_input[214] = 1
    network_input[244] = 1

    network_input[274] = 1
    network_input[304] = 1
    network_input[334] = 1
    network_input[364] = 1
    network_input[394] = 1
    network_input[424] = 1

from graph import graph

graph(clf=clf, network_input=network_input, reset_inputs=reset_inputs)

# reset_inputs()

# from manual_test import manual_test

# manual_test(clf=clf, network_input=network_input)