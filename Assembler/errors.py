def verifyComponentNumber(i_type, c_length):
    if((i_type == "U"  or i_type == "J") and c_length != 3):
        raise ValueError("The number of instructions does not match the instruction.")
    elif((i_type == "I"  or i_type == "I2" or i_type == "R" or i_type == "B" or i_type == "S") and c_length != 4):
        raise ValueError("The number of instructions does not match the instruction.")