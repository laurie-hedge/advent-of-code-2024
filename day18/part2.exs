defmodule Solution do
	def parse_coord(line) do
		[x_str, y_str] = String.split(line, ",")
		{x, _} = Integer.parse(x_str)
		{y, _} = Integer.parse(y_str)
		{x, y}
	end
	
	def mh_dist({x0, y0}, {x1, y1}) do
		abs(x0 - x1) + abs(y0 - y1)
	end

	def path_exists({x, y}, {x, y}, _) do true end
	def path_exists({x, y}, {mx, my}, blocked_locations) do
		options = [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
		valid_options = Enum.filter(options, fn {opt_x, opt_y} ->
			opt_x >= 0 and opt_x <= mx and
			opt_y >= 0 and opt_y <= my and
			{opt_x, opt_y} not in blocked_locations
		end)
		sorted_options = Enum.sort(valid_options, fn lhs, rhs ->
			mh_dist(lhs, {mx, my}) <= mh_dist(rhs, {mx, my})
		end)
		Enum.any?(sorted_options, fn opt ->
			path_exists(opt, {mx, my}, MapSet.put(blocked_locations, {x, y}))
		end)
	end

	def find_first_blocking_coord([head|tail], dest, corrupt_locations) do
		coord = parse_coord(head)
		updated_corrupt_locations = MapSet.put(corrupt_locations, coord)
		if path_exists({0, 0}, dest, updated_corrupt_locations) do
			find_first_blocking_coord(tail, dest, updated_corrupt_locations)
		else
			coord
		end
	end

	def calculate_result(lines, dest) do
		find_first_blocking_coord(lines, dest, MapSet.new())
	end
end

dest = {70, 70}
contents = File.read!("input.txt")
lines = String.split(contents, "\n")
{x, y} = Solution.calculate_result(lines, dest)
IO.puts("result: #{x},#{y}")
