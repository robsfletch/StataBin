*******************************************************************************
** OVERVIEW
**
** cd "~/Documents/"
**
**
*******************************************************************************

program PropensityTrim, rclass
version 16
  syntax , PROB(varname) GENerate(string) [REPLACE]

  if "`replace'" != "" {
    capture drop `generate'
  }

  tempvar g AvgGUnder Over
  gen `g' = 1 / (`prob' * (1 - `prob'))

  sum `g'
  local max_g = r(max)
  local mean_g = r(mean)
  if `max_g' <= 2 * `mean_g' {
    local lb = 0
    local ub = 1
  }
  else {
    qui gen `AvgGUnder' = .

    qui count
    local numobs = r(N)

    tempvar Under
    qui gen byte `Under' = .
    forvalues ii = 1/`numobs' {
      local lambda = `g'[`ii']

      qui replace `Under' = (`lambda' >= `g')

      qui sum `g' if `Under' == 1
      local avgunder = r(mean)
      local max = 2 * `avgunder'
      qui replace `AvgGUnder' = `max' in `ii'
    }

    gen `Over' = (`AvgGUnder' >= `g')

    gsort - `Over' `prob'
    local lb = `prob'[1]
    local ub = 1 - `prob'[1]
  }

  gen `generate' = .
  replace `generate' = -1 if (`prob' < `lb')
  replace `generate' = 0 if (`prob' >= `lb')
  replace `generate' = 1 if (`prob' > `ub')

  label define `generate' -1 "Low Trim" 0 Keep 1 "High Trim" , replace
  label values `generate' `generate'

  return local alpha `lb'

end

******************************************************************************
