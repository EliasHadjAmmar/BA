# Identification

Two dimensions to the exogenous variation:
- quasi-random timing: *when* does the ruling lineage go extinct?
- quasi-random succession: *which lineage's territory* will the city join?

I feel like the second one is way more imporant, and the first one is barely important at all. I also feel like the second is way harder to argue for than the first.

What are the implications of this?
Well, I could exclude acquisitions by e.g. the Habsburgs. Or I could control for this - and I should do this anyway - by **interacting the treatment dummy with the size of the new territory,** i.e. to use a treatment with varying intensity. Or use other interactions, such as wealth of the acquiring family (proxied by construction in their city of residence?).

## Diff-in-diff

My instinct says to just plot the construction time series for each city, add vertical lines where there's a territory change for the city, and see if there's a break in the time series afterwards. Check this for all cities and see whether there is an effect on average.

In other words, run a generalised diff-in-diff, using lineage extinctions as treatment.

To refine the analysis, split the sample or interact the treatment with city or lineage characteristics.