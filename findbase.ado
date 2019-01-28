program findbase, rclass
    version 14
    args basename

    local path = "`c(pwd)'"
    local rel_path =  substr("`path'", strpos("`path'", "`basename'"), .)
    local dist = length("`rel_path'") - length(subinstr("`rel_path'", "/", "", .))

    local base = ""
    forvalues ii = 1/`dist' {
        local base = "`base'.."
        if `ii' != `dist' {
            local base = "`base'/"
        }
    }

    return local base = "`base'"
end
