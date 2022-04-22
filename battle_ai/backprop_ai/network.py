import msgpack
import os
import numpy as np

from sklearn.neural_network import MLPClassifier
from sklearn.model_selection import train_test_split

process_log_dir = "../state_files/processed_logs/"

def get_data():
    x = []
    y = []
    fileCount = len(os.listdir(process_log_dir))
    increment = 0
    for fileName in os.listdir(process_log_dir):
        increment+=1
        if fileName != ".DS_Store":
            print("{0}/{1}".format(increment, fileCount), process_log_dir+fileName)
            file = open(process_log_dir+fileName, "rb")
            fileRead = file.read()
            # print(fileRead)
            if fileRead != b"":
                val = msgpack.unpackb(fileRead)
                x.append(val[0])
                y.append(int(val[1]))
    return x, y

X, y = get_data()
print("got data")

# X_train, X_test, y_train, y_test = train_test_split(X, y, stratify=y, random_state=1)
# clf = MLPClassifier(random_state=1, max_iter=300, hidden_layer_sizes=(100, 20)).fit(X_train, y_train)

clf = MLPClassifier(random_state=1, max_iter=300, hidden_layer_sizes=(200, 50, 20, 20, 10)).fit(X, y)
print("got finished training")

file = open("./weights.txt", "wb")

file.write(
    msgpack.packb( [ 
        clf.coefs_[0].tolist(), 
        clf.coefs_[1].tolist(), 
        clf.coefs_[2].tolist(),
        clf.coefs_[3].tolist(),
        clf.coefs_[4].tolist(),
        clf.coefs_[5].tolist(),
        [ 
            clf.intercepts_[0].tolist(),
            clf.intercepts_[1].tolist(),
            clf.intercepts_[2].tolist(),
            clf.intercepts_[3].tolist(),
            clf.intercepts_[4].tolist(),
            clf.intercepts_[5].tolist()
        ] 
    ] )
)