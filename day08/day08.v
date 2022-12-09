import os
import time
import arrays

fn main() {
	sw := time.new_stopwatch()
	f := os.read_file('input.txt') or {
		println('Cannot open input')
		return
	}

	mut tree_dict := map[int]map[int]int{}

	for x, line in f.split('\n') {
		for y, tree_rune in line.runes() {
			tree_dict[x][y] = tree_rune.str().int()
		}
	}

	mut visible_left := map[int]map[int]int{}
	mut visible_right := map[int]map[int]int{}
	mut visible_top := map[int]map[int]int{}
	mut visible_bottom := map[int]map[int]int{}

	x_len := tree_dict.len - 1
	y_len := tree_dict[0].len - 1

	for x, row in tree_dict {
		mut highest_left := 0
		for y, height in row {
			if height > highest_left {
				highest_left = height
			}
			visible_left[x][y] = highest_left
		}
	}

	for x, row in tree_dict {
		mut highest_right := 0
		for y in row.keys().reverse() {
			height := row[y]
			if height > highest_right {
				highest_right = height
			}
			visible_right[x][y] = highest_right
		}
	}

	for y := y_len; y >= 0; y -= 1 {
		mut highest_top := 0
		for x in 0 .. x_len + 1 {
			height := tree_dict[x][y]
			if height > highest_top {
				highest_top = height
			}
			visible_top[x][y] = highest_top
		}
	}

	for y in 0 .. y_len + 1 {
		mut highest_bottom := 0
		for x := x_len; x >= 0; x -= 1 {
			height := tree_dict[x][y]
			if height > highest_bottom {
				highest_bottom = height
			}
			visible_bottom[x][y] = highest_bottom
		}
	}

	mut visible_trees := 0
	mut scenic_score := 0
	for x in 0 .. x_len + 1 {
		for y in 0 .. y_len + 1 {
			height := tree_dict[x][y]
			if x == 0 || y == 0 || x == x_len || y == y_len {
				visible_trees += 1
			} else if x <= x_len && height > visible_bottom[x + 1][y] {
				visible_trees += 1
			} else if x > 0 && height > visible_top[x - 1][y] {
				visible_trees += 1
			} else if y <= y_len && height > visible_right[x][y + 1] {
				visible_trees += 1
			} else if y > 0 && height > visible_left[x][y - 1] {
				visible_trees += 1
			}

			// scenic score go bottom
			mut bottom_matches := 0
			for x_n in x .. x_len + 1 {
				n_height := tree_dict[x_n][y]
				if n_height < height {
					bottom_matches += 1
				} else {
					break
				}
			}
			// scenic score go up
			mut top_matches := 0
			for x_n := x_len; x_n >= 0; x_n -= 1 {
				n_height := tree_dict[x_n][y]
				if n_height < height {
					top_matches += 1
				} else {
					break
				}
			}

			// scenic score go right
			mut right_matches := 0
			for y_n in y .. y_len + 1 {
				n_height := tree_dict[x][y_n]
				if n_height < height {
					right_matches += 1
				} else {
					break
				}
			}

			// scenic score go left
			mut left_matches := 0
			for y_n := y_len; y_n >= 0; y_n -= 1 {
				n_height := tree_dict[x][y_n]
				if n_height < height {
					left_matches += 1
				} else {
					break
				}
			}

			new_scenic_score := arrays.reduce([left_matches, right_matches, top_matches,
				bottom_matches].filter(it > 0), fn (x1 int, x2 int) int {
				return x1 * x2
			}) or { 0 }

			if new_scenic_score > scenic_score {
				println("$x $y : $left_matches $right_matches $top_matches $bottom_matches")
				scenic_score = new_scenic_score
			}
		}
	}

	println('p1 ${visible_trees} (took ${sw.elapsed().milliseconds()}ms)')
	println('p2 ${scenic_score} (took ${sw.elapsed().milliseconds()}ms)')
}
