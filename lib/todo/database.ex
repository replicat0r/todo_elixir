defmodule Todo.Database do
    use GenServer

    def start(db_folder) do
        GenServer.start(__MODULE__, db_folder, name: :database_server)
    end

    def store(key, data) do
        GenServer.cast(:database_server, {:store, key, data})
    end

    def get(key) do
        GenServer.call(:database_server , {:get, key})
    end

    ## Server Api

    def init(db_folder) do
        File.mkdir_p!(db_folder)
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
