defmodule YouTrackMailProxy.SMTPProxy do
  defmacro __using__(_) do
    quote do
      import ConfigMacro
      config :youtrack_mail_proxy, [{:client_options, []}, {:server_options, []}, :password]

      @behaviour :gen_smtp_server_session

      def init(_, _, _, _), do: {:ok, "SMTP proxy", %{}}

      def code_change(_, state, _), do: {:ok, state}
      def terminate(_, state), do: {:ok, state}

      def handle_AUTH(_, _, auth_password, state) do
        if SecureCompare.compare(auth_password, password()) do
          {:ok, %{auth?: true}}
        else
          :error
        end
      end

      def handle_DATA(from, to, mime, state) do
        mime = :mimemail.encode(transform(:mimemail.decode(mime)))
        id = Integer.to_string(System.unique_integer([:positive]))

        spawn(fn -> relay(from, to, mime) end)

        {:ok, id, state}
      end

      def handle_EHLO(_, _, state) do
        {:ok, [{'AUTH', 'PLAIN'}], state}
      end

      @doc """
        Always returns 530 on HELO.

        Proxy requires authentication, so it naturally can't handle HELO.
      """
      def handle_HELO(_, state) do
        {:error, "530", state}
      end

      def handle_MAIL(_, state = %{auth?: true}), do: {:ok, state}
      def handle_MAIL(_, state), do: {:error, "530", state}
      def handle_MAIL_extension(_, state), do: :error

      def handle_RCPT(_, state), do: {:ok, state}
      def handle_RCPT_extension(_, state), do: :error

      def handle_RSET(state), do: %{}

      @doc """
        Always returns 252 on VRFY.

        Proxy doesn't handle verification.
      """
      def handle_VRFY(_, state) do
        {:error, "252", state}
      end

      def handle_other(_, _, state), do: {"500", state}

      def relay(from, to, data) do
        :gen_smtp_client.send({from, to, data}, client_options())
      end

      @default_server_options [port: 37811]

      def start(_, _) do
        :gen_smtp_server.start(__MODULE__, [[], server_options() ++ @default_server_options])
      end
    end
  end
end
