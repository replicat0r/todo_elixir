defmodule Todo.Server do
  use GenServer

  def start(name) do
    GenServer.start(Todo.Server, name)
  end

  def add_entry(todo_server, new_entry) do
    GenServer.cast(todo_server, {:add_entry, new_entry})
  end

  def entries(todo_server, data) do
    GenServer.call(todo_server, {:entries, data})
  end


  def init(name) do
    todo_list = Todo.Database.get(name) || Todo.List.new
    {:ok, {name, todo_list}}
  end


  def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
    new_state = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(name, new_state)
    {:noreply, {name, new_state}}
  end


  def handle_call({:entries, data}, _, {name, todo_list}) do
    #

    {
      :reply,
      Todo.List.entries(todo_list, data),
      {name, todo_list}
    }
  end

  # Needed for testing purposes
  def handle_info(:stop, todo_list), do: {:stop, :normal, todo_list}
  def handle_info(_, state), do: {:noreply, state}
end
