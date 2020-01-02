defmodule MorseCodeBlinky.Queue do
  use GenServer

  alias MorseCodeBlinky.Blinker

  def start_link(_any) do
    GenServer.start_link(__MODULE__, :queue.new, name: :encoding_queue)
  end

  def encode(string) do
    GenServer.cast(:encoding_queue, {:enqueue, string})
    :ok
  end

  # private API

  def init(state) do
    await_strings()
    {:ok, state}
  end

  defp await_strings() do
    Process.send_after(self(), :process_strings, 100)
  end

  def handle_info(:process_strings, state) do
    case :queue.out(state) do
      {{_val, string}, new_state} ->
        Blinker.blink!(string)
        await_strings()
        {:noreply, new_state}
      {:empty, _} ->
        await_strings()
        {:noreply, state}
    end
  end

  def handle_cast({:enqueue, string}, state) do
    {:noreply, :queue.in(string, state)}
  end
end
