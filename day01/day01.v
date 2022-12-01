import os
import arrays

fn main() {

	if !os.is_file('input.txt') {
		println('Cannot find input')
	}
	f := os.read_file('input.txt') or {
		println('Cannot open input')
		return
	}

	mut calories := []int{}

	for elve_calories_contents in f.split("\n\n") {
		mut elve_calories := 0
		for item in elve_calories_contents.split("\n") {
			elve_calories += item.int()
		}

		calories << elve_calories
	}

	calories.sort()

	println("p1: ${calories.last()}")
	println("p2: ${arrays.sum(calories#[-3..])?}")
}
