# Tiny RISC-V Compiler

![Tiny RISC-V Compiler Logo](https://keep-it-simple.com/images/riscv-logo-1.png) <!-- Replace with an actual image link or remove if not needed -->

## Overview

The **Tiny RISC-V Compiler** is a minimalist yet powerful tool that transforms RISC-V assembly code into binary or hexadecimal machine instructions. Whether you're a student, a hobbyist, or an experienced developer, this compiler is designed to be simple, intuitive, and easy to integrate into your projects.

## Key Features

- **Complete RISC-V Instruction Set Support**: Covers all standard instructions, ensuring compatibility with a wide range of RISC-V assembly code.
- **Label Handling**: Automatically resolves labels, making your assembly code more readable and easier to manage.
- **Binary/Hexadecimal Output**: Choose between binary or hexadecimal output formats to suit your specific needs.
- **Lightweight & Fast**: Minimal dependencies and rapid compilation make this tool ideal for quick iterations and small projects.

## Getting Started

### Prerequisites

Before using the Tiny RISC-V Compiler, ensure you have the following installed:

- **Python 3.x**

### Installation

- Clone the repository:
    ```bash
    git clone https://github.com/Areshkew/tiny-risc-v.git
    cd tiny-risc-v
    ```

### Usage

To use the Tiny RISC-V Compiler:

1. **Edit Your Assembly Code:**

   - Modify the content of the `assembly_code.asm` file with your RISC-V assembly instructions.

2. **Compile the Assembly Code:**

    Run the following command to compile your assembly code:

    ```bash
    python3 main.py
    ```

3. **Output:**

    The compiled binary or hexadecimal output will be generated and saved in the `program.mem` file.

### Example

Here's an example of editing and compiling a simple RISC-V assembly program:

```assembly
main:
    add x1, x2, x3
    beq x1, x4, label1
    nop

label1:
    sub x5, x6, x7
```

1. **Edit**: Place the above code in `assembly_code.asm`.
2. **Compile**: Use the command:
    ```bash
    python3 main.py
    ```
3. **Result**: The hexadecimal instructions will be saved in `program.mem`.

### Supported Instructions

The Tiny RISC-V Compiler supports the full suite of standard RISC-V instructions, including:

- **Arithmetic**: `add`, `sub`, `mul`, etc.
- **Logical**: `and`, `or`, `xor`, etc.
- **Branching**: `beq`, `bne`, `blt`, etc.
- **Memory Operations**: `lw`, `sw`, `ld`, `sd`, etc.
- **Shift Operations**: `sll`, `srl`, `sra`, etc.
- **Control**: `jal`, `jalr`, `ebreak`, etc.

### Contributing

We welcome contributions from the community! If you'd like to contribute:

1. Fork the repository.
2. Create a new branch for your feature/bugfix.
3. Submit a pull request with a detailed description of your changes.

### License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

A special thanks to the RISC-V community and all contributors who made this project possible.

---

Happy coding! 🚀