defmodule Solution do
	def build_map([], _, _) do %{} end
	def build_map([head|tail], x, y) do
		{n1, n2} = case head do
			"." -> {nil, nil}
			"#" -> {:wall, :wall}
			"O" -> {:boxl, :boxr}
			"@" -> {:robot, nil}
		end
		map = Map.put(Map.put(build_map(tail, x + 2, y), {x, y}, n1), {x + 1, y}, n2)
		if n1 == :robot do
			Map.put(map, :robot_pos, {x, y})
		else
			map
		end
	end

	def build_map([], _) do %{} end
	def build_map([line|tail], y) do
		Map.merge(build_map(String.graphemes(line), 0, y), build_map(tail, y + 1))
	end

	def build_map(ascii_map) do
		lines = String.split(ascii_map, "\n")
		build_map(lines, 0)
	end

	def exec_move(map, {px, py}, {dx, dy}) do
		start_movable = Map.get(map, {px, py})
		nx = px + dx
		ny = py + dy
		cur_occupier = Map.get(map, {nx, ny})
		updated_map = cond do
			cur_occupier == nil ->
				Map.replace(
					Map.replace(map, {px, py}, nil),
				{nx, ny}, start_movable)
			dy == 0 ->
				Map.replace(
					Map.replace(
						exec_move(map, {nx, ny}, {dx, dy}),
					{px, py}, nil),
				{nx, ny}, start_movable)
			cur_occupier == :boxl ->
				Map.replace(
					Map.replace(
						exec_move(
							exec_move(map, {nx, ny}, {dx, dy}),
						{nx + 1, ny}, {dx, dy}),
					{px, py}, nil),
				{nx, ny}, start_movable)
			cur_occupier == :boxr ->
				Map.replace(
					Map.replace(
						exec_move(
							exec_move(map, {nx, ny}, {dx, dy}),
						{nx - 1, ny}, {dx, dy}),
					{px, py}, nil),
				{nx, ny}, start_movable)
		end
		if start_movable == :robot do
			Map.replace(updated_map, :robot_pos, {nx, ny})
		else
			updated_map
		end
	end

	def test_move(map, {px, py}, {dx, dy}) do
		nx = px + dx
		ny = py + dy
		cur_occupier = Map.get(map, {nx, ny})
		cond do
			cur_occupier == :wall -> false
			cur_occupier == nil -> true
			dy == 0 -> test_move(map, {nx, ny}, {dx, dy})
			cur_occupier == :boxl -> test_move(map, {nx, ny}, {dx, dy}) and test_move(map, {nx + 1, ny}, {dx, dy})
			cur_occupier == :boxr -> test_move(map, {nx, ny}, {dx, dy}) and test_move(map, {nx - 1, ny}, {dx, dy})
		end
	end

	def move(map, dir) do
		pos = Map.get(map, :robot_pos)
		if test_move(map, pos, dir) do
			exec_move(map, pos, dir)
		else
			map
		end
	end

	def step_instructions(map, []) do map end
	def step_instructions(map, [cmd|tail]) do
		dir = case cmd do
			"^" -> {0, -1}
			"v" -> {0, 1}
			"<" -> {-1, 0}
			">" -> {1, 0}
		end
		step_instructions(move(map, dir), tail)
	end

	def calculate_gps_sum_from_locations([]) do 0 end
	def calculate_gps_sum_from_locations([{:robot_pos, _}|tail]) do
		calculate_gps_sum_from_locations(tail)
	end
	def calculate_gps_sum_from_locations([{{x, y}, obj}|tail]) do
		case obj do
			:boxl -> (100 * y) + x
			_ -> 0
		end +
		calculate_gps_sum_from_locations(tail)
	end

	def calculate_gps_sum(map) do
		locations = Map.to_list(map)
		calculate_gps_sum_from_locations(locations)
	end

	def calculate_result(contents) do
		[map_part, direction_part] = String.split(contents, "\n\n")
		start_map = build_map(map_part)
		final_map = step_instructions(start_map, Enum.filter(String.graphemes(direction_part), fn c -> c != "\n" end))
		calculate_gps_sum(final_map)
	end
end

contents = File.read!("input.txt")
result = Solution.calculate_result(contents)
IO.puts("result: #{result}")
