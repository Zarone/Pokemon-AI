import msgpack
import os
import numpy as np

from sklearn.neural_network import MLPClassifier
from sklearn.model_selection import train_test_split

process_log_dir = "../state_files/processed_logs/"

def get_data():
    x = []
    y = []
    for fileName in os.listdir(process_log_dir):
        file = open(process_log_dir+fileName, "rb")
        val = msgpack.unpackb(file.read())
        x.append(val[0])
        y.append(int(val[1]))
    return x, y

X, y = get_data()

X_train, X_test, y_train, y_test = train_test_split(X, y, stratify=y, random_state=1)
clf = MLPClassifier(random_state=1, max_iter=300, hidden_layer_sizes=(100,)).fit(X_train, y_train)

# print(np.ndarray(shape=(2,2), dtype=float, order='F'))
# print(len(clf.coefs_[0]))
# print(len(clf.coefs_[1]))

file = open("./weights.txt", "wb")
file.write(msgpack.packb( [ clf.coefs_[0].tolist(), clf.coefs_[1].tolist() ]))