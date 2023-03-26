# Empirical approach
## Exploration and descriptive props

Plot switching events across time (no. of cities that switched per year). this would actually be important upfront, to determine the ideal specification.

For cities with available craftsman wage data in Allen (2001), overlay wages and construction activity to show that they match.

For some exemplary cities (to be identified), plot the construction time series and add vertical lines where the city switches territory. See if there's a break in the time trends afterwards. Maybe talk to Elvira about how she did it with the names.

## Identification

the most braindead version of the analysis is:

construction_{it} = city + year + β treat x post_{it} + e_{it}

what i currently wanna do is:

construction_{it} = city + year + β sizediff_{e} x post_{et} + e_{it}

What if I used "extinction of dynasty ruling i in period t" **as an IV** for "increase in territory size of city i"? Wouldn't this solve the problem of selection into the territories of more/less prosperous families, if such a problem exists? The reduced form is equivalent to my "braindead" specification, but with 2SLS I actually do get the effect of *size* rather than ruler quality difference. Dittmar and Seabold (2018) do something similar using the deaths of printers as an IV for higher printed output, to estimate the effect of printed output on growth. This would be exactly analogous.

Next steps here: 
- read Cantoni and Yuchtman's chapter in the Handbook
- read the relevant chapters of Mostly Harmless Econometrics
- read the paper by Baker et al. (2022) on staggered DiD
- if I want to use the IV: read Dittmar and Seabold (2018)

### NEW: switching and non-switching cities

This is absolutely *crucial*. 

There are two things that can lead to a sizediff treatment for a city. One is being a city in a territory that is taken over. The other one, which I totally haven't considered so far, is *being a city in a territory that takes over another.*

I have not thought at all about how to incorporate these into the analysis, or whether I should. My hunch is that I may want to drop those, or else I may really be able to exploit them? Or do the analysis for both separately. Or jointly.

Parallel trends means that construction in all cities would have trended the same without the size increases. It means assignment of treatment that is as good as random.
What this means for takeover victims: your propensity to grow does not determine whether the ruler of a small or large territory gets you.
What this means for the previous holdings of the successor: your propensity to grow does not determine whether your ruler acquires more or less new territory.

If the two cases are not exactly the same, then it must also hold that growth potential does not affect the probability of being on either side of a takeover. But I think that is the one thing I've been assuming so far, because that's determined by ruler fertility etc.

Worst case, which empirical strategy best supports these assumptions?

### The variation

Bring some order into this section.

Before making the final decisions, think hard about the variation in your variables (see [John Cochrane](https://web.archive.org/web/20110411061350/https://faculty.chicagobooth.edu/john.cochrane/research/papers/phd_paper_writing.pdf), section 3).

Potential source of OVB: leader quality (part of the error term) may be correlated with terr size (maybe not systematically though) as well as construction. this will always have to remain an omitted variable I guess. Unless I do something *really* fancy. 

That's a much bigger problem than I initially thought. If I look at short-term effects, then who's to say that the explanation is on the lineage level, rather than the ruler level? Just read the introduction of Dube and Harish (2020) to understand what I mean here.

Maybe here's a way around this: 
- you estimate the effects of ruler changes in normal successions, and show that they're an order of magnitude smaller than dynasty switches.
- you control for the city's ruler in period t (ruler fixed effects). could this lead to a multicollinearity problem though?


(this is older) Two dimensions to the exogenous variation:
- quasi-random timing: *when* does the ruling lineage go extinct?
- quasi-random succession: *which lineage's territory* will the city join?

I feel like the second one is way more imporant, and the first one is barely important at all. I also feel like the second is way harder to argue for than the first.

What are the implications of this?
Well, I could exclude acquisitions by e.g. the Habsburgs. But what does this achieve?

Or I could control for this - and I should do this anyway - by **interacting the treatment dummy with the size of the new territory,** i.e. to use a treatment with varying intensity. Or use other interactions, such as wealth of the acquiring family (proxied by construction in their city of residence?).

### Initial idea: basic staggered Diff-in-diff, no size

My instinct says to just plot the construction time series for each city, add vertical lines where there's a territory change for the city, and see if there's a break in the time series afterwards. Check this for all cities and see whether there is an effect on average.

In other words, run a generalised diff-in-diff, using lineage extinctions as treatment.

To refine the analysis, split the sample or interact the treatment with city or lineage characteristics.


## Chaotic writings from 17.02.2023

Don’t glorify it.
What you do is run a regression. Your thesis is just presenting that regression.

You have what are essentially OLS results. Don’t have any pretensions about causal identification. 
Do get MHE and try to find the best spec possible. But don’t wax poetic about the importance of the results; it comes off as delusional.


Show that construction is good: overlay construction and crafts wages. That’s also a good descriptive prop. Could be Fig. 1.

Use # of children as IV for dynasty extinction?
Use # of daughters?
All of this depends on what exactly the endogeneity problem is. If there even is one.
Issue: This would work on the ruler level. But on the city-year level the first stage would not exist.

The problem of selection in terms of which lineage takes over can probably be solved by splitting the sample / using interactions.

### This is the important part
But what if the size of the city plays a role? What if bigger, faster-growing cities go to bigger, faster-growing territories?

*That is the main endogeneity problem, the main source of bias.*

What if I regress on the difference between before and after?
**Treat the size increase like a random cash transfer. The size increase is the treatment. If a city’s territory’s size didn’t change then it didn’t get treatment.**

That's a big conceptual step right there.

### What kind of variation to use
Faction-year fixed effects?

Essentially what you would ideally want to do:
take the same city twice. put one in a big terr and put one in a small terr.

What seems like a good approximation:
take two similar cities from the same terr. one of them goes to a big terr and another to a small. compare the trends.
do this for all similar-city pairs from all terrs and average the effects.

**this means that i want territory-of-origin fixed effects.**
**i want to know the effect of going to a bigger territory, holding the territory of origin constant. i want to essentially run an epidemiological study. or something like a border-discontinuity.**

if cities are people, construction is some behavioural outcome, territory size is income, and the treatment is a cash transfer, then I want to control for pre-treatment income. this is what holding pre-switch territory constant amounts to.

one small thing with that: **territory of origin is time-invariant and will be included in the city fixed effect.**


isnt pre-treatment income included in the person fixed effect? but then what are we comparing?
honestly, I think this is me worrying about something that the DiD already takes care of. I might want to just write down a regression equation, a working version, and then see whether it’s fine. iteratively. 

My working version of the equation: see above.

#### Detour: multiple switches
Territory-of-origin is actually not time-invariant if there are multiple switches. Or is it? Yes it should be. Lets say munich goes to hannover in 1700 then to prussia in 1703. open question: what should the regression look like?

My hunch: split / prune the data so that there is at most one switch per city per regression.

-> exclude munich from the analysis. when the switches are sufficiently close together, omit the middle one and recode it as a single switch in the data. when there are multiple switches with like a century between them, and if this is the case for many cities, then run separate regressions for each century, omitting all cities that have multiple switches within that century only.

Another option could be to just add another diff. Run the following regression: 
construction_it = city + year + beta * diff1 * post1 + gamma * diff2 * post2. 

What would be the implications of this?



#### Probably even less relevant
isnt it, worst case, about how the city and the territory match?
maybe a small city does well in a big territory and a big city does well in a small territory. in that case i wont be able to get a meaningful estimate -

Well, that’s why it will be important to split the sample along all possible dimensions, like city size at the time of split, and see where the effects come from.


## Validity

If I do a DiD, I definitely need an event study (or the staggered equivalent) to show parallel trends / no pre-trends.

I'm a bit scared that there *is* no staggered equivalent to an event study? I'm sure it will be in the Baker et al. (2022) paper.


Acharya and Lee (2019) show that a shortage of male heirs led to worse development. Intuitively, this seems like a glaring weakness of my approach. But is it?
If I compare cities with no territory switches to cities *with* territory switches, then I should expect a negative effect of the switch. (Check whether they find this for the long term or short term). But if I restrict the sample to cities that switched, and the only variation I use is variation in new-territory size, then it should be a non-issue.

I definitely need a glanceable list of all issues.


# Note from 24.02.2023
Save progress on id writeup
Rewrite id writeup:
- old spec doesn’t include non-extinction takeovers -> problem?
- alternative: use all size changes and iv for size change with extinction
- problem: overlapping; if there is a post for each size change then there may be a lot more of them (data?)
- -> actually compute
    - the share of cities that switch never, once, twice
    - the number of size diff events
    - the number of switching events
    - the share of extinctions in them
    - the share of terrs that doesn’t go extinct
    - the share of terrs that doesn’t cease to exist
    - extinction events ranked by affected cities, and by no. of beneficiaries
and (first of all) make a simple graph of terr size for terrs across time
to see whether splitting into period regressions is feasible / how many cities I would have to drop
also to see how much it varies across time

For the purpose of computing these summary statistics, make a simple script in the analysis folder. Build the data once it becomes necessary (except for regression dummies).

BUT NOT NOW
Do your laundry first, then eat, then do bar stuff, then clean your room, then at night you can play.

—

And then, with the IV, there‘s a different issue. I‘m not sure it‘s valid. I‘m not sure it works exactly like in Dittmar and Seabold.

Reason being: in DS the ER holds because why would a printer‘s death affect growth through any channel other than his printing?

—

Run a stacked DiD / event study, following the IU slides.
This involves partitioning observations into cleanly separable sub-experiments and dropping everything else, then stacking the sub-experiments, then running a regular old DiD on the stacked data.
Stacked DiD: gives you the unbiased average of the time-varying effects.
Stacked event study: gives you the unbiased effect in each post period.
see how many observations you can keep for treatment windows of varying size.


can I do „department-specific trends“ as Banerjee et al. (2010) do on p. 

—-
definition of „size“?
if it’s about integration, maybe it should be „number of cities“, „number of markets“, or „number of larger cities. Or „number of people“.


control for leader death for city i in year t!! this is what jones and olken tells us. for sure I should do that. As summarised by CY, „they find that when a leader happens to die, growth trajectories significantly change.

——

Power and prosperity
Territory-level outcome aggregation
Control for capitals
Enlightened despots vs church (g_A)
alesina spolaore state /elite formation

measure segregation:
overfit a polynomial regression of population on x and y coordinates
add race FEs and interactions with each term of the polynomial
somehow evaluate how much of a difference the interactions make

——

Naive OLS
Reverse causality from growth to size -> solution: HNE(s)
Properties of the HNE -> challenges -> solutions:
- staggered treatment and dynamic effects -> stacked event study
- selection into treatment -> use extinction as IV
- differential effects -> slice and dice

I just realised: the predicted values for sizediff will all be the same: the mean sizediff in extinction years among all cities (holding controls constant). So I should look at the distribution of the true sizediffs to see if that reduction misses something important.

# Note End