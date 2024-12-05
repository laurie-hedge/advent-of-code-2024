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

	def middle_value(queue) do
		Enum.at(queue, Integer.floor_div(length(queue), 2))
	end

	def sum_valid_middle_numbers([], _) do 0 end

	def sum_valid_middle_numbers([head|tail], ordering_rules) do
		applicable_rules = filter_ordering_rules(head, ordering_rules)
		value_to_add = if queue_valid(head, applicable_rules) do middle_value(head) else 0 end
		value_to_add + sum_valid_middle_numbers(tail, ordering_rules)
	end

	def calculate_result(lines) do
		{ordering_rules, remaining_lines} = create_ordering_rules(lines, [])
		print_queues = create_print_queues(remaining_lines)
		sum_valid_middle_numbers(print_queues, ordering_rules)
	end
end

contents = File.read!("input.txt")
lines = String.split(contents, "\n")
result = Solution.calculate_result(lines)
IO.puts("result: #{result}")
