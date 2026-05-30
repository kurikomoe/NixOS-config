function __find_parent_venv
    set -l dir (pwd -P)

    while test "$dir" != "/"
        if test -f "$dir/.venv/bin/activate.fish"
            echo "$dir/.venv"
            return 0
        end

        set dir (path dirname "$dir")
    end

    return 1
end


function auto_enter_venv --on-variable PWD --on-event fish_focus_in
    status --is-command-substitution; and return

    set -l venv (__find_parent_venv)

    if test -n "$venv"
        # Already in the correct venv.
        if test "$VIRTUAL_ENV" = "$venv"
            return
        end

        # Leave any previous venv before entering the new one.
        if test -n "$VIRTUAL_ENV"
            deactivate
        end

        source "$venv/bin/activate.fish" >/dev/null 2>&1
        return
    end

    # No parent .venv found. Leave the current venv if one is active.
    if test -n "$VIRTUAL_ENV"
        deactivate
    end
end

auto_enter_venv
