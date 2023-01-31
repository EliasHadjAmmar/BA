### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ 1b494746-a128-11ed-0c0e-6f5473fb4a8c
md"""

# Sketch of a theory

What is the theory? There's a set of lineages and a set of cities belonging to each lineage. When a lineage goes extinct, its cities change possession. This means a qualitative change in leadership for these cities. It also means a change in territory size for all cities in the newly enlarged territory. I want to focus on the latter.

Maybe I can do some sort of (aggregate but structural) model of cities and territory sizes. As in, _sketching_ a _very simple_ model of the channels through which territory size affects construction in cities. 

Important: I don't need to come up with this by myself. If I can find something good and relevant in the literature, that would actually be better. Then it's just about exploring and visualising it in a notebook.
"""

# ╔═╡ 8305abd1-48f0-47c3-84fb-aa0ba930a403
md"""
### How to approach this
- read the papers on territory size for inspiration
- decide which channels you think are plausible
- study example notebooks that derive models (like [this one](https://floswald.github.io/julia-bootcamp/09-introsir.html))
- come up with the - important - *simplest possible way* of modeling small pieces of the problem
- translate those concepts / aspects into sets of objects and functions
- continue to tinker with them as you assemble the model
"""

# ╔═╡ Cell order:
# ╟─1b494746-a128-11ed-0c0e-6f5473fb4a8c
# ╟─8305abd1-48f0-47c3-84fb-aa0ba930a403
