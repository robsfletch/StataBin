program dr, rclass
	version 13
	syntax [anything] , [FULL] *

	local vlist = ""
	local counter = 0

	foreach v of varlist * {
		foreach arg of local 0 {
			if regexm("`v'", "`arg'") {
				local vlist = "`vlist'" + "`v' "
				// disp as text "`v'"
				local counter = `counter' + 1
				continue
			}
		}
	}


	if `counter' >= 1 {
		if ("`full'" != "" ) {
			disp 1
			desc `vlist'
			}
		else {
			* desc `vlist', simple
			ds `vlist', `options'
		}
	}

	return local varlist = "`vlist'"
end
