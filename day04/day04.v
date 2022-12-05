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
	results := f.split('\n').map(fn (x string) int {
		assignments := x.split(',')
		a1 := assignments[0].split('-')[0].int()
		a2 := assignments[0].split('-')[1].int()
		b1 := assignments[1].split('-')[0].int()
		b2 := assignments[1].split('-')[1].int()

		if a1 <= b1 && b2 <= a2 {
			return 1
		} else if b1 <= a1 && a2 <= b2 {
			return 1
		} else {
			return 0
		}
	})

	println('p1: ${arrays.sum(results) or { 0 }}')
}

fn part2(f string) {
	results := f.split('\n').map(fn (x string) int {
		assignments := x.split(',')
		a1 := assignments[0].split('-')[0].int()
		a2 := assignments[0].split('-')[1].int()
		b1 := assignments[1].split('-')[0].int()
		b2 := assignments[1].split('-')[1].int()

		if a1 <= b1 && b1 <= a2 {
			return 1
		} else if a1 <= b2 && b2 <= a2 {
			return 1
		} else if b1 <= a1 && a1 <= b1 {
			return 1
		} else if b1 <= a2 && a2 <= b2 {
			return 1
		} else {
			return 0
		}
	})

	println('p2: ${arrays.sum(results) or { 0 }}')
}
