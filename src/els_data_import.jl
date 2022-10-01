if !isfile(elements_dbfile)
    cp(elements_src, elements_dbfile)
end

function readdf(jfile)
    jsource = open(jfile) do file
       read(file, String)
    end
    return DataFrame(jsontable(jsource))
end


function read_db_tables(dbfile)
    edb = SQLite.DB(dbfile)
    tbls = SQLite.tables(edb)
    tblnames = [t.name for t in tbls]
    dfs = (; [Symbol(tname) => (DBInterface.execute(edb, "SELECT * FROM $tname") |> DataFrame) for tname in tblnames]...)
    return dfs
end

const dfs = read_db_tables(elements_dbfile)
dfcb = readdf(chembook_jsonfile)

els = dfs.elements
els = rightjoin(dfcb, els, on = :atomic_number)
els = rightjoin(dfpt, els, on = :atomic_number)

sort!(els, :atomic_number)

const last_no = maximum(els[!, :atomic_number])

function sortcols!(df)
    nms = sort!(collect(names(df)))
    select!(df, nms...)
    return nothing
end

# boolean columns are sometimes encoded as integer {0, 1} and sometimes as {missing, 1} - let's convert them to Bool
select!(els, [:is_monoisotopic, :is_radioactive] .=> ByRow(x -> !(ismissing(x) || x == 0)), renamecols=false, :)
# @show els[1:3, :is_monoisotopic]
# @show els[81:84, :is_radioactive]


select!(els, :symbol => ByRow(x -> Symbol.(x)), renamecols=false, :)
# @show els[1:3, :symbol]

# should new elements be discovered, guarantee there are rows for all atomic numbers (including for missing elements)
rn_els = DataFrame(atomic_number = 1:last_no)
els = rightjoin(els, rn_els, on = :atomic_number)
