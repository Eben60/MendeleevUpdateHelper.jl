function el_ionradii(df, el)
    an = elements[el].number
    !(an in df[!, :atomic_number]) && return missing
    df = subset(df, :atomic_number => x -> x .== an)
    return df
end

function irad_range(df, el)
    an = elements[el].number
    rng = searchsorted(df[!, :atomic_number], an)
    length(rng) == 0 && return missing
    return (start=rng.start, stop=rng.stop)
end

irad_ranges(df) = [irad_range(df, el) for el in 1:last_no]

function writerange(io, range, el="")
    if ismissing(range)
        println(io, "    missing, # $el") 
    else
        println(io, "    ($(range.start), $(range.stop)), # $el")
    end
    return nothing
end

function writeranges(io, df)
    ranges = irad_ranges(df)
    println(io, "const ionrad_ranges = (")
    for (n, r) in pairs(ranges)
        writerange(io, r, elements[n].symbol)
    end
    println(io, ")")
end


function writecolumn(io, df, colname)
    col = df[!, colname]
    println(io, "    $colname = [")
    for (n, c) in pairs(col)
        an = df[n, :atomic_number]
        sym = elements[an].symbol
        ch = df[n, :charge]
        cmnt = "# $sym$ch"
        if ismissing(c) || c == ""
            s = "missing"
        elseif (colname in ("coordination", "spin"))
            s = "Symbol(\"$c\")"
        else
            s = to_str(c)
        end
        println(io, "    $s, $cmnt" )
    end
    println(io, "    ],")
end

function writecolumns(io, df)
    nms = names(df)
    filter!(x -> x != "atomic_number", nms)
    println(io, "const ionrad_data = (;")
    for nm in nms
        # println(io, "    $nm = ")
        writecolumn(io, df, nm)
    end
    println(io, ")")
end

function write_irad_data(fl, df)
    open(fl, "w") do io
        writeranges(io, df)
        writecolumns(io, df)
        println(io, ";")
    end
end

make_irad_data(fl) = write_irad_data(fl, irs)

function ionicradii()
    irs = dfs.ionicradii

    if "id" in names(irs)
        select!(irs, Not([:id]))
    end
    select!(irs, sort(names(irs)))
    sort!(irs, [:atomic_number, :charge, :coordination, :econf])
    return irs
end


