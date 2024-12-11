defmodule Solution do
	def count_after_blinks(_, 0) do 1 end
	def count_after_blinks(stone, blinks) do
		stone_str = Integer.to_string(stone)
		slen = String.length(stone_str)
		cond do
			stone == 0 ->
				count_after_blinks(1, blinks - 1)
			rem(slen, 2) == 0 ->
				{lhs, rhs} = String.split_at(stone_str, Integer.floor_div(slen, 2))
				count_after_blinks(elem(Integer.parse(lhs), 0), blinks - 1) +
					count_after_blinks(elem(Integer.parse(rhs), 0), blinks - 1)
			true ->
				count_after_blinks(stone * 2024, blinks - 1)
		end
	end

	def count_stones_after_blinks(stones) do
		Enum.reduce(stones, 0, fn stone, acc -> count_after_blinks(stone, 25) + acc end)
	end
end

contents = File.read!("input.txt")
stones = for e <- String.split(contents, " "), do: elem(Integer.parse(e), 0)
result = Solution.count_stones_after_blinks(stones)
IO.puts("result: #{result}")
