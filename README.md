# 49.3 leaderboard

This is a quick and dirty one-page website that parses the website of Assemblée Nationale to find the number of 49.3 uses of each French Prime Minister.

See it live [here](https://klafyvel.github.io/quaranteneuftrois/).

## Adding a Prime Minister

You need to add them to the `ALL_PRIME_MINISTERS` vector.

## How is it parsed?

It is dirty. Basically we take the page [here](https://www.assemblee-nationale.fr/dyn/decouvrir-l-assemblee/engagements-de-responsabilite-du-gouvernement-et-motions-de-censure-depuis-1958), take the first `table` element, and then each row with exactly 7 cells is a 49.3 use. Then we rank the Prime Ministers by number of uses and generate the leaderboard.

## Can I change the template?

By all means do. I am not a good designer, everything is held in one single file: `template.html`. You will easily find the place where the leaderboard is inserted. If you wan to change the leaderboard, you need to edit the relevant section of `generate.jl` (the `entry` section).

## How does the website get update?

Through a GitHub workflow.

## Why use Julia?

I engaged the responsibility of my government on that.
