defmodule ScoreTracker do
	def launch() do
		run(%{})
	end

	def run(best_scores) do
		updated_scores = receive do
			{:visit, sender, pos, dir, score} ->
				case Map.get(best_scores, {pos, dir}) do
					nil ->
						send(sender, :ok)
						Map.put(best_scores, {pos, dir}, score)
					best_score ->
						if best_score < score do
							send(sender, :stop)
							best_scores
						else
							send(sender, :ok)
							Map.replace(best_scores, {pos, dir}, score)
						end
				end
		end
		run(updated_scores)
	end
end

defmodule Solution do
	def build_map([], _, _) do %{} end
	def build_map([head|tail], x, y) do
		new_map = case head do
			"#" -> %{{x, y} => :wall}
			"." -> %{}
			"E" -> %{{x, y} => :exit}
			"S" -> %{:start => {x, y}}
		end
		Map.merge(new_map, build_map(tail, x + 1, y))
	end

	def build_map([], _) do %{} end
	def build_map([row|tail], y) do
		Map.merge(build_map(String.graphemes(row), 0, y), build_map(tail, y + 1))
	end

	def build_map(lines) do
		build_map(lines, 0)
	end

	def rotation_cost(cdir, ndir) do
		ns = [:north, :south]
		ew = [:east, :west]
		cond do
			cdir == ndir -> 0
			cdir in ns and ndir in ns -> 2000
			cdir in ew and ndir in ew -> 2000
			true -> 1000
		end
	end

	def next_step({px, py}, cdir, ndir, score) do
		npos = case ndir do
			:north -> {px, py - 1}
			:south -> {px, py + 1}
			:east  -> {px + 1, py}
			:west  -> {px - 1, py}
		end
		nscore = score + 1 + rotation_cost(cdir, ndir)
		{npos, ndir, nscore}
	end

	def traverse_map(pos, dir, map, score_tracker, score, visited) do
		send(score_tracker, {:visit, self(), pos, dir, score})
		receive do
			:stop ->
				nil
			:ok ->
				case Map.get(map, pos) do
					:exit ->
						{score, MapSet.put(visited, pos)}
					:wall ->
						nil
					nil ->
						directions = [:north, :south, :east, :west]
						next_steps = for d <- directions, do: next_step(pos, dir, d, score)
						results = for {npos, ndir, nscore} <- next_steps, do: traverse_map(npos, ndir, map, score_tracker, nscore, MapSet.put(visited, pos))
						valid_results = Enum.filter(results, fn result -> result != nil end)
						if length(valid_results) > 0 do
							valid_scores = for {s, _} <- valid_results, do: s
							lowest = Enum.min(valid_scores, &Kernel.<=/2, fn -> nil end)
							shortest_path_results = Enum.filter(valid_results, fn {s, _} -> s == lowest end)
							shortest_paths = for {_, v} <- shortest_path_results, do: v
							updated_visited = Enum.reduce(shortest_paths, fn ms, acc -> MapSet.union(ms, acc) end)
							{lowest, updated_visited}
						else
							nil
						end
				end
		end
	end

	def find_num_tiles_on_best_paths(lines) do
		map = build_map(lines)
		start = Map.get(map, :start)
		score_tracker = spawn(ScoreTracker, :launch, [])
		{_, visited} = traverse_map(start, :east, map, score_tracker, 0, MapSet.new())
		MapSet.size(visited)
	end
end

contents = File.read!("input.txt")
lines = String.split(contents, "\n")
result = Solution.find_num_tiles_on_best_paths(lines)
IO.puts("result: #{result}")
