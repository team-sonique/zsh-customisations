typeset -A _AGGREGATES
_AGGREGATES=(
    provisioning "kiki raiden gruffalo shovel"
    landlineassurance "aview optimusprimer"
    assurance "superman ffestiniog luthor spm-sat"
)

function aggregate {
    local goal="$1"
    local aggregate_name="$2"

    case ${goal} in
        deploy)
            ;;
        start)
            ;;
        stop)
            ;;
        status)
            ;;
        clean)
            ;;
        *)
            echo "Usage: $0 {deploy|start|stop|status|clean} aggregate-name"
            return 1
            ;;
    esac

    local aggregate=${_AGGREGATES[$aggregate_name]}
    if [ -z ${aggregate} ]; then
        echo "No aggregate named \"${aggregate_name}\" found"
        return 2
    fi

    local -a apps
    apps=(${(s: :)$(echo $aggregate)})

    for app in ${apps}; do
        echo "> ${_BOLD}${_TEXT_YELLOW}${goal} ${app}${_RESET_FORMATTING}"
        ${goal} ${app}
    done
}
