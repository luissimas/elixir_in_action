defmodule EnumStreamsPractice do
  def line_lengths!(file_path) do
    file_path
    |> File.stream!()
    |> Stream.map(&String.trim_trailing/1)
    |> Enum.map(&String.length/1)
  end

  def longest_line_length!(file_path) do
    file_path
    |> File.stream!()
    |> Stream.map(&String.trim_trailing/1)
    |> Stream.map(&String.length/1)
    |> Enum.max()
  end

  def longest_line!(file_path) do
    file_path
    |> File.stream!()
    |> Stream.map(&String.trim_trailing(&1))
    |> Enum.max_by(&String.length/1)
  end

  def words_per_line!(file_path) do
    file_path
    |> File.stream!()
    |> Stream.map(&String.trim(&1))
    |> Enum.map(&(&1 |> String.split() |> length()))
  end
end
