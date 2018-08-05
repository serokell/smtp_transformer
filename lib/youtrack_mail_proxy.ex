alias YouTrackMailProxy.SMTPProxy

defmodule YouTrackMailProxy do
  use SMTPProxy

  def transform(mail) do
    mail
  end
end
