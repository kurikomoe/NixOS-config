function __find_parent_venv
    set -l dir (pwd -P)

    while test "$dir" != "/"
        for name in .venv venv
            if test -f "$dir/$name/bin/activate.fish"
                echo "$dir/$name"
                return 0
            end
        end

        set dir (path dirname "$dir")
    end

    return 1
end


function __deactivate_venv_if_any
    if functions -q deactivate
        deactivate
    end

    set -e VENV_LOADED
end

function __venv_python_is_active --argument-names venv
    set -l python (command -v python 2>/dev/null)
    test "$python" = "$venv/bin/python"
end

function __ensure_venv_active --argument-names venv
    if test "$VIRTUAL_ENV" = "$venv"; \
      and test -n "$VENV_LOADED"; \
      and __venv_python_is_active "$venv"
        return
    end

    source "$venv/bin/activate.fish"
    set -gx VENV_LOADED true
end

function auto_enter_venv --on-variable PWD
    status --is-command-substitution; and return

    set -g __AUTO_VENV_PATH (__find_parent_venv)

    if test -n "$__AUTO_VENV_PATH"
        __ensure_venv_active "$__AUTO_VENV_PATH"
        return
    end

    if test -n "$VIRTUAL_ENV"
        __deactivate_venv_if_any
    end
end

function __repair_venv_before_command --on-event fish_preexec
    status --is-command-substitution; and return

    if test -n "$__AUTO_VENV_PATH"
        __ensure_venv_active "$__AUTO_VENV_PATH"
    end
end

auto_enter_venv
