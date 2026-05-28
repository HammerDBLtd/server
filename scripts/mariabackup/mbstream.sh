#!/bin/bash
ARGS=()
SKIP_NEXT=0
for arg in "$@"; do
    [[ $SKIP_NEXT -eq 1 ]] && { SKIP_NEXT=0; continue; }
    case "$arg" in
        -p|--parallel)
            SKIP_NEXT=1
            ;;
        -p*)
            ;;
        --parallel=*)
            ;;
        *)
            ARGS+=("$arg")
            ;;
    esac
done
exec tar "${ARGS[@]}"
