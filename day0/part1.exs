defmodule Solution do
	def print_lines([]) do :ok end

	def print_lines([head|tail]) do
		IO.puts(head)
		print_lines(tail)
	end
end

contents = File.read!("input.txt")
lines = String.split(contents, "\n")
Solution.print_lines(lines)
