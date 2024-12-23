defmodule Solution do
	def build_connection_map([]) do %{} end
	def build_connection_map([line|tail]) do
		[pc1, pc2] = String.split(line, "-")
		build_connection_map(tail) |>
		Map.update(pc1, [pc2], fn l -> [pc2] ++ l end) |>
		Map.update(pc2, [pc1], fn l -> [pc1] ++ l end)
	end

	def pcs_to_add([pc], connection_map) do
		Map.get(connection_map, pc) |> MapSet.new()
	end
	def pcs_to_add([pc|tail], connection_map) do
		Map.get(connection_map, pc) |> MapSet.new() |> MapSet.intersection(pcs_to_add(tail, connection_map))
	end

	def expand_lans([], _) do [] end
	def expand_lans([lan|tail], connection_map) do
		for pc <- MapSet.to_list(pcs_to_add(lan, connection_map)) do
			Enum.sort(if pc not in lan do [pc] else [] end ++ lan)
		end ++ expand_lans(tail, connection_map)
	end

	def make_unique(lans) do
		lans |> MapSet.new() |> MapSet.to_list()
	end

	def find_largest_lan_group(lans, connection_map) do
		updated_lans = expand_lans(lans, connection_map) |> make_unique()
		if length(updated_lans) == 1 do
			Enum.at(updated_lans, 0)
		else
			find_largest_lan_group(updated_lans, connection_map)
		end
	end

	def find_largest_lan_group(connection_map) do
		for pc <- Map.keys(connection_map) do [pc] end |> find_largest_lan_group(connection_map)
	end

	def calculate_result(lines) do
		build_connection_map(lines) |> find_largest_lan_group() |> Enum.sort() |> Enum.join(",")
	end
end

contents = File.read!("input.txt")
lines = String.split(contents, "\n")
result = Solution.calculate_result(lines)
IO.puts("result: #{result}")
