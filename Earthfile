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
    # global backup caches exist in case a previous command failed that had a unique cache id
    # they ensure the global caches are not overwritten
    ARG global_deps_cache_id_backup="${EARTHLY_ELIXIR_DEPS_CACHE_ID}#backup"
    ARG global_build_cache_id_backup="${EARTHLY_ELIXIR_BUILD_CACHE_ID}#backup"
    ARG global_deps_cache_dir_backup="/tmp/elixir-deps-cache-backup"
    ARG global_build_cache_dir_backup="/tmp/elixir-build-cache-backup"
    # unique caches are accessible only by the user who provies the unique_cache_id
    # if the unique_cache_id is provided, the global caches will not be overwritten
    ARG unique_deps_cache_id="${EARTHLY_ELIXIR_DEPS_CACHE_ID}#${UNIQUE_CACHE_ID}"
    ARG unique_build_cache_id="${EARTHLY_ELIXIR_BUILD_CACHE_ID}#${UNIQUE_CACHE_ID}"
    ARG unique_deps_cache_dir="/tmp/elixir-deps-cache-${UNIQUE_CACHE_ID}"
    ARG unique_build_cache_dir="/tmp/elixir-build-cache-${UNIQUE_CACHE_ID}"

    # TODO: MIX_HOME could be cached to prevent reinstalling hex and rebar
    RUN --mount=type=cache,mode=0777,id=$global_deps_cache_id,sharing=locked,target=$DEPS_DIR \
        --mount=type=cache,mode=0777,id=$global_build_cache_id,sharing=locked,target=$BUILD_DIR \
        --mount=type=cache,mode=0777,id=$global_deps_cache_id_backup,sharing=locked,target=$global_deps_cache_dir_backup \
        --mount=type=cache,mode=0777,id=$global_build_cache_id_backup,sharing=locked,target=$global_build_cache_dir_backup \
        --mount=type=cache,mode=0777,id=$unique_deps_cache_id,sharing=locked,target=$unique_deps_cache_dir \
        --mount=type=cache,mode=0777,id=$unique_build_cache_id,sharing=locked,target=$unique_build_cache_dir \
        set -e; \
        # sync the global cache and the global backup cache in case a previous command failed that had a
        # unique cache id (or not)
        if [ "$(find $global_deps_cache_dir_backup -mindepth 1 -print -quit 2>/dev/null)" ]; then \
            cp -r $global_deps_cache_dir_backup/* $DEPS_DIR/; \
        fi; \
        if [ "$(find $global_build_cache_dir_backup -mindepth 1 -print -quit 2>/dev/null)" ]; then \
            cp -r $global_build_cache_dir_backup/* $BUILD_DIR/; \
        fi; \
        # pull in files from a previous run with the same unique cache id
        if [ "$UNIQUE_CACHE_ID" != "" ]; then \
            if [ "$(find $unique_deps_cache_dir -mindepth 1 -print -quit 2>/dev/null)" ]; then \
                cp -r $unique_deps_cache_dir/* $DEPS_DIR/; \
            fi; \
            if [ "$(find $unique_build_cache_dir -mindepth 1 -print -quit 2>/dev/null)" ]; then \
                cp -r $unique_build_cache_dir/* $BUILD_DIR/; \
            fi; \
        fi; \
        printf "Running:\n      $command\n"; \
        eval $command; \
        # copy all files out to the unique cache dir if a unique cache id was provided
        if [ "$UNIQUE_CACHE_ID" != "" ]; then \
            if [ "$(find $DEPS_DIR -mindepth 1 -print -quit 2>/dev/null)" ]; then \
                cp -r $DEPS_DIR/* $unique_deps_cache_dir/; \
            fi; \
            if [ "$(find $BUILD_DIR -mindepth 1 -print -quit 2>/dev/null)" ]; then \
                cp -r $BUILD_DIR/* $unique_build_cache_dir/; \
            fi; \
        else \
            # copy all files out to the global cache dir if no unique cache id was provided
            if [ "$(find $DEPS_DIR -mindepth 1 -print -quit 2>/dev/null)" ]; then \
                cp -r $DEPS_DIR/* $global_deps_cache_dir_backup/; \
            fi; \
            if [ "$(find $BUILD_DIR -mindepth 1 -print -quit 2>/dev/null)" ]; then \
                cp -r $BUILD_DIR/* $global_build_cache_dir_backup/; \
            fi; \
        fi;