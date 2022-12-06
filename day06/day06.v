import os
import arrays

fn main() {
	f := os.read_file('input.txt') or {
		println('Cannot open input')
		return
	}

	part1(f)
	part2(f)
}

fn part1(f string) {
	println("p1 ${solve(f, 4)}")
}

fn part2(f string) {
	println("p2 ${solve(f, 14)}")
}

fn solve(f string, amount int) int {
	for index in 0..f.len {
		chunk := f[index..index+amount].runes()
	    different_char_amount := arrays.group_by(chunk, fn (v rune) rune { return v }).len
		if different_char_amount == amount {
			return index + amount
		}
	}
	return 0
}
