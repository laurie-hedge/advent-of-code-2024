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
	def pattern_valid("", _, _, _) do true end
	def pattern_valid(_, [], _, _) do false end
	def pattern_valid(pattern, [towel|tail], available_towels, result_cache) do
		send(result_cache, {:check, self(), pattern})
		receive do
			{:check_resp, nil} ->
				result = (
					String.starts_with?(pattern, towel) and
					pattern_valid(String.slice(pattern, String.length(towel)..-1), available_towels, available_towels, result_cache)
				) or pattern_valid(pattern, tail, available_towels, result_cache)
				send(result_cache, {:add, pattern, result})
				result
			{:check_resp, result} -> result
		end
	end

	def pattern_valid(pattern, available_towels, result_cache) do
		towel_shortlist = Enum.filter(available_towels, fn towel -> String.contains?(pattern, towel) end)
		pattern_valid(pattern, towel_shortlist, towel_shortlist, result_cache)
	end

	def calculate_result(contents) do
		result_cache = spawn(ResultCache, :launch, [])
		[available_part, patterns_part] = String.split(contents, "\n\n")
		available_towels = String.split(available_part, ", ")
		patterns = String.split(patterns_part, "\n")
		Enum.count(patterns, fn pattern -> pattern_valid(pattern, available_towels, result_cache) end)
	end
end

contents = File.read!("input.txt")
result = Solution.calculate_result(contents)
IO.puts("result: #{result}")
