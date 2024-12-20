defmodule Solution do
	def run_test(a) do
		b0 = Bitwise.band(a, 7)
		b1 = Bitwise.bxor(b0, 5)
		c0 = Bitwise.bsr(a, b1)
		b2 = Bitwise.bxor(b1, 6)
		b3 = Bitwise.bxor(b2, c0)
		Bitwise.band(b3, 7)
	end

	def find_valid_a_value([], _, _, init_a) do init_a end
	def find_valid_a_value(_, max_new_a, max_new_a, _) do :no_match end
	def find_valid_a_value([head|tail], new_a, max_new_a, init_a) do
		a = Bitwise.bor(new_a, Bitwise.bsl(init_a, 3))
		if run_test(a) == head do
			case find_valid_a_value(tail, 0, 8, a) do
				:no_match -> find_valid_a_value([head|tail], new_a + 1, max_new_a, init_a)
				value -> value
			end
		else
			find_valid_a_value([head|tail], new_a + 1, max_new_a, init_a)
		end
	end

	def calculate_result() do
		rprogram_listing = Enum.reverse([2,4,1,5,7,5,1,6,4,1,5,5,0,3,3,0])
		initial_max = 64 - (length(rprogram_listing) * 3) + 3
		find_valid_a_value(rprogram_listing, 0, Bitwise.bsl(1, initial_max), 0)
	end
end

result = Solution.calculate_result()
IO.puts("result: #{result}")
