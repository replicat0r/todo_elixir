defmodule Todo.DatabaseWorker do
 use GenServer

    def start(db_folder) do
        GenServer.start(__MODULE__, db_folder)
    end

    def store(pid, key, data) do
        GenServer.cast(pid, {:store, key, data})
    end

    def get(pid, key) do
        GenServer.call(pid , {:get, key})
    end

    ## Server Api

    def init(db_folder) do
        IO.puts("starting Worker!")
        #File.mkdir_p!(db_folder)
        {:ok, db_folder}
    end

    def handle_cast({:store, key, data}, data_folder) do
        file_name(data_folder, key)
        |> File.write!(:erlang.term_to_binary(data))

        {:noreply, data_folder}

    end

    def handle_call({:get, key},_,  data_folder) do
        data = case File.read(file_name(data_folder, key)) do
            {:ok, contents} -> :erlang.binary_to_term(contents)
            _ -> nil

        end
        {:reply, data, data_folder}

    end

    defp file_name(db_folder, key), do: "#{db_folder}/#{key}"

end