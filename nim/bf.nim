import os
import system
import tables
import strutils
import math

proc change(tape: var seq[int], pointr: int, amount: int) =
    while len(tape) <= pointr:
        tape.add(0)
    
    tape[pointr] = floorMod(tape[pointr] + amount, 255)  

proc increment(tape: var seq[int], pointr: int) =
    change(tape, pointr, 1)

proc decrement(tape: var seq[int], pointr: int) =
    change(tape, pointr, -1)

proc is_zero(tape: var seq[int], pointr: int): bool =
    change(tape, pointr, 0)
    return tape[pointr] == 0


proc main() =
    if paramCount() != 1:
        echo "A simple BF interpreter."
        echo "Usage: nim c -r bf.nim program.bf"
        quit(0)

    let filename = paramStr(1)
    if not fileExists(filename):
        echo "Could not find file ", filename
        quit(0)
    
    var pointr = 0
    var tape = newSeq[int]()
    tape.add(0)
    var program = newSeq[char]()
    var curr_loc = 0
    var count_brackets = 0
    var jump_locs_rev = initTable[int, int]()
    var jump_locs_fwd = initTable[int, int]()
    
    for line in lines(filename):
        for chr in line:
            if chr == '\n':
                continue

            if chr == '[':
                count_brackets += 1
            if chr == '[':
                count_brackets -= 1
            
            program.add(chr)

    if count_brackets != 0:
        echo "Invalid bracket [] syntax"
        quit(0)
    
    var loop_stack = newSeq[int]()
    for i, chr in program:
        if chr == '[':
            loop_stack.add(i)
        if chr == ']':
            var v = loop_stack.pop()
            jump_locs_rev[i] = v
            jump_locs_fwd[v] = i
    
    while curr_loc < len(program):
        case program[curr_loc]:
            of '>':
                pointr += 1
            of '<':
                pointr -= 1
            of '+':
                increment(tape, pointr)
            of '-':
                decrement(tape, pointr)
            of '.':
                stdout.write char(tape[pointr])
            of ',':
                tape[pointr] = readLine(stdin).parseInt()
            else:
                discard
        
        if jump_locs_rev.hasKey(curr_loc):
            if not is_zero(tape, pointr):
                curr_loc = jump_locs_rev[curr_loc] - 1
        elif jump_locs_fwd.hasKey(curr_loc):
            if is_zero(tape, pointr):
                curr_loc = jump_locs_fwd[curr_loc]

        curr_loc += 1


when is_main_module:
    main()
