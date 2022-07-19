import numpy as np
import const

def _backprop_injection(original):
    def newFunction(*args):
        loss, coef_grads, intercept_grads = original(*args)
        
        links = [
            [95, 125, 155, 185, 215],
            [275, 305, 335, 365, 395]
        ]

        for group in links:

            # print("before")
            # for link in group:
            #     print(link, coef_grads[0][link+1][0:4])

            for i in range(30):
                avg = np.zeros(np.shape(coef_grads[0][0]))
                for el in group:
                    avg = np.add(avg, coef_grads[0][el+i])
                
                avg /= len(links[0])

                for el in group:
                    coef_grads[0][el+i] = avg

            # print("after")
            # for link in group:
            #     print(link, coef_grads[0][link+1][0:4])


        return loss, coef_grads, intercept_grads
    return newFunction

def _init_coef_injection(original):
    def newFunction(*args):
        coef_init, intercept_init = original(*args)
        if (args[1] == 425):
            coef_init[125:155] = coef_init[95:125]
            coef_init[155:185] = coef_init[95:125]
            coef_init[185:215] = coef_init[95:125]
            coef_init[215:245] = coef_init[95:125]

            coef_init[305:335] = coef_init[275:305]
            coef_init[335:365] = coef_init[275:305]
            coef_init[365:395] = coef_init[275:305]
            coef_init[395:425] = coef_init[275:305]

        return coef_init, intercept_init

    return newFunction