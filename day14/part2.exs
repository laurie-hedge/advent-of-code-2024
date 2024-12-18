defmodule Solution do
	def parse_robot(line) do
		[_, px_str, py_str, vx_str, vy_str] =
			List.flatten(Regex.scan(~r/p=(-?\d+),(-?\d+) v=(-?\d+),(-?\d+)/, line))
		{px, _} = Integer.parse(px_str)
		{py, _} = Integer.parse(py_str)
		{vx, _} = Integer.parse(vx_str)
		{vy, _} = Integer.parse(vy_str)
		{{px, py}, {vx, vy}}
	end

	def step_with_wrap(coord, vel, dim) do
		ncoord = coord + vel
		cond do
			ncoord >= dim -> rem(ncoord, dim)
			ncoord < 0 -> dim + ncoord
			true -> ncoord
		end
	end

	def step_robot({{px, py}, {vx, vy}}, {width, height}) do
		nx = step_with_wrap(px, vx, width)
		ny = step_with_wrap(py, vy, height)
		{{nx, ny}, {vx, vy}}
	end

	def draw_cols(width, _, {width, _}, _) do
		IO.write("\n")
	end
	def draw_cols(x, y, dims, robot_positions) do
		if {x, y} in robot_positions do
			IO.write("#")
		else
			IO.write(".")
		end
		draw_cols(x + 1, y, dims, robot_positions)
	end

	def draw_rows(height, {_, height}, _) do
		IO.write("\n")
	end
	def draw_rows(y, dims, robot_positions) do
		draw_cols(0, y, dims, robot_positions)
		draw_rows(y + 1, dims, robot_positions)
	end

	def draw_map(dims, robots, seconds) do
		robot_positions = MapSet.new(for {pos, _} <- robots, do: pos)
		IO.puts("Map at #{seconds} seconds:")
		draw_rows(0, dims, robot_positions)
	end

	def run_simulation(_, _, max_seconds, max_seconds) do end
	def run_simulation(dims, robots, seconds, max_seconds) do
		draw_map(dims, robots, seconds)
		updated_robots = for robot <- robots, do: step_robot(robot, dims)
		run_simulation(dims, updated_robots, seconds + 1, max_seconds)
	end

	def run_simulation(lines, max_seconds) do
		dims = {101, 103}
		robots = for line <- lines, do: parse_robot(line)
		run_simulation(dims, robots, 0, max_seconds)
	end
end

contents = File.read!("input.txt")
lines = String.split(contents, "\n")
Solution.run_simulation(lines, 10000)
