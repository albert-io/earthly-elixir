VERSION --global-cache 0.7

INIT:
    COMMAND
    ARG cache_id
    ARG OS_VERSION
    ARG ELIXIR_VERSION
    ARG OTP_VERSION
    ARG DEPS_DIR=deps
    ARG BUILD_DIR=_build
    ENV UNIQUE_CACHE_ID=$cache_id
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
    ARG cache_id
    ENV UNIQUE_CACHE_ID=${UNIQUE_CACHE_ID:-$cache_id}
    DO +RUN_WITH_CACHE \
        --command="set -e;
            MIX_ENV=$MIX_ENV mix $command;"

RUN_WITH_CACHE:
    COMMAND
    ARG --required command
    # global caches are accessible by all users
    ARG global_deps_cache_id=${EARTHLY_ELIXIR_DEPS_CACHE_ID}
    ARG global_build_cache_id=${EARTHLY_ELIXIR_BUILD_CACHE_ID}
    # unique caches are accessible only by the user who provies the unique_cache_id
    # if the unique_cache_id is provided, the global caches will not be overwritten
    ARG unique_deps_cache_id="${EARTHLY_ELIXIR_DEPS_CACHE_ID}#${UNIQUE_CACHE_ID}"
    ARG unique_build_cache_id="${EARTHLY_ELIXIR_BUILD_CACHE_ID}#${UNIQUE_CACHE_ID}"
    ARG unique_deps_cache_dir="/tmp/elixir-deps-cache-${UNIQUE_CACHE_ID}"
    ARG unique_build_cache_dir="/tmp/elixir-build-cache-${UNIQUE_CACHE_ID}"
    # TODO: MIX_HOME could be cached to prevent reinstalling hex and rebar
    RUN --mount=type=cache,mode=0777,id=$global_deps_cache_id,sharing=locked,target=$DEPS_DIR \
        --mount=type=cache,mode=0777,id=$global_build_cache_id,sharing=locked,target=$BUILD_DIR \
        --mount=type=cache,mode=0777,id=$unique_deps_cache_id,sharing=locked,target=$unique_deps_cache_dir \
        --mount=type=cache,mode=0777,id=$unique_build_cache_id,sharing=locked,target=$unique_build_cache_dir \
        set -e; \
        # copy out all files in deps and build to save the state of the global cache
        if [ "$UNIQUE_CACHE_ID" != "" ]; then \
            cp -r $DEPS_DIR/* $unique_deps_cache_dir/; \
            cp -r $BUILD_DIR/* $unique_build_cache_dir/; \
        fi; \
        printf "Running:\n      $command\n"; \
        eval $command; \
        # copy back all files in deps and build to restore the state of the global cache, removing
        # any files that were added by the command
        if [ "$UNIQUE_CACHE_ID" != "" ]; then \
            rm -rf $DEPS_DIR/*; \
            rm -rf $BUILD_DIR/*; \
            cp -r $unique_deps_cache_dir/* $DEPS_DIR/; \
            cp -r $unique_build_cache_dir/* $BUILD_DIR/; \
        fi