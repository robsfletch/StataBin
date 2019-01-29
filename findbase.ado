program findbase, rclass
    version 14
    args basename


	local path = "`c(pwd)'"
    local rel_path =  substr("`path'", strpos("`path'", "`basename'"), .)

	** Determine the OS and the slash character used for paths
    local os = "`c(os)'"
	if "`os'" == "Windows" {
		local char = "\"
	}
	else {
		local char = "/"
	}

	local dist = length("`rel_path'") - ///
		length(subinstr("`rel_path'", "`char'", "", .))

    local base = ""
    forvalues ii = 1/`dist' {
        local base = "`base'.."
        if `ii' != `dist' {
            local base = "`base'`char'"
        }
    }

    return local base = "`base'"
end
