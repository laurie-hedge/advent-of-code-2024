defmodule Solution do
	def find_corrupt_locations(_, 0) do MapSet.new() end
	def find_corrupt_locations([head|tail], lines_remaining) do
		[x_str, y_str] = String.split(head, ",")
		{x, _} = Integer.parse(x_str)
		{y, _} = Integer.parse(y_str)
		MapSet.put(find_corrupt_locations(tail, lines_remaining - 1), {x, y})
	end

	def find_shortest_path(_, dest, dest, location_cost, cost) do
		Map.update(location_cost, dest, cost, fn cur_cost -> Enum.min([cur_cost, cost]) end)
	end
	def find_shortest_path(corrupt_locations, {x, y}, {mx, my}, location_cost, cost) do
		cur_cost = Map.get(location_cost, {x, y})
		cond do
			{x, y} in corrupt_locations ->
				location_cost
			x < 0 or y < 0 or x > mx or y > my ->
				location_cost
			cur_cost == nil or cur_cost > cost ->
				updated_cost = cost + 1
				updated_location_cost = Map.put(location_cost, {x, y}, cost)
				find_shortest_path(corrupt_locations, {x + 1, y}, {mx, my},
					find_shortest_path(corrupt_locations, {x - 1, y}, {mx, my},
						find_shortest_path(corrupt_locations, {x, y + 1}, {mx, my},
							find_shortest_path(corrupt_locations, {x, y - 1}, {mx, my},
								updated_location_cost,
							updated_cost),
						updated_cost),
					updated_cost),
				updated_cost)
			true ->
				location_cost
		end
	end

	def calculate_result(lines, dest, bytes_fallen) do
		corrupt_locations = find_corrupt_locations(lines, bytes_fallen)
		cost_map = find_shortest_path(corrupt_locations, {0, 0}, dest, %{}, 0)
		Map.get(cost_map, dest)
	end
end

bytes_fallen = 1024
dest = {70, 70}
contents = File.read!("input.txt")
lines = String.split(contents, "\n")
result = Solution.calculate_result(lines, dest, bytes_fallen)
IO.puts("result: #{result}")
