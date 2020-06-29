*******************************************************************************
** OVERVIEW
**
** cd "~/Documents/"
**
**
*******************************************************************************

program EstimatePropensityScore, rclass
version 16
  syntax , TREAT(varname) MAIN(varlist) OTHER(varlist) [clin(real 1) cquad(real 2.71)]

  local included = "`main'"
  local excluded = "`other'"

  local c_alt = `clin'
  while `c_alt' >= `clin' {
    local c_alt = 0
    local new_var = ""

    qui logit `treat' `included'
    estimates store base

    foreach var of local excluded {
      qui logit `treat' `included' `var'
      estimates store alt

      qui lrtest base alt
      local c_alt_new = r(chi2)

      if `c_alt_new' >= `c_alt' {
        local new_var = "`var'"
        local c_alt = `c_alt_new'
      }
    }

    disp "`c_alt' `new_var'"

    if `c_alt' >= `clin' {
      local included = "`included' `new_var'"
      local excluded : list excluded - new_var
    }

  }

  local included_quad = "`included'"
  local excluded_quad = `" " " "'

  local c_alt = `cquad'
  while `c_alt' >= `cquad' {
    local c_alt = 0
    local new_var = ""

    qui logit `treat' `included'
    estimates store base
    local rank = e(rank)

    foreach var1 of local included {
      foreach var2 of local included {

        if inlist("`var1'_`var2'", `excluded_quad') ///
          | inlist("`var2'_`var1'", `excluded_quad') {
          continue
        }

        tempvar quad
        gen `quad' = `var1'*`var2'

        qui logit `treat' `included' `quad'
        estimates store alt
        local rank_new = e(rank)

        if `rank' != `rank_new' {
          qui lrtest base alt
          local c_alt_new = r(chi2)
        }
        else{
          local c_alt_new = 0
        }

        * disp "`var1'_`var2' `c_alt_new'"

        if `c_alt_new' >= `c_alt' {
          local new_var1 = "`var1'"
          local new_var2 = "`var2'"
          local c_alt = `c_alt_new'
        }

      }
    }

    disp "`c_alt' `new_var1'_`new_var2'"

    if `c_alt' >= `cquad' {
      gen `new_var1'_`new_var2' = `new_var1'*`new_var2'
      local included_quad = "`included_quad' `new_var1'_`new_var2'"
      local excluded_quad = `" `excluded_quad', "`new_var1'_`new_var2'" "'
    }

  }

  estimates drop base alt

  disp "`included_quad'"
  return local included "`included_quad'"

end

******************************************************************************
