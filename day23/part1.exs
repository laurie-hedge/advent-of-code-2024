defmodule Solution do
	def build_connection_map([]) do %{} end
	def build_connection_map([line|tail]) do
		[pc1, pc2] = String.split(line, "-")
		build_connection_map(tail) |>
		Map.update(pc1, [pc2], fn l -> [pc2] ++ l end) |>
		Map.update(pc2, [pc1], fn l -> [pc1] ++ l end)
	end

	def find_lan_groups(_, _, [], _) do [] end
	def find_lan_groups(pc1, pc2, [pc3|tail], connection_map) do
		connected_pcs = Map.get(connection_map, pc3)
		if pc1 in connected_pcs do
			[Enum.sort([pc1, pc2, pc3])]
		else
			[]
		end ++
		find_lan_groups(pc1, pc2, tail, connection_map)
	end

	def find_lan_groups(_, [], _) do [] end
	def find_lan_groups(pc1, [pc2|tail], connection_map) do
		connected_pcs = Map.get(connection_map, pc2)
		find_lan_groups(pc1, pc2, connected_pcs, connection_map) ++ find_lan_groups(pc1, tail, connection_map)
	end

	def find_lan_groups([], _) do [] end
	def find_lan_groups([pc1|tail], connection_map) do
		connected_pcs = Map.get(connection_map, pc1)
		find_lan_groups(pc1, connected_pcs, connection_map) ++ find_lan_groups(tail, connection_map)
	end

	def find_unique_lan_groups(pcs, connection_map) do
		find_lan_groups(pcs, connection_map) |> MapSet.new() |> MapSet.to_list()
	end

	def calculate_result(lines) do
		connection_map = build_connection_map(lines)
		lan_groups = find_unique_lan_groups(Map.keys(connection_map), connection_map)
		Enum.count(lan_groups, fn group -> Enum.any?(group, fn pc -> String.starts_with?(pc, "t") end) end)
	end
end

contents = File.read!("input.txt")
lines = String.split(contents, "\n")
result = Solution.calculate_result(lines)
IO.puts("result: #{result}")
