*******************************************************************************
** OVERVIEW
**
** cd "~/Documents/"
**
**
*******************************************************************************

program CreateBlocks
version 16
  syntax , PROB(varname) TREAT(varname) GENerate(string) ///
    NUMCOVariates(integer) [TVAL(real 1.96)]

  tempvar Accepted
  gen `Accepted' = 0
  qui sum `Accepted'
  local min_accept = r(min)

  tempvar Block Block2
  gen `Block'= 0
  gen `Block2' = 0

  tempvar LogOdds
  gen `LogOdds' = log(`prob' / (1 - `prob'))

  while `min_accept' == 0 {
    qui levelsof `Block'
    local block_list = r(levels)

    foreach block of numlist `block_list' {
      qui ttest `LogOdds' if `Block' == `block', by(`treat')
      local t = abs(r(t))

      if (`t' >= `tval') {
        qui sum `prob' if `Block' == `block', de
        local split = r(p50)

        qui replace `Block2' = (`prob' >= `split') if `Block' == `block'

        qui count if `Block2' == 0 & `Block' == `block' & `treat' == 0
        local N1 = r(N)
        qui count if `Block2' == 0 & `Block' == `block' & `treat' == 1
        local N2 = r(N)
        qui count if `Block2' == 1 & `Block' == `block' & `treat' == 0
        local N3 = r(N)
        qui count if `Block2' == 1 & `Block' == `block' & `treat' == 1
        local N4 = r(N)

        local N = min(`N1', `N2', `N3', `N4')

        if `N' <= 3 {
          qui replace `Accepted' = 1 if `Block' == `block'
          qui replace `Block2' = 0 if `Block' == `block'
        }

        local NB = min(`N1' + `N2' , `N3' + `N4')

        if `NB' <= `numcovariates' + 2 {
          qui replace `Accepted' = 1 if `Block' == `block'
          qui replace `Block2' = 0 if `Block' == `block'
        }

      }
      else {
        qui replace `Accepted' = 1 if `Block' == `block'
        qui replace `Block2' = 0 if `Block' == `block'
      }
    }

    qui replace `Block' = `Block'*10 + `Block2'
    qui replace `Block2' = .

    qui sum `Accepted'
    local min_accept = r(min)

  }

  sort `Block'
  egen `generate' = group(`Block')

end

******************************************************************************
