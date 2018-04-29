defmodule Todo.Cache do
    use GenServer
    
    ## Client 
    def start do
        GenServer.start(__MODULE__, nil)
 
    end
    
    def server_process(cach_pid, todo_list_name) do
    
        GenServer.call(cach_pid, {:server_process, todo_list_name})
    end
    
    ## Server Api
    def init(_) do
        Todo.Database.start("./persist/")
        {:ok, HashDict.new}
    end
    
    def handle_call({:server_process, todo_list_name}, _, todo_servers) do
        case HashDict.fetch(todo_servers, todo_list_name) do
        {:ok, todo_server} ->
            {:reply, todo_server, todo_servers}
        :error ->
        {:ok, new_server} = Todo.Server.start(todo_list_name)
        {
            :reply, new_server, HashDict.put(todo_servers, todo_list_name, new_server)
        }
            
        end
    end

end