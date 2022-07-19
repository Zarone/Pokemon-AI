
from matplotlib import pyplot as plt

def graph(clf, network_input, reset_inputs):
    fig, ax = plt.subplots(nrows=2, ncols=1)

    def display_HP_versus_winrate(enemy):
        inputX = [i for i in range(100, 0, -1)]
        inputY1 = []
        inputY2 = []
        inputY3 = []
        inputY4 = []
        inputY5 = []
        inputYActive = []
        inputY5Active = []

        for val in inputX:

            enemy_offset=0
            if enemy: enemy_offset = 180

            reset_inputs()
            network_input[95+enemy_offset] = val
            inputY1.append(clf._forward_pass_fast([ network_input ])[0][0])

            reset_inputs()
            network_input[95+enemy_offset] = val
            network_input[125+enemy_offset] = val
            inputY2.append(clf._forward_pass_fast([ network_input ])[0][0])
            
            reset_inputs()
            network_input[95+enemy_offset] = val
            network_input[125+enemy_offset] = val
            network_input[155+enemy_offset] = val
            inputY3.append(clf._forward_pass_fast([ network_input ])[0][0])
            
            reset_inputs()
            network_input[95+enemy_offset] = val
            network_input[125+enemy_offset] = val
            network_input[155+enemy_offset] = val
            network_input[185+enemy_offset] = val
            inputY4.append(clf._forward_pass_fast([ network_input ])[0][0])
            
            reset_inputs()
            network_input[95+enemy_offset] = val
            network_input[125+enemy_offset] = val
            network_input[155+enemy_offset] = val
            network_input[185+enemy_offset] = val
            network_input[215+enemy_offset] = val
            inputY5.append(clf._forward_pass_fast([ network_input ])[0][0])

            reset_inputs()
            network_input[65+enemy_offset] = val
            network_input[95+enemy_offset] = val
            network_input[125+enemy_offset] = val
            network_input[155+enemy_offset] = val
            network_input[185+enemy_offset] = val
            network_input[215+enemy_offset] = val
            inputY5Active.append(clf._forward_pass_fast([ network_input ])[0][0])

            reset_inputs()
            network_input[65+enemy_offset] = val
            inputYActive.append(clf._forward_pass_fast([ network_input ])[0][0])

        row = 0
        column = 0
        if (enemy): row = 1
        ax[row].plot(inputX, inputY1, label="1 pokemon")
        ax[row].plot(inputX, inputY2, label="2 pokemon")
        ax[row].plot(inputX, inputY3, label="3 pokemon")
        ax[row].plot(inputX, inputY4, label="4 pokemon")
        ax[row].plot(inputX, inputY5, label="5 pokemon")
        ax[row].plot(inputX, inputYActive, label="active")
        ax[row].plot(inputX, inputY5Active, label="5 pokemon + active")
        ax[row].legend()

        if (enemy):
            ax[row].set(xlabel='enemy hp', ylabel='winrate')
        else:
            ax[row].set(xlabel='hp', ylabel='winrate')

        ax[row].grid()

    display_HP_versus_winrate(True)
    display_HP_versus_winrate(False)
    plt.show()