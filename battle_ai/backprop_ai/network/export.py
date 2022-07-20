import msgpack
import const

def export(clf):
    file = open("../weights.txt", "wb")

    max = len(const.layers_tuple)+1

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