import os
import arrays

fn main() {
	f := os.read_file('input.txt') or {
		println('Cannot open input')
		return
	}

	mut scores := map[u8]int{}
	for index, item in 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ' {
		scores[item] = index + 1
	}

	scoring := fn [scores] (x u8) int {
		return scores[x]
	}

	part1(f, scoring)
	part2(f, scoring)
}

fn part1(f string, scoring fn (u8) int) {
	results := f.split('\n').map(fn (x string) u8 {
		comp1 := x[..x.len / 2].bytes()
		comp2 := x[x.len / 2..].bytes()
		return comp1.filter(it in comp2)[0]
	}).map(scoring(it))

	println('p1: ${arrays.sum(results) or { 0 }}')
}

fn part2(f string, scoring fn (u8) int) {
	results := arrays.chunk(f.split('\n'), 3).map(fn (x []string) u8 {
		e1 := x[0].bytes()
		e2 := x[1].bytes()
		e3 := x[2].bytes()
		return e1.filter(it in e2).filter(it in e3)[0]
	}).map(scoring(it))

	println('p2: ${arrays.sum(results) or { 0 }}')
}
