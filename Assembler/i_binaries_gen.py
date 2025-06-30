def determine_func3(instruction):                   
    type_i_ld = ["lb", "lh", "lw", "lbu", "lhu"]  # I_type_load
    type_i_alu = ["addi", "slli", "slti", "sltiu", "xori", "srli", "srai", "ori", "andi"]  # I_type_alu
    type_s = ["sb", "sh", "sw"]  # S_type           
    type_r = ["add", "sub", "sll", "slt", "sltu", "xor", "srl", "sra", "or", "and"]
    type_r_mul = ["mul", "mulh", "mulsu", "mulu", "div", "divu", "rem", "remu"]
    type_b = ["beq", "bne", "blt", "bge", "bltu", "bgeu"]

    if instruction in type_i_ld:
        index = type_i_ld.index(instruction)
        if index == 3 or index == 4:
            index += 1
        return format(index, '03b')

    elif instruction in type_i_alu:
        index = type_i_alu.index(instruction)
        if index == 6 or index == 7 or index == 8:
            index -= 1
        return format(index, '03b')

    elif instruction in type_s:
        return format(type_s.index(instruction), '03b')

    elif instruction in type_r:
        index = type_r.index(instruction)
        if index >= 1:
            index -= 1
        if index >= 6:
            index -= 1
        return format(index, '03b')

    elif instruction in type_r_mul:
        return format(type_r_mul.index(instruction), '03b')  # direct mapping

    elif instruction in type_b:
        index = type_b.index(instruction)
        if index >= 2:
            index += 2
        return format(index, '03b')

    elif instruction == "jal":
        return format(0, '03b')

    else:
       return format(0, '03b')


def determine_func7(instruction):
    alu_ops = ["slli", "srli", "add", "sll", "slt", "sltu", "xor", "srl", "or", "and"]

    if instruction in alu_ops:
        return "0000000"
    elif instruction in ["srai", "sub", "sra"]:
        return "0100000"
    elif instruction in ["mul", "mulh", "mulsu", "mulu", "div", "divu", "rem", "remu"]:
        return "0000001"
    else:
        return None


def determine_instruction_binaries(instruction):
    func7 = determine_func7(instruction)
    func3 = determine_func3(instruction)

    if instruction in ["lb", "lh", "lw", "lbu", "lhu"]:
        i_type = "I_ld"
        i_bin = "0000011"

    elif instruction in ["addi", "slli", "slti", "sltiu", "xori", "srli", "srai", "ori", "andi"]:
        i_type = "I_alu"
        i_bin = "0010011"

    elif instruction in ["auipc"]:
        i_type = "U"
        i_bin = "0010111"

    elif instruction in ["sb", "sh", "sw"]:
        i_type = "S"
        i_bin = "0100011"

    elif instruction in ["add", "sub", "sll", "slt", "sltu", "xor", "srl", "sra", "or", "and",
                        "mul", "mulh", "mulsu", "mulu", "div", "divu", "rem", "remu"]:
        i_type = "R"
        i_bin = "0110011"

    elif instruction in ["lui"]:
        i_type = "U"
        i_bin = "0110111"

    elif instruction in ["beq", "bne", "blt", "bge", "bltu", "bgeu"]:
        i_type = "B"
        i_bin = "1100011"

    elif instruction in ["jalr"]:
        i_type = "I_jalr"
        i_bin = "1100111"

    elif instruction in ["jal"]:
        i_type = "J"
        i_bin = "1101111"

    else:
        raise ValueError("Unknown instruction, please check the program!")

    return {
        "type": i_type,
        "op": i_bin,
        "func3": func3,
        "func7": func7
    }


def register_to_binary(register):
    conventions = {
        "zero": 0, "ra": 1, "sp": 2, "gp": 3, "tp": 4,
        "t0": 5, "t1": 6, "t2": 7, "s0": 8, "fp": 8,
        "s1": 9, "a0": 10, "a1": 11, "a2": 12, "a3": 13,
        "a4": 14, "a5": 15, "a6": 16, "a7": 17, "s2": 18,
        "s3": 19, "s4": 20, "s5": 21, "s6": 22, "s7": 23,
        "s8": 24, "s9": 25, "s10": 26, "s11": 27, "t3": 28,
        "t4": 29, "t5": 30, "t6": 31
    }

    if register in conventions:
        register_number = conventions[register]
    else:
        cleaned_register = register.replace('x', '').replace(',', '')
        register_number = int(cleaned_register)

    if register_number > 31:
        raise ValueError("Invalid register")

    return format(register_number, '05b')


def component_to_binary(length, component):
    try:
        # Check if the component is a hexadecimal string (starts with 0x or 0X)
        if isinstance(component, str) and component.lower().startswith('0x'):
            register_number = int(component, 16)  # Convert hex to integer
        else:
            # Treat as decimal (handles positive and negative numbers)
            register_number = int(component)
    except ValueError:
        raise ValueError(f"Invalid immediate value: {component}")

    # Check if the number fits within the signed range for the given bit width
    max_positive = 2 ** (length - 1) - 1
    min_negative = -2 ** (length - 1)
    if register_number > max_positive or register_number < min_negative:
        raise ValueError(f"Number {register_number} exceeds {length}-bit signed range [{min_negative}, {max_positive}].")

    # Handle negative numbers using two's complement
    if register_number < 0:
        register_number = (1 << length) + register_number
    return format(register_number, f'0{length}b')


def generate_instruction(i_binaries, i_components, labels, line): 
    if i_binaries['type'] == "I_alu":
        imm = component_to_binary(12, i_components[3])
        rs1 = register_to_binary(i_components[2])
        rd = register_to_binary(i_components[1])
        return f"{imm}{rs1}{i_binaries['func3']}{rd}{i_binaries['op']}"
    
    elif i_binaries['type'] == "I_ld":
        imm = component_to_binary(12, i_components[2])
        rs1 = register_to_binary(i_components[3])
        rd = register_to_binary(i_components[1])
        return f"{imm}{rs1}{i_binaries['func3']}{rd}{i_binaries['op']}"


    elif i_binaries['type'] == "I_jalr":
        if i_components[0] == "jalr":
            imm = component_to_binary(12, i_components[3])
            rs1 = register_to_binary(i_components[2])
            rd = register_to_binary(i_components[1])
        
        return f"{imm}{rs1}{i_binaries['func3']}{rd}{i_binaries['op']}"

    elif i_binaries['type'] == "U":
        imm = component_to_binary(20, i_components[2])
        rd = register_to_binary(i_components[1])
        return f"{imm}{rd}{i_binaries['op']}"

    elif i_binaries['type'] == "S":
        imm = component_to_binary(12, i_components[2])
        rs1 = register_to_binary(i_components[3])
        rs2 = register_to_binary(i_components[1])
        return f"{imm[0:7]}{rs2}{rs1}{i_binaries['func3']}{imm[7:12]}{i_binaries['op']}"

    elif i_binaries['type'] == "R":
        rd = register_to_binary(i_components[1])
        rs1 = register_to_binary(i_components[2])
        rs2 = register_to_binary(i_components[3])
        return f"{i_binaries['func7']}{rs2}{rs1}{i_binaries['func3']}{rd}{i_binaries['op']}"

    elif i_binaries['type'] == "B":
        label = i_components[3]
        imm_calc = labels[label] - line
        imm = component_to_binary(13, imm_calc)
        rs2 = register_to_binary(i_components[2])
        rs1 = register_to_binary(i_components[1])
        return f"{imm[0]}{imm[2:8]}{rs2}{rs1}{i_binaries['func3']}{imm[8:12]}{imm[1]}{i_binaries['op']}"

    elif i_binaries['type'] == "J":
        label = i_components[2]
        imm_calc = labels[label] - line
        imm = component_to_binary(21, imm_calc)
        rd = register_to_binary(i_components[1])
        return f"{imm[0]}{imm[10:20]}{imm[9]}{imm[1:9]}{rd}{i_binaries['op']}"