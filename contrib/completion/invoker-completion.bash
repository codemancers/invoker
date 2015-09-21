# BASH completion function for Invoker

# source it from bashrc
# dependencies:
# 1) netcat
# 2) find

check_open_port()
{
    local port=$1
    if [[ $(which nc) ]]; then
        local open=$(nc -z -w2 localhost $port > /dev/null; echo $?)
        if [[ "$open" == "1" ]]; then
            COMPREPLY=( $(compgen -W "${port}" -- ${cur}) )
        else
            check_open_port $(($port+1))
        fi
    fi
}
_invoker()
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="add add_http help list reload remove setup"
    opts="$opts start stop tail uninstall version"

    case "${prev}" in
        add | add_http | list | reload | remove | setup | stop | tail \
            | uninstall | version)
            COMPREPLY=()
            ;;
        -d | --daemon | --no-daemon)
            local extra_opts=("--port")
            COMPREPLY=( $(compgen -W "${extra_opts}" -- ${cur}) )
            ;;
        --port)
            # auto-suggest port
            check_open_port 9000
            ;;
        help)
            # Show opts again, but only once; don't infinitely recurse
            local prev2="${COMP_WORDS[COMP_CWORD-2]}"
            if [ "$prev2" == "help" ]; then
                COMPREPLY=()
            else
                COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
            fi
            ;;
        start)
            local filename=$(find . -type f -name "*.ini")
            if [[ $filename ]]; then
                COMPREPLY=( $(compgen -W "${filename}" -- ${cur}) )
            else
                COMPREPLY=()
            fi
            ;;
        *.ini)
            local start_opts="-d --daemon --no-daemon --port"
            COMPREPLY=( $(compgen -W "${start_opts}" -- ${cur}) )
            ;;
        invoker)
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
            ;;
    esac

    return 0
}
complete -F _invoker invoker
