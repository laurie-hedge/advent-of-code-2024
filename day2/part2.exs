defmodule Solution do
	def build_value_change_list([_], list) do list end

	def build_value_change_list([a, b | tail], list) do
		build_value_change_list([b] ++ tail, list ++ [a - b])
	end

	def delta_values_are_safe(_, []) do true end

	def delta_values_are_safe(first, [head|tail]) do
		cond do
			first == 0 or head == 0 -> false
			first > 0 != head > 0 -> false
			abs(head) > 3 -> false
			true -> delta_values_are_safe(first, tail)
		end
	end

	def check_safety_with_problem_dampener(report_values, removed_index) do
		modified_value_list = if removed_index == -1 do report_values else List.delete_at(report_values, removed_index) end
		delta_values = build_value_change_list(modified_value_list, [])
		[first|_] = delta_values
		cond do
			delta_values_are_safe(first, delta_values) -> 1
			length(report_values) == removed_index + 1 -> 0
			true -> check_safety_with_problem_dampener(report_values, removed_index + 1)
		end
	end

	def parse_int(sval) do
		{val, _} = Integer.parse(sval)
		val
	end

	def is_report_safe(report) do
		report_values = for sval <- String.split(report, " "), do: parse_int(sval)
		check_safety_with_problem_dampener(report_values, -1)
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
