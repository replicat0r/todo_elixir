defmodule Todo.Database do
    use GenServer
    require IEx
    def start_link(db_folder) do
        GenServer.start_link(__MODULE__, db_folder, name: :database_server )
    end

    def store(key, data) do
        key |> choose_worker |> Todo.DatabaseWorker.store(key,data)
    end

    def get(key) do
        key |> choose_worker |> Todo.DatabaseWorker.get(key)
    end
    

    ## Server Api

    def init(db_folder) do
         File.mkdir_p(db_folder)
        pool = start_workers(db_folder)

        # # start 3 workers
        # Todo.DatabaseWorker.start

        {:ok, pool}
    end
    
    defp start_workers(db_folder) do
        for index <- 1..3, into: HashDict.new do
          {:ok, pid} = Todo.DatabaseWorker.start_link(db_folder)
          {index - 1, pid}
        end
    end

    def choose_worker(key) do
        GenServer.call(:database_server, {:choose_worker, key})
    end
    
    def handle_call({:choose_worker,key},_,pool) do
        worker_pid = :erlang.phash2(key,3)
        {:reply, HashDict.get(pool, worker_pid), pool}
    end

end
