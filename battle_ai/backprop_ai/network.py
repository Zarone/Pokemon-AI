from tabnanny import verbose
import msgpack
import os
import numpy as np

from sklearn.neural_network import MLPClassifier
from sklearn.model_selection import train_test_split

process_log_dir = "../state_files/processed_logs/"

def get_data(turn_minimum, max_datapoints):
    x = []
    y = []
    fileCount = len(os.listdir(process_log_dir))
    increment = 0
    for fileName in os.listdir(process_log_dir):
        if increment > max_datapoints: break
        increment+=1
        if fileName != ".DS_Store":

            turn_count = int(fileName.split(".txt-")[1])
            valid_turn = turn_count > turn_minimum

            # print("{0}/{1} valid turn: {2}".format(increment, fileCount, valid_turn), process_log_dir+fileName)
            
            if valid_turn:
                file = open(process_log_dir+fileName, "rb")
                fileRead = file.read()
                if fileRead != b"":
                    val = msgpack.unpackb(fileRead)
                    x.append(val[0])
                    y.append(int(val[1]))
    return x, y

X, y = get_data(15, 1E7)
print("got data")


clf = MLPClassifier(random_state=1, max_iter=200, hidden_layer_sizes=(300, 150, 50), verbose=True).fit(X, y)
# clf = MLPClassifier(random_state=1, max_iter=200, hidden_layer_sizes=(20, 10), verbose=True).fit(X, y)
print("got finished training")


"""
X_test, y_test = get_data(0, 1000000)

def train_classifier(turn_minimum, max_datapoints):
    X, y = get_data(turn_minimum, max_datapoints)
    print("got data")

    # clf = MLPClassifier(random_state=1, max_iter=50, hidden_layer_sizes=(200, 100, 50, 20, 10)).fit(X, y)
    clf = MLPClassifier(random_state=1, max_iter=50, hidden_layer_sizes=(100, 50, 20, 10)).fit(X, y)
    print("got finished training")

    score = clf.score(X_test, y_test)
    print("turn_minimum, max_datapoints: {0} {1}".format(turn_minimum, max_datapoints), score)
    
    return score

logs_minturn = [[],[],[],[],[],[],[]]
logs_score = [[],[],[],[],[],[],[]]

def train_and_log(turn_minimum, max_datapoints, index):
    logs_minturn[index].append(turn_minimum)
    logs_score[index].append(train_classifier(turn_minimum, max_datapoints))

train_and_log(0, 1000, 0)
train_and_log(2, 1000 * 236918/218727, 0)
train_and_log(4, 1000 * 236918/200680, 0)
train_and_log(6, 1000 * 236918/182828, 0)
train_and_log(10, 1000 * 236918/148049, 0)

train_and_log(0, 5000, 1)
train_and_log(2, 5000 * 236918/218727, 1)
train_and_log(4, 5000 * 236918/200680, 1)
train_and_log(6, 5000 * 236918/182828, 1)
train_and_log(10, 5000 * 236918/148049, 1)

train_and_log(0, 10000, 2)
train_and_log(2, 10000 * 236918/218727, 2)
train_and_log(4, 10000 * 236918/200680, 2)
train_and_log(6, 10000 * 236918/182828, 2)
train_and_log(10, 10000 * 236918/148049, 2)

train_and_log(0, 20000, 3)
train_and_log(2, 20000 * 236918/218727, 3)
train_and_log(4, 20000 * 236918/200680, 3)
train_and_log(6, 20000 * 236918/182828, 3)
train_and_log(10, 20000 * 236918/148049, 3)

train_and_log(0, 50000, 4)
train_and_log(2, 50000 * 236918/218727, 4)
train_and_log(4, 50000 * 236918/200680, 4)
train_and_log(6, 50000 * 236918/182828, 4)
train_and_log(10, 50000 * 236918/148049, 4)

train_and_log(0, 100000, 5)
train_and_log(2, 100000 * 236918/218727, 5)
train_and_log(4, 100000 * 236918/200680, 5)
train_and_log(6, 100000 * 236918/182828, 5)
train_and_log(10, 100000 * 236918/148049, 5)

train_and_log(0, 150000, 6)
train_and_log(2, 150000 * 236918/218727, 6)
train_and_log(4, 150000 * 236918/200680, 6)
train_and_log(6, 150000 * 236918/182828, 6)
train_and_log(10, 150000 * 236918/148049, 6)

import matplotlib.pyplot as plt

plt.title("adjusted for datapoints")
plt.plot(logs_minturn[0], logs_score[0], c ="#AAAAAA", label="1000")
plt.plot(logs_minturn[1], logs_score[1], c ="#777777", label="5000")
plt.plot(logs_minturn[2], logs_score[2], c ="#444444", label="10000")
plt.plot(logs_minturn[3], logs_score[3], c ="#111111", label="20000")
plt.plot(logs_minturn[4], logs_score[4], c ="#0000FF", label="50000")
plt.plot(logs_minturn[5], logs_score[5], c ="#00FF00", label="100000")
plt.plot(logs_minturn[6], logs_score[6], c ="#FF0000", label="150000")

plt.legend(bbox_to_anchor =(0.75, 1.15), ncol = 2)

# # To show the plot
plt.show()
"""


file = open("./weights.txt", "wb")

print("len(clf.coefs)", len(clf.coefs_))
print("len(clf.intercepts_)", len(clf.intercepts_))

file.write(
    msgpack.packb( [ 
        clf.coefs_[0].tolist(), 
        clf.coefs_[1].tolist(), 
        clf.coefs_[2].tolist(),
        clf.coefs_[3].tolist(),
        # clf.coefs_[4].tolist(),
        # clf.coefs_[5].tolist(),
        [ 
            clf.intercepts_[0].tolist(),
            clf.intercepts_[1].tolist(),
            clf.intercepts_[2].tolist(),
            clf.intercepts_[3].tolist(),
            # clf.intercepts_[4].tolist(),
            # clf.intercepts_[5].tolist()
        ] 
    ] )
)