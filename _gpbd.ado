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
	tempvar touse x touse2 bygroup bygrouptemp NumPresent TotalOutcome

    marksample touse
    replace `touse' = 0 if `Outcome' == .

*******************************************************************************
** Figure Out groupings
*******************************************************************************
    gen `type' `Probability' = .
    if "`by'" == "" {
        gen `bygroup' = 1 if `touse' == 1
        egen `TotalOutcome' = total(`Outcome') if `touse' == 1
    }
    else {
        egen `bygrouptemp' = group(`by') if `touse' == 1
        by `by' : egen `TotalOutcome' = total(`Outcome') if `touse' == 1

        bys `bygrouptemp' : gen `NumPresent' = _N if `touse' == 1

        replace `Probability' = `Prob' if `NumPresent' == 1
        replace `bygrouptemp' = 0 if `NumPresent' == 1

        tempvar ProbabilityTemp1 ProbabilityTemp2 NegProb
        gen `NegProb' = 1 - `Prob'
        bys `bygrouptemp' : egen `ProbabilityTemp1' = prod(`Prob') , pmiss(ignore)
        bys `bygrouptemp' : egen `ProbabilityTemp2' = prod(`NegProb') , pmiss(ignore)

        replace `Probability' = `ProbabilityTemp1' ///
            if `NumPresent' == 2 & `TotalOutcome' == 2
        replace `Probability' = `ProbabilityTemp2' ///
            if `NumPresent' == 2 & `TotalOutcome' == 0
        replace `Probability' = 1 - `ProbabilityTemp1' - `ProbabilityTemp2' ///
            if `NumPresent' == 2 & `TotalOutcome' == 1
        drop `ProbabilityTemp1' `ProbabilityTemp2' `NegProb'

        replace `bygrouptemp' = 0 if `NumPresent' == 2

        egen `bygroup' = group(`bygrouptemp') if `bygrouptemp' != 0
    }

    sum `bygroup'
    local NumObs = r(N)
    local NumGroups = r(max)

    if `NumObs' != 0 {
        qui {
            gen `x' = .
            gen `touse2' = 0
            forvalues group = 1/`NumGroups' {
                replace `touse2' = 1 if `bygroup' == `group' & `touse' == 1
                mkmat `Prob' if `touse2' == 1, matrix(ProbMat)
                gpdcalc ProbMat
                matrix TotalProbs = r(TotalProbs)
                replace `x' = .
                replace `x' = `TotalOutcome' if `touse2' == 1
                gsort - `touse2'
                local LocalTotalOutcome = `x'[1]
                local P = TotalProbs[`LocalTotalOutcome' + 1, 2]
                replace `Probability' = `P' if `touse2'
                replace `touse2' = 0
            }
        }
    }

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
