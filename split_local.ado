program define split_local, rclass
** Totally a rip off of splitlabelvals, so thanks to them!
    version 13
    syntax anything, [ Length(int 15) NOBREAK VARNAME]

	disp "`anything'"
	
	if ("`varname'" != "" ) {
		local anything : variable label `anything'
	}
	
	
	local i 1
	local chunk ""

	local part : piece `i' `length' of "`anything'" , `nobreak'

	while `"`part'"'!="" {
		local chunk `"`chunk' "`part'" "'
		local i=`i'+1
		local part : piece `i' `length' of "`anything'" , `nobreak'
		if `i'==2 & `"`part'"'=="" local chunk `"`chunk'"" "'
	}

	return local relabel "`chunk'"
	
end
