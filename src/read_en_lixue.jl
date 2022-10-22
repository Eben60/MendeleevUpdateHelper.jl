const None = missing

function alllixue(lx)
    lx01 = lx[begin+1:end-1]
    curles = r"{(.*?)}"
    lx02 = replace(lx01, curles => s"Dict(\1)")
    lx03 = replace(lx02, "'" => "\"")
    lx04 = replace(lx03, ":" => "=>")
    lx05 = "Dict($lx04)"
    lx_e = eval(Meta.parse(lx05))
    return lx_e
end

function ntlx(d)
    d1 = Dict()
    for (key, val) in d
        push!(d1, lixuelem(key, val) )
    end
    return d1
end

lixuelem(key, val) = (;symbol=Symbol(key[1]), atomic_number=key[2], charge=key[3]) => lxelemdict(val)

function lxelemdict(d)
    d1 = Dict()
    for (key, val) in d
        push!(d1, lixueitem(key) => val)
    end
    return d1
end

lixueitem(x) = (; coord = x[1], spin = x[2]) 

fl = normpath(@__DIR__, "../data/lixue_all.txt")
lx_in = read(fl, String)
lxs = alllixue(lx_in)
d = ntlx(lxs)
;