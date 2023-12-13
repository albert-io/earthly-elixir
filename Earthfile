VERSION --global-cache 0.7

INIT:
    COMMAND
    ARG OS_VERSION
    ARG ELIXIR_VERSION
    ARG OTP_VERSION
    ARG DEPS_DIR=deps
    ARG BUILD_DIR=_build
    ENV OS_VERSION=$OS_VERSION
    ENV ELIXIR_VERSION=$ELIXIR_VERSION
    ENV OTP_VERSION=$OTP_VERSION
    ENV DEPS_DIR=$DEPS_DIR
    ENV BUILD_DIR=$BUILD_DIR
    ENV EARTHLY_ELIXIR_DEPS_CACHE_ID="${ELIXIR_VERSION}#${OTP_VERSION}#${OS_VERSION}#deps-cache"
    ENV EARTHLY_ELIXIR_BUILD_CACHE_ID="${ELIXIR_VERSION}#${OTP_VERSION}#${OS_VERSION}#build-cache"

MIX:
    COMMAND
    ARG --required command
    ARG MIX_ENV
    ARG read_only=true
    DO +RUN_WITH_CACHE \
        --command="set -e;
            MIX_ENV=$MIX_ENV mix $command;"

RUN_WITH_CACHE:
    COMMAND
    ARG --required command
    ARG deps_cache_id=${EARTHLY_ELIXIR_DEPS_CACHE_ID}
    ARG build_cache_id=${EARTHLY_ELIXIR_BUILD_CACHE_ID}
    RUN --mount=type=cache,mode=0777,id=$deps_cache_id,sharing=locked,target=$DEPS_DIR \
        --mount=type=cache,mode=0777,id=$build_cache_id,sharing=locked,target=$BUILD_DIR \
        set -e; \
        printf "Running:\n      $command\n"; \
        eval $command