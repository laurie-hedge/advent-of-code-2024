defmodule Solution do
	def convert_to_pos_step(step, dim) do
		if step >= 0 do
			step
		else
			dim + step
		end
	end

	def parse_robot(line, {width, height}) do
		[_, px_str, py_str, vx_str, vy_str] =
			List.flatten(Regex.scan(~r/p=(-?\d+),(-?\d+) v=(-?\d+),(-?\d+)/, line))
		{px, _} = Integer.parse(px_str)
		{py, _} = Integer.parse(py_str)
		{vx_signed, _} = Integer.parse(vx_str)
		{vy_signed, _} = Integer.parse(vy_str)
		vx = convert_to_pos_step(vx_signed, width)
		vy = convert_to_pos_step(vy_signed, height)
		{{px, py}, {vx, vy}}
	end

	def calculate_pos({{px, py}, {vx, vy}}, num_seconds, {width, height}) do
		{
			rem(px + (vx * num_seconds), width),
			rem(py + (vy * num_seconds), height)
		}
	end

	def split_into_quads(positions, {width, height}) do
		dx = Integer.floor_div(width, 2)
		dy = Integer.floor_div(height, 2)
		Enum.group_by(positions, fn {x, y} ->
			cond do
				x < dx and y < dy -> :tl
				x < dx and y > dy -> :bl
				x > dx and y < dy -> :tr
				x > dx and y > dy -> :br
				true -> :on_line
			end
		end)
	end

	def calculate_result(lines) do
		dims = {101, 103}
		robots = for line <- lines, do: parse_robot(line, dims)
		final_positions = for robot <- robots, do: calculate_pos(robot, 100, dims)
		quadrants = split_into_quads(final_positions, dims)
		length(Map.get(quadrants, :tl, [])) *
		length(Map.get(quadrants, :tr, [])) *
		length(Map.get(quadrants, :bl, [])) *
		length(Map.get(quadrants, :br, []))
	end
end

contents = File.read!("input.txt")
lines = String.split(contents, "\n")
result = Solution.calculate_result(lines)
IO.puts("result: #{result}")
