import os

struct State {
	x          int
	cpu_cycles int
	part1      int
	part2      string
}

fn (a State) apply_command(cmd string) State {
	mut new_cpu_cycles := a.cpu_cycles
	mut new_part1 := a.part1
	mut new_part2 := a.part2

	ops_cycles := if cmd == 'noop' { 1 } else { 2 }
	add := if cmd[..1] == 'a' { cmd.split(' ').last().int() } else { 0 }

	for _ in 0 .. ops_cycles {
		new_cpu_cycles += 1
		if new_cpu_cycles in [20, 60, 100, 140, 180, 220] {
			new_part1 += new_cpu_cycles * a.x
		}

		if (new_cpu_cycles % 40) - 1 in [a.x - 1, a.x , a.x + 1] {
			new_part2 += '#'
		} else {
			new_part2 += '.'
		}

		if new_cpu_cycles % 40 == 0 && new_cpu_cycles > 1 {
			new_part2 += '\n'
		}
	}

	return State{a.x + add, new_cpu_cycles, new_part1, new_part2}
}

fn main() {
	f := os.read_file('input.txt') or {
		println('Cannot open input')
		return
	}

	mut state := State{
		x: 1
		cpu_cycles: 0
		part1: 0
		part2: ''
	}

	for line in f.split('\n') {
		state = state.apply_command(line)
	}
	println('p1 ${state.part1}')
	println('p2 \n${state.part2}')
}
