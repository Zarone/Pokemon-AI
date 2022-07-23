
from matplotlib import pyplot as plt

from input_data import get_inputs

def graph(clf, dir=None):
    fig, ax = plt.subplots(nrows=2, ncols=2)

    def display_HP_versus_winrate(enemy=True, col=0, row=0, input_index=0):
        inputX = [i for i in range(100, -2, -1)]
        inputY1 = []
        inputY3 = []
        inputY5 = []
        inputYActive = []
        inputY1Active = []
        inputY3Active = []
        inputY5Active = []

        for val in inputX:

            enemy_offset=0
            if enemy: enemy_offset = 180

            network_input = get_inputs(input_index)
            network_input[95+enemy_offset] = val
            if val<1:
                network_input[124+enemy_offset] = 1
            inputY1.append(clf._forward_pass_fast([ network_input ])[0][0])

            network_input = get_inputs(input_index)
            network_input[95+enemy_offset] = val
            network_input[125+enemy_offset] = val
            network_input[155+enemy_offset] = val
            if val<1:
                network_input[124+enemy_offset] = 1
                network_input[154+enemy_offset] = 1
                network_input[184+enemy_offset] = 1
            inputY3.append(clf._forward_pass_fast([ network_input ])[0][0])
            
            network_input = get_inputs(input_index)
            network_input[95+enemy_offset] = val
            network_input[125+enemy_offset] = val
            network_input[155+enemy_offset] = val
            network_input[185+enemy_offset] = val
            network_input[215+enemy_offset] = val
            if val<1:
                network_input[124+enemy_offset] = 1
                network_input[154+enemy_offset] = 1
                network_input[184+enemy_offset] = 1
                network_input[214+enemy_offset] = 1
                network_input[244+enemy_offset] = 1
            inputY5.append(clf._forward_pass_fast([ network_input ])[0][0])

            network_input = get_inputs(input_index)
            network_input[65+enemy_offset] = val
            network_input[95+enemy_offset] = val
            network_input[125+enemy_offset] = val
            network_input[155+enemy_offset] = val
            network_input[185+enemy_offset] = val
            network_input[215+enemy_offset] = val
            if val<1:
                network_input[94+enemy_offset] = 1
                network_input[124+enemy_offset] = 1
                network_input[154+enemy_offset] = 1
                network_input[184+enemy_offset] = 1
                network_input[214+enemy_offset] = 1
                network_input[244+enemy_offset] = 1
            inputY5Active.append(clf._forward_pass_fast([ network_input ])[0][0])

            network_input = get_inputs(input_index)
            network_input[65+enemy_offset] = val
            network_input[95+enemy_offset] = val
            network_input[125+enemy_offset] = val
            network_input[155+enemy_offset] = val
            if val<1:
                network_input[94+enemy_offset] = 1
                network_input[124+enemy_offset] = 1
                network_input[154+enemy_offset] = 1
                network_input[184+enemy_offset] = 1
            inputY3Active.append(clf._forward_pass_fast([ network_input ])[0][0])


            network_input = get_inputs(input_index)
            network_input[65+enemy_offset] = val
            network_input[95+enemy_offset] = val
            if val<1:
                network_input[94+enemy_offset] = 1
                network_input[124+enemy_offset] = 1
            inputY1Active.append(clf._forward_pass_fast([ network_input ])[0][0])

            network_input = get_inputs(input_index)
            network_input[65+enemy_offset] = val
            inputYActive.append(clf._forward_pass_fast([ network_input ])[0][0])

        ax[row, col].plot(inputX, inputY1, label="1 pokemon")
        ax[row, col].plot(inputX, inputY3, label="3 pokemon")
        ax[row, col].plot(inputX, inputY5, label="5 pokemon")
        ax[row, col].plot(inputX, inputYActive, label="active")
        ax[row, col].plot(inputX, inputY1Active, label="1 pokemon + active")
        ax[row, col].plot(inputX, inputY3Active, label="3 pokemon + active")
        ax[row, col].plot(inputX, inputY5Active, label="5 pokemon + active")
        ax[row, col].legend()

        if (enemy):
            ax[row, col].set(xlabel='enemy hp (input index {0})'.format(input_index), ylabel='winrate')
        else:
            ax[row, col].set(xlabel='hp (input index {0})'.format(input_index), ylabel='winrate')

        ax[row, col].grid()

    def display_Boosts_versus_winrate(enemy=True, col=0, row=0, input_index=0):
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

            network_input = get_inputs(input_index)
            network_input[51+enemy_offset] = val
            inputY1.append(clf._forward_pass_fast([ network_input ])[0][0])

            network_input = get_inputs(input_index)
            network_input[52+enemy_offset] = val
            inputY2.append(clf._forward_pass_fast([ network_input ])[0][0])
            
            network_input = get_inputs(input_index)
            network_input[53+enemy_offset] = val
            inputY3.append(clf._forward_pass_fast([ network_input ])[0][0])
            
            network_input = get_inputs(input_index)
            network_input[54+enemy_offset] = val
            inputY4.append(clf._forward_pass_fast([ network_input ])[0][0])
            
            network_input = get_inputs(input_index)
            network_input[55+enemy_offset] = val
            inputY5.append(clf._forward_pass_fast([ network_input ])[0][0])

            network_input = get_inputs(input_index)
            network_input[56+enemy_offset] = val
            inputY6.append(clf._forward_pass_fast([ network_input ])[0][0])

            network_input = get_inputs(input_index)
            network_input[57+enemy_offset] = val
            inputY7.append(clf._forward_pass_fast([ network_input ])[0][0])

        row = 0
        if (enemy): row = 1
        ax[row, col].plot(inputX, inputY1, label="attack")
        ax[row, col].plot(inputX, inputY2, label="def")
        ax[row, col].plot(inputX, inputY3, label="special attack")
        ax[row, col].plot(inputX, inputY4, label="special defense")
        ax[row, col].plot(inputX, inputY5, label="speed")
        ax[row, col].plot(inputX, inputY6, label="accuracy")
        ax[row, col].plot(inputX, inputY7, label="evasion")
        ax[row, col].legend()

        if (enemy):
            ax[row, col].set(xlabel='enemy stats (input index {0})'.format(input_index), ylabel='winrate')
        else:
            ax[row, col].set(xlabel='stats (input index {0})'.format(input_index), ylabel='winrate')

        ax[row, col].grid()

    

    display_HP_versus_winrate(enemy=True, col=0, row=1, input_index=0)
    display_HP_versus_winrate(enemy=False, col=0, row=0, input_index=0)
    # display_HP_versus_winrate(enemy=True, col=1, row=1, input_index=1)
    # display_HP_versus_winrate(enemy=False, col=1, row=0, input_index=1)
    display_Boosts_versus_winrate(enemy=True, col=1, row=0, input_index=0)
    display_Boosts_versus_winrate(enemy=False, col=1, row=1, input_index=0)
    
    if dir:
        plt.gcf().set_size_inches(16, 12)
        plt.savefig(dir, dpi=300)
    else:
        plt.show()

    
