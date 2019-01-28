program dr, rclass
	version 13
	syntax [anything] , [FULL]
	
	local vlist = ""
	local counter = 0
	foreach v of varlist * {
		if regexm("`v'", "`1'") {
			local vlist = "`vlist'" + "`v' "
			// disp as text "`v'"
			local counter = `counter' + 1
		}
	}
	
	if `counter' >= 1 {
		if ("`full'" != "" ) {
			disp 1
			desc `vlist'
			}
		else {
			desc `vlist', simple
		}
	}
	
	return local varlist = "`vlist'"
end
