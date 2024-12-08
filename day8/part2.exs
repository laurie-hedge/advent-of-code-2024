defmodule Solution do
	def merge_antenna_maps(_, v1, v2) do v1 ++ v2 end

	def build_antenna_map([], _, _) do %{} end
	def build_antenna_map(["."|tail], x, y) do
		build_antenna_map(tail, x + 1, y)
	end
	def build_antenna_map([head|tail], x, y) do
		Map.merge(%{head => [{x, y}]}, build_antenna_map(tail, x + 1, y), &merge_antenna_maps/3)
	end

	def build_antenna_map([], _) do %{} end
	def build_antenna_map([row|tail], y) do
		Map.merge(
			build_antenna_map(row, 0, y),
			build_antenna_map(tail, y + 1),
			&merge_antenna_maps/3
		)
	end

	def build_antenna_map(map) do
		build_antenna_map(map, 0)
	end

	def find_map_dimensions(map) do
		{length(Enum.at(map, 0)), length(map)}
	end

	def out_of_bounds({x, y}, {width, height}) do
		x < 0 or y < 0 or x >= width or y >= height
	end

	def next_pos({x, y}, {dx, dy}) do
		{x + dx, y + dy}
	end

	def find_antinodes(pos, dir, dims) do
		if out_of_bounds(pos, dims) do
			[]
		else
			[pos] ++ find_antinodes(next_pos(pos, dir), dir, dims)
		end
	end

	def antinodes_for_pair({x0, y0}, {x1, y1}, dims) do
		dx = x1 - x0
		dy = y1 - y0
		find_antinodes({x1, y1}, {dx, dy}, dims) ++ find_antinodes({x0, y0}, {-dx, -dy}, dims)
	end

	def find_antinode_locations_for_antenna(_, [], _) do [] end
	def find_antinode_locations_for_antenna(from, [to|rest], dims) do
		antinodes_for_pair(from, to, dims) ++
		find_antinode_locations_for_antenna(from, rest, dims) ++
		find_antinode_locations_for_antenna(to, rest, dims)
	end

	def find_antinode_locations_for_antenna([], _) do [] end
	def find_antinode_locations_for_antenna([head|tail], dims) do
		find_antinode_locations_for_antenna(head, tail, dims)
	end

	def find_antinode_locations(antenna_map, dims) do
		MapSet.new(
			List.flatten(
				for {_, locations} <- antenna_map do
					find_antinode_locations_for_antenna(locations, dims)
				end
			)
		)
	end

	def count_antinode_locations(map) do
		dims = find_map_dimensions(map)
		antenna_map = build_antenna_map(map)
		antinode_locations = find_antinode_locations(antenna_map, dims)
		MapSet.size(antinode_locations)
	end
end

contents = File.read!("input.txt")
map = for line <- String.split(contents, "\n"), do: String.graphemes(line)
result = Solution.count_antinode_locations(map)
IO.puts("result: #{result}")
