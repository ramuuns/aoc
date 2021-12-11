defmodule Day4 do
  def run(mode) do
    data = read_input(mode)

    {
      data |> part1(),
      data |> part2()
    }
  end

  def read_input(:test) do
    "7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

22 13 17 11  0
 8  2 23  4 24
21  9 14 16  7
 6 10  3 18  5
 1 12 20 15 19

 3 15  0  2 22
 9 18 13 17  5
19  8  7 25 23
20 11 10 24  4
14 21 16 12  6

14 21 17 24  4
10 16 15  9 19
18  8 23 26 20
22 11 13  6  5
 2  0 12  3  7"
    |> String.split("\n")
    |> prepare_data
  end

  def read_input(:actual) do
    File.stream!("input-04")
    |> Enum.map(fn n -> n |> String.trim() end)
    |> prepare_data
  end

  def prepare_data([numbers | boards]) do
    {
      numbers |> String.split(","),
      boards |> prepare_boards([], 0)
    }
  end

  def default_row_or_col() do
    0..4 |> Enum.reduce(%{}, fn n, acc -> acc |> Map.put(n, 5) end)
  end

  def prepare_boards(["" | rest], boards, _),
    do:
      prepare_boards(
        rest,
        [%{num_coords: %{}, rows: default_row_or_col(), cols: default_row_or_col()} | boards],
        0
      )

  def prepare_boards([numbers | rest], [board | boards], row) do
    board =
      numbers
      |> String.split(" ")
      |> Enum.filter(fn n -> n != "" end)
      |> add_to_board(board, 0, row)

    prepare_boards(rest, [board | boards], row + 1)
  end

  def prepare_boards([], boards, _), do: boards

  def add_to_board([], board, _, _), do: board

  def add_to_board([num | rest], %{num_coords: num_coords} = board, col, row),
    do:
      add_to_board(
        rest,
        %{board | num_coords: num_coords |> Map.put(num, {row, col})},
        col + 1,
        row
      )

  def calc_sum({board, num}) do
    num = String.to_integer(num)

    unmarked_sum =
      board.num_coords
      |> Map.keys()
      |> Enum.reduce(0, fn n, acc -> acc + String.to_integer(n) end)

    num * unmarked_sum
  end

  def part1({numbers, boards}) do
    numbers
    |> draw_next_number(:first, {boards, false, 0, nil})
    |> calc_sum
  end

  def part2({numbers, boards}) do
    numbers
    |> draw_next_number(:last, {boards, false, 0, nil})
    |> calc_sum
  end

  def draw_next_number(_, :last, {[], _, prev_num, last_board}), do: {last_board, prev_num}
  def draw_next_number(_, :first, {_, true, prev_num, last_board}), do: {last_board, prev_num}

  def draw_next_number([num | rest_of_nums], mode, {boards, _, _, _}),
    do: draw_next_number(rest_of_nums, mode, check_for_bingo(boards, {[], false, num, nil}))

  def check_for_bingo([], acc), do: acc

  def check_for_bingo(
        [%{num_coords: num_coords} = board | rest_of_boards],
        {boards, had_bingo, num, winning_board}
      )
      when is_map_key(num_coords, num) do
    {{row, col}, num_coords} = Map.pop!(num_coords, num)
    rw = board.rows[row] - 1
    cl = board.cols[col] - 1
    has_bingo? = rw == 0 or cl == 0

    board = %{
      num_coords: num_coords,
      rows: board.rows |> Map.put(row, rw),
      cols: board.cols |> Map.put(col, cl)
    }

    check_for_bingo(
      rest_of_boards,
      if has_bingo? do
        {boards, true, num, board}
      else
        {[board | boards], had_bingo, num, winning_board}
      end
    )
  end

  def check_for_bingo([board | rest_of_boards], {boards, had_bingo, num, winning_board}),
    do: check_for_bingo(rest_of_boards, {[board | boards], had_bingo, num, winning_board})
end

