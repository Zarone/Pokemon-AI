
# from sklearn.neural_network._base import DERIVATIVES, LOSS_FUNCTIONS
# from sklearn.utils.extmath import safe_sparse_dot
import numpy as np
import const

# def _compute_loss_grad_injection(
#         self, layer, n_samples, activations, deltas, coef_grads, intercept_grads
#     ):
#         """Compute the gradient of loss with respect to coefs and intercept for
#         specified layer.

#         This function does backpropagation for the specified one layer.
#         """

#         coef_grads[layer] = safe_sparse_dot(activations[layer].T, deltas[layer])
#         coef_grads[layer] += self.alpha * self.coefs_[layer]
#         coef_grads[layer] /= n_samples
        
#         print(len(coef_grads[layer][0]))

#         intercept_grads[layer] = np.mean(deltas[layer], 0)

def _backprop_injection(original):
    def newFunction(*args):
        loss, coef_grads, intercept_grads = original(*args)
        
        links = [
            [95, 125, 155, 185, 215],
            [275, 305, 335, 365, 395]
        ]

        for group in links:
            for i in range(30):
                avg = np.zeros(np.shape(coef_grads[0][0]))
                for el in group:
                    avg = np.add(avg, coef_grads[0][el+i])
                
                avg /= len(links[0])

                for el in group:
                    coef_grads[0][el+i] = avg

        # print(len(coef_grads), len(coef_grads[0]), len(coef_grads[0][0]), coef_grads[0][0][0])

        return loss, coef_grads, intercept_grads
    return newFunction