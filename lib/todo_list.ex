defmodule TodoList do
  defstruct auto_id: 1, entries: %{}

  def new(), do: %TodoList{}

  def new(entries) do
    Enum.reduce(entries, %TodoList{}, &add_entry(&2, &1))
  end

  def add_entry(%TodoList{auto_id: auto_id, entries: entries} = todo_list, entry) do
    entry = Map.put(entry, :id, auto_id)
    new_entries = Map.put(entries, auto_id, entry)

    %TodoList{todo_list | entries: new_entries, auto_id: auto_id + 1}
  end

  def entries(%TodoList{entries: entries}, date) do
    entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end

  def update_entry(%TodoList{entries: entries} = todo_list, entry_id, updater_fun) do
    case Map.fetch(entries, entry_id) do
      :error ->
        todo_list

      {:ok, old_entry} ->
        old_entry_id = old_entry.id
        new_entry = %{id: ^old_entry_id} = updater_fun.(old_entry)
        new_entries = Map.put(entries, entry_id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def delete_entry(%TodoList{entries: entries} = todo_list, entry_id) do
    new_entries = Map.delete(entries, entry_id)
    %TodoList{todo_list | entries: new_entries}
  end
end

defmodule TodoList.CsvImporter do
  def import(file_path) do
    File.stream!(file_path)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, ","))
    |> Stream.map(&create_entry/1)
    |> TodoList.new()
  end

  defp parse_date(date) do
    [year, month, day] =
      date
      |> String.split("/")
      |> Enum.map(&String.to_integer/1)

    {:ok, date} = Date.new(year, month, day)
    date
  end

  defp create_entry([date, title]) do
    %{date: parse_date(date), title: title}
  end
end

defimpl String.Chars, for: TodoList do
  def to_string(_) do
    "#TodoList"
  end
end

defimpl Collectable, for: TodoList do
  def into(original) do
    {original, &into_callback/2}
  end

  defp into_callback(todo_list, {:cont, entry}) do
    TodoList.add_entry(todo_list, entry)
  end

  defp into_callback(todo_list, :done), do: todo_list
  defp into_callback(_todo_list, :halt), do: :ok
end

defmodule TodoServer do
  use GenServer

  def start, do: GenServer.start(__MODULE__, nil)

  def entries(server_pid, date) do
    GenServer.call(server_pid, {:entries, date})
  end

  def add_entry(server_pid, entry) do
    GenServer.cast(server_pid, {:add_entry, entry})
  end

  def update_entry(server_pid, entry_id, updater_fun) do
    GenServer.cast(server_pid, {:update_entry, entry_id, updater_fun})
  end

  def delete_entry(server_pid, entry_id) do
    GenServer.cast(server_pid, {:delete_entry, entry_id})
  end

  @impl GenServer
  def init(_) do
    {:ok, TodoList.new()}
  end

  @impl GenServer
  def handle_call({:entries, date}, _, state) do
    {:reply, TodoList.entries(state, date), state}
  end

  @impl GenServer
  def handle_cast({:add_entry, entry}, state) do
    {:noreply, TodoList.add_entry(state, entry)}
  end

  @impl GenServer
  def handle_cast({:update_entry, entry_id, updater_fun}, state) do
    {:noreply, TodoList.update_entry(state, entry_id, updater_fun)}
  end

  @impl GenServer
  def handle_cast({:delete_entry, entry_id}, state) do
    {:noreply, TodoList.delete_entry(state, entry_id)}
  end
end
