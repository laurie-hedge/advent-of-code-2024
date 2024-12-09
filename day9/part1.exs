defmodule Solution do
	def expanded_block(0, _) do [] end
	def expanded_block(size, id) do
		for _ <- 1..size, do: id
	end

	def expand_input([], _, _) do [] end
	def expand_input([size|tail], type, id) do
		case type do
			:file -> expanded_block(size, id) ++ expand_input(tail, :space, id + 1)
			:space -> expanded_block(size, :nil) ++ expand_input(tail, :file, id)
		end
	end

	def find_next_gap(_, max, max) do :nil end
	def find_next_gap(array, index, max) do
		if :array.get(index, array) == :nil do
			index
		else
			find_next_gap(array, index + 1, max)
		end
	end
	def find_next_gap(array, start) do
		find_next_gap(array, start, :array.size(array))
	end

	def find_next_reloc(_, -1) do :nil end
	def find_next_reloc(array, index) do
		if :array.get(index, array) != :nil do
			index
		else
			find_next_reloc(array, index - 1)
		end
	end

	def swap_elements(array, i1, i2) do
		v1 = :array.get(i1, array)
		v2 = :array.get(i2, array)
		:array.set(i2, v1, :array.set(i1, v2, array))
	end

	def defrag(expanded_array, gap_search_start, reloc_search_start) do
		next_gap = find_next_gap(expanded_array, gap_search_start)
		next_to_reloc = find_next_reloc(expanded_array, reloc_search_start)
		if next_gap < next_to_reloc do
			defrag(swap_elements(expanded_array, next_gap, next_to_reloc), next_gap, next_to_reloc)
		else
			expanded_array
		end
	end
	def defrag(expanded_array) do
		defrag(expanded_array, 0, :array.size(expanded_array) - 1)
	end

	def calculate_checksum(defragmented_array, index) do
		value = :array.get(index, defragmented_array)
		if value == :nil do
			0
		else
			index * value + calculate_checksum(defragmented_array, index + 1)
		end
	end

	def calculate_checksum(input) do
		expanded_input = :array.from_list(expand_input(input, :file, 0))
		defragmented_array = defrag(expanded_input)
		calculate_checksum(defragmented_array, 0)
	end
end

input = for e <- String.graphemes(File.read!("input.txt")), do: elem(Integer.parse(e), 0)
result = Solution.calculate_checksum(input)
IO.puts("result: #{result}")
