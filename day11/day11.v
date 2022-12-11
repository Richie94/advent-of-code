import os

struct Monkey {
	op         string
	test_div   int
	test_true  int
	test_false int
mut:
	items []i64
	inspected i64
}

struct Item {
	target int
	worry  i64
}

fn (mut m Monkey) throw_items(divisor int, common i64) []Item {
	mut thrown_items := []Item{}

	for i in m.items {
		new_worry := (get_worry(i, m.op) % common) / divisor
		m.inspected += 1
		if new_worry % m.test_div == 0 {
			thrown_items << Item{m.test_true, new_worry}
		} else {
			thrown_items << Item{m.test_false, new_worry}
		}
	}
	m.items.clear()

	return thrown_items
}

fn get_worry(worry i64, operation string) i64 {
	updated_op := operation.replace("old", worry.str())
	if updated_op.split(" ")[1] == "*" {
		return updated_op.split(" ")[0].i64() * updated_op.split(" ")[2].i64()
	} else {
		return updated_op.split(" ")[0].i64() + updated_op.split(" ")[2].i64()
	}
	
}

fn main() {
	f := os.read_file('input_test.txt') or {
		println('Cannot open input')
		return
	}

	part1(f)
	part2(f)
}

struct Input{
	common int
	monkeys map[int]Monkey
}

fn parse_input(f string) Input {
	mut monkeys := map[int]Monkey{}
	mut divisor := 1

	for block in f.split('\n\n') {
		monkey_id := block.split('\n')[0].split(':')[0].split(' ')[1].int()
		monkey_items := block.split('\n')[1].split(':')[1].split(',').map(it.split(' ')[1].i64())
		monkey_op := block.split('\n')[2].split('new = ')[1]
		monkey_test_div := block.split('\n')[3].split(' ').last().int()
		monkey_test_true := block.split('\n')[4].split(' ').last().int()
		monkey_test_false := block.split('\n')[5].split(' ').last().int()

		divisor *= monkey_test_div
		monkeys[monkey_id] = &Monkey{monkey_op, monkey_test_div, monkey_test_true, monkey_test_false, monkey_items, 0}
	}

	return Input{divisor, monkeys}
}

fn part1(f string) {
	input := parse_input(f)
	s := solve(input.monkeys, input.common, 3, 20)
	println("P1 $s")
}

fn part2(f string) {
	input := parse_input(f)
	s := solve(input.monkeys, input.common, 1, 10_000)
	println("P2 $s")
}

fn solve(monkeys_param map[int]Monkey, common int, divisor int, rounds int) i64 {
	mut monkeys := monkeys_param.clone()
	for _ in 1 .. rounds+1 {
		for monkey_id in 0 .. monkeys.keys().len {
			items := monkeys[monkey_id].throw_items(divisor, common)
			for item in items {
				monkeys[item.target].items << item.worry
			}
		}
	}

	return score(monkeys)
}


fn score(monkeys map[int]Monkey) i64 {
	mut inspections := monkeys.values().map(fn (m Monkey) i64 {return m.inspected})
	inspections.sort()
	a := inspections.pop()
	b := inspections.pop()
	return a * b
}
