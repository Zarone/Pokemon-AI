import msgpack

def export(clf, layers_tuple):
    file = open("../weights.txt", "wb")

    max = len(layers_tuple)+1

    outputArr = [
        *[clf.coefs_[i].tolist() for i in range(max)],
        [clf.intercepts_[i].tolist() for i in range(max)]
    ] 

    file.write(
        msgpack.packb( 
            outputArr
        )
    )