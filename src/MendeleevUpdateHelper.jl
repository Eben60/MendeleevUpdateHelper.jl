"""
The MendeleevUpdateHelper module updates files in the (separate) Mendeleev.jl package.
For this purpose, some function must be called in a sequence. Thus, usage is as following
# Examples
```julia-repl
julia> using UpdateMendeleev; # upd_mend1(); upd_mend2(); upd_mend3()
```
"""
module MendeleevUpdateHelper
using SQLite, DataFrames, Tables, PeriodicTable # Unitful, 
using JSONTables
using Scratch

dev = true # set to false to actually write data to Mendeleev.jl
update_db = false
dev = dev || update_db # only write to Mendeleev.jl after you controlled the changes of the database

d = @__DIR__
inclpath(fl) = normpath(d, fl)

# TODO somehow set path before runnung the whole package
path_m = normpath(d, "../../Mendeleev.jl/src")


include("paths.jl")
if dev
    using Mendeleev
    include("check_docs.jl")
end
include(db_struct_prev_fl)
include(path_in_Mend("data.jl/seriesnames.jl", path_m)) # part of Mendeleev
include(path_in_Mend("Group_M_def_data.jl", path_m)) # part of Mendeleev
include(path_in_Mend("property_functions.jl", path_m)) # part of Mendeleev
include(path_in_Mend("synonym_fields.jl", path_m)) # part of Mendeleev
include(path_in_Mend("screeniningconsts_def.jl", path_m)) # part of Mendeleev
include("PeriodicTable2df.jl")
include("make_struct.jl")
include("els_data_import.jl")
include("more_data_import.jl")
include("Isotopes.jl")

include("make_static_data.jl")
include("ionicradii.jl")

if ! dev
    make_chem_elements(elements_init_data, els)
    make_elements_data(static_data_fl, data_dict)
    # make_isotopes_data(isotopes_fl) # temporary, or at least until py-mendeleev checked and found OK
    # make_static_data(static_data_fl, vs, f_unames)
    make_screening_data(screening_fl)
    make_ionization_data(ionization_fl)
    make_irad_data(ionicradii_fl)
    # oxidation states are my own work now, no import from Mendeleev db
    # make_oxstates_data(oxstate_fl)
end

export checkdocs

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

end  # module MendeleevUpdateHelper
