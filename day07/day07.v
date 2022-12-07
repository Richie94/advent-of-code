import os
import arrays

fn main() {
	f := os.read_file('input.txt') or {
		println('Cannot open input')
		return
	}

	mut dir_dict := map[string]int{}

	mut current_path := ''
	for line in f.split('\n') {
		if line.len > 4 {
			if '$ cd ' == line[0..5].str() {
				if line == '$ cd ..' {
					current_path = current_path.split('/')#[..-1].join('/')
				} else if line == '$ cd /' {
					current_path = ''
				} else {
					current_path += '/' + line.split(' ').last()
				}
			} else if line[0..3] != 'dir' {
				fsize := line.split(' ')[0].int()

				for index, dir in current_path.split('/') {
					dir_dict[current_path.split('/')[0..index + 1].join('/')] += fsize
				}
			}
		}
	}

	part1(dir_dict)
	part2(dir_dict)
}

fn part1(dir_dict map[string]int) {
	mut result := 0
	for dir, size in dir_dict {
		if size < 100000 {
			result += size
		}
	}
	println('p1 ${result}')
}

fn part2(dir_dict map[string]int) {
	total := 70_000_000
	goal := 30_000_000
	used_space := dir_dict['']
	unused_space := total - used_space

	need := goal - unused_space
	mut biggest_dirs := []int{}

	for _, size in dir_dict {
		if size >= need {
			biggest_dirs << size
		}
	}

	println('p2 ${arrays.min(biggest_dirs) or { 0 }}')
}
