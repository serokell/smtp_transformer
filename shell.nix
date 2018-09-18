with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "smtp_transformer";
  buildInputs = [ elixir telnet ];
}
