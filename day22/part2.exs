defmodule Solution do
	def mix(lhs, rhs) do
		Bitwise.bxor(lhs, rhs)
	end

	def prune(value) do
		Integer.mod(value, 16777216)
	end

	def get_price(value) do
		Integer.mod(value, 10)
	end

	def generate_prices(start_value, 0) do
		[get_price(start_value)]
	end
	def generate_prices(start_value, iterations_remaining) do
		sn1 = prune(mix(start_value, start_value * 64))
		sn2 = prune(mix(sn1, Bitwise.bsr(sn1, 5)))
		sn3 = prune(mix(sn2, Bitwise.bsl(sn2, 11)))
		[get_price(start_value)] ++ generate_prices(sn3, iterations_remaining - 1)
	end

	def generate_price_changes(_, []) do [] end
	def generate_price_changes(a, [b|tail]) do
		[{b, b - a}] ++ generate_price_changes(b, tail)
	end

	def generate_price_changes([a, b|tail]) do
		[{b, b - a}] ++ generate_price_changes(b, tail)
	end

	def generate_sequence_score_map([_, _, _]) do %{} end
	def generate_sequence_score_map([{_, da}, {pb, db}, {pc, dc}, {pd, dd}|tail]) do
		Map.put(
			generate_sequence_score_map([{pb, db}, {pc, dc}, {pd, dd}|tail]),
			{da, db, dc, dd}, pd
		)
	end

	def build_score_map([]) do %{} end
	def build_score_map([head|tail]) do
		{value, _} = Integer.parse(head)
		prices = generate_prices(value, 2000)
		price_changes = generate_price_changes(prices)
		sequence_score_map = generate_sequence_score_map(price_changes)
		Map.merge(
			sequence_score_map,
			build_score_map(tail),
			fn _, v1, v2 -> v1 + v2 end
		)
	end

	def calculate_result(lines) do
		score_map = build_score_map(lines)
		{_, best_score} = Enum.max(
			score_map,
			fn {_, lhs}, {_, rhs} -> lhs >= rhs end
		)
		best_score
	end
end

contents = File.read!("input.txt")
lines = String.split(contents, "\n")
result = Solution.calculate_result(lines)
IO.puts("result: #{result}")
