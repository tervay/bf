const fs = require("fs");
const readline = require("readline");

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
})

function change(tape, pointer, amount) {
    while (tape.length <= pointer) {
        tape.push(0);
    }

    tape[pointer] = (tape[pointer] + amount) % 255;
}

function increment(tape, pointer) {
    change(tape, pointer, 1);
}

function decrement(tape, pointer) {
    change(tape, pointer, -1);
}

function isZero(tape, pointer) {
    change(tape, pointer, 0);
    return tape[pointer] == 0;
}

function main() {
    if (process.argv.length != 3) {
        console.log("A simple BF interpreter.");
        console.log("Usage: \t node bf.js program.bf");
        process.exit(0);
    }

    const filename = process.argv[2];
    if (!fs.existsSync(filename)) {
        console.log(`Could not find file ${filename}`);
        process.exit(0);
    }

    const fileContents = fs.readFileSync(filename, "utf8");

    let pointer = 0;
    let tape = [0];
    let program = [];
    let currLoc = 0;
    let countBrackets = 0;
    let jumpLocsRev = {};
    let jumpLocsFwd = {};

    for (let line of fileContents) {
        for (let char of line) {
            if (char === "\n") {
                continue;
            }

            if (char === "[") {
                countBrackets++;
            }
            if (char === "]") {
                countBrackets--;
            }

            program.push(char);
        }
    }

    if (countBrackets !== 0) {
        console.log("Invalid bracket [] syntax");
        process.exit(0);
    }

    let loopStack = [];
    program.map((char, i) => {
        if (char === "[") {
            loopStack.push(i);
        }
        if (char === "]") {
            const v = loopStack.pop();
            jumpLocsRev[i] = v;
            jumpLocsFwd[v] = i;
        }
    });

    while (currLoc <= program.length) {
        const char = program[currLoc];
        if (char === ">") {
            pointer++;
        }
        if (char === "<") {
            pointer--;
        }
        if (char === "+") {
            increment(tape, pointer);
        }
        if (char === "-") {
            decrement(tape, pointer);
        }
        if (char === ".") {
            process.stdout.write(String.fromCharCode(tape[pointer]));
        }
        if (char === ",") {
            rl.question("", (input) => {
                tape[pointer] = Number(input);
            });
        }

        if (currLoc in jumpLocsRev) {
            if (!isZero(tape, pointer)) {
                currLoc = jumpLocsRev[currLoc] - 1;
            }
        } else if (currLoc in jumpLocsFwd) {
            if (isZero(tape, pointer)) {
                currLoc = jumpLocsFwd[currLoc];
            }
        }

        currLoc++;
    }
}

main();
process.exit();