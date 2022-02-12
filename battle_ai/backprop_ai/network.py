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

            # hpP1 = []
            # hpP2 = []
            
            # hpP1.append(val[0][65])
            # hpP1.append(val[0][95])
            # hpP1.append(val[0][125])
            # hpP1.append(val[0][155])
            # hpP1.append(val[0][185])
            # hpP1.append(val[0][215])
            
            # hpP2.append(val[0][245])
            # hpP2.append(val[0][275])
            # hpP2.append(val[0][305])
            # hpP2.append(val[0][335])
            # hpP2.append(val[0][365])
            # hpP2.append(val[0][395])
            
            # print(hpP1)
            # print(hpP2)
            # print("\n")

            x.append(val[0])
            y.append(int(val[1]))
    return x, y

X, y = get_data()
print("got data")

# X_train, X_test, y_train, y_test = train_test_split(X, y, stratify=y, random_state=1)
# clf = MLPClassifier(random_state=1, max_iter=300, hidden_layer_sizes=(100, 20)).fit(X_train, y_train)

clf = MLPClassifier(random_state=1, max_iter=300, hidden_layer_sizes=(200, 100)).fit(X, y)
print("got finished training")

file = open("./weights.txt", "wb")

file.write(
    msgpack.packb( [ 
        clf.coefs_[0].tolist(), 
        clf.coefs_[1].tolist(), 
        clf.coefs_[2].tolist(),
        [ 
            clf.intercepts_[0].tolist(),
            clf.intercepts_[1].tolist(),
            clf.intercepts_[2].tolist()
        ] 
    ] )
)