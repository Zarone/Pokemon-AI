import random
import os
import math

import numpy as np
from sklearn.neural_network import MLPClassifier
from sklearn.model_selection import train_test_split
import msgpack

import network_injection
from export import export
from graph import graph

process_log_dir = "../../state_files/processed_logs/"

MLPClassifier._backprop = network_injection._backprop_injection(MLPClassifier._backprop)
MLPClassifier._init_coef = network_injection._init_coef_injection(MLPClassifier._init_coef)

def get_data(turn_minimum=0, max_datapoints=0, skip_on_fainted_linear=0, skip_on_fainted_exp=0, re_order=False, occasional_swap=False):
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

        if skip_on_fainted_linear != 0:
            if skip_on_fainted_linear*(fainted_pokemon_count-11)/11+1 < random.random():
                continue
        elif skip_on_fainted_exp != 0:
            if math.exp( (fainted_pokemon_count-11)*skip_on_fainted_exp/2 ) < random.random():
                continue

        if re_order:
            # reorder the bench pokemon
            # this reduces overfitting
            bench_order = np.array([1,2,3,4,5])
            np.random.shuffle(bench_order)

            new_value = val[0][95:245]

            for i in range(1, 6):
                if i != bench_order[i-1]:
                    new_value[(i*30-30):(i*30)] = val[0][ (bench_order[i-1]*30+65):bench_order[i-1]*30+95 ]
                    
            val[0][95:245] = new_value

            np.random.shuffle(bench_order)

            new_value = val[0][275:425]

            for i in range(1, 6):
                if i != bench_order[i-1]:
                    new_value[(i*30-30):(i*30)] = val[0][ (bench_order[i-1]*30+65+180):bench_order[i-1]*30+95+180 ]
                    
            val[0][275:425] = new_value

        if occasional_swap and not not random.randrange(0, 2):

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

        x.append(val[0])
        y.append(int(val[1]))

    return x, y

X, y = None, None

def train_with_params(
    turn_minimum=0, max_datapoints=0, 
    skip_on_fainted_linear=False, skip_on_fainted_exp=False, 
    re_order=False, occasional_swap=False, rng_seed=1, max_iter=100,
    layers_tuple=(200, 100, 50, 20, 10), globalInput=False
):
    if (globalInput): global X, y
    else: X, y

    if X == None or not globalInput:
        X, y = get_data(
            turn_minimum=turn_minimum, 
            max_datapoints=max_datapoints,
            skip_on_fainted_exp=skip_on_fainted_exp,
            skip_on_fainted_linear=skip_on_fainted_linear,
            re_order=re_order,
            occasional_swap=occasional_swap
        )
    # print("got data")

    clf = MLPClassifier(random_state=rng_seed, max_iter=max_iter, hidden_layer_sizes=layers_tuple, verbose=True, tol=-1).fit(X, y)
    # print("got finished training")
    
    graph(clf, "./graphs/turnmin={0}; maxdata={1}; skipfaintexp={2}; skipfaintlinear={3}; reorder={4}; swap={5}; seed={6}.png".format(
            turn_minimum, max_datapoints, skip_on_fainted_exp, skip_on_fainted_linear, re_order, occasional_swap, rng_seed
        )
    )

    return clf

baseline = 1E7
baselayers = (200, 50, 20, 20, 20, 20, 5)

clfs = [
    train_with_params(
        max_datapoints=baseline, 
        rng_seed=20, 
        occasional_swap=True, 
        max_iter=300, 
        layers_tuple=baselayers, 
        globalInput=True
    ),
]

# export( clfs[int(input("Export Which Network? "))], baselayers )
export( clfs[0], baselayers )