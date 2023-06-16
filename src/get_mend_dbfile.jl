function get_mend_dbfile()
    pycmd = `python3 -c 'import mendeleev, inspect; print(inspect.getsourcefile(mendeleev))'`
    mend_init_file = ""
    open(pycmd, "r", stdout) do io
        mend_init_file = readline(io)
    end
    
    mend_src, _ = splitdir(mend_init_file)
    mend_db = joinpath(mend_src, "elements.db")
    @assert ispath(mend_db)
    return mend_db
end
get_mend_dbfile()
