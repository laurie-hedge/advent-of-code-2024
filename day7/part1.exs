defmodule Solution do
	def parse_test(line) do
		[test_value_str, tail_str] = String.split(line, ": ")
		test_value = elem(Integer.parse(test_value_str), 0)
		inputs = Enum.reverse(for i <- String.split(tail_str, " "), do: elem(Integer.parse(i), 0))
		{ test_value, inputs }
	end

	def calculate_test_result([last], _) do last end
	def calculate_test_result([head|tail], op_mask) do
		if Bitwise.band(op_mask, 1) == 1 do
			head * calculate_test_result(tail, Bitwise.bsr(op_mask, 1))
		else
			head + calculate_test_result(tail, Bitwise.bsr(op_mask, 1))
		end
	end

	def test_valid(_, _, -1) do false end
	def test_valid(test_value, inputs, op_mask) do
		value = calculate_test_result(inputs, op_mask)
		value == test_value or test_valid(test_value, inputs, op_mask - 1)
	end

	def test_valid(test_value, inputs) do
		op_mask = Bitwise.bsl(1, length(inputs) - 1) - 1
		test_valid(test_value, inputs, op_mask)
	end

	def sum_valid_test_values([]) do 0 end
	def sum_valid_test_values([head|tail]) do
		{test_value, inputs} = parse_test(head)
		value = if test_valid(test_value, inputs) do test_value else 0 end
		value + sum_valid_test_values(tail)
	end
end

contents = File.read!("input.txt")
lines = String.split(contents, "\n")
result = Solution.sum_valid_test_values(lines)
IO.puts("result: #{result}")
