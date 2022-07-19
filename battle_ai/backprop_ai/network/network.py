import random
import msgpack
import os
import numpy as np

from sklearn.neural_network import MLPClassifier
from sklearn.model_selection import train_test_split

import const

import network_injection

import math

process_log_dir = "../../state_files/processed_logs/"

def get_data(turn_minimum, max_datapoints):
    x = []
    y = []
    fileCount = len(os.listdir(process_log_dir))
    increment = 0
    for fileName in os.listdir(process_log_dir):
        if increment > max_datapoints: break
        increment+=1
        if fileName == ".DS_Store": continue

        turn_count = int(fileName.split(".txt-")[1])
        valid_turn = turn_count > turn_minimum
        if not valid_turn: continue
        
        
        print("{0}/{1} valid turn: {2}".format(increment, fileCount, valid_turn), process_log_dir+fileName)
        file = open(process_log_dir+fileName, "rb")
        fileRead = file.read()
        if fileRead == b"": continue
        
        val = msgpack.unpackb(fileRead)

        fainted_pokemon = [int(val[0][65+i*30] < 1) for i in range(12)]
        fainted_pokemon_count = sum( fainted_pokemon )

        # linear chance of being skipped
        # 11 fainted -->   0%
        # 10 fainted -->   9%
        #  9 fainted -->  18%
        #  8 fainted -->  27%
        #  7 fainted -->  36%
        #  6 fainted -->  45%
        #  5 fainted -->  55%
        #  4 fainted -->  64%
        #  3 fainted -->  72%
        #  2 fainted -->  82%
        #  1 fainted -->  91%
        #  0 fainted --> 100%

        # if fainted_pokemon_count/11 < random.random():
        #     continue

        # exponential chances of being skipped
        # 11 fainted -->   0%
        # 10 fainted -->  39%
        #  9 fainted -->  63%
        #  8 fainted -->  78%
        #  7 fainted -->  86%
        #  6 fainted -->  92%
        #  5 fainted -->  95%
        #  4 fainted -->  97%
        #  3 fainted -->  98%
        #  2 fainted -->  99%
        #  1 fainted -->  99%
        #  0 fainted --> 100%

        if math.exp( (fainted_pokemon_count-11)/2 ) < random.random():
            continue


        # print("")
        # print("before")
        # print(val[0][65], val[0][95], val[0][125], val[0][155], val[0][185], val[0][215])
        # print(val[0][245], val[0][275], val[0][305], val[0][335], val[0][365], val[0][395])
        # print(val[1])


        # reorder the bench pokemon
        # this reduces overfitting
        bench_order = np.array([1,2,3,4,5])
        np.random.shuffle(bench_order)

        new_value = val[0][95:245]

        for i in range(1, 6):
            if i != bench_order[i-1]:
                new_value[(i*30-30):(i*30)] = val[0][ (bench_order[i-1]*30+65):bench_order[i-1]*30+95 ]
                
        val[0][95:245] = new_value

        new_value = val[0][275:425]

        for i in range(1, 6):
            if i != bench_order[i-1]:
                new_value[(i*30-30):(i*30)] = val[0][ (bench_order[i-1]*30+65+180):bench_order[i-1]*30+95+180 ]
                
        val[0][275:425] = new_value

        if not not random.randrange(0, 2):
            val[1] = not val[1]

            temp_p1_hazards = val[0][5:14]
            val[0][5:14] = val[0][14:23]
            val[0][14:23] = temp_p1_hazards
            
            temp_p1_volatiles = val[0][23:37]
            val[0][23:37] = val[0][37:51]
            val[0][37:51] = temp_p1_volatiles

            temp_p1_boosts = val[0][51:58]
            val[0][51:58] = val[0][58:65]
            val[0][58:65] = temp_p1_boosts

            temp_p1_pokemon = val[0][65:245]
            val[0][65:245] = val[0][245:425]
            val[0][245:425] = temp_p1_pokemon

        # print("")
        # print("after")
        # print(val[0][65], val[0][95], val[0][125], val[0][155], val[0][185], val[0][215])
        # print(val[0][245], val[0][275], val[0][305], val[0][335], val[0][365], val[0][395])
        # print(val[1])

        x.append(val[0])
        y.append(int(val[1]))
    return x, y


MLPClassifier._backprop = network_injection._backprop_injection(MLPClassifier._backprop)
MLPClassifier._init_coef = network_injection._init_coef_injection(MLPClassifier._init_coef)

X, y = get_data(3, 1E3)

print("got data")

clf = MLPClassifier(random_state=1, max_iter=300, hidden_layer_sizes=const.layers_tuple, verbose=True, tol=-1).fit(X, y)
print("got finished training")

file = open("../weights.txt", "wb")

print("len(clf.coefs_)",len(clf.coefs_))
print("len(clf.intercepts_)",len(clf.intercepts_))

max = len(const.layers_tuple)+1
print("max", max)

outputArr = [
    *[clf.coefs_[i].tolist() for i in range(max)],
    [clf.intercepts_[i].tolist() for i in range(max)]
] 

print(len(outputArr))

file.write(
    msgpack.packb( 
        outputArr
    )
)