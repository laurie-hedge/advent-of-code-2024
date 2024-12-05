defmodule Solution do
	def create_ordering_rules([""|tail], rules) do { rules, tail } end
	def create_ordering_rules([head|tail], rules) do
		[b, a] = String.split(head, "|")
		create_ordering_rules(tail, rules ++ [{elem(Integer.parse(b), 0), elem(Integer.parse(a), 0)}])
	end

	def create_print_queues([]) do [] end
	def create_print_queues([head|tail]) do
		queue = for part <- String.split(head, ","), do: elem(Integer.parse(part), 0)
		[queue] ++ create_print_queues(tail)
	end

	def filter_ordering_rules(queue, ordering_rules) do
		rule_filter = fn rule ->
			{b, a} = rule
			b in queue and a in queue
		end
		Enum.filter(ordering_rules, rule_filter)
	end

	def queue_valid(_, []) do true end
	def queue_valid(queue, [rule|tail]) do
		{b, a} = rule
		bpos = Enum.find_index(queue, fn e -> e == b end)
		apos = Enum.find_index(queue, fn e -> e == a end)
		bpos < apos and queue_valid(queue, tail)
	end

	def find_invalid_queues(print_queues, ordering_rules) do
		queue_filter = fn queue ->
			not queue_valid(queue, filter_ordering_rules(queue, ordering_rules))
		end
		Enum.filter(print_queues, queue_filter)
	end

	def fix_queue([], _) do [] end
	def fix_queue(queue, applicable_rules) do
		next_index = Enum.find_index(queue, fn e ->
			rules_for_elem = Enum.filter(applicable_rules, fn {_, a} -> a == e end)
			not Enum.any?(rules_for_elem, fn {b, _} -> b in queue end)
		end)
		{value, updated_queue} = List.pop_at(queue, next_index)
		[value] ++ fix_queue(updated_queue, applicable_rules)
	end

	def fix_invalid_queues([], _) do [] end
	def fix_invalid_queues([head|tail], ordering_rules) do
		applicable_rules = filter_ordering_rules(head, ordering_rules)
		[fix_queue(head, applicable_rules)] ++ fix_invalid_queues(tail, ordering_rules)
	end

	def sum_middle_numbers([]) do 0 end
	def sum_middle_numbers([head|tail]) do
		Enum.at(head, Integer.floor_div(length(head), 2)) + sum_middle_numbers(tail)
	end

	def calculate_result(lines) do
		{ordering_rules, remaining_lines} = create_ordering_rules(lines, [])
		print_queues = create_print_queues(remaining_lines)
		invalid_queues = find_invalid_queues(print_queues, ordering_rules)
		fixed_queues = fix_invalid_queues(invalid_queues, ordering_rules)
		sum_middle_numbers(fixed_queues)
	end
end

contents = File.read!("input.txt")
lines = String.split(contents, "\n")
result = Solution.calculate_result(lines)
IO.puts("result: #{result}")
