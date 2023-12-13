# earthly-elixir

Attempt at making generic Elixir functions for earthly that utilize caching.

## Getting started

Install earthly: https://docs.earthly.dev/install

## Usage

```
VERSION --global-cache 0.7

IMPORT github.com/albert-io/earthly-elixir:main AS elixir

build:
    ARG ELIXIR_VERSION=1.15.4
    ARG OTP_VERSION=26.0.2
    ARG DEBIAN_VERSION=bullseye-20230612
    FROM hexpm/elixir:$ELIXIR_VERSION-erlang-$OTP_VERSION-debian-$DEBIAN_VERSION
    RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    build-essential \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

    WORKDIR /app

    # Initialize environment variables
    DO elixir+INIT
    # Install rebar and hex
    DO elixir+MIX --command="do local.rebar --force, local.hex --force"

    # Fetch dependencies
    COPY mix.exs mix.lock ./
    DO elixir+MIX --command="deps.get"

    # Compile dependencies
    COPY --if-exists --dir config ./
    DO elixir+MIX --command="deps.compile"

    # Compile application
    COPY --dir lib ./
    DO elixir+MIX --command="clean"
    DO elixir+MIX --command="compile"

test:
    FROM +build
    # Run tests
    DO elixir+MIX --command="test"

    # Run dialyzer
    COPY --if-exists .dialyzer_ignore.exs ./
    DO elixir+MIX --command="dialyzer"
```

## Contributing

If you don't have earthly installed, you can install it via devenv: https://devenv.sh/getting-started/

Don't forget to hook up direnv and devenv to your shell: https://devenv.sh/automatic-shell-activation/
