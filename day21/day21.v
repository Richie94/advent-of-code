import os { read_file }
import math {abs, max, min}

fn main() {
	file_name := "input.txt"
	println("Part 1 ${part1(file_name) or {0}}")
	println("Part 2 ${part2(file_name) or {0}}")
}

struct Formula {
	formula string
	requires []string
	operator string
}

fn (f Formula) solve(given map[string]i64) !i64 {
	match f.operator {
		"*" {
			return given[f.requires[0]] * given[f.requires[1]]
		}
		"+" {
			return given[f.requires[0]] + given[f.requires[1]]
		}
		"-" {
			return given[f.requires[0]] - given[f.requires[1]]
		}
		"/" {
			return given[f.requires[0]] / given[f.requires[1]]
		}
		else {
			panic("Unknown operator ${f.operator}")
		}
	}
}

fn part1(file_name string) !i64 {
	mut given := map[string]i64{}
	mut open := map[string]Formula{}

	for line in read_file(file_name)!.split("\n") {
		name := line.split(": ")[0]
		formula := line.split(": ")[1]
		if formula.bytes().all(it.is_digit()) {
			given[name] = formula.int()
		} else {
			open[name] = Formula{formula, [formula.split(" ")[0], formula.split(" ")[2]], formula.split(" ")[1]}
		}
	}

	for open.len > 0 {
		mut solved_open := []string{}

		for name, formula in open {
			if formula.requires.all(it in given) {
				given[name] = formula.solve(given)!
				solved_open << name
			}
		}

		for s in solved_open {
			open.delete(s)
		}
	}
	return given["root"]
}

fn part2(file_name string) !i64 {
	mut given := map[string]i64{}
	mut open := map[string]Formula{}

	for line in read_file(file_name)!.split("\n") {
		name := line.split(": ")[0]
		formula := line.split(": ")[1]
		if name == "humn" {
			continue
		}

		if formula.bytes().all(it.is_digit()) {
			given[name] = formula.int()
		} else {
			open[name] = Formula{formula, [formula.split(" ")[0], formula.split(" ")[2]], formula.split(" ")[1]}
		}
	}

	// try to solve as many as possible without the humn, 
	// if thats fixed we just try all other combinations with binary search
	mut solved_more := true
	for open.len > 0 && solved_more {
		mut solved_open := []string{}
		solved_more = false

		for name, formula in open {
			if formula.requires.all(it in given) {
				given[name] = formula.solve(given)!
				solved_open << name
			}
		}

		for s in solved_open {
			open.delete(s)
			solved_more = true
		}
	}

	mut max_val := i64(10000000000000)
	mut min_val := i64(0)

	for true {
		mut mid := max_val - (max_val - min_val) / 2

		call := fn [given, open] (value i64) CallResult {
			a, b := complete_part2(given, open, value)
			return CallResult{value, a, b, abs(a - b)} 
		}
		mut results := [min_val, mid, max_val].map(call)
		results.sort(a.dist < b.dist)
		
		if results.any(it.dist == 0) {
			// there can be smaller solutions, somehow it seems only the smallest is allowed
			mut base_result := results.filter(it.dist == 0).first().value
			mut smallest_result := base_result
			for x in 1..10 {
				a, b := complete_part2(given, open, base_result - x)
				if a == b {
					smallest_result = base_result - x
				}
			}
			return smallest_result
		} else {
			min_val = min(results[0].value, results[1].value)
			max_val = max(results[0].value, results[1].value)
		}

	}
	panic("No valid solution")
}

struct CallResult {
	value i64
	a i64
	b i64
	dist i64
}

fn complete_part2(given map[string]i64, open map[string]Formula, humn i64) (i64, i64) {
	mut mod_given := given.clone()
	mod_given["humn"] = humn
	mut mod_open := open.clone()

	required := mod_open["root"].requires

	for !required.all(it in mod_given) {
		mut solved_open := []string{}

		for name, formula in mod_open {
			if formula.requires.all(it in mod_given) {
				mod_given[name] = formula.solve(mod_given) or { -1 }
				solved_open << name
			}
		}

		for s in solved_open {
			mod_open.delete(s)
		}
	}

	return mod_given[required[0]], mod_given[required[1]]
}