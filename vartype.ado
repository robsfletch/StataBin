program vartype, rclass
  version 16
  syntax varname

  tab `varname'
  d `varname'

  capture confirm numeric variable `varname'
  if !_rc {
    local type = "numeric"
  }
  else {
    local type = "string"
  }

  return local type = "`type'"

end
