defmodule Solution do
	def build_location_list([], list1, list2) do
		List.zip([Enum.sort(list1), Enum.sort(list2)])
	end

	def build_location_list([head|tail], list1, list2) do
		[part1, part2] = String.split(head, "   ")
		{val1, _} = Integer.parse(part1)
		{val2, _} = Integer.parse(part2)
		build_location_list(tail, list1 ++ [val1], list2 ++ [val2])
	end

	def build_location_list(lines) do
		build_location_list(lines, [], [])
	end

	def calculate_difference([], running_total) do
		running_total
	end

	def calculate_difference([head|tail], running_total) do
		{val1, val2} = head
		calculate_difference(tail, running_total + abs(val1 - val2))
	end

	def calculate_result(lines) do
		location_list = build_location_list(lines)
		calculate_difference(location_list, 0)
	end
end

contents = File.read!("input.txt")
lines = String.split(contents, "\n")
result = Solution.calculate_result(lines)
IO.puts("result: #{result}")
