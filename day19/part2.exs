defmodule ResultCache do
	def launch() do
		run(%{})
	end

	def run(cache) do
		receive do
			{:check, sender, pattern} ->
				send(sender, {:check_resp, Map.get(cache, pattern)})
				run(cache)
			{:add, pattern, result} ->
				run(Map.put(cache, pattern, result))
		end
	end
end

defmodule Solution do
	def count_ways("", _, _, _) do 1 end
	def count_ways(_, [], _, _) do 0 end
	def count_ways(pattern, [towel|tail], available_towels, result_cache) do
		send(result_cache, {:check, self(), pattern})
		receive do
			{:check_resp, nil} ->
				result = if String.starts_with?(pattern, towel) do
					count_ways(String.slice(pattern, String.length(towel)..-1), available_towels, available_towels, result_cache)
				else
					0
				end +
				count_ways(pattern, tail, available_towels, result_cache)
				send(result_cache, {:add, pattern, result})
				result
			{:check_resp, ways} -> ways
		end
	end

	def count_ways(pattern, available_towels, result_cache) do
		towel_shortlist = Enum.filter(available_towels, fn towel -> String.contains?(pattern, towel) end)
		count_ways(pattern, towel_shortlist, towel_shortlist, result_cache)
	end

	def calculate_result(contents) do
		result_cache = spawn(ResultCache, :launch, [])
		[available_part, patterns_part] = String.split(contents, "\n\n")
		available_towels = String.split(available_part, ", ")
		patterns = String.split(patterns_part, "\n")
		Enum.reduce(patterns, 0, fn pattern, acc -> acc + count_ways(pattern, available_towels, result_cache) end)
	end
end

contents = File.read!("input.txt")
result = Solution.calculate_result(contents)
IO.puts("result: #{result}")
