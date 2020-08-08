package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"strings"
)

func Use(vals ...interface{}) {
	for _, val := range vals {
		_ = val
	}
}

func Change(tape *[]int, pointer int, amount int) {
	for len(*tape) <= pointer+1 {
		*tape = append(*tape, 0)
	}
	(*tape)[pointer] = (*tape)[pointer] + amount
}

func Increment(tape *[]int, pointer int) {
	Change(tape, pointer, 1)
}

func Decrement(tape *[]int, pointer int) {
	Change(tape, pointer, -1)
}

func IsZero(tape *[]int, pointer int) bool {
	Change(tape, pointer, 0)
	return (*tape)[pointer] == 0
}

func main() {
	args := os.Args

	if len(args) != 2 {
		fmt.Println("A simple BF interpreter.")
		fmt.Println("Usage: \t ./bf program.bf")
		os.Exit(0)
	}

	content, err := ioutil.ReadFile(args[1])
	if err != nil {
		fmt.Println("Unable to find file ", args[1])
		os.Exit(0)
	}

	lines := strings.Split(string(content), "\n")
	pointer, currLoc, countBrackets := 0, 0, 0

	var tape []int
	var program []rune
	jumpLocsRev := make(map[int]int)
	jumpLocsFwd := make(map[int]int)

	Use(pointer, currLoc, tape)

	for _, line := range lines {
		for _, ch := range line {
			if ch == '\n' {
				continue
			} else if ch == '[' {
				countBrackets++
			} else if ch == ']' {
				countBrackets--
			}

			program = append(program, ch)
		}
	}

	if countBrackets != 0 {
		fmt.Println("Invalid bracket syntax")
		os.Exit(0)
	}

	var loopStack []int
	for i, chr := range program {
		if chr == '[' {
			loopStack = append([]int{i}, loopStack...)
		} else if chr == ']' {
			var v int
			v, loopStack = loopStack[0], loopStack[1:]
			jumpLocsRev[i] = v
			jumpLocsFwd[v] = i
		}
	}

	for currLoc < len(program) {
		chr := program[currLoc]
		switch chr {
		case '<':
			pointer--
		case '>':
			pointer++
		case '+':
			Increment(&tape, pointer)
		case '-':
			Decrement(&tape, pointer)
		case '.':
			fmt.Print(string(tape[pointer]))
		}

		if val, ok := jumpLocsRev[currLoc]; ok {
			if !IsZero(&tape, pointer) {
				currLoc = val - 1
			}
		} else if val, ok := jumpLocsFwd[currLoc]; ok {
			if IsZero(&tape, pointer) {
				currLoc = val
			}
		}

		currLoc++
	}
}