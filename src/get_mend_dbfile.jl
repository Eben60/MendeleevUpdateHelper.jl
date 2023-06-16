function get_mend_dbfile()
    pyf = joinpath(@__DIR__ , "get_mend_pkgfile.py")
    @assert ispath(pyf)
    pycmd = `python3 $pyf`
    mend_init_file = ""
    open(pycmd, "r", stdout) do io
        while !eof(io)
            mend_init_file = (readuntil(io, '\n'))
        end
    end
    
    mend_src, _ = splitdir(mend_init_file)
    mend_db = joinpath(mend_src, "elements.db")
    @assert ispath(mend_db)
    return mend_db
end
# get_mend_dbfile()
