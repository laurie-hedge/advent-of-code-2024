defmodule ResultCache do
	def loop(cache) do
		receive do
			{:add, {key, value}} ->
				loop(Map.put(cache, key, value))
			{:query, src, key} ->
				send(src, Map.get(cache, key))
				loop(cache)
			:end ->
				:ok
		end
	end

	def run() do
		loop(%{})
	end
end

defmodule Solution do
	def count_after_blinks(_, _, 0) do 1 end
	def count_after_blinks(cache, stone, blinks) do
		key = {blinks, stone}
		send(cache, {:query, self(), key})
		receive do
			nil ->
				result = if stone == 0 do
					count_after_blinks(cache, 1, blinks - 1)
				else
					stone_str = Integer.to_string(stone)
					slen = String.length(stone_str)
					if rem(slen, 2) == 0 do
						{lhs, rhs} = String.split_at(stone_str, Integer.floor_div(slen, 2))
						count_after_blinks(cache, elem(Integer.parse(lhs), 0), blinks - 1) +
							count_after_blinks(cache, elem(Integer.parse(rhs), 0), blinks - 1)
					else
						count_after_blinks(cache, stone * 2024, blinks - 1)
					end
				end
				send(cache, {:add, {key, result}})
				result
			count ->
				count
		end
	end

	def count_stones_after_blinks(stones, cache) do
		Enum.reduce(stones, 0, fn stone, acc -> count_after_blinks(cache, stone, 75) + acc end)
	end
end

contents = File.read!("input.txt")
stones = for e <- String.split(contents, " "), do: elem(Integer.parse(e), 0)
cache = spawn(ResultCache, :run, [])
result = Solution.count_stones_after_blinks(stones, cache)
send(cache, :end)
IO.puts("result: #{result}")
