*******************************************************************************
** OVERVIEW
**
** cd "~/Documents/"
**
**
*******************************************************************************

program BlocksBalanceCheck
version 16
  syntax , PROB(varname) TREAT(varname) VARS(varlist) [TVAL(real 1)]

    local num_covar : word count `vars'
    tempvar BalanceBlocks
    CreateBlocks , prob(Prob) treat(`treat') gen(`BalanceBlocks') ///
      numcov(`num_covar') tval(`tval')


    /*
    sort `BalanceBlocks'

    local teststr = ""
    levelsof `BalanceBlocks'
    local vals = r(levels)
    foreach ii of local vals {
      gen Block`ii'Dummy = (`BalanceBlocks' == `ii')
      gen TreatBlock`ii'Dummy = (`BalanceBlocks' == `ii' & `treat' == 1)
      local teststr = "`teststr' TreatBlock`ii'Dummy = "
    }

    local teststr = "`teststr' 0"
    disp "`teststr'"

    foreach var of local vars {
      StratafiedATE , treat(`treat') var(`var') stratavar(Block)
      local ate = r(ate)
      local z = r(z)


      qui reg `var' Block*Dummy TreatBlock*Dummy , noconst
      qui test `teststr'
      local F = r(F)
      local p = r(p)

      disp "ATE: `ate' Z: `z' F: `F' p: `p'"
    }
    */

    tempvar TVals
    qui gen `TVals' = .
    BalanceQQ , balanceblocks(`BalanceBlocks') treat(`treat') vars(`vars') tvals(`TVals')

    qnorm `TVals' , `graph_prefs' ///
      subtitle("QQ-plot for t-values by treatment of all variables in all blocks")
    drop `TVals'

end

program BalanceQQ
  syntax , BALANCEBLOCKS(varname) TREAT(varname) VARS(varlist) TVALS(varname)

  qui levelsof `balanceblocks'
  local blockvals = r(levels)

  local counter = 1
  foreach block of local blockvals {
    foreach var of varlist `vars' {
      qui ttest `var' if `balanceblocks' == `block', by(`treat')
      qui replace `tvals' = - r(t) in `counter'

      local counter = `counter' + 1
    }
  }

end


******************************************************************************
