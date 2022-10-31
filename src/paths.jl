# local files
datadir = normpath(@__DIR__ , "../data/")
elements_src = normpath(datadir , "elements.db")
tmp_dir = @get_scratch!("mendeleev_files")
elements_dbfile = normpath(tmp_dir, "mendeleev-elements.db")
chembook_jsonfile = normpath(datadir , "el_chembook.json")

python_db_file = "~/Library/Python/3.9/lib/python/site-packages/mendeleev/elements.db"

# Mendeleev.jl files
function path_in_Mend(fl, path=nothing)
    if isnothing(path)
        # path = normpath(@__DIR__ , "../../src/")
        path = normpath(raw"C:\_MyOwnDocs\SoftwareDevelopment\Mendeleev.jl\src")
    end
    return normpath(path, fl)
end

path_docs = normpath(path_m, "../docs/src/")

elements_init_data = path_in_Mend("elements_init.jl", path_m)
static_data_fl = path_in_Mend("data.jl/elements_data.jl", path_m)
oxstate_fl = path_in_Mend("data.jl/oxistates_data.jl", path_m)
screening_fl = path_in_Mend("data.jl/screening_data.jl", path_m)
ionization_fl = path_in_Mend("data.jl/ionization_data.jl", path_m)
isotopes_fl = path_in_Mend("data.jl/isotopes_data.jl", path_m)
fields_doc_fl = path_in_Mend("elements_data_fields.md", path_docs)

ionicradii_fl = path_in_Mend("data.jl/ionrad_data.jl", path_m) 

db_struct_prev_fl = normpath(datadir , "db_struct_prev.jl")
db_struct_new_fl = normpath(datadir , "db_struct_new.jl")

@assert ispath(fields_doc_fl)