#!/bin/bash
echo $1

if [ $1 == "python" ]
then
    python3 python/bf.py bf/$2.bf
elif [ $1 == "cpp" ] || [ $1 == "c++" ]
then
    g++ cpp/bf.cpp && ./a.out bf/$2.bf
elif [ $1 == "go" ]
then
    go run go/bf.go bf/$2.bf
elif [ $1 == "java" ]
then
    cd java && javac Bf.java && java Bf ../bf/$2.bf
elif [ $1 == "js" ]
then
    node js/bf.js bf/$2.bf
elif [ $1 == "rust" ]
then
    cd rust && cargo run ../bf/$2.bf
elif [ $1 == "nim" ]
then
    nim c -r nim/bf.nim bf/$2.bf
fi
