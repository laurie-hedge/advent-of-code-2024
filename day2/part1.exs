defmodule Solution do
	def build_value_change_list([_], list) do list end

	def build_value_change_list([a, b | tail], list) do
		{a_val, _} = Integer.parse(a)
		{b_val, _} = Integer.parse(b)
		build_value_change_list([b] ++ tail, list ++ [a_val - b_val])
	end

	def check_delta_values(_, []) do 1 end

	def check_delta_values(first, [head|tail]) do
		cond do
			first == 0 or head == 0 -> 0
			first > 0 != head > 0 -> 0
			abs(head) > 3 -> 0
			true -> check_delta_values(first, tail)
		end
	end

	def is_report_safe(report) do
		delta_values = build_value_change_list(String.split(report, " "), [])
		[first|_] = delta_values
		check_delta_values(first, delta_values)
	end

	def count_safe_reports([], running_total) do running_total end

	def count_safe_reports([head|tail], running_total) do
		count_safe_reports(tail, running_total + is_report_safe(head))
	end
end

contents = File.read!("input.txt")
lines = String.split(contents, "\n")
result = Solution.count_safe_reports(lines, 0)
IO.puts("result: #{result}")
