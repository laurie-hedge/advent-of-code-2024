defmodule Solution do
	def parse_test(line) do
		[test_value_str, tail_str] = String.split(line, ": ")
		{ elem(Integer.parse(test_value_str), 0), String.split(tail_str, " ") }
	end

	def equasion_matches(test_value, op, lhs, rhs, remaining_operands) do
		case op do
			"||" ->
				test_valid_with_ops(test_value, lhs <> rhs, remaining_operands)
			"+" ->
				test_valid_with_ops(test_value,
					Integer.to_string(elem(Integer.parse(lhs), 0) + elem(Integer.parse(rhs), 0)),
					remaining_operands)
			"*" ->
				test_valid_with_ops(test_value,
					Integer.to_string(elem(Integer.parse(lhs), 0) * elem(Integer.parse(rhs), 0)),
					remaining_operands)
		end
	end

	def test_valid_with_ops(test_value, lhs, []) do
		test_value == elem(Integer.parse(lhs), 0)
	end

	def test_valid_with_ops(test_value, lhs, [rhs|tail]) do
		Enum.any?(["||", "+", "*"], fn op ->
			equasion_matches(test_value, op, lhs, rhs, tail)
		end)
	end

	def test_valid(test_value, [head|tail]) do
		test_valid_with_ops(test_value, head, tail)
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
