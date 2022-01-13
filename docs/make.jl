using RoboSimples
using Documenter

DocMeta.setdocmeta!(RoboSimples, :DocTestSetup, :(using RoboSimples); recursive=true)

makedocs(;
    modules=[RoboSimples],
    authors="Paulo Jabardo <pjabardo@ipt.br>",
    repo="https://github.com/pjsjipt/RoboSimples.jl/blob/{commit}{path}#{line}",
    sitename="RoboSimples.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)
