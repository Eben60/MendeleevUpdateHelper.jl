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
els_range = DataFrame(atomic_number = 1:last_no)
els = rightjoin(els, els_range, on = :atomic_number)

mainfields = [:atomic_number, :name, :symbol]
allfields = Symbol.(names(els))
datafields = sort(setdiff(allfields, mainfields))

el_symbols = string.(els[!, :symbol])

function make_data_dict(df, nms)
    d = Dict{Symbol, Vector{Any}}()
    for nm in nms
        v = df[!, nm]
        push!(d, nm => v)
    end
    return d
end

data_dict = make_data_dict(els, datafields)

function to_str(x)
    x = (ismissing(x) || x == "") ? missing : x
    x isa AbstractString && return "\"$(escape_string(x))\""
    x isa AbstractFloat && return string(round(x; sigdigits=13))
    return string(x)
end


function printvector(io, v)
    println(io, "    [")
    for (n, x) in pairs(v)
         println(io, "    $(to_str(x)) , # $(el_symbols[n])")
    end
    println(io, "    ]")
end

function make_elements_data(fl, data)
    nms = sort(collect(keys(data)))
    open(fl, "w") do io
        println(io, "# this is computer generated file - better not edit")
        println(io)
        println(io, "const elements_data = Dict{Symbol, Vector{Any}}(")
        for nm in nms
            println(io, "    $nm => ")
            printvector(io, data[nm])
            println(io, "    ,")
        end
        println(io, ")")
    end
    return nothing
end


function make_chem_elements(fl, df)
    nums = df[!, :atomic_number]
    open(fl, "w") do io
        println(io, "# this is computer generated file - better not edit")
        println(io)
        println(io, "const ELEMENTS_M = Elements_M([")
        for n in nums
            symb = df[n, :symbol]
            nm = df[n, :name]
            !ismissing(symb) && println(io, "    Element_M($n, \"$nm\", :$symb),")
        end
        println(io, "])")
    end
    return nothing
end
