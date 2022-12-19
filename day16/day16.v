import arrays
import os
import regex

struct Pipe {
	name    string
	flow    int
	targets []string
	open    bool
}

struct PipeState {
	open_pipes []string
	my_pos     string
	score      int
	time       int
}

struct PipeStateWithElefant {
	open_pipes []string
	my_pos     string
	ele_pos    string
	score      int
	time       int
}

fn str_to_pipe(s string) Pipe {
	mut r := regex.regex_opt('Valve (.*) has flow rate=(.*);.*valves? (.*)') or { panic(err) }
	r.match_string(s)
	return Pipe{r.get_group_by_id(s, 0), r.get_group_by_id(s, 1).int(), r.get_group_by_id(s,
		2).split(', '), true}
}

fn main() {
	part2()
}

fn part1() {
	f := os.read_file('input.txt') or {
		println('Cannot open input')
		return
	}

	pipes := f.split('\n').map(str_to_pipe)

	mut stack := [PipeState{[], 'AA', 0, 1}]
	mut best_released := 0

	mut seen := map[string]int{}
	for stack.len > 0 {
		current := stack.pop()
		score := current.score
		encoded := '${current.time}:${current.my_pos}'

		if encoded in seen && seen[encoded] >= score {
			continue
		}

		seen[encoded] = score

		if current.time == 30 {
			if score >= best_released {
				best_released = score
			}
			continue
		}

		current_pipe := get_pipe_by_name(current.my_pos, pipes)
		flow_by_name := fn [pipes] (name string) int {
			return get_pipe_by_name(name, pipes).flow
		}

		// if we open the valve here
		if current.my_pos !in current.open_pipes && current_pipe.flow > 0 {
			mut new_open_pipes := current.open_pipes.clone()
			new_open_pipes << current.my_pos

			new_score := current.score + arrays.sum(new_open_pipes.map(flow_by_name)) or { 0 }

			stack << PipeState{new_open_pipes, current.my_pos, new_score, current.time + 1}
		}

		new_score := current.score + arrays.sum(current.open_pipes.map(flow_by_name)) or { 0 }

		// move
		for neighbour_name in current_pipe.targets {
			stack << PipeState{current.open_pipes, neighbour_name, new_score, current.time + 1}
		}
	}

	println(best_released)
}

fn part2() {
	f := os.read_file('input_test.txt') or {
		println('Cannot open input')
		return
	}

	pipes := f.split('\n').map(str_to_pipe)

	relevant_pipes := pipes.filter(it.flow > 0).map(it.name)

	mut stack := [PipeStateWithElefant{[], 'AA', 'AA', 0, 1}]
	mut best_released := 0
	mut fastest := 26

	flow_by_name := fn [pipes] (name string) int {
		return get_pipe_by_name(name, pipes).flow
	}

	mut seen := map[string]int{}
	for stack.len > 0 {
		current := stack.pop()
		score := current.score
		encoded := '${current.time}:${current.my_pos}:${current.ele_pos}'

		if encoded in seen && seen[encoded] >= score {
			continue
		}

		seen[encoded] = score

		is_open := fn [current] (name string) bool {
			return name in current.open_pipes
		}

		if current.time == 26 {
			if score >= best_released {
				best_released = score
			}
			continue
		}

		// if all necessary valves are open, stop too
		if relevant_pipes.all(is_open) {
			if current.time < fastest {
				fastest = current.time
			}
			mut new_time := current.time
			mut new_score := current.score + arrays.sum(current.open_pipes.map(flow_by_name)) or {
				0
			}
			for new_time < 25 {
				new_time += 1
				new_score = new_score + arrays.sum(current.open_pipes.map(flow_by_name)) or { 0 }
			}

			stack << PipeStateWithElefant{current.open_pipes, '', '', new_score, 26}

			continue
		}

		current_pipe_me := get_pipe_by_name(current.my_pos, pipes)
		current_pipe_ele := get_pipe_by_name(current.ele_pos, pipes)

		// if we open the valve here
		if current.my_pos !in current.open_pipes && current_pipe_me.flow > 0 {
			// elefant opens valve too
			if current.ele_pos !in current.open_pipes && current_pipe_ele.flow > 0
				&& current.ele_pos != current.my_pos {
				mut new_open_pipes := current.open_pipes.clone()
				new_open_pipes << current.my_pos
				new_open_pipes << current.ele_pos

				new_score := current.score + arrays.sum(new_open_pipes.map(flow_by_name)) or { 0 }

				stack << PipeStateWithElefant{new_open_pipes, current.my_pos, current.ele_pos, new_score,
					current.time + 1}
			}

			// ele moves
			mut new_open_pipes := current.open_pipes.clone()
			new_open_pipes << current.my_pos
			new_score := current.score + arrays.sum(new_open_pipes.map(flow_by_name)) or { 0 }

			for neighbour_name in current_pipe_ele.targets {
				stack << PipeStateWithElefant{current.open_pipes, current.my_pos, neighbour_name, new_score,
					current.time + 1}
			}
		}

		// move
		for my_move in current_pipe_me.targets {
			// elefant opens valve
			if current.ele_pos !in current.open_pipes && current_pipe_ele.flow > 0 {
				mut new_open_pipes := current.open_pipes.clone()
				new_open_pipes << current.ele_pos

				new_score := current.score + arrays.sum(new_open_pipes.map(flow_by_name)) or { 0 }

				stack << PipeStateWithElefant{new_open_pipes, my_move, current.ele_pos, new_score,
					current.time + 1}
			}

			new_score := current.score + arrays.sum(current.open_pipes.map(flow_by_name)) or { 0 }
			// elefant moves too
			for ele_move in current_pipe_ele.targets {
				stack << PipeStateWithElefant{current.open_pipes, my_move, ele_move, new_score,
					current.time + 1}
			}
		}
	}

	println(fastest)
	println(best_released)
}

fn get_pipe_by_name(name string, pipes []Pipe) Pipe {
	return pipes.filter(it.name == name)[0]
}
