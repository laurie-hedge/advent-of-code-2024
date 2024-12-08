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

	def antinodes_for_pair({x0, y0}, {x1, y1}) do
		dx = x0 - x1
		dy = y0 - y1
		[{x0 + dx, y0 + dy}, {x1 - dx, y1 - dy}]
	end

	def find_antinode_locations_for_antenna(_, []) do [] end
	def find_antinode_locations_for_antenna(from, [to|rest]) do
		antinodes_for_pair(from, to) ++
		find_antinode_locations_for_antenna(from, rest) ++
		find_antinode_locations_for_antenna(to, rest)
	end

	def find_antinode_locations_for_antenna([]) do [] end
	def find_antinode_locations_for_antenna([head|tail]) do
		find_antinode_locations_for_antenna(head, tail)
	end

	def find_antinode_locations(antenna_map, {width, height}) do
		MapSet.new(
			Enum.filter(
				List.flatten(
					for {_, locations} <- antenna_map do
						find_antinode_locations_for_antenna(locations)
					end
				),
				fn {x, y} -> x >= 0 and y >= 0 and x < width and y < height end
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
