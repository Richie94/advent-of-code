import os { read_file }

fn main() {
	file_name := "input.txt"
	println("Part 1: ${part1(file_name) or {0}}")
	println("Part 2: ${part2(file_name) or {0}}")
}

fn part1(file_name string) !i64 {
	seq := read_file(file_name)!.split("\n").map(it.i64())
	return decrypt(seq, 1, 1)
}

fn part2(file_name string) !i64 {
	seq := read_file(file_name)!.split("\n").map(it.i64())
	return decrypt(seq, 811589153, 10)
}

fn decrypt(seq []i64, multiplier int, rounds int ) i64 {
	// since we have duplicate values have a map from entry-idx to value
	mut dict := map[int]i64{}
	mut code := []int{}
	for idx, s in seq {
		dict[idx] = s * multiplier
		code << idx
	}

	code_len := code.len
	for _ in 0 .. rounds {
		for key, value in dict {
			// find the key idx in code
			key_idx := code.index(key)

			code.delete(key_idx)
			mut new_idx := i64((key_idx + value) % (code_len - 1))
			if new_idx <= 0 {
				new_idx += code_len - 1
			}
			code.insert(int(new_idx), key)
		}
	}

	new_code := code.map(dict[it])
	index_zero := new_code.index(0)
	mut result := i64(0)
	for idx in [1000, 2000, 3000] {
		result += new_code[(index_zero + idx) % new_code.len]
	}

	return result
}