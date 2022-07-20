
from matplotlib import pyplot as plt

from input_data import get_inputs


def graph(clf, dir):
    fig, ax = plt.subplots(nrows=2, ncols=2)

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

            network_input = get_inputs()
            network_input[95+enemy_offset] = val
            inputY1.append(clf._forward_pass_fast([ network_input ])[0][0])

            network_input = get_inputs()
            network_input[95+enemy_offset] = val
            network_input[125+enemy_offset] = val
            inputY2.append(clf._forward_pass_fast([ network_input ])[0][0])
            
            network_input = get_inputs()
            network_input[95+enemy_offset] = val
            network_input[125+enemy_offset] = val
            network_input[155+enemy_offset] = val
            inputY3.append(clf._forward_pass_fast([ network_input ])[0][0])
            
            network_input = get_inputs()
            network_input[95+enemy_offset] = val
            network_input[125+enemy_offset] = val
            network_input[155+enemy_offset] = val
            network_input[185+enemy_offset] = val
            inputY4.append(clf._forward_pass_fast([ network_input ])[0][0])
            
            network_input = get_inputs()
            network_input[95+enemy_offset] = val
            network_input[125+enemy_offset] = val
            network_input[155+enemy_offset] = val
            network_input[185+enemy_offset] = val
            network_input[215+enemy_offset] = val
            inputY5.append(clf._forward_pass_fast([ network_input ])[0][0])

            network_input = get_inputs()
            network_input[65+enemy_offset] = val
            network_input[95+enemy_offset] = val
            network_input[125+enemy_offset] = val
            network_input[155+enemy_offset] = val
            network_input[185+enemy_offset] = val
            network_input[215+enemy_offset] = val
            inputY5Active.append(clf._forward_pass_fast([ network_input ])[0][0])

            network_input = get_inputs()
            network_input[65+enemy_offset] = val
            inputYActive.append(clf._forward_pass_fast([ network_input ])[0][0])

        row = 0
        if (enemy): row = 1
        ax[row, 0].plot(inputX, inputY1, label="1 pokemon")
        ax[row, 0].plot(inputX, inputY2, label="2 pokemon")
        ax[row, 0].plot(inputX, inputY3, label="3 pokemon")
        ax[row, 0].plot(inputX, inputY4, label="4 pokemon")
        ax[row, 0].plot(inputX, inputY5, label="5 pokemon")
        ax[row, 0].plot(inputX, inputYActive, label="active")
        ax[row, 0].plot(inputX, inputY5Active, label="5 pokemon + active")
        ax[row, 0].legend()

        if (enemy):
            ax[row, 0].set(xlabel='enemy hp', ylabel='winrate')
        else:
            ax[row, 0].set(xlabel='hp', ylabel='winrate')

        ax[row, 0].grid()

    def display_Boosts_versus_winrate(enemy):
        inputX = [i for i in range(-6, 6, 1)]
        inputY1 = []
        inputY2 = []
        inputY3 = []
        inputY4 = []
        inputY5 = []
        inputY6 = []
        inputY7 = []

        for val in inputX:

            enemy_offset=0
            if enemy: enemy_offset = 7

            network_input = get_inputs()
            network_input[51+enemy_offset] = val
            inputY1.append(clf._forward_pass_fast([ network_input ])[0][0])

            network_input = get_inputs()
            network_input[52+enemy_offset] = val
            inputY2.append(clf._forward_pass_fast([ network_input ])[0][0])
            
            network_input = get_inputs()
            network_input[53+enemy_offset] = val
            inputY3.append(clf._forward_pass_fast([ network_input ])[0][0])
            
            network_input = get_inputs()
            network_input[54+enemy_offset] = val
            inputY4.append(clf._forward_pass_fast([ network_input ])[0][0])
            
            network_input = get_inputs()
            network_input[55+enemy_offset] = val
            inputY5.append(clf._forward_pass_fast([ network_input ])[0][0])

            network_input = get_inputs()
            network_input[56+enemy_offset] = val
            inputY6.append(clf._forward_pass_fast([ network_input ])[0][0])

            network_input = get_inputs()
            network_input[57+enemy_offset] = val
            inputY7.append(clf._forward_pass_fast([ network_input ])[0][0])

        row = 0
        if (enemy): row = 1
        ax[row, 1].plot(inputX, inputY1, label="attack")
        ax[row, 1].plot(inputX, inputY2, label="def")
        ax[row, 1].plot(inputX, inputY3, label="special attack")
        ax[row, 1].plot(inputX, inputY4, label="special defense")
        ax[row, 1].plot(inputX, inputY5, label="speed")
        ax[row, 1].plot(inputX, inputY6, label="accuracy")
        ax[row, 1].plot(inputX, inputY7, label="evasion")
        ax[row, 1].legend()

        if (enemy):
            ax[row, 1].set(xlabel='enemy stats', ylabel='winrate')
        else:
            ax[row, 1].set(xlabel='stats', ylabel='winrate')

        ax[row, 1].grid()

    display_HP_versus_winrate(True)
    display_HP_versus_winrate(False)
    display_Boosts_versus_winrate(True)
    display_Boosts_versus_winrate(False)
    # plt.show()

    plt.gcf().set_size_inches(16, 12)
    plt.savefig(dir, dpi=300)