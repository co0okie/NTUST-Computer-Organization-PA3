#!/usr/bin/env python3
import sys
import re

# Mapping of mnemonic to its encoding information.
# R-type: fields: opcode=0, then rs, rt, rd, shamt, funct.
# I-type: fields: opcode, rs, rt, immediate.
# J-type: fields: opcode, target.
instr_info = {
    "addu":  {"type": "R", "funct": 0x21},
    "subu":  {"type": "R", "funct": 0x23},
    "or":    {"type": "R", "funct": 0x25},
    # For sll, the standard syntax is "sll $rd, $rt, shamt", where rs is always 0.
    "sll":   {"type": "R", "funct": 0x00, "sll": True},
    
    "addiu": {"type": "I", "opcode": 0x09},
    "ori":   {"type": "I", "opcode": 0x0d},
    "sw":    {"type": "I", "opcode": 0x2b},
    "lw":    {"type": "I", "opcode": 0x23},
    # "beq":   {"type": "I", "opcode": 0x04},
    
    # "j":     {"type": "J", "opcode": 0x02},
}

def parse_register(reg_str):
    """
    Parse a register string like '$5' or '$zero' (only numeric registers supported).
    Returns integer register number.
    """
    reg_str = reg_str.strip()
    m = re.match(r'^\$(\d+)$', reg_str)
    if not m:
        sys.exit(f"Error: Invalid register format '{reg_str}'")
    reg_num = int(m.group(1))
    if reg_num < 0 or reg_num > 31:
        sys.exit(f"Error: Register out of range: '{reg_str}'")
    return reg_num

def parse_immediate(imm_str):
    """
    Parse immediate value supporting decimal or hex (with 0x prefix).
    """
    imm_str = imm_str.strip()
    try:
        if imm_str.startswith("0x") or imm_str.startswith("0X"):
            return int(imm_str, 16)
        else:
            return int(imm_str, 10)
    except ValueError:
        sys.exit(f"Error: Invalid immediate value: {imm_str}")

def assemble_line(line, lineno):
    """
    Assemble a single line of assembly. Returns a 32-bit integer instruction.
    If the instruction is not valid, exits with an error.
    """
    # Remove comments (anything after '#' or '//')
    line = line.split(';')[0].strip()
    if line == "":
        return None  # skip empty line

    # Tokenize by comma and whitespace.
    tokens = re.split(r'[,\s()]+', line)
    # Remove empty tokens.
    tokens = [t for t in tokens if t != ""]

    if len(tokens) == 0:
        return None

    mnemonic = tokens[0].lower()
    if mnemonic not in instr_info:
        sys.exit(f"Error on line {lineno}: Unsupported instruction '{mnemonic}'")

    info = instr_info[mnemonic]
    instr_type = info["type"]

    if instr_type == "R":
        # For R-type instructions.
        # Check if it is SLL (shift instruction): syntax: sll $rd, $rs, shamt
        if info.get("sll", False):
            if len(tokens) != 4:
                sys.exit(f"Error on line {lineno}: sll expects 3 operands")
            rd = parse_register(tokens[1])
            rs = parse_register(tokens[2])
            shamt = parse_immediate(tokens[3])
            rt = 0
        else:
            # Other R-type instructions: syntax: mnemonic $rd, $rs, $rt
            if len(tokens) != 4:
                sys.exit(f"Error on line {lineno}: {mnemonic} expects 3 operands")
            rd = parse_register(tokens[1])
            rs = parse_register(tokens[2])
            rt = parse_register(tokens[3])
            shamt = 0
        opcode = 0
        funct = info["funct"]
        # Build the 32-bit word:
        # [opcode(6) rs(5) rt(5) rd(5) shamt(5) funct(6)]
        instr = (opcode << 26) | (rs << 21) | (rt << 16) | (rd << 11) | (shamt << 6) | funct
        return instr

    elif instr_type == "I":
        opcode = info["opcode"]
        if mnemonic in ["sw", "lw"]:
            # Syntax: mnemonic $rt, imm($rs)
            if len(tokens) != 4:
                sys.exit(f"Error on line {lineno}: {mnemonic} improperly formatted")
            rt = parse_register(tokens[1])
            # tokens[2] should be immediate, and next token should be register,
            # but since we split on '(',')', the immediate and register become separate tokens.
            # We expect tokens[2] = immediate and tokens[3] = register.
            # However, if the format is different, throw an error.
            # Check if there is a register value after the immediate.
            # Look for pattern imm and a following register.
            # After splitting, the sequence should be: mnemonic, "$rt", "imm", "$rs"
            imm = parse_immediate(tokens[2])
            rs = parse_register(tokens[3])
        # elif mnemonic == "beq":
        #     # Syntax: beq $rs, $rt, Imm.
        #     if len(tokens) != 4:
        #         sys.exit(f"Error on line {lineno}: beq expects 3 operands")
        #     rs = parse_register(tokens[1])
        #     rt = parse_register(tokens[2])
        #     imm = parse_immediate(tokens[3])
        else:
            # Other I-type: addiu, ori
            # Syntax: mnemonic $rt, $rs, Imm.
            if len(tokens) != 4:
                sys.exit(f"Error on line {lineno}: {mnemonic} expects 3 operands")
            rt = parse_register(tokens[1])
            rs = parse_register(tokens[2])
            imm = parse_immediate(tokens[3])
        # Mask immediate to 16 bits (for negative numbers, two's complement)
        imm &= 0xFFFF
        instr = (opcode << 26) | (rs << 21) | (rt << 16) | imm
        return instr

    # elif instr_type == "J":
    #     # J-type: syntax: j Imm.
    #     if len(tokens) != 2:
    #         sys.exit(f"Error on line {lineno}: j expects 1 operand")
    #     opcode = info["opcode"]
    #     target = parse_immediate(tokens[1])
    #     # Use only lower 26 bits of target.
    #     target &= 0x03FFFFFF
    #     instr = (opcode << 26) | target
    #     return instr

    else:
        sys.exit(f"Error on line {lineno}: Unknown instruction type for '{mnemonic}'")

def main():
    if len(sys.argv) < 2:
        print("Usage: assembler.py input_asm_file [output_file]")
        sys.exit(1)
        
    input_filename = sys.argv[1]
    output_filename = sys.argv[2] if len(sys.argv) > 2 else "IM.dat"

    # Read and parse input assembly file.
    with open(input_filename, "r") as f:
        lines = f.readlines()

    # Build a list of (original assembly, assembled instruction)
    instr_list = []
    for lineno, orig_line in enumerate(lines, 1):
        line = orig_line.strip()
        # Skip empty lines or lines that start with comments.
        if line == "" or line.startswith("#"):
            continue
        instr = assemble_line(line, lineno)
        if instr is not None:
            instr_list.append((orig_line.strip(), instr))
    
    # Convert instructions to bytes (big endian) and prepare binary formatting.
    bytes_list = []
    inst_info = []  # Each element: (original assembly, binary formatted string, 4 bytes list)
    for orig, instr in instr_list:
        # Create a 32-bit binary string.
        binary_str = "{:032b}".format(instr)
        opcode = instr >> 26
        if opcode == 0:  # R-type: opcode(6) rs(5) rt(5) rd(5) shamt(5) funct(6)
            bin_formatted = (binary_str[0:6] + " " + binary_str[6:11] + " " +
                             binary_str[11:16] + " " + binary_str[16:21] + " " +
                             binary_str[21:26] + " " + binary_str[26:32])
        elif opcode == 0x02:  # J-type: opcode(6) target(26)
            bin_formatted = binary_str[0:6] + " " + binary_str[6:32]
        else:  # I-type: opcode(6) rs(5) rt(5) immediate(16)
            bin_formatted = (binary_str[0:6] + " " + binary_str[6:11] + " " +
                             binary_str[11:16] + " " + binary_str[16:32])
        b0 = (instr >> 24) & 0xFF
        b1 = (instr >> 16) & 0xFF
        b2 = (instr >> 8) & 0xFF
        b3 = instr & 0xFF
        bytes_for_instr = [b0, b1, b2, b3]
        bytes_list.extend(bytes_for_instr)
        inst_info.append((orig, bin_formatted, bytes_for_instr))

    # Total instruction memory size is 128 bytes.
    total_bytes = 128

    with open(output_filename, "w") as outf:
        outf.write("// Instruction Memory in Hex\n")
        addr = 0
        for orig, bin_formatted, instr_bytes in inst_info:
            outf.write("// " + orig + "\n")
            outf.write("// " + bin_formatted + "\n")
            for b in instr_bytes:
                outf.write("{:02X} // Addr = 0x{:02X}\n".format(b, addr))
                addr += 1

        # Pad the rest of the memory with 0xFF.
        while addr < total_bytes:
            outf.write("FF // Addr = 0x{:02X}\n".format(addr))
            addr += 1

if __name__ == "__main__":
    main()
