defmodule ExBin.Netcat do
  use GenServer
  require Logger

  def start_link() do
    ip = Application.get_env(:exbin, :tcp_ip)
    port = Application.get_env(:exbin, :tcp_port)
    Logger.info("TCP Server listening on #{inspect(ip)}:#{inspect(port)}")
    GenServer.start_link(__MODULE__, [ip, port], [])
  end

  def init([ip, port]) do
    opts = [:binary, packet: :line, active: false, reuseaddr: true, ip: ip, exit_on_close: false]

    return_value =
      case :gen_tcp.listen(port, opts) do
        {:ok, listen_socket} ->
          {:ok, %{listener: listen_socket}}

        {:error, reason} ->
          {:stop, reason}
      end

    GenServer.cast(self(), :accept)
    return_value
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  def handle_cast(:accept, %{listener: listen_socket} = state) do
    {:ok, client} = :gen_tcp.accept(listen_socket)
    Task.async(fn -> serve(client) end)
    GenServer.cast(self(), :accept)
    {:noreply, state}
  end

  defp serve(client_socket) do
    {:ok, data} = do_receive(client_socket, <<>>)
    {:ok, snippet} = ExBin.Logic.Snippet.insert(%{"content" => data, "private" => "true"})
    :gen_tcp.send(client_socket, "#{ExBinWeb.Endpoint.url()}/raw/#{snippet.name}")
  end

  defp do_receive(socket, bytes) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        Logger.debug("IN: #{inspect(data)}")
        do_receive(socket, bytes <> data)

      {:error, e} ->
        IO.inspect(e)
        {:ok, bytes}
    end
  end
end
