import os
import arrays

fn main() {
	f := os.read_file('input.txt') or {
		println('Cannot open input')
		return
	}

	mut calories := []int{}

	for elve_calories_contents in f.split("\n\n") {
		calories << arrays.sum(elve_calories_contents.split("\n").map(it.int()))!
	}

	calories.sort()

	println("p1: ${calories.last()}")
	println("p2: ${arrays.sum(calories#[-3..])?}")
}
