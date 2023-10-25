# credo:disable-for-this-file
defmodule Extrace do
  @moduledoc """
  for a simple tracer
  """

  @default_trace_config %{
    # 不设置就是5分钟结束
    expire: 300
  }

  defmacro __using__(opts) do
    quote do
      import unquote(__MODULE__)
      require unquote(__MODULE__)
      require Logger

      @one_second 1_000
      @default_trace_target :all
      @default_expire_time 300
      @default_trace_flag [:timestamp, :c]

      @default_trace_config %{
        # 不设置就是5分钟结束
        expire: @default_expire_time
      }

      def start() do
        config = Keyword.get(unquote(opts), :config, @default_trace_config)
        trace_back = Keyword.get(unquote(opts), :trace_back, &unquote(__MODULE__).on_trace_msg/2)

        expire = Map.get(config, :expire, @default_expire_time)

        case :dbg.get_tracer() do
          {:error, _} ->
            {:ok, _} = :dbg.tracer(:process, {trace_back, config})

            :timer.apply_after(expire * @one_second, :dbg, :stop_clear, [])

            :dbg.p(@default_trace_target, @default_trace_flag)

          {:ok, _} ->
            Logger.warn("dbg is already started, do not retart")
            {:error, :already_running}
        end
      end

      def stop() do
        :dbg.stop_clear()
      end
    end
  end

  @doc """
  match_spec 包装
  """
  defmacro match_spec(params, is_return_trace \\ true) do
    quote do
      need_return_trace = unquote(is_return_trace)
      raw_ms = :dbg.fun2ms(fn unquote(params) -> :return_trace end)

      Enum.map(raw_ms, fn {p, g, _opt} = origin ->
        if need_return_trace do
          {p, g, [{:return_trace}]}
        else
          origin
        end
      end)
    end
  end

  def init() do
    {@default_trace_config, &__MODULE__.on_trace_msg/2}
  end

  def on_trace_msg(
        {
          _tt,
          pid,
          tag,
          {module, func, args},
          tss
        } = info,
        config
      ) do
    on_trace_msg({
      _tt,
      pid,
      tag,
      {module, func, args},
      :nil,
      tss
    }, config)
  end
  def on_trace_msg(
        {
          _tt,
          pid,
          tag,
          {module, func, args},
          msg,
          tss
        } = info,
        config
      ) do
    time_str = get_time_str(tss)

    case tag do
      :call ->
        my_put(
          "#{time_str} | #{inspect(pid)} | call ~>",
          {module, func, args},
          :white,
          :blue
        )

      :return_from ->
        my_put(
          "#{time_str} | #{inspect(pid)} | resp ~>",
          msg,
          :white,
          :yellow
        )

      :exception_from ->
        my_put(
          "#{time_str} | #{inspect(pid)} | resp ~>",
          msg,
          :red_background,
          :blue
        )

      _ ->
        IO.inspect(info)
    end

    config
  end

  def my_put(tag, msg, bg_color, color) when is_binary(msg) do
    IO.puts(IO.ANSI.format([bg_color, color, inspect(tag)]))
    IO.puts(Jason.Formatter.pretty_print(msg))
  end

  def my_put(tag, msg, bg_color, color) do
    my_inspect(tag, msg, bg_color, color)
  end

  def my_inspect(tag, msg, bg_color, color) do
    IO.inspect(msg, label: IO.ANSI.format([bg_color, color, inspect(tag)]))
  end

  def get_time_str({ts1, ts2, ts3}) do
    get_time_str(ts1, ts2, ts3)
  end

  def get_time_str(ts1, ts2, ts3) do
    v = DateTime.from_unix!(ts1 * 1_000_000 + ts2, :second) |> to_string()
    "#{v}~#{ts3}"
  end
end
