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

# print("prediction", clf.predict([[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
#     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
#     0, 0, 0, 0, 0, 0, 0, -2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 326,
#     221, 216, 349, 216, 324, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
#     0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 101, 78, 94, 56, 66, 43, 1, 0, 0, 0,
#     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 100, 342,
#     241, 231, 207, 249, 188, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0,
#     0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 125, 98, 95, 62, 65, 91, 0, 0, 0, 0,
#     0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 100, 233,
#     153, 152, 251, 139, 190, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
#     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
#     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 244, 111, 125,
#     132, 192, 111, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0,
#     0, 0, 0, 0, 0, 0, 228, 202, 139, 93, 139, 114, 0, 0, 0, 0, 0, 0, 0,
#     1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 100, 201, 139, 137,
#     125, 125, 182, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0,
#     0, 0, 0, 0, 0, 100, 315, 139, 88, 154, 102, 139, 0, 0, 0, 0, 0, 0,
#     1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 184, 97,
#     232, 161, 192, 61, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0,
#     0, 0, 0, 0, 0, 0, 0, 100, 192, 96, 158, 238, 173, 143, 0, 0, 0, 0,
#     0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
# ))

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