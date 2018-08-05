with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "youtrack_mail_proxy";
  buildInputs = [ elixir telnet ];

  shellHook = ''
    mix local.hex --force
    mix local.rebar --force
    mix deps.get
  '';
}
