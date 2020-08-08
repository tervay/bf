import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.*;

public class Bf {
    public static void main(String[] args) throws IOException {
        if (args.length != 1) {
            System.out.println("A simple BF interpreter.");
            System.out.println("Usage: \t ./Bf.java program.bf");
            System.exit(0);
        }

        String filename = args[0];
        File file = new File(filename);
        if (!file.exists() || file.isDirectory()) {
            System.out.println("Could not find file " + filename);
            System.exit(0);
        }

        List<String> fileContents = Files.readAllLines(Paths.get(filename));

        int pointer = 0, currLoc = 0, countBrackets = 0;
        ArrayList<Integer> tape = new ArrayList<>();
        ArrayList<String> program = new ArrayList<>();
        HashMap<Integer, Integer> jumpLocsRev = new HashMap<>();
        HashMap<Integer, Integer> jumpLocsFwd = new HashMap<>();
        Scanner sc = new Scanner(System.in);

        for (String line : fileContents) {
            for (char ch : line.toCharArray()) {
                String chr = "" + ch;
                if (chr.equals("\n")) {
                    continue;
                }

                if (chr.equals("[")) {
                    countBrackets++;
                }
                if (chr.equals("]")) {
                    countBrackets--;
                }

                program.add(chr);
            }
        }

        if (countBrackets != 0) {
            System.out.println("Invalid bracket [] syntax");
            System.exit(0);
        }

        Stack<Integer> loopStack = new Stack<>();
        ListIterator<String> it = program.listIterator();
        while (it.hasNext()) {
            int i = it.nextIndex();
            String chr = it.next();

            if (chr.equals("[")) {
                loopStack.push(i);
            }
            if (chr.equals("]")) {
                int v = loopStack.pop();
                jumpLocsRev.put(i, v);
                jumpLocsFwd.put(v, i);
            }
        }

        while (currLoc < program.size()) {
            String chr = program.get(currLoc);
            switch (chr) {
                case "<":
                    pointer--;
                    break;
                case ">":
                    pointer++;
                    break;
                case "+":
                    increment(tape, pointer);
                    break;
                case "-":
                    decrement(tape, pointer);
                    break;
                case ".":
                    System.out.print((char) tape.get(pointer).intValue());
                    break;
                case ",":
                    tape.set(pointer, Integer.parseInt(sc.nextLine()));
                    break;
            }

            if (jumpLocsRev.containsKey(currLoc)) {
                if (!isZero(tape, pointer)) {
                    currLoc = jumpLocsRev.get(currLoc) - 1;
                }
            } else if (jumpLocsFwd.containsKey(currLoc)) {
                if (isZero(tape, pointer)) {
                    currLoc = jumpLocsFwd.get(currLoc);
                }
            }

            currLoc++;
        }
    }

    private static void change(List<Integer> tape, int pointer, int amount) {
        while (tape.size() <= pointer + 1) {
            tape.add(0);
        }

        tape.set(pointer, tape.get(pointer) + amount);
    }

    private static void increment(List<Integer> tape, int pointer) {
        change(tape, pointer, 1);
    }

    private static void decrement(List<Integer> tape, int pointer) {
        change(tape, pointer, -1);
    }

    private static boolean isZero(List<Integer> tape, int pointer) {
        change(tape, pointer, 0);
        return tape.get(pointer) == 0;
    }
}