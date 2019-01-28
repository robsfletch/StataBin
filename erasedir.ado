program erasedir
    version 14
    args delete_dir

    local datafiles: dir "`delete_dir'" files "*"

    foreach datafile of local datafiles {
            rm "`delete_dir'/`datafile'"
    }

    rmdir "`delete_dir'"
end
