
from tkinter import *

def manual_test(clf, network_input):

    def get_output():
        return f"{clf._forward_pass_fast([ network_input ])[0][0]:.8f}"

    def value_change(args):
        newVal = int(boxes[args].get())
        newKey = args*30+65

        if (newVal < 1):
            network_input[newKey+29]=0
        else:
            network_input[newKey+29]=1

        network_input[newKey] = newVal
        msg.config(
            text=get_output(), 
            font=('sans-serif', 16),
            bg='#D97904'
        )

    ws = Tk()
    ws.title('')
    ws.geometry('400x400')
    ws.config(bg='#3060a0')

    boxes = []

    for i in range(12):
        boxes.append(IntVar())
        boxes[i].set( network_input[65+i*30] )
        spin = Spinbox(
            ws,
            textvariable=boxes[i],
            from_=0, to=100,
            increment=25,
            width=5,
            command = lambda thisIncrement=i : value_change( thisIncrement ),
            font=('sans-serif', 18)
        )
        thisColumn = 1
        if (i < 6): thisColumn = 0
        thisRow = i%6
        spin.grid(column=thisColumn,row=thisRow)

    msg = Label(
        ws,
        text=get_output(), 
        font=('sans-serif', 16),
        bg='#D97904'
    )

    msg.grid(row=7)

    ws.mainloop()