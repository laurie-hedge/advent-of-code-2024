defmodule Solution do
	def parse_button(line) do
		[_, dx_str, dy_str] = List.flatten(Regex.scan(~r/Button .: X\+(\d+), Y\+(\d+)/, line))
		{dx, _} = Integer.parse(dx_str)
		{dy, _} = Integer.parse(dy_str)
		{dx, dy}
	end

	def parse_prize(line) do
		[_, x_str, y_str] = List.flatten(Regex.scan(~r/Prize: X=(\d+), Y=(\d+)/, line))
		{x, _} = Integer.parse(x_str)
		{y, _} = Integer.parse(y_str)
		{x, y}
	end

	def build_machine(block) do
		[button_a_line, button_b_line, prize_line] = String.split(block, "\n")
		{parse_button(button_a_line), parse_button(button_b_line), parse_prize(prize_line)}
	end

	def build_machines(contents) do
		for block <- String.split(contents, "\n\n"), do: build_machine(block)
	end

	def eval_machine(_, 101, _) do nil end
	def eval_machine(a_pushes, b_pushes, machine) do
		{{ax, ay}, {bx, by}, {px, py}} = machine
		x = (a_pushes * ax) + (b_pushes * bx)
		y = (a_pushes * ay) + (b_pushes * by)
		if x == px and y == py do
			(3 * a_pushes) + b_pushes
		else
			eval_machine(a_pushes, b_pushes + 1, machine)
		end
	end

	def eval_machine(101, _) do 0 end
	def eval_machine(a_pushes, machine) do
		case eval_machine(a_pushes, 0, machine) do
			nil -> eval_machine(a_pushes + 1, machine)
			cost -> cost
		end
	end

	def eval_machine(machine) do
		eval_machine(0, machine)
	end

	def calculate_result(contents) do
		Enum.sum(for machine <- build_machines(contents), do: eval_machine(machine))
	end
end

contents = File.read!("input.txt")
result = Solution.calculate_result(contents)
IO.puts("result: #{result}")
