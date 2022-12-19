import os { read_file }
import regex
import math { max }
import arrays

struct Blueprint {
	id                  int
	ore_ore_cost        int
	clay_ore_cost       int
	obsidian_ore_cost   int
	obsidian_clay_cost  int
	geode_ore_cost      int
	geode_obsidian_cost int
}

fn (b Blueprint) max_ore() int {
	return max(b.ore_ore_cost, max(b.clay_ore_cost, max(b.obsidian_ore_cost, b.geode_ore_cost)))
}

fn (b Blueprint) max_clay() int {
	return b.obsidian_clay_cost
}

struct State {
	time            int
	ore             int
	clay            int
	obsidian        int
	geodes          int
	ore_robots      int
	clay_robots     int
	obsidian_robots int
	geode_robots    int
}

fn main() {
	part1()!
	part2()!
}

fn part1() !int {
	println("Part 1")
	blueprints := read_file('input.txt')!.split('\n').map(parse_blueprint)
	mut scores := []int{}
	for blueprint in blueprints {
		max_geodes := run_blueprint(blueprint, 24)
		println('Blueprint ${blueprint.id}: ${max_geodes}')
		scores << blueprint.id * max_geodes
	}
	part1 := arrays.sum(scores) or { 0 }
	println(part1)
	return part1
}

fn part2() !int {
	println("Part 2")
	blueprints := read_file('input.txt')!.split('\n').map(parse_blueprint)[..3]
	mut scores := []int{}
	for blueprint in blueprints {
		max_geodes := run_blueprint(blueprint, 32)
		println('Blueprint ${blueprint.id}: ${max_geodes}')
		scores << max_geodes
	}
	part2 := arrays.reduce(scores, fn (a int, b int) int {
		return a * b
	}) or { 0 }
	println(part2)
	return part2
}

fn run_blueprint(blueprint Blueprint, max_time int) int {
	mut stack := []State{}

	stack << State{0, 1, 0, 0, 0, 1, 0, 0, 0}
	mut max_geodes := 0
	mut geodes_at_time := map[int]int{}

	for stack.len > 0 {
		current := stack.pop()

		if current.time >= max_time - 1 {
			new_geodes := current.geodes
			max_geodes = max(max_geodes, new_geodes)
			continue
		}

		if geodes_at_time[current.time] - 2 > current.geodes {
			continue
		}
		geodes_at_time[current.time] = max(geodes_at_time[current.time], current.geodes)

		// try build geode bot
		if blueprint.geode_ore_cost <= current.ore
			&& blueprint.geode_obsidian_cost <= current.obsidian {
			stack << build_geode(produce(current), blueprint)
			// probably not useful doing anything other
			continue
		}

		// try build obsidian bot or produce
		can_build_obsidian := blueprint.obsidian_ore_cost <= current.ore
			&& blueprint.obsidian_clay_cost <= current.clay
		if can_build_obsidian {
			stack << build_obsidian(produce(current), blueprint)
			continue
		}

		can_build_clay := blueprint.clay_ore_cost <= current.ore
			&& blueprint.max_clay() > current.clay_robots
		// try build clay bot
		if can_build_clay {
			stack << build_clay(produce(current), blueprint)
		}

		can_build_ore := blueprint.ore_ore_cost <= current.ore
			&& blueprint.max_ore() > current.ore_robots && current.time < 10
		// try build ore bot
		if can_build_ore {
			stack << build_ore(produce(current), blueprint)
		}

		if !(can_build_ore && can_build_clay && can_build_obsidian) {
			// not building makes no sense when we can produce everything
			stack << produce(current)
		}
	}

	return max_geodes
}

fn build_ore(state State, blueprint Blueprint) State {
	return State{state.time, state.ore - blueprint.ore_ore_cost, state.clay, state.obsidian, state.geodes,
		state.ore_robots + 1, state.clay_robots, state.obsidian_robots, state.geode_robots}
}

fn build_clay(state State, blueprint Blueprint) State {
	return State{state.time, state.ore - blueprint.clay_ore_cost, state.clay, state.obsidian, state.geodes, state.ore_robots,
		state.clay_robots + 1, state.obsidian_robots, state.geode_robots}
}

fn build_obsidian(state State, blueprint Blueprint) State {
	return State{state.time, state.ore - blueprint.obsidian_ore_cost, state.clay - blueprint.obsidian_clay_cost, state.obsidian, state.geodes, state.ore_robots, state.clay_robots,
		state.obsidian_robots + 1, state.geode_robots}
}

fn build_geode(state State, blueprint Blueprint) State {
	return State{state.time, state.ore - blueprint.geode_ore_cost, state.clay, state.obsidian - blueprint.geode_obsidian_cost, state.geodes, state.ore_robots, state.clay_robots, state.obsidian_robots,
		state.geode_robots + 1}
}

fn produce(state State) State {
	return State{state.time + 1, state.ore + state.ore_robots, state.clay + state.clay_robots,
		state.obsidian + state.obsidian_robots, state.geodes + state.geode_robots, state.ore_robots, state.clay_robots, state.obsidian_robots, state.geode_robots}
}

fn parse_blueprint(line string) Blueprint {
	mut r := regex.regex_opt('Blueprint (.*): Each ore robot costs (.*) ore. Each clay robot costs (.*) ore. Each obsidian robot costs (.*) ore and (.*) clay. Each geode robot costs (.*) ore and (.*) obsidian.') or {
		panic(err)
	}
	r.match_string(line)
	return Blueprint{r.get_group_by_id(line, 0).int(), r.get_group_by_id(line, 1).int(), r.get_group_by_id(line,
		2).int(), r.get_group_by_id(line, 3).int(), r.get_group_by_id(line, 4).int(), r.get_group_by_id(line,
		5).int(), r.get_group_by_id(line, 6).int()}
}
