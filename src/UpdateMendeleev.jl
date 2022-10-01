"""
The UpdateMendeleev module updates files in the (separate) Mendeleev.jl package.
For this purpose, three function must be called in a sequence. Thus, usage is as following
# Examples
```julia-repl
julia> using UpdateMendeleev; upd_mend1(); upd_mend2(); upd_mend3()
```
"""
module UpdateMendeleev
using SQLite, DataFrames, Tables, PeriodicTable # Unitful, 
using JSONTables
using Scratch

dev = false

d = @__DIR__
inclpath(fl) = normpath(d, fl)

# TODO somehow set path before runnung the whole package
path_m = normpath(d, "../../Mendeleev.jl/src")


include("paths.jl")
# include(path_in_Mend("units.jl")) # part of Mendeleev
include(path_in_Mend("seriesnames.jl", path_m)) # part of Mendeleev
include(path_in_Mend("Group_M_def_data.jl", path_m)) # part of Mendeleev
include(path_in_Mend("synonym_fields.jl", path_m)) # part of Mendeleev
include(path_in_Mend("screeniningconsts_def.jl", path_m)) # part of Mendeleev
include("PeriodicTable2df.jl")
include("make_struct.jl")
# include("utype2str.jl")
# include("f_units.jl")
include("els_data_import.jl")
include("more_data_import.jl")
include("Isotopes.jl")

include("make_static_data.jl")

if ! dev
    make_chem_elements(elements_init_data, els)
    make_elements_data(static_data_fl, data_dict)
    make_isotopes_data(isotopes_fl)
    # make_static_data(static_data_fl, vs, f_unames)
    make_screening_data(screening_fl)
    make_ionization_data(ionization_fl)

    # oxidation states are my own work now, no import from Mendeleev db
    # make_oxstates_data(oxstate_fl)
end

# function upd_mend1(m_path=nothing; dev = false)
#     if ! dev
#         write_struct_jl(struct_fl, s_def_text)
#     end
#     return nothing
# end

# function upd_mend2(m_path=nothing; dev = false)
#     if ! dev
#          include(inclpath("make_static_data.jl"))
#     end
#     return nothing
# end

# function upd_mend3(m_path=nothing; dev = false)
#     if ! dev
#         make_isotopes_data(isotopes_fl)
#         make_static_data(static_data_fl, vs, f_unames)
#         make_screening_data(screening_fl)
#         make_ionization_data(ionization_fl)

#         # oxidation states are my own work now, no import from Mendeleev db
#         # make_oxstates_data(oxstate_fl)
#     end
#     return nothing
# end
# 
# export upd_mend1, upd_mend2, upd_mend3

end  # module UpdateMendeleev
