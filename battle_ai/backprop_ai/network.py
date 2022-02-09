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

X_train, X_test, y_train, y_test = train_test_split(X, y, stratify=y, random_state=1)
clf = MLPClassifier(random_state=1, max_iter=300, hidden_layer_sizes=(100, 20)).fit(X_train, y_train)


# print("calculating input_scaling")
# input_scaling = [0 for _ in range (425)]

# for i in range(len(clf.coefs_[0])):
#     # len(clf.coefs_[0]) = 425

#     for j in range(len(clf.coefs_[1])):
#         #len(clf.coefs_[1]) = 200
        
#         for k in range(len(clf.coefs_[2])):
#             input_scaling[i] += clf.coefs_[0][i][j] * clf.coefs_[1][j][k] * clf.coefs_[2][k][0]



# print("HP P1")
# print(input_scaling[65])
# print(input_scaling[95])
# print(input_scaling[125])
# print(input_scaling[155])
# print(input_scaling[185])
# print(input_scaling[215])
# print("Boosts P1")
# print(input_scaling[51])
# print(input_scaling[52])
# print(input_scaling[53])
# print(input_scaling[54])
# print(input_scaling[55])
# print(input_scaling[56])
# print(input_scaling[57])
# print("\n")
# print("HP P2")
# print(input_scaling[245])
# print(input_scaling[275])
# print(input_scaling[305])
# print(input_scaling[335])
# print(input_scaling[365])
# print(input_scaling[395])
# print("Boosts P2")
# print(input_scaling[58])
# print(input_scaling[59])
# print(input_scaling[60])
# print(input_scaling[61])
# print(input_scaling[62])
# print(input_scaling[63])
# print(input_scaling[64])

test = [ [254, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 326,
          221, 216, 349, 216, 324, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 99, 101, 71, 94, 56, 66, 43, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 342, 221, 231,
          207, 249, 188, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 80, 125, 98, 85, 62, 65, 91, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 43, 233, 153, 152, 251, 139,
          190, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 57, 184, 97, 232, 161, 192, 61, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 244, 111,
          125, 132, 192, 111, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 100, 201, 139, 137, 125, 125, 182, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 315, 139, 88,
          154, 102, 139, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 100, 228, 202, 139, 93, 139, 114, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 192, 96, 158,
          238, 173, 143, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          0, 0, 0, 0, 0
]]

print(clf.predict(test))

# file = open("./weights.txt", "wb")

# file.write(
#     msgpack.packb( [ 
#         clf.coefs_[0].tolist(), 
#         clf.coefs_[1].tolist(), 
#         clf.coefs_[2].tolist(),
#         [ 
#             clf.intercepts_[0].tolist(),
#             clf.intercepts_[1].tolist(),
#             clf.intercepts_[2].tolist()
#         ] 
#     ] )
# )