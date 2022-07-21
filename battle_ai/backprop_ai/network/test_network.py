import msgpack
from sklearn.neural_network import MLPClassifier
import numpy as np

from graph import graph
from manual_test import manual_test

weight_text = open("../weights.txt", "rb")
weight_bytes = weight_text.read()
weight_text.close()

weights = msgpack.unpackb(weight_bytes)

layers_tuple = (200, 100, 50, 20, 10)

clf = MLPClassifier(random_state=1, max_iter=1, hidden_layer_sizes=layers_tuple, tol=1E-6).fit( [[0 for i in range(425)]] , [1] )

max = len(layers_tuple)+1
for i in range(max):
    clf.coefs_[i] = np.array(weights[i])
    clf.intercepts_[i] = np.array(weights[max][i])


graph(clf=clf)
# manual_test(clf=clf)