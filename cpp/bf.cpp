#include <fstream>
#include <iostream>
#include <stack>
#include <unordered_map>
#include <vector>

bool is_file_exist(const char *filename) {
  std::ifstream infile(filename);
  return infile.good();
}

void change(std::vector<int> *tape, int pointer, int amount) {
  while (tape->size() <= pointer + 1) {
    tape->push_back(0);
  }

  (*tape)[pointer] = tape->at(pointer) + amount;
}

void increment(std::vector<int> *tape, int pointer) {
  change(tape, pointer, 1);
}

void decrement(std::vector<int> *tape, int pointer) {
  change(tape, pointer, -1);
}

bool is_zero(std::vector<int> *tape, int pointer) {
  change(tape, pointer, 0);
  return tape->at(pointer) == 0;
}

int main(int argc, char *argv[]) {
  if (argc != 2) {
    std::cout << "A simple BF interpreter.\n";
    std::cout << "Usage: \t g++ bf.cpp && ./a.out program.bf\n";
    return 0;
  }

  if (!is_file_exist(argv[1])) {
    std::cout << "A simple BF interpreter.\n";
    std::cout << "Usage: \t g++ bf.cpp && ./a.out program.bf\n";
    return 0;
  }

  std::ifstream bf_file(argv[1]);
  std::string line;
  std::vector<std::string> lines;
  while (std::getline(bf_file, line)) {
    lines.push_back(line);
  }

  int pointer = 0;
  std::vector<int> tape = {0};
  std::vector<char> program = {};
  unsigned int curr_loc = 0;
  int count_brackets = 0;
  std::unordered_map<int, int> jump_locs_rev = {};
  std::unordered_map<int, int> jump_locs_fwd = {};

  for (std::string line : lines) {
    for (const char &ch : line) {
      if (ch == '\n') {
        continue;
      }

      if (ch == '[') {
        count_brackets++;
      } else if (ch == ']') {
        count_brackets--;
      }

      program.push_back(ch);
    }
  }

  if (count_brackets != 0) {
    std::cout << "Invalid bracket syntax\n";
    return 0;
  }

  std::stack<int> loop_stack;
  int index = 0;
  for (char chr : program) {
    if (chr == '[') {
      loop_stack.push(index);
    } else if (chr == ']') {
      int v = loop_stack.top();
      loop_stack.pop();
      jump_locs_rev[index] = v;
      jump_locs_fwd[v] = index;
    }
    index++;
  }

  while (curr_loc < program.size()) {
    char chr = program.at(curr_loc);
    switch (chr) {
    case '<':
      pointer--;
      break;
    case '>':
      pointer++;
      break;
    case '+':
      increment(&tape, pointer);
      break;
    case '-':
      decrement(&tape, pointer);
      break;
    case '.':
      std::cout << static_cast<char>(tape.at(pointer));
      break;
    case ',':
      int user_input = 0;
      std::cin >> user_input;
      tape.insert(tape.begin() + pointer, user_input);
      break;
    }

    if (jump_locs_rev.find(curr_loc) != jump_locs_rev.end()) {
      if (!is_zero(&tape, pointer)) {
        curr_loc = jump_locs_rev.at(curr_loc) - 1;
      }
    } else if (jump_locs_fwd.find(curr_loc) != jump_locs_fwd.end()) {
      if (is_zero(&tape, pointer)) {
        curr_loc = jump_locs_fwd.at(curr_loc);
      }
    }

    curr_loc++;
  }

  std::cout << "\n";
}