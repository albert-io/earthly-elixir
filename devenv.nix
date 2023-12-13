{ pkgs, ... }:

{
  # https://devenv.sh/packages/
  packages = [ pkgs.git pkgs.earthly pkgs.beam.packages.erlangR26.elixir_1_15 ];

  # See full reference at https://devenv.sh/reference/options/
}
