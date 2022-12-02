import os
import arrays

fn main() {
	f := os.read_file('input_test.txt') or {
		println('Cannot open input')
		return
	}

	mut calories := f.split("\n\n").map(arrays.sum(it.split("\n").map(it.int()))!)

	calories.sort()

	println("p1: ${calories.last()}")
	println("p2: ${arrays.sum(calories#[-3..])?}")
}
