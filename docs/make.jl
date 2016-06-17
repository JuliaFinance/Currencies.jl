using Documenter
using Currencies

makedocs(
    modules = [Currencies],
    doctest = false
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    deps = Deps.pip(
            "pygments",
            "mkdocs",
            "mkdocs-material",
            "python-markdown-math"),
    repo = "github.com/JuliaFinance/Currencies.jl.git"
)
