defmodule Solution do
	def find_start_location([head|tail], y) do
		case Enum.find_index(head, fn e -> e == "^" end) do
			:nil -> find_start_location(tail, y + 1)
			x -> {x, y}
		end
	end

	def find_map_dimensions(map) do
		{length(Enum.at(map, 0)), length(map)}
	end

	def coords_out_of_bounds({x, y}, {width, height}) do
		x < 0 or y < 0 or x >= width or y >= height
	end

	def coords_blocked(map, dims, {x, y}) do
		not coords_out_of_bounds({x, y}, dims) and Enum.at(Enum.at(map, y), x) == "#"
	end

	def next_move(map, dims, {x, y}, {directions, dir_index}) do
		{dx, dy} = elem(directions, dir_index)
		new_pos = {x + dx, y + dy}
		if coords_blocked(map, dims, new_pos) do
			{{x, y}, {directions, Integer.mod(dir_index + 1, tuple_size(directions))}}
		else
			{new_pos, {directions, dir_index}}
		end
	end

	def traverse_map(map, dims, pos, dir, locations_visited) do
		if coords_out_of_bounds(pos, dims) do
			locations_visited
		else
			updated_locations_visited = MapSet.put(locations_visited, pos)
			{new_pos, new_dir} = next_move(map, dims, pos, dir)
			traverse_map(map, dims, new_pos, new_dir, updated_locations_visited)
		end
	end

	def count_locations_visited(map) do
		directions = {{0, -1}, {1, 0}, {0, 1}, {-1, 0}}
		start_pos = find_start_location(map, 0)
		dims = find_map_dimensions(map)
		locations_visited = traverse_map(map, dims, start_pos, {directions, 0}, MapSet.new())
		MapSet.size(locations_visited)
	end
end

contents = File.read!("input.txt")
map = for line <- String.split(contents, "\n"), do: String.graphemes(line)
result = Solution.count_locations_visited(map)
IO.puts("result: #{result}")
