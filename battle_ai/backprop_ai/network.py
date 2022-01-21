import msgpack
import os

from sklearn.neural_network import MLPClassifier
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split

process_log_dir = "../state_files/processed_logs/"

def get_data():
    x = []
    y = []
    for fileName in os.listdir(process_log_dir):
        file = open(process_log_dir+fileName, "rb")
        val = msgpack.unpackb(file.read())
        x.append(val[0])
        y.append(int(val[1]))
    return x, y

X, y = get_data()
print(y[0:5])

# X, y = make_classification(n_samples=100, random_state=1)
X_train, X_test, y_train, y_test = train_test_split(X, y, stratify=y, random_state=1)
clf = MLPClassifier(random_state=1, max_iter=300).fit(X_train, y_train)

print(
        clf.predict(
            X[0:5]
        )
)
