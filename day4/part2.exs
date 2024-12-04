defmodule Solution do
	def char_at(wordsearch, x, y) do
		Enum.at(Enum.at(wordsearch, y), x)
	end

	def count_word_cross(word, s1, s2) do
		s1_matches = word == s1 or word == String.reverse(s1)
		s2_matches = word == s2 or word == String.reverse(s2)
		if s1_matches and s2_matches do
			1
		else
			0
		end
	end

	def count_words(_, _, _, max_y, _, max_y, running_total) do
		running_total
	end

	def count_words(word, wordsearch, max_x, y, max_x, max_y, running_total) do
		count_words(word, wordsearch, 0, y + 1, max_x, max_y, running_total)
	end

	def count_words(word, wordsearch, x, y, max_x, max_y, running_total) do
		s1 = char_at(wordsearch, x, y) <> char_at(wordsearch, x + 1, y + 1) <> char_at(wordsearch, x + 2, y + 2)
		s2 = char_at(wordsearch, x + 2, y) <> char_at(wordsearch, x + 1, y + 1) <> char_at(wordsearch, x, y + 2)
		new_occurences = count_word_cross(word, s1, s2)
		count_words(word, wordsearch, x + 1, y, max_x, max_y, running_total + new_occurences)
	end

	def solve_wordsearch(wordsearch) do
		max_x  = length(Enum.at(wordsearch, 0)) - 2
		max_y = length(wordsearch) - 2
		count_words("MAS", wordsearch, 0, 0, max_x, max_y, 0)
	end
end

contents = File.read!("input.txt")
wordsearch = for line <- String.split(contents, "\n"), do: String.graphemes(line)
result = Solution.solve_wordsearch(wordsearch)
IO.puts("result: #{result}")
