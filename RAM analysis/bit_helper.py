def get_bits(num):
    bits = []
    for i in range(8):
        bit = 7 - i
        bits.append(int(bool(num & 1 << bit)))
    return(bits)

def get_bits_array(array):
    bit_array = []
    for num in array:
        for bit in get_bits(num):
            bit_array.append(bit)
    return bit_array