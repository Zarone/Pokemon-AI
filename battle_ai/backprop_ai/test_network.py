import msgpack
from sklearn.neural_network import MLPClassifier
import numpy as np

weight_text = open("weights.txt", "rb")
weight_bytes = weight_text.read() # if you only wanted to read 512 bytes, do .read(512)
weight_text.close()

weights = msgpack.unpackb(weight_bytes)
clf = MLPClassifier(random_state=1, max_iter=200, hidden_layer_sizes=(200, 100, 50, 25, 10, 5), verbose=True, tol=1E-6).fit([[0 for i in range(425)]], [[1]])

clf.coefs_[0] = np.array(weights[0])
clf.coefs_[1] = np.array(weights[1])
clf.coefs_[2] = np.array(weights[2])
clf.coefs_[3] = np.array(weights[3])
clf.coefs_[4] = np.array(weights[4])
clf.coefs_[5] = np.array(weights[5])
clf.coefs_[6] = np.array(weights[6])
clf.intercepts_[0] = np.array(weights[7][0])
clf.intercepts_[1] = np.array(weights[7][1])
clf.intercepts_[2] = np.array(weights[7][2])
clf.intercepts_[3] = np.array(weights[7][3])
clf.intercepts_[4] = np.array(weights[7][4])
clf.intercepts_[5] = np.array(weights[7][5])
clf.intercepts_[6] = np.array(weights[7][6])

network_input = [0 for i in range(425)]
print( clf._forward_pass_fast([ network_input ]) )