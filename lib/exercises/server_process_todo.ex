defmodule TodoServer do
  def init, do: TodoList.new()

  def start, do: ServerProcess.start(TodoServer)

  def entries(server_pid, date) do
    ServerProcess.call(server_pid, {:entries, date})
  end

  def add_entry(server_pid, new_entry) do
    ServerProcess.cast(server_pid, {:add_entry, new_entry})
  end

  def update_entry(server_pid, entry_id, updater_fun) do
    ServerProcess.cast(server_pid, {:update_entry, entry_id, updater_fun})
  end

  def delete_entry(server_pid, entry_id) do
    ServerProcess.cast(server_pid, {:delete_entry, entry_id})
  end

  def handle_call({:entries, date}, todo_list) do
    {TodoList.entries(todo_list, date), todo_list}
  end

  def handle_cast({:add_entry, new_entry}, todo_list) do
    TodoList.add_entry(todo_list, new_entry)
  end

  def handle_cast({:update_entry, entry_id, updater_fun}, todo_list) do
    TodoList.update_entry(todo_list, entry_id, updater_fun)
  end

  def handle_cast({:delete_entry, entry_id}, todo_list) do
    TodoList.delete_entry(todo_list, entry_id)
  end
end

defmodule ServerProcess do
  def start(callback_module) do
    spawn(fn ->
      initial_state = callback_module.init()
      loop(callback_module, initial_state)
    end)
  end

  def call(server_pid, request) do
    send(server_pid, {:call, request, self()})

    receive do
      {:response, response} ->
        response
    after
      1000 ->
        {:error, :timeout}
    end
  end

  def cast(server_pid, request) do
    send(server_pid, {:cast, request})
  end

  defp loop(callback_module, current_state) do
    receive do
      {:call, request, caller} ->
        {response, new_state} = callback_module.handle_call(request, current_state)
        send(caller, {:response, response})
        loop(callback_module, new_state)

      {:cast, request} ->
        new_state = callback_module.handle_cast(request, current_state)
        loop(callback_module, new_state)
    end
  end
end
