use std::collections::HashMap;
use std::env;
use std::fs;
use std::process;

fn change(tape: &mut Vec<i32>, pointer: i32, amount: i32) {
    while tape.len() <= (pointer as usize) + 1 {
        tape.push(0);
    }

    tape[pointer as usize] = tape[pointer as usize] + amount
}

fn increment(tape: &mut Vec<i32>, pointer: i32) {
    change(tape, pointer, 1);
}

fn decrement(tape: &mut Vec<i32>, pointer: i32) {
    change(tape, pointer, -1);
}

fn is_zero(tape: &mut Vec<i32>, pointer: i32) -> bool {
    change(tape, pointer, 0);
    tape[pointer as usize] == 0
}

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() != 2 {
        println!("A simple BF interpreter.");
        println!("Usage: \t cargo run program.bf");
        process::exit(0);
    }

    let filename = &args[1];
    let contents = fs::read_to_string(filename).expect("Invalid file specified");
    let mut pointer: i32 = 0;
    let mut curr_loc: i32 = 0;
    let mut count_brackets: i32 = 0;
    let mut tape: Vec<i32> = Vec::new();
    let mut program: Vec<String> = Vec::new();
    let mut jump_locs_rev: HashMap<i32, i32> = HashMap::new();
    let mut jump_locs_fwd: HashMap<i32, i32> = HashMap::new();

    for line in contents.split("\n") {
        for chr in line.chars() {
            if chr == '[' {
                count_brackets += 1;
            } else if chr == ']' {
                count_brackets -= 1;
            }

            program.push(chr.to_string());
        }
    }

    if count_brackets != 0 {
        println!("Invalid bracket syntax");
        process::exit(0);
    }

    let mut loop_stack: Vec<i32> = Vec::new();
    for (i, chr) in program.iter().enumerate() {
        if chr == "[" {
            loop_stack.insert(0, i as i32);
        } else if chr == "]" {
            let v: i32 = loop_stack[0];
            loop_stack.remove(0);
            jump_locs_rev.insert(i as i32, v);
            jump_locs_fwd.insert(v, i as i32);
        }
    }

    while (curr_loc as usize) < program.len() {
        let chr = &(program[curr_loc as usize]);
        match chr.as_ref() {
            "<" => pointer -= 1,
            ">" => pointer += 1,
            "+" => increment(&mut tape, pointer),
            "-" => decrement(&mut tape, pointer),
            "." => print!("{}", tape[pointer as usize] as u8 as char),
            _ => print!(""),
        }

        if jump_locs_rev.contains_key(&curr_loc) {
            if !is_zero(&mut tape, pointer) {
                match jump_locs_rev.get(&curr_loc) {
                    Some(&loc) => curr_loc = loc - 1,
                    _ => panic!("Missing rev jump location"),
                }
            }
        } else if jump_locs_fwd.contains_key(&curr_loc) {
            if is_zero(&mut tape, pointer) {
                match jump_locs_fwd.get(&curr_loc) {
                    Some(&loc) => curr_loc = loc,
                    _ => panic!("Missing fwd jump location"),
                }
            }
        }

        curr_loc += 1;
    }
}