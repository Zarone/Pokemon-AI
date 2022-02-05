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
        if fileName != ".DS_Store":
            file = open(process_log_dir+fileName, "rb")
            val = msgpack.unpackb(file.read())
            x.append(val[0])
            y.append(int(val[1]))
    return x, y

X, y = get_data()
# print(len(X[0]))

X_train, X_test, y_train, y_test = train_test_split(X, y, stratify=y, random_state=1)
clf = MLPClassifier(random_state=1, max_iter=300, hidden_layer_sizes=(100,)).fit(X_train, y_train)

# print(len(clf.coefs_[0]))
# print(len(clf.coefs_[1]))
# print(len(clf.intercepts_[0]))
# print(len(clf.intercepts_[1]))


# print(clf.coefs_[0][0][0])
# print(clf.coefs_[0][0][1])
# print(clf.coefs_[0][0][2])
# print(clf.coefs_[0][0][3])
# print(clf.coefs_[0][0][4])
# print(clf.coefs_[0][0][5])
# print(clf.coefs_[0][0][6])
# print(clf.coefs_[0][0][7])

# print(clf.coefs_[1][0][0])
# print(clf.coefs_[1][1][0])
# print(clf.coefs_[1][2][0])
# print(clf.coefs_[1][3][0])
# print(clf.coefs_[1][4][0])
# print(clf.coefs_[1][5][0])
# print(clf.coefs_[1][6][0])
# print(clf.coefs_[1][7][0])

# print(clf.intercepts_[0][0])
# print(clf.intercepts_[0][1])
# print(clf.intercepts_[0][2])
# print(clf.intercepts_[0][3])
# print(clf.intercepts_[0][4])
# print(clf.intercepts_[0][5])
# print(clf.intercepts_[1][0])

file = open("./weights.txt", "wb")
# file.write(msgpack.packb( [ ["0-0", "0-1"], ["1-0", "1-1"], ["2-0", "2-1"] ] ))
file.write(
    msgpack.packb( [ 
        clf.coefs_[0].tolist(), 
        clf.coefs_[1].tolist(), 
        [ 
            clf.intercepts_[0].tolist(),
            clf.intercepts_[1].tolist()
        ] 
    ] )
)