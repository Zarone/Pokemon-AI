import os
import json
# import bit_helper as bit
from sklearn.multioutput import MultiOutputClassifier
from sklearn.neural_network import MLPClassifier
# import numpy as np

startRam = 0x021F3CB4
hidden_layer_size = 20

x = []
y = []

for file in (os.listdir("./states")):
    with open("./states/" + file, "r") as read_file:
        temp_json = json.load(read_file)
        # x.append(bit.get_bits_array(temp_json[1]))
        x.append(temp_json[1])

        # y_append = []

        # for item in temp_json[0]:
        #     for el in item:
        #         y_append.append(el)
        # y.append(y_append)
        


        # y.append(temp_json[0])

        y_append = []
        if temp_json[0][0][0]==1:
            y_append.append(3)
        elif temp_json[0][0][1]==1:
            y_append.append(2)
        elif temp_json[0][0][2]==1:
            y_append.append(1)
        elif temp_json[0][0][3]==1:
            y_append.append(0)
        
        if temp_json[0][1][0]==1:
            y_append.append(2)
        elif temp_json[0][1][1]==1:
            y_append.append(1)
        elif temp_json[0][1][2]==1:
            y_append.append(0)

        if temp_json[0][2][0]==1:
            y_append.append(1)
        elif temp_json[0][2][1]==1:
            y_append.append(0)

        y.append(y_append)

clf = MultiOutputClassifier(
    MLPClassifier(solver='adam', activation="relu",
                  hidden_layer_sizes=(hidden_layer_size), 
                  verbose=True,
                  max_iter=1000,
                  tol=-1
    )
).fit(x, y)


pred_x = []
with open("./predict.json", "r") as read_file:
    temp_json = json.load(read_file)
    pred_x.append(temp_json[1])
print(clf.predict(pred_x))

# estimator_num = 0
# print_threshold = 0.11

# for j in range(hidden_layer_size):
#     print(j, clf.estimators_[estimator_num].coefs_[1][j])


# input_weights = []
# for i in range(len(clf.estimators_[estimator_num].coefs_[0])):
#     weight_sum = 0
#     abs_weight_sum = 0
#     for j in range(hidden_layer_size):
#         abs_weight_sum+=abs(clf.estimators_[estimator_num].coefs_[1][j][0]*clf.estimators_[estimator_num].coefs_[0][i][j])
#         weight_sum+=clf.estimators_[estimator_num].coefs_[1][j][0]*clf.estimators_[estimator_num].coefs_[0][i][j]
#     # if (abs(weight_sum) > print_threshold):
#     # print(hex(i*4+startRam), weight_sum)
#     input_weights.append([i*4+startRam, weight_sum, abs_weight_sum])

# for element in (sorted(input_weights, key=lambda x: x[1])):
#     print(hex(element[0]), element[1], element[2])