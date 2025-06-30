import re
from i_binaries_gen import determine_instruction_binaries, generate_instruction
from errors import verifyComponentNumber

line_n = 1
labels = {}

def process_labels(line):
    global line_n
    line = line.strip().split('#')[0].strip()  # Remove inline comments
    if not line:
        return
    label_match = re.match(r'^(\w+):$', line)  # Match labels like 'loop:'
    if label_match:
        label = label_match.group(1)
        hex_line = (line_n - 1) * 4
        labels[label] = hex_line
    else:
        line_n += 1

def process_assembly_line(line, output_file):
    global line_n
    line = line.strip().split('#')[0].strip()  # Remove inline comments
    print(f"Processing line {line_n}: {line}")
    if not line:
        return

    # Split the line into instruction and operands, handling offset(rs) syntax
    components = [comp.strip() for comp in re.split(r',\s*', line) if comp.strip()]
    if not components:
        return

    instruction = components[0].split()[0]
    operands = components[0].split()[1:] + components[1:] if len(components[0].split()) > 1 else components[1:]
    
    # Handle offset(rs) syntax for S-type and I-type instructions
    parsed_components = [instruction]
    for op in operands:
        # Match patterns like "0(s6)" or "123(a0)"
        offset_match = re.match(r'^([-]?0x[0-9a-fA-F]+|\d+|-\d+)\(([^)]+)\)$', op)
        if offset_match:
            offset = offset_match.group(1)  # e.g., "0", "-123", or "0x10"
            register = offset_match.group(2)  # e.g., "s6"
            parsed_components.extend([offset, register])
        else:
            parsed_components.append(op)

    print(f"Parsed components: {parsed_components}")
    
    if len(parsed_components) == 1:
        return

    try:
        instruction = parsed_components[0]
        instr_binaries = determine_instruction_binaries(instruction)
        print(f"Instruction type: {instr_binaries['type']}")
        print(f"Verifying components: {len(parsed_components)} for type {instr_binaries['type']}")
        verifyComponentNumber(instr_binaries['type'], len(parsed_components))
        binary_instruction = generate_instruction(instr_binaries, parsed_components, labels, (line_n - 1) * 4)
        print(f"Binary: {binary_instruction}")
        decimal_i = int(binary_instruction, 2)
        bytes_be = decimal_i.to_bytes(4, byteorder='big')  # Big endian
        for byte in bytes_be:
            output_file.write(f"{byte:02x}\n")
        line_n += 1
    except Exception as e:
        print(f"Error on line {line_n}: {line} - {e}")
        raise

def main():
    global line_n
    input_file_path = "assembly_code.asm"  # Change to test file path
    output_file_name = r'C:\Users\cgarg\Desktop\comp_arch\RISC V\main\i_mem.hex'

    # First pass: label resolution
    try:
        with open(input_file_path, "r") as input_file:
            for line in input_file:
                if line.strip():
                    process_labels(line)
        print(f"Labels: {labels}")
        line_n = 1  # Reset line number for second pass
    except FileNotFoundError:
        print(f"File '{input_file_path}' not found.")
        return
    except Exception as e:
        print(f"Error during label processing: {e}")
        return

    # Second pass: generate hex output
    try:
        with open(input_file_path, "r") as input_file, open(output_file_name, "w") as output_file:
            for line in input_file:
                if line.strip():
                    process_assembly_line(line, output_file)
        print(f"Binaries saved in '{output_file_name}'.")
    except FileNotFoundError:
        print(f"File '{input_file_path}' not found.")
    except Exception as e:
        print(f"Error during instruction processing: {e}")

if __name__ == "__main__":
    main()