defmodule Wire do
	def launch(name) do
		run(name, :x, [])
	end

	def broadcast_value([], _) do :ok end
	def broadcast_value([output|tail], packet) do
		send(output, {:input, packet})
		broadcast_value(tail, packet)
	end

	def run(name, value, outputs) do
		receive do
			{:add_output, output} ->
				run(name, value, [output] ++ outputs)
			{:set, nvalue} ->
				broadcast_value(outputs, {name, nvalue})
				run(name, nvalue, outputs)
		end
	end
end

defmodule Gate do
	def launch(w0, w1, gate, output_wire) do
		run({w0, :x}, {w1, :x}, gate, output_wire)
	end

	def eval(v0, v1, gate, output_wire) do
		if :x not in [v0, v1] do
			send(output_wire, {:set,
				case gate do
					"AND" -> Bitwise.band(v0, v1)
					"XOR" -> Bitwise.bxor(v0, v1)
					"OR"  -> Bitwise.bor(v0, v1)
				end
			})
		end
	end

	def run({w0n, w0v}, {w1n, w1v}, gate, output_wire) do
		receive do
			{:input, {from_name, value}} ->
				cond do
					from_name == w0n ->
						eval(value, w1v, gate, output_wire)
						run({w0n, value}, {w1n, w1v}, gate, output_wire)
					from_name == w1n ->
						eval(w0v, value, gate, output_wire)
						run({w0n, w0v}, {w1n, value}, gate, output_wire)
				end
		end
	end
end

defmodule OutputNode do
	def launch(sim_host) do
		run(sim_host, %{})
	end

	def build_stable_value([]) do 0 end
	def build_stable_value([{wire_name, value}|tail]) do
		{shift, _} = Integer.parse(String.trim(wire_name, "z"))
		Bitwise.bor(Bitwise.bsl(value, shift), build_stable_value(tail))
	end

	def eval(sim_host, inputs) do
		input_list = Map.to_list(inputs)
		if not Enum.any?(input_list, fn {_, v} -> v == :x end) do
			send(sim_host, {:stable_value, build_stable_value(input_list)})
		end
	end

	def run(sim_host, inputs) do
		receive do
			{:add_input, wire} ->
				run(sim_host, Map.put(inputs, wire, :x))
			{:input, {from_name, value}} ->
				updated_inputs = Map.replace!(inputs, from_name, value)
				eval(sim_host, updated_inputs)
				run(sim_host, updated_inputs)
		end
	end
end

defmodule Solution do
	def parse_logic_lines([]) do [] end
	def parse_logic_lines([line|tail]) do
		[w0, gate, w1, _, output_wire] = String.split(line, " ")
		[{w0, w1, gate, output_wire}] ++ parse_logic_lines(tail)
	end

	def find_unique_wires([]) do MapSet.new() end
	def find_unique_wires([{w0, w1, _, w2}|tail]) do
		MapSet.new([w0, w1, w2]) |>
		MapSet.union(find_unique_wires(tail))
	end

	def build_wire_map([]) do %{} end
	def build_wire_map([wire|tail]) do
		map = build_wire_map(tail)
		if wire in map do
			map
		else
			Map.put(map, wire, spawn(Wire, :launch, [wire]))
		end
	end

	def add_output_node_input([], _, _) do :ok end
	def add_output_node_input([wire|tail], wire_map, output_node) do
		send(output_node, {:add_input, wire})
		send(Map.get(wire_map, wire), {:add_output, output_node})
		add_output_node_input(tail, wire_map, output_node)
	end

	def add_output_node_input(wire_map) do
		output_node = spawn(OutputNode, :launch, [self()])
		output_wires = wire_map |> Map.keys() |> Enum.filter(fn wire -> wire |> String.starts_with?("z") end)
		add_output_node_input(output_wires, wire_map, output_node)
	end

	def build_logic_gates([], _) do :ok end
	def build_logic_gates([{w0, w1, gate, output_wire}|tail], wire_map) do
		gate_pid = spawn(Gate, :launch, [w0, w1, gate, Map.get(wire_map, output_wire)])
		send(Map.get(wire_map, w0), {:add_output, gate_pid})
		send(Map.get(wire_map, w1), {:add_output, gate_pid})
		build_logic_gates(tail, wire_map)
	end

	def build_circuit_sim(logic_part) do
		logic_lines = parse_logic_lines(String.split(logic_part, "\n"))
		wire_map = logic_lines |> find_unique_wires() |> MapSet.to_list() |> build_wire_map()
		add_output_node_input(wire_map)
		build_logic_gates(logic_lines, wire_map)
		wire_map
	end

	def set_input_values([], _) do :ok end
	def set_input_values([line|tail], wire_map) do
		[wire, svalue] = String.split(line, ": ")
		{value, _} = Integer.parse(svalue)
		send(Map.get(wire_map, wire), {:set, value})
		set_input_values(tail, wire_map)
	end

	def calculate_result(contents) do
		[reset_part, logic_part] = String.split(contents, "\n\n")
		wire_map = build_circuit_sim(logic_part)
		set_input_values(String.split(reset_part, "\n"), wire_map)
		receive do
			{:stable_value, value} -> value
		end
	end
end

contents = File.read!("input.txt")
result = Solution.calculate_result(contents)
IO.puts("result: #{result}")
