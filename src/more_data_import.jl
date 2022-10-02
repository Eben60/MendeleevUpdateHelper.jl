
ser = dfs.series
# sort(ser, :name)
# check if series names still the same es ever
@assert collect(seriesnames) == ser.name
# rename column; see getproperty(...., :series)
rename!(els, :series_id => :series)

groups = dfs.groups
sort!(groups, :group_id)
grouplist = [Group_M(g.group_id, g.symbol, g.name) for g in Tables.rowtable(groups)]
# check if groups still the same es ever
@assert collect(groups_m) == grouplist
# rename column; see getproperty(...., :group)
rename!(els, :group_id => :group)

function getoxstates(no)
    ox = dfs.oxidationstates
    oxstates = ox[ox.atomic_number.==no , :oxidation_state]
    (isempty(oxstates) || ismissing(oxstates[1])) && return missing # Int[]
    return sort([Int(x) for x in oxstates])
end

function alloxstates()
    return Dict([no=>getoxstates(no) for no in els.atomic_number])
end


function round_pos(x::Float64, pos::Int=13)
    f = 10^pos
    return round(x*f)/f
end

round_pos(x, pos::Int=13) = x

round_pos(x::Array, pos::Int=13) = round_pos.(x, pos)

const scr = dfs.screeningconstants
rename!(scr, :s => :orb_type)
rename!(scr, :n => :shell)
transform!(scr, :orb_type => (x->Symbol.(x)); renamecols=false)
transform!(scr, :screening => (x->round_pos.(x)); renamecols=false)

getscreening(no) = scr[scr.atomic_number.==no, [:atomic_number, :shell, :orb_type, :screening]] |> Tables.rowtable .|> Tuple

function getscreenings()
    nos = sort(unique(scr.atomic_number))
    return [getscreening(no) for no in nos]
end

const ird = dfs.ionicradii
# transform!(ird, :screening => (x->round_pos.(x, 13)); renamecols=false)

function unmiss(x, T::Type)
    T = nonmissingtype(T)
    ! ismissing(x) && return x
    T <: AbstractFloat && return T(NaN)
    T <: AbstractString && return ""
    T <: Integer && return intNaN
end

function unmiss!(df::AbstractDataFrame, collabel)
    T = eltype(df[!, collabel])
    transform!(df, collabel => (x->unmiss.(x, T)); renamecols=false)
end

function unmiss!(df::AbstractDataFrame)
    for n in names(df)
        unmiss!(df, n)
    end
end


# df2unitful!(els, f_units)
sortcols!(els)

# ctypes = coltypes(eachcol(els), fu1) # de-unitfulling

cnames = names(els) # 70-element Vector{String}: "annotation"...
vs = NamedTuple.(eachrow(els))


ion = dfs.ionizationenergies

function ionizenergies(atomic_number)
    iz = ion[ion.atomic_number.== atomic_number, [:degree, :energy]]
    isempty(iz) && return missing
    nts = iz  |> Tables.rowtable

    d = Dict{Int, Union{Float64, Missing}}([nt.degree => round_pos(nt.energy) for nt in nts])
    for n in 1:atomic_number
        if ! haskey(d, n)
            push!(d, n=>missing)
        end
    end

    v = [d[i] for i in 1:atomic_number]
    return v
end


