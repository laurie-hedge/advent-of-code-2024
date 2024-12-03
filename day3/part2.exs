defmodule Solution do
	def calculate_sum([], running_total, _) do running_total end

	def calculate_sum(["do()"|tail], running_total, _) do
		calculate_sum(tail, running_total, true)
	end

	def calculate_sum(["don't()"|tail], running_total, _) do
		calculate_sum(tail, running_total, false)
	end

	def calculate_sum([_|tail], running_total, false) do
		calculate_sum(tail, running_total, false)
	end

	def calculate_sum([head|tail], running_total, enabled) do
		[[sval1], [sval2]] = Regex.scan(~r/\d+/, head)
		{val1, _} = Integer.parse(sval1)
		{val2, _} = Integer.parse(sval2)
		calculate_sum(tail, running_total + (val1 * val2), enabled)
	end
end

contents = File.read!("input.txt")
matches = List.flatten(Regex.scan(~r/mul\(\d\d?\d?,\d\d?\d?\)|do\(\)|don't\(\)/, contents))
result = Solution.calculate_sum(matches, 0, true)
IO.puts("result: #{result}")
