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

	def find_next_gap(_, max, max) do nil end
	def find_next_gap(array, index, max) do
		if :array.get(index, array) == nil do
			index
		else
			find_next_gap(array, index + 1, max)
		end
	end

	def movable_file(id, files_moved) do
		id != nil and id not in files_moved
	end

	def find_file_start_size(_, _, -1, size) do {0, size} end
	def find_file_start_size(id, array, index, size) do
		if id == :array.get(index, array) do
			find_file_start_size(id, array, index - 1, size + 1)
		else
			{index + 1, size}
		end
	end
	def find_file_start_size(array, index) do
		find_file_start_size(:array.get(index, array), array, index, 0)
	end

	def find_next_file_to_move(_, _, -1) do nil end
	def find_next_file_to_move(array, files_moved, index) do
		if movable_file(:array.get(index, array), files_moved) do
			find_file_start_size(array, index)
		else
			find_next_file_to_move(array, files_moved, index - 1)
		end
	end
	def find_next_file_to_move(array, files_moved) do
		find_next_file_to_move(array, files_moved, :array.size(array) - 1)
	end

	def gap_large_enough(_, _, size, size) do true end
	def gap_large_enough(array, index, size, running_total) do
		if :array.get(index, array) == nil do
			gap_large_enough(array, index + 1, size, running_total + 1)
		else
			false
		end
	end
	def gap_large_enough(array, index, size) do
		gap_large_enough(array, index, size, 0)
	end

	def find_gap_for_file(array, index, max_index, size) do
		case find_next_gap(array, index, max_index) do
			nil -> nil
			start_index -> if gap_large_enough(array, start_index, size) do
				start_index
			else
				find_gap_for_file(array, start_index + 1, max_index, size)
			end
		end
	end

	def find_next_move_op(expanded_array, files_moved) do
		case find_next_file_to_move(expanded_array, files_moved) do
			nil ->
				nil
			{from_index, size} ->
				id = :array.get(from_index, expanded_array)
				case find_gap_for_file(expanded_array, 0, from_index, size) do
					nil -> {id, :noop}
					to_index -> {id, {from_index, to_index, size}}
				end
		end
	end

	def swap_elements(array, _, _, 0) do array end
	def swap_elements(array, i1, i2, size) do
		v1 = :array.get(i1, array)
		v2 = :array.get(i2, array)
		swap_elements(:array.set(i2, v1, :array.set(i1, v2, array)), i1 + 1, i2 + 1, size - 1)
	end

	def move_file(array, :noop) do array end
	def move_file(array, {from_index, to_index, size}) do
		swap_elements(array, from_index, to_index, size)
	end

	def defrag(expanded_array, files_moved) do
		case find_next_move_op(expanded_array, files_moved) do
			nil -> expanded_array
			{id, move_op} -> defrag(move_file(expanded_array, move_op), MapSet.put(files_moved, id))
		end
	end
	def defrag(expanded_array) do
		defrag(expanded_array, MapSet.new())
	end

	def calculate_checksum(_, max_index, max_index) do 0 end
	def calculate_checksum(defragmented_array, index, max_index) do
		value = :array.get(index, defragmented_array)
		if value == nil do
			0
		else
			index * value
		end +
		calculate_checksum(defragmented_array, index + 1, max_index)
	end

	def calculate_checksum(input) do
		expanded_input = :array.from_list(expand_input(input, :file, 0))
		defragmented_array = defrag(expanded_input)
		calculate_checksum(defragmented_array, 0, :array.size(defragmented_array))
	end
end

input = for e <- String.graphemes(File.read!("input.txt")), do: elem(Integer.parse(e), 0)
result = Solution.calculate_checksum(input)
IO.puts("result: #{result}")
