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

	def move_pos({x, y}, {directions, dir_index}) do
		{dx, dy} = elem(directions, dir_index)
		{x + dx, y + dy}
	end

	def coords_out_of_bounds({x, y}, {width, height}) do
		x < 0 or y < 0 or x >= width or y >= height
	end

	def coords_blocked(map, {x, y}, test_block) do
		{x, y} == test_block or Enum.at(Enum.at(map, y), x) == "#"
	end

	def coords_blockable(map, locations_visited, {x, y}, test_block) do
		test_block == :nil and Enum.at(Enum.at(map, y), x) == "." and not Enum.any?(locations_visited, fn {{lx, ly}, _} -> x == lx and y == ly end)
	end

	def next_dir({directions, dir_index}) do
		{directions, Integer.mod(dir_index + 1, tuple_size(directions))}
	end

	def traverse_map(map, dims, pos, dir, locations_visited, test_block) do
		current_location = {pos, elem(dir, 1)}
		updated_locations_visited = MapSet.put(locations_visited, current_location)
		new_pos = move_pos(pos, dir)
		cond do
			current_location in locations_visited ->
				MapSet.new([test_block])
			coords_out_of_bounds(new_pos, dims) ->
				MapSet.new()
			coords_blocked(map, new_pos, test_block) ->
				traverse_map(map, dims, pos, next_dir(dir), updated_locations_visited, test_block)
			coords_blockable(map, locations_visited, new_pos, test_block) ->
				MapSet.union(
					traverse_map(map, dims, pos, next_dir(dir), updated_locations_visited, new_pos),
					traverse_map(map, dims, new_pos, dir, updated_locations_visited, :nil)
				)
			true ->
				traverse_map(map, dims, new_pos, dir, updated_locations_visited, test_block)
		end
	end

	def count_block_locations(map) do
		directions = {{0, -1}, {1, 0}, {0, 1}, {-1, 0}}
		start_pos = find_start_location(map, 0)
		dims = find_map_dimensions(map)
		block_locations = traverse_map(map, dims, start_pos, {directions, 0}, MapSet.new(), :nil)
		MapSet.size(block_locations)
	end
end

contents = File.read!("input.txt")
map = for line <- String.split(contents, "\n"), do: String.graphemes(line)
result = Solution.count_block_locations(map)
IO.puts("result: #{result}")
