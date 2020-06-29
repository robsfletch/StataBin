program DHS
version 10
    syntax varlist(min=2 max=2) [if] [in] , GENerate(string) [ZEROS] [ONE] ///
      [REPLACE]

    if "`replace'" != "" {
      capture drop `generate'
    }
    if "`one'" == "" {
      gen `generate' = (2*(`1' - `2')) / (`1' + `2')
    }
    else {
      gen `generate' = (`1' - `2') / (`1' + `2')
    }

    replace `generate' = . if inlist(`1', ., -777, -999) | inlist(`2', ., -777, -999)

    if "`zeros'" != "" {
      replace `generate' = 0 if `1' == 0 & `2' == 0
    }
end
