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

	def process_region(region_type, {x, y}, map, visited) do
		plot = Map.get(map, {x, y})
		cond do
			plot != region_type ->
				{visited, 0, 1}
			{x, y} in visited ->
				{visited, 0, 0}
			true ->
				v = MapSet.put(visited, {x, y})
				{v1, a1, p1} = process_region(region_type, {x + 1, y}, map, v)
				{v2, a2, p2} = process_region(region_type, {x - 1, y}, map, v1)
				{v3, a3, p3} = process_region(region_type, {x, y + 1}, map, v2)
				{v4, a4, p4} = process_region(region_type, {x, y - 1}, map, v3)
				{
					v4,
					1 + a1 + a2 + a3 + a4,
					p1 + p2 + p3 + p4
				}
		end
	end

	def process_region(coord, map, visited) do
		plot = Map.get(map, coord)
		if coord in visited or plot == nil do
			{visited, 0, 0}
		else
			{new_visited, area, perim} = process_region(plot, coord, map, MapSet.new())
			{MapSet.union(new_visited, visited), area, perim}
		end
	end

	def calculate_total_price([], _, _) do 0 end
	def calculate_total_price([coord|tail], map, visited) do
		{updated_visited, area, perim} = process_region(coord, map, visited)
		(area * perim) + calculate_total_price(tail, map, updated_visited)
	end

	def calculate_total_price(contents) do
		map = build_plot_map(contents)
		all_coords = Map.keys(map)
		calculate_total_price(all_coords, map, MapSet.new())
	end
end

contents = File.read!("input.txt")
result = Solution.calculate_total_price(contents)
IO.puts("result: #{result}")
