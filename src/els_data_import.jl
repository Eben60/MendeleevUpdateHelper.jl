if !isfile(elements_dbfile)
    cp(elements_src, elements_dbfile)
else
    src_info = stat(elements_src)
    cd_info = stat(elements_dbfile)
    if (src_info.size != cd_info.size)
        cp(elements_src, elements_dbfile; force=true)
        println("updated database cached file")
    end
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
const allnames = vcat([names(x) for x in dfs]...)

sortednames(nt::NamedTuple, to_omit) = sort(setdiff(keys(nt), to_omit))
sortednames(df::DataFrame) = sort(setdiff(names(df), ["id"]))

tablenames = sortednames(dfs, [:alembic_version,])
tabledict = Dict{Symbol, Vector{String}}()

for tn in tablenames 
    df = dfs[tn]
    # println(tn)
    dfnames = sortednames(df)
    # println(dfnames)
    push!(tabledict, tn=>dfnames)
end


function write_dflayout(fl)
 
    open(fl, "w") do io
        println(io, "# this is computer generated file - better not edit")
        println(io)
        println(io, "df_layout = Dict{Symbol, Vector{String}}(")
        for (k, nms) in pairs(tabledict)
            println(io, "    :$k => [")
            # nms = sortednames(dfs[k])
            for v in nms
                println(io, "    \"$v\",")
            end
            println(io, "    ],")
            # symb = df[n, :symbol]
            # nm = df[n, :name]
            # !ismissing(symb) && println(io, "    ChemElem($n, \"$nm\", :$symb),")
        end
        println(io, ")")
    end
    return nothing 
end

try
    @assert df_layout == tabledict
catch
    if update_db
         write_dflayout(db_struct_new_fl)
         println("wrote the current db layout into file \"db_struct_new.jl\"")
    end
    throw(ErrorException("database layout changed! - please re-check"))
end

# # # # # # # # # # 

dfcb = readdf(chembook_jsonfile)

els = dfs.elements
els = rightjoin(dfcb, els, on = :atomic_number)
els = rightjoin(dfpt, els, on = :atomic_number)

select!(els, Not([:en_allen, :en_ghosh, :en_pauling])) # all electronegativies treated separately
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

# function printtuple(io, v)
#     println(io, "    (")
#     for (n, x) in pairs(v)
#          println(io, "    $(to_str(x)) , # $(el_symbols[n])")
#     end
#     println(io, "    )")
# end

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
        println(io, "const elements_data = (; ")
        for nm in nms
            println(io, "    $nm = ")
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
        println(io, "const chem_elements = ChemElems([")
        for n in nums
            symb = df[n, :symbol]
            nm = df[n, :name]
            !ismissing(symb) && println(io, "    ChemElem($n, \"$nm\", :$symb),")
        end
        println(io, "])")
    end
    return nothing
end
