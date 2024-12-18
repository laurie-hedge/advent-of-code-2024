defmodule RegisterFile do
	def launch(reg_string) do
		[l1, l2, l3] = String.split(reg_string, "\n")
		[_, _, reg_a_value_str] = String.split(l1, " ")
		[_, _, reg_b_value_str] = String.split(l2, " ")
		[_, _, reg_c_value_str] = String.split(l3, " ")
		{a, _} = Integer.parse(reg_a_value_str)
		{b, _} = Integer.parse(reg_b_value_str)
		{c, _} = Integer.parse(reg_c_value_str)
		run(a, b, c)
	end

	def run(a, b, c) do
		receive do
			{:read, sender, reg} ->
				value = case reg do
					:A -> a
					:B -> b
					:C -> c
				end
				send(sender, {:read_resp, value})
				run(a, b, c)
			{:write, :A, value} ->
				run(value, b, c)
			{:write, :B, value} ->
				run(a, value, c)
			{:write, :C, value} ->
				run(a, b, value)
		end
	end
end

defmodule Solution do
	def read_reg(reg_file, reg) do
		send(reg_file, {:read, self(), reg})
		receive do
			{:read_resp, value} -> value
		end
	end

	def write_reg(reg_file, reg, value) do
		send(reg_file, {:write, reg, value})
	end

	def read_combo_operand(reg_file, operand) do
		case operand do
			0 -> 0
			1 -> 1
			2 -> 2
			3 -> 3
			4 -> read_reg(reg_file, :A)
			5 -> read_reg(reg_file, :B)
			6 -> read_reg(reg_file, :C)
		end
	end

	def run_instruction(mem, reg_file, pc) do
		opcode = :array.get(pc, mem)
		operand = :array.get(pc + 1, mem)
		case opcode do
			0 ->
				write_reg(reg_file, :A, Integer.floor_div(
					read_reg(reg_file, :A),
					Integer.pow(2, read_combo_operand(reg_file, operand))))
				{pc + 2, []}
			1 ->
				write_reg(reg_file, :B, Bitwise.bxor(read_reg(reg_file, :B), operand))
				{pc + 2, []}
			2 ->
				write_reg(reg_file, :B, Integer.mod(read_combo_operand(reg_file, operand), 8))
				{pc + 2, []}
			3 ->
				if read_reg(reg_file, :A) == 0 do
					{pc + 2, []}
				else
					{operand, []}
				end
			4 ->
				write_reg(reg_file, :B, Bitwise.bxor(read_reg(reg_file, :B), read_reg(reg_file, :C)))
				{pc + 2, []}
			5 ->
				{
					pc + 2,
					[Integer.mod(read_combo_operand(reg_file, operand), 8)]
				}
			6 ->
				write_reg(reg_file, :B, Integer.floor_div(
					read_reg(reg_file, :A),
					Integer.pow(2, read_combo_operand(reg_file, operand))))
				{pc + 2, []}
			7 ->
				write_reg(reg_file, :C, Integer.floor_div(
					read_reg(reg_file, :A),
					Integer.pow(2, read_combo_operand(reg_file, operand))))
				{pc + 2, []}
		end
	end

	def run_program(mem, reg_file, pc) do
		if pc + 1 >= :array.size(mem) do
			[]
		else
			{npc, noutput} = run_instruction(mem, reg_file, pc)
			noutput ++ run_program(mem, reg_file, npc)
		end
	end

	def calculate_result(contents) do
		[reg_part, program_part] = String.split(contents, "\n\n")
		reg_file = spawn(RegisterFile, :launch, [reg_part])
		[_, program_listing] = String.split(program_part, " ")
		mem = :array.from_list(for e <- String.split(program_listing, ","), do: elem(Integer.parse(e), 0))
		output = run_program(mem, reg_file, 0)
		output_str = for v <- output, do: Integer.to_string(v)
		Enum.join(output_str, ",")
	end
end

contents = File.read!("input.txt")
result = Solution.calculate_result(contents)
IO.puts("result: #{result}")
