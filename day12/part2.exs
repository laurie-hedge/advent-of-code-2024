defmodule Solution do
	def build_plot_map([], _, _) do %{} end
	def build_plot_map([plot|tail], x, y) do
		Map.put(
			build_plot_map(tail, x + 1, y),
			{x, y}, plot
		)
	end

	def build_plot_map([], _) do %{} end
	def build_plot_map([row|tail], y) do
		Map.merge(
			build_plot_map(String.graphemes(row), 0, y),
			build_plot_map(tail, y + 1)
		)
	end

	def build_plot_map(contents) do
		rows = String.split(contents, "\n")
		build_plot_map(rows, 0)
	end

	def process_region(region_type, {x, y}, map, region) do
		plot = Map.get(map, {x, y})
		if plot != region_type or {x, y} in region do
			region
		else
			process_region(region_type, {x, y - 1}, map,
				process_region(region_type, {x, y + 1}, map,
					process_region(region_type, {x - 1, y}, map,
						process_region(region_type, {x + 1, y}, map, [{x, y}] ++ region)
					)
				)
			)
		end
	end

	def process_region(coord, map) do
		process_region(Map.get(map, coord), coord, map, [])
	end

	def find_regions([], _, _) do [] end
	def find_regions([coord|tail], map, visited) do
		if coord in visited do
			find_regions(tail, map, visited)
		else
			region = process_region(coord, map)
			[region] ++ find_regions(tail, map, MapSet.union(visited, MapSet.new(region)))
		end
	end

	def find_edge_with({x0, y0}, {x1, y1}, region) do
		cond do
			{x1, y1} in region -> []
			x1 < x0 -> [{:v, :b, {x0, y0}}]
			x0 < x1 -> [{:v, :a, {x1, y0}}]
			y1 < y0 -> [{:h, :b, {x0, y0}}]
			y0 < y1 -> [{:h, :a, {x0, y1}}]
		end
	end

	def find_edges_for_patch({x, y}, region) do
		find_edge_with({x, y}, {x + 1, y}, region) ++
		find_edge_with({x, y}, {x - 1, y}, region) ++
		find_edge_with({x, y}, {x, y + 1}, region) ++
		find_edge_with({x, y}, {x, y - 1}, region)
	end

	def find_edges([], _) do [] end
	def find_edges([head|tail], region) do
		find_edges_for_patch(head, region) ++ find_edges(tail, region)
	end

	def find_edges(region) do
		find_edges(region, region)
	end

	def next(edge, dir) do
		case edge do
			{:v, _, _} -> {0, dir}
			{:h, _, _} -> {dir, 0}
		end
	end

	def move({d, s, {x, y}}, {dx, dy}) do
		{d, s, {x + dx, y + dy}}
	end

	def extend_edge(start, edge_set, dir) do
		nedge = move(start, dir)
		if nedge in edge_set do
			[start] ++ extend_edge(nedge, edge_set, dir)
		else
			[start]
		end
	end

	def build_sides_from_edges([], _) do [] end
	def build_sides_from_edges([edge|tail], edge_set) do
		if edge in edge_set do
			side = extend_edge(edge, edge_set, next(edge, -1)) ++
			       extend_edge(edge, edge_set, next(edge, 1))
			[side] ++ build_sides_from_edges(tail, MapSet.difference(edge_set, MapSet.new(side)))
		else
			build_sides_from_edges(tail, edge_set)
		end
	end

	def build_sides_from_edges(edges) do
		build_sides_from_edges(edges, MapSet.new(edges))
	end

	def region_price(region) do
		area = length(region)
		edges = find_edges(region)
		sides = build_sides_from_edges(edges)
		area * length(sides)
	end

	def calculate_total_price(contents) do
		map = build_plot_map(contents)
		all_coords = Map.keys(map)
		regions = find_regions(all_coords, map, MapSet.new())
		Enum.sum(for region <- regions, do: region_price(region))
	end
end

contents = File.read!("input.txt")
result = Solution.calculate_total_price(contents)
IO.puts("result: #{result}")
