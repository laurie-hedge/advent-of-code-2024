defmodule Solution do
	def parse_pin_lines([], pins) do pins end
	def parse_pin_lines([line|tail], pins) do
		parse_pin_lines(tail,
			for {c, p} <- Enum.zip([String.graphemes(line), pins]) do
				if c == "#" do
					p + 1
				else
					p
				end
			end
		)
	end

	def parse_pin_lines(lines) do
		parse_pin_lines(lines, [0, 0, 0, 0, 0])
	end

	def count_locks_matching_key(_, []) do 0 end
	def count_locks_matching_key(key, [lock|tail]) do
		total_sizes = for {k, l} <- Enum.zip([key, lock]), do: k + l
		if Enum.any?(total_sizes, fn size -> size > 5 end) do
			0
		else
			1
		end +
		count_locks_matching_key(key, tail)
	end

	def count_possible_key_lock_pairs([], _) do 0 end
	def count_possible_key_lock_pairs([key|tail], locks) do
		count_locks_matching_key(key, locks) + count_possible_key_lock_pairs(tail, locks)
	end

	def calculate_result(contents) do
		schematics = for block <- String.split(contents, "\n\n") do
			lines = String.split(block, "\n")
			if Enum.at(lines, 0) == "#####" do
				{
					:lock,
					lines |> Enum.slice(1..-1) |> parse_pin_lines()
				}
			else
				{
					:key,
					lines |> Enum.reverse() |> Enum.slice(1..-1) |> parse_pin_lines()
				}
			end
		end
		groups = Enum.group_by(schematics, fn {type, _} -> type end, fn {_, pins} -> pins end)
		keys = Map.get(groups, :key)
		locks = Map.get(groups, :lock)
		count_possible_key_lock_pairs(keys, locks)
	end
end

contents = File.read!("input.txt")
result = Solution.calculate_result(contents)
IO.puts("result: #{result}")
