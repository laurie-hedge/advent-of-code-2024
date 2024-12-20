defmodule Solution do
	def build_map([], _, _) do %{} end
	def build_map([col|tail], x, y) do
		map = case col do
			"S" -> %{:start => {x, y}, {x, y} => :path}
			"E" -> %{:end => {x, y}, {x, y} => :path}
			"." -> %{{x, y} => :path}
			"#" -> %{{x, y} => :wall}
		end
		Map.merge(map, build_map(tail, x + 1, y))
	end

	def build_map([], _) do %{} end
	def build_map([row|tail], y) do
		Map.merge(build_map(String.graphemes(row), 0, y), build_map(tail, y + 1))
	end

	def build_map(lines) do
		build_map(lines, 0)
	end

	def next_pos({x, y}, lpos, map) do
		options = [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
		[npos] = Enum.filter(options, fn pos -> pos != lpos and Map.get(map, pos) == :path end)
		npos
	end

	def build_path_cost_map(_, _, spos, spos, ps_to_end) do %{spos => ps_to_end} end
	def build_path_cost_map(map, lpos, pos, spos, ps_to_end) do
		Map.put(build_path_cost_map(map, pos, next_pos(pos, lpos, map), spos, ps_to_end + 1), pos, ps_to_end)
	end

	def build_path_cost_map(map_with_start_end) do
		{epos, map_with_start} = Map.pop!(map_with_start_end, :end)
		{spos, map} = Map.pop!(map_with_start, :start)
		build_path_cost_map(map, nil, epos, spos, 0)
	end

	def mh_distance({x1, y1}, {x2, y2}) do
		abs(x1 - x2) + abs(y1 - y2)
	end

	def find_cheats_from(from_pos, path_cost_map) do
		start_cost = Map.get(path_cost_map, from_pos)
		positions_on_path = Map.keys(path_cost_map)
		possible_cheat_dests = Enum.filter(positions_on_path, fn pos ->
			Map.get(path_cost_map, pos) < start_cost and mh_distance(pos, from_pos) <= 20
		end)
		cheat_savings = for pos <- possible_cheat_dests do
			start_cost - (Map.get(path_cost_map, pos) + mh_distance(pos, from_pos))
		end
		Enum.filter(cheat_savings, fn saving -> saving > 0 end)
	end

	def calculate_cheat_savings([], _) do [] end
	def calculate_cheat_savings([pos|tail], path_cost_map) do
		find_cheats_from(pos, path_cost_map) ++ calculate_cheat_savings(tail, path_cost_map)
	end

	def calculate_cheat_savings(path_cost_map) do
		positions_on_path = Map.keys(path_cost_map)
		calculate_cheat_savings(positions_on_path, path_cost_map)
	end

	def calculate_result(lines, threshold) do
		map = build_map(lines)
		path_cost_map = build_path_cost_map(map)
		cheat_savings = calculate_cheat_savings(path_cost_map)
		length(Enum.filter(cheat_savings, fn saving -> saving >= threshold end))
	end
end

contents = File.read!("input.txt")
lines = String.split(contents, "\n")
result = Solution.calculate_result(lines, 100)
IO.puts("result: #{result}")
