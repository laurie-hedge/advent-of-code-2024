defmodule Solution do
	def parse_raw_map([], _, _, map, trailheads) do {map, trailheads} end
	def parse_raw_map([head|tail], x, y, map, trailheads) do
		updated_trailheads = if head == "0" do
			[{x, y}] ++ trailheads
		else
			trailheads
		end
		{height, _} = Integer.parse(head)
		updated_map = Map.put(map, {x, y}, height)
		parse_raw_map(tail, x + 1, y, updated_map, updated_trailheads)
	end

	def parse_raw_map([], _, map, trailheads) do {map, trailheads} end
	def parse_raw_map([row|tail], y, map, trailheads) do
		{updated_map, updated_trailheads} = parse_raw_map(row, 0, y, map, trailheads)
		parse_raw_map(tail, y + 1, updated_map, updated_trailheads)
	end

	def parse_raw_map(raw_map) do
		parse_raw_map(raw_map, 0, %{}, [])
	end

	def find_trails(pos, 9, _) do [pos] end
	def find_trails({x, y}, height, map) do
		steps = [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
		valid_steps = Enum.filter(steps, fn step -> Map.get(map, step) == height + 1 end)
		dests = for step <- valid_steps, do: find_trails(step, height + 1, map)
		Enum.reduce(dests, [], &Kernel.++/2)
	end

	def trail_score(start_pos, map) do
		MapSet.size(MapSet.new(find_trails(start_pos, 0, map)))
	end

	def traverse_trails([], _) do [] end
	def traverse_trails([head|tail], map) do
		[trail_score(head, map)] ++ traverse_trails(tail, map)
	end

	def sum_trailhead_scores(raw_map) do
		{map, trailheads} = parse_raw_map(raw_map)
		trailhead_scores = traverse_trails(trailheads, map)
		Enum.reduce(trailhead_scores, 0, &Kernel.+/2)
	end
end

contents = File.read!("input.txt")
raw_map = for line <- String.split(contents, "\n"), do: String.graphemes(line)
result = Solution.sum_trailhead_scores(raw_map)
IO.puts("result: #{result}")
