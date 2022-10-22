using CSV, DataFrames, JSON3

fl = normpath(@__DIR__, "../data/electronegativities.csv")
# stat(fl)

# df = CSV.read(fl, DataFrame) # ; kwargs

# lx11 = df[11, "Li-Xue"]
# lx11s = lx11[begin+1:end-1]
# lx11sr = replace(lx11s, ":" => "=>")
# lx11st = replace(lx11sr, "'" => "\"")
# ls11b = "[$lx11st]"

# lx11e = eval(Meta.parse(ls11b))

function parselixue(s)
    s == "{}" && return missing
    s_1 = s[begin+1:end-1]
    s_2 = replace(s_1, ":" => "=>")
    s_3 = replace(s_2, "'" => "\"")
    s_4 = "[$s_3]"
    s_5 = eval(Meta.parse(s_4))
    return s_5
end

function lixueitem(x)
    k = x.first
    return (; coord = k[1], spin = k[2]) => x.second
end

