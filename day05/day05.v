import os
import arrays

struct Crate {
mut:
	name  string
	stack int
	pos   int
}

fn main() {
	f := os.read_file('input.txt') or {
		println('Cannot open input')
		return
	}

	part1(f)
	part2(f)
}

fn part1(f string) {
	mut crates := parse_crates(f)

	for line in f.split('\n') {
		if line.contains('move') {
			// move them
			amount := line.split(' from')[0].split(' ').last().int()
			from_stack := line.split(' to')[0].split(' ').last().int()
			to_stack := line.split('to')[1].split(' ').last().int()

			for _ in 0 .. amount {
				crate := get_top(from_stack, crates)
				crates.delete(crates.index(crate))
				new_pos := get_top_pos(to_stack, crates) + 1
				new_crate := Crate{
					name: crate.name
					stack: to_stack
					pos: new_pos
				}
				crates << new_crate
			}
		}
	}

	mut rslt := ''
	for s in 1 .. get_stacks(crates) + 1 {
		rslt += get_top(s, crates).name
	}
	println(rslt)
}

fn part2(f string) {
	mut crates := parse_crates(f)

	for line in f.split('\n') {
		if line.contains('move') {
			// move them
			amount := line.split(' from')[0].split(' ').last().int()
			from_stack := line.split(' to')[0].split(' ').last().int()
			to_stack := line.split('to')[1].split(' ').last().int()

			new_pos := get_top_pos(to_stack, crates) + 1

			for offset in 0 .. amount {
				crate := get_top(from_stack, crates)
				crates.delete(crates.index(crate))

				new_crate := Crate{
					name: crate.name
					stack: to_stack
					pos: new_pos + amount - offset
				}
				crates << new_crate
			}
		}
	}

	mut rslt := ''
	for s in 1 .. get_stacks(crates) + 1 {
		rslt += get_top(s, crates).name
	}
	println(rslt)
}

fn parse_crates(f string) []Crate {
	reserved_runes := ['[', ']', ' ']
	mut crates := []Crate{}

	mut depth := 0
	for line in f.split('\n') {
		if line.contains('[') {
			depth += 1
		}
	}

	for line_idx, line in f.split('\n') {
		if line.contains('[') {
			// create the crates
			for index, c in line.runes() {
				if !reserved_runes.contains(c.str()) {
					stack := 1 + index / 4
					name := c.str()
					pos := depth - line_idx

					crates << Crate{
						name: name
						stack: stack
						pos: pos
					}
				}
			}
		}
	}
	return crates
}

fn get_top(stack_num int, crates []Crate) Crate {
	pos_max := get_top_pos(stack_num, crates)
	return crates.filter(it.stack == stack_num).filter(it.pos == pos_max).first()
}

fn get_top_pos(stack_num int, crates []Crate) int {
	return arrays.max(crates.filter(it.stack == stack_num).map(it.pos)) or { 0 }
}

fn get_stacks(crates []Crate) int {
	return arrays.max(crates.map(it.stack)) or { 0 }
}
