import msprime


def tree_topology(
    model,
    *,
    svgid,
    size=(300, 500),
    x_axis=False,
    node_labels={},
    symbol_size=0,
    style=".edge {stroke-width: 2px}",
):
    """Plot tree topology under different evolutionary scenarios"""
    kwargs = dict(
        size=size,
        x_axis=x_axis,
        node_labels=node_labels,
        symbol_size=symbol_size,
        style=f"#{svgid} {{ {style} }}",
        root_svg_attributes={"id": svgid},
    )
    if model == "neutral":
        ts = msprime.sim_ancestry(10, random_seed=12)
    elif model == "expansion":
        demography = msprime.Demography()
        demography.add_population(name="A", initial_size=10_000, growth_rate=0.1)
        ts = msprime.sim_ancestry(
            samples={"A": 10}, demography=demography, random_seed=12
        )
    elif model == "bottleneck":
        demography = msprime.Demography()
        demography.add_population(name="A", initial_size=1_000)
        demography.add_instantaneous_bottleneck(time=100, strength=1000, population=0)
        ts = msprime.sim_ancestry(
            samples={"A": 10}, demography=demography, random_seed=12
        )
    elif model == "selection":
        Ne = 1_000
        L = 1e6
        sweep_model = msprime.SweepGenicSelection(
            position=L / 2,
            start_frequency=1.0 / (2 * Ne),
            end_frequency=1.0 - (1.0 / (2 * Ne)),
            s=0.25,
            dt=1e-6,
        )
        ts = msprime.sim_ancestry(
            10,
            model=[sweep_model, msprime.StandardCoalescent()],
            population_size=Ne,
            sequence_length=L,
            random_seed=119,
        )
    return ts.draw_svg(**kwargs)
