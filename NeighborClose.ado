*******************************************************************************
** OVERVIEW
**
** cd "~/Documents/"
**
**
*******************************************************************************

program NeighborClose
version 16
  syntax , PROB(varname) TREAT(varname) GENerate(string) [lthresh(real .1)]

  qui count
  local NumObs = r(N)

  tempvar LogOdds NeighborCount
  gen `LogOdds' = log(`prob' / (1 - `prob'))
  qui gen `NeighborCount' = .

  forvalues ii = 1/`NumObs' {
    local lval = `LogOdds'[`ii']
    local treat_status = `treat'[`ii']
    local lb = `lval' - `lthresh'
    local ub = `lval' + `lthresh'

    local range = "`lb' <= `LogOdds' & `ub' >= `LogOdds'"
    qui count if `treat' == (1 - `treat_status') & `range'
    qui replace `NeighborCount' = r(N) in `ii'
  }

  gen `generate' = (`NeighborCount' >= 1)


end

******************************************************************************
