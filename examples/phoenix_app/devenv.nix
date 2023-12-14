{ pkgs, ... }:

{
  # https://devenv.sh/packages/
  packages = [ pkgs.git pkgs.earthly ];

  # https://devenv.sh/languages/
  languages.elixir.enable = true;

  # See full reference at https://devenv.sh/reference/options/
}
