defmodule Solution do
	def build_map([], _, _) do %{} end
	def build_map([head|tail], x, y) do
		node = case head do
			"." -> nil
			"#" -> :wall
			"O" -> :box
			"@" -> :robot
		end
		map = Map.put(build_map(tail, x + 1, y), {x, y}, node)
		if node == :robot do
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

	def move(map, {px, py}, {dx, dy}) do
		start_movable = Map.get(map, {px, py})
		npos = {px + dx, py + dy}
		case Map.get(map, npos) do
			:wall ->
				{:rej, map}
			nil ->
				{:acc, Map.replace(Map.replace(map, {px, py}, nil), npos, start_movable)}
			_ ->
				case move(map, npos, {dx, dy}) do
					{:rej, _} ->
						{:rej, map}
					{:acc, updated_map} ->
						{:acc, Map.replace(Map.replace(updated_map, {px, py}, nil), npos, start_movable)}
				end
		end
	end

	def next_robot_pos(map, {dx, dy}) do
		{x, y} = Map.get(map, :robot_pos)
		{x + dx, y + dy}
	end

	def move(map, dir) do
		pos = Map.get(map, :robot_pos)
		case move(map, pos, dir) do
			{:rej, _} -> map
			{:acc, updated_map} ->
				Map.replace(updated_map, :robot_pos, next_robot_pos(updated_map, dir))
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
			:box -> (100 * y) + x
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
