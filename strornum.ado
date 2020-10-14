program strornum, rclass
  version 16
  syntax varname

  capture confirm numeric variable `varlist'
  if !_rc {
    local type = "numeric"
  }
  else {
    local type = "string"
  }

  return local type = "`type'"

end
