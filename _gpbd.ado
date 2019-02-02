program define _gpbd
    version 14

    gettoken type 0 : 0
    gettoken Probability 0 : 0
    gettoken eqs 0 : 0			/* "=" */

    gettoken paren 0 : 0, parse("(), ")	/* "(" */

    gettoken Outcome 0 : 0, parse("(), ")
    gettoken Prob  0 : 0, parse("(), ")
    if `"`inc'"' == "," {
        gettoken Prob  0 : 0, parse("(), ")
    }
    gettoken paren 0 : 0, parse("(), ")	/* ")" */
    if `"`paren'"' != ")" {
        error 198
    }

	syntax [if] [in] [, BY(varlist)]
	tempvar touse x touse2 bygroup

	* quietly {
		gen byte `touse' = 1 `if' `in'

        egen `bygroup' = group(`by')
        sum `bygroup'
		local NumGroups = r(max)

        gen `x' = .
        gen `type' `Probability' = .
        gen `touse2' = 0
        forvalues group = 1/`NumGroups' {
            replace `touse2' = 1 if `by' == `group' & `touse' == 1
            mkmat `Prob' if `touse2' == 1
            gpdcalc Prob
            matrix TotalProbs = r(TotalProbs)
            tempvar xtemp
            egen `xtemp' = total(`Outcome') if `touse2' == 1
            replace `x' = `xtemp' if `touse2' == 1
            drop `xtemp'
            gsort - `touse2'
            local TotalOutcome = `x'[1]
            local P = TotalProbs[`TotalOutcome' + 1, 2]

            replace `Probability' = `P' if `touse2'
            replace `touse2' = 0
        }

	* }
end


program gpdcalc , rclass
    args Probs

*******************************************************************************
** Setup
*******************************************************************************
    local NumTrials = rowsof(`Probs')

    matrix NegProbs = J(`NumTrials', 1, 1) - `Probs'

    matrix Ratios = J(`NumTrials', 1, 0)
    forvalues j = 1/`NumTrials' {
    	 matrix Ratios[`j', 1] = `Probs'[`j', 1] / NegProbs[`j', 1]
    }

    // Construct T values table for calculating Total Probabilities later
    TTable Ratios
    matrix Tvals = r(Tvals)

*******************************************************************************
** Construct Total Probability Table
*******************************************************************************
    // Initialize the table
    matrix TotalProbs = J(`NumTrials' + 1, 2, 0)

    // Calculate the values for 0
    local zeroprob = 1
    forvalues j = 1/`NumTrials' {
        local zeroprob = `zeroprob' * NegProbs[`j', 1]
    }

    matrix TotalProbs[1, 1] = 0
    matrix TotalProbs[1, 2] = `zeroprob'

    // Iterate over the rest of the values starting from 1
    foreach NumTreat of numlist 1/`NumTrials' {
        local row = `NumTreat' + 1

        local sum = 0
        foreach i of numlist 1/`NumTreat'{
            local sum = `sum' + (-1)^(`i'-1) * TotalProbs[`row' - `i', 2] * Tvals[`i', 1]
        }

        matrix TotalProbs[`row', 1] = `NumTreat'
        matrix TotalProbs[`row', 2] = `sum' / `NumTreat'
    }

    matrix list TotalProbs
    return matrix TotalProbs = TotalProbs

end

program TTable , rclass
    args Ratios

    local NumTrials = rowsof(`Ratios')

    matrix Tvals = J(`NumTrials', 1, 0)
    foreach i of numlist 1/`NumTrials' {
        TRow `Ratios' `i'
        matrix Tvals[`i', 1] = r(factor)
    }

    return matrix Tvals = Tvals

end

program TRow , rclass
    args Ratios NumTreat

    local NumTrials = rowsof(`Ratios')
    local factor = 0
    forvalues j = 1/`NumTrials' {
        local factor = `factor' + `Ratios'[`j', 1]^`NumTreat'
    }

    return scalar factor = `factor'

end
