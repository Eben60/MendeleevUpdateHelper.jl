    # Mendeleev.jl files
function path_in_Mend(fl, path=nothing)
    if isnothing(path)
        path = normpath(@__DIR__ , "../../Mendeleev.jl/src/")
        # path = normpath(raw"C:\_MyOwnDocs\SoftwareDevelopment\Mendeleev.jl\src")
    end
    p = normpath(path, fl)
    if ! ispath(p)
        error("file $p not found")
    end
    return p
end

function paths()
    # local files
    global datadir = normpath(@__DIR__ , "../data/")
    global elements_src = normpath(datadir , "elements.db")
    if update_db
        elements_src = get_mend_dbfile()
    end
    global tmp_dir = @get_scratch!("mendeleev_files")
    global elements_dbfile = normpath(tmp_dir, "mendeleev-elements.db")
    global chembook_jsonfile = normpath(datadir , "el_chembook.json")

    # python_db_file = "~/Library/Python/3.9/lib/python/site-packages/mendeleev/elements.db"



    global path_docs = normpath(path_m, "../docs/src/")

    # elements_init_data = path_in_Mend("elements_init.jl", path_m)
    global static_data_fl = path_in_Mend("data.jl/elements_data.jl", path_m)
    global oxstate_fl = path_in_Mend("data.jl/oxistates_data.jl", path_m)
    global screening_fl = path_in_Mend("data.jl/screening_data.jl", path_m)
    global ionization_fl = path_in_Mend("data.jl/ionization_data.jl", path_m)
    global isotopes_fl = path_in_Mend("data.jl/isotopes_data.jl", path_m)
    global fields_doc_fl = path_in_Mend("elements_data_fields.md", path_docs)

    global ionicradii_fl = path_in_Mend("data.jl/ionrad_data.jl", path_m) 

    global db_struct_prev_fl = normpath(datadir , "db_struct_prev.jl")
    global db_struct_new_fl = normpath(datadir , "db_struct_new.jl")

    @assert ispath(fields_doc_fl)
end