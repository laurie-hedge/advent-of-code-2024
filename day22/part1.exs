defmodule Solution do
	def mix(lhs, rhs) do
		Bitwise.bxor(lhs, rhs)
	end

	def prune(value) do
		Integer.mod(value, 16777216)
	end

	def generate_secret_number(start_value, 0) do
		start_value
	end
	def generate_secret_number(start_value, iterations_remaining) do
		sn1 = prune(mix(start_value, start_value * 64))
		sn2 = prune(mix(sn1, Bitwise.bsr(sn1, 5)))
		sn3 = prune(mix(sn2, Bitwise.bsl(sn2, 11)))
		generate_secret_number(sn3, iterations_remaining - 1)
	end

	def calculate_result([]) do 0 end
	def calculate_result([head|tail]) do
		{value, _} = Integer.parse(head)
		generate_secret_number(value, 2000) + calculate_result(tail)
	end
end

contents = File.read!("input.txt")
lines = String.split(contents, "\n")
result = Solution.calculate_result(lines)
IO.puts("result: #{result}")
