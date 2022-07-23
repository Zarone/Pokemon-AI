
from tkinter import *

from input_data import get_inputs

def manual_test(clf):
    network_input = get_inputs()

    def get_output():
        return f"{clf._forward_pass_fast([ network_input ])[0][0]:.8f}"

    def value_change(args):
        newVal = int(boxes[args].get())
        newKey = args*30+65

        if (newVal < 1):
            network_input[newKey+29]=1
        else:
            network_input[newKey+29]=0

        network_input[newKey] = newVal
        msg.config(
            text=get_output(), 
            font=('sans-serif', 16),
            bg='#D97904'
        )

    def value_change_boost(args):
        newVal = int(statusBoxes[args].get())
        newKey = 51+args

        network_input[newKey] = newVal
        msg.config(
            text=get_output(), 
            font=('sans-serif', 16),
            bg='#D97904'
        )

    ws = Tk()
    ws.title('')
    ws.geometry('500x300')
    ws.config(bg='#3060a0')

    boxes = []

    for i in range(12):
        boxes.append(IntVar())
        boxes[i].set( network_input[65+i*30] )
        spin = Spinbox(
            ws,
            textvariable=boxes[i],
            from_=0, to=100,
            increment=5,
            width=5,
            command = lambda thisIncrement=i : value_change( thisIncrement ),
            font=('sans-serif', 18)
        )
        thisColumn = 1
        if (i < 6): thisColumn = 0
        thisRow = (i%6)+1
        spin.grid(column=thisColumn,row=thisRow)

    statusBoxes = []

    for i in range(14):
        statusBoxes.append(IntVar())
        statusBoxes[i].set( network_input[51+i] )
        spin = Spinbox(
            ws,
            textvariable=statusBoxes[i],
            from_=-6, to=6,
            increment=1,
            width=5,
            command = lambda thisIncrement=i : value_change_boost( thisIncrement ),
            font=('sans-serif', 18)
        )
        thisColumn = 3
        if (i < 7): thisColumn = 2
        thisRow = (i%7)+1
        spin.grid(column=thisColumn,row=thisRow)

    Label(
        ws,
        text="P1 HP", 
        font=('sans-serif', 16),
        bg='#D97904'
    ).grid(column=0,row=0)
    
    Label(
        ws,
        text="P2 HP", 
        font=('sans-serif', 16),
        bg='#D97904'
    ).grid(column=1,row=0)
    
    Label(
        ws,
        text="P1 Boosts", 
        font=('sans-serif', 13),
        bg='#D97904'
    ).grid(column=2,row=0)
    
    Label(
        ws,
        text="P2 Boosts", 
        font=('sans-serif', 13),
        bg='#D97904'
    ).grid(column=3,row=0)

    Label(
        ws,
        text="P1 Winrate", 
        font=('sans-serif', 14),
        bg='#D97904'
    ).grid(column=4,row=0)

    msg = Label(
        ws,
        text=get_output(), 
        font=('sans-serif', 16),
        bg='#D97904'
    )
    
    msg.grid(column=4,row=1)

    ws.mainloop()