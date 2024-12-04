defmodule Solution do
	def filter_directions([], _, _, _, _, _, list) do list end

	def filter_directions([head|tail], x, y, width, height, word_length, list) do
		{dx, dy} = head
		endx = x + ((word_length - 1) * dx)
		endy = y + ((word_length - 1) * dy)
		if endx < 0 or endx >= width or endy < 0 or endy >= height do
			filter_directions(tail, x, y, width, height, word_length, list)
		else
			filter_directions(tail, x, y, width, height, word_length, list ++ [head])
		end
	end

	def count_from_coords_in_dir(_, [], _, _, _) do 1 end

	def count_from_coords_in_dir(dir, [char|rest], wordsearch, x, y) do
		if char == Enum.at(Enum.at(wordsearch, y), x) do
			{dx, dy} = dir
			count_from_coords_in_dir(dir, rest, wordsearch, x + dx, y + dy)
		else
			0
		end
	end

	def count_from_coords([], _, _, _, _) do 0 end

	def count_from_coords([dir|tail], word, wordsearch, x, y) do
		count_from_coords_in_dir(dir, word, wordsearch, x, y) + count_from_coords(tail, word, wordsearch, x ,y)
	end

	def count_words(_, _, _, height, _, height, running_total) do
		running_total
	end

	def count_words(word, wordsearch, width, y, width, height, running_total) do
		count_words(word, wordsearch, 0, y + 1, width, height, running_total)
	end

	def count_words(word, wordsearch, x, y, width, height, running_total) do
		direction_vectors = [{1, 0}, {1, 1}, {0, 1}, {-1, 1}, {-1, 0}, {-1, -1}, {0, -1}, {1, -1}]
		directions_to_check = filter_directions(direction_vectors, x, y, width, height, length(word), [])
		new_occurences = count_from_coords(directions_to_check, word, wordsearch, x, y)
		count_words(word, wordsearch, x + 1, y, width, height, running_total + new_occurences)
	end

	def solve_wordsearch(wordsearch) do
		width  = length(Enum.at(wordsearch, 0))
		height = length(wordsearch)
		count_words(String.graphemes("XMAS"), wordsearch, 0, 0, width, height, 0)
	end
end

contents = File.read!("input.txt")
wordsearch = for line <- String.split(contents, "\n"), do: String.graphemes(line)
result = Solution.solve_wordsearch(wordsearch)
IO.puts("result: #{result}")
