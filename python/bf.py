import sys
import os


def change(tape, pointer, amount):
    while len(tape) <= pointer:
        tape.append(0)
    
    tape[pointer] = (tape[pointer] + amount) % 255


def increment(tape, pointer):
    change(tape, pointer, 1)


def decrement(tape, pointer):
    change(tape, pointer, -1)

def is_zero(tape, pointer):
    change(tape, pointer, 0)
    return tape[pointer] == 0


def main():
    if len(sys.argv) != 2:
        print('A simple BF intepreter.')
        print('Usage: \t ./bf.py program.bf')
        exit(0)

    filename = sys.argv[1]
    if not os.path.isfile(filename):
        print(f'Could not find file {filename}')
        exit(0)
    
    file_contents = None
    with open(filename, 'r') as f:
        file_contents = f.readlines()
    
    pointer = 0
    tape = [0]
    program = []
    curr_loc = 0
    count_brackets = 0
    jump_locs_rev = {}
    jump_locs_fwd = {}

    for line in file_contents:
        for char in line:
            if char == '\n':
                continue

            if char == '[':
                count_brackets += 1
            if char == ']':
                count_brackets -= 1

            program.append(char)

    if count_brackets != 0:
        print('Invalid bracket [] syntax')
        exit(0)
    else:
        loop_stack = []
        for i, char in enumerate(program, start=0):
            if char == '[':
                loop_stack.append(i)
            if char == ']':
                v = loop_stack.pop()
                jump_locs_rev[i] = v
                jump_locs_fwd[v] = i

    while curr_loc < len(program):
        char = program[curr_loc]
        if char == '>':
            pointer += 1
        if char == '<':
            pointer -= 1
        if char == '+':
            increment(tape, pointer)
        if char == '-':
            decrement(tape, pointer)
        if char == '.':
            print(chr(tape[pointer]), end='')
        if char == ',':
            tape[pointer] = int(input())
        
        if curr_loc in jump_locs_rev.keys():
            if not is_zero(tape, pointer):
                curr_loc = jump_locs_rev[curr_loc] - 1
        elif curr_loc in jump_locs_fwd.keys():
            if is_zero(tape, pointer):
                curr_loc = jump_locs_fwd[curr_loc]
        
        curr_loc += 1

if __name__ == '__main__':
    main()