defmodule Solution do
	def calculate_sum([], running_total) do running_total end

	def calculate_sum([head|tail], running_total) do
		[[sval1], [sval2]] = Regex.scan(~r/\d+/, head)
		{val1, _} = Integer.parse(sval1)
		{val2, _} = Integer.parse(sval2)
		calculate_sum(tail, running_total + (val1 * val2))
	end
end

contents = File.read!("input.txt")
matches = List.flatten(Regex.scan(~r/mul\(\d\d?\d?,\d\d?\d?\)/, contents))
result = Solution.calculate_sum(matches, 0)
IO.puts("result: #{result}")
