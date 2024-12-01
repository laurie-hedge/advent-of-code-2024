defmodule Solution do
	def build_location_structs([], location_list, occurence_map) do
		{location_list, occurence_map}
	end

	def build_location_structs([head|tail], location_list, occurence_map) do
		[part1, part2] = String.split(head, "   ")
		{val1, _} = Integer.parse(part1)
		{val2, _} = Integer.parse(part2)
		build_location_structs(tail,
		                       location_list ++ [val1],
		                       Map.update(occurence_map, val2, 1, fn current_count -> current_count + 1 end)
		                       )
	end

	def build_location_structs(lines) do
		build_location_structs(lines, [], %{})
	end

	def calculate_similarity([], _, running_total) do
		running_total
	end

	def calculate_similarity([head|tail], occurence_map, running_total) do
		calculate_similarity(tail,
		                     occurence_map,
		                     running_total + (head * Map.get(occurence_map, head, 0)))
	end

	def calculate_result(lines) do
		{location_list, occurence_map} = build_location_structs(lines)
		calculate_similarity(location_list, occurence_map, 0)
	end
end

contents = File.read!("input.txt")
lines = String.split(contents, "\n")
result = Solution.calculate_result(lines)
IO.puts("result: #{result}")
