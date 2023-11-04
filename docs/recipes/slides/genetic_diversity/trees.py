import msprime
import pandas as pd

# Small tree for calculation purposes
ts_small = msprime.sim_ancestry(2, sequence_length=1e4, random_seed=38)
ts_small_mut = msprime.sim_mutations(ts_small, rate=3e-5, random_seed=4)

# Balancing selection topology
ts_small_balance = msprime.sim_ancestry(2, sequence_length=1e4, random_seed=7)
ts_small_balance_mut = msprime.sim_mutations(
    ts_small_balance, rate=2.5e-5, random_seed=7
)


def genotypes(ts, *, sample_names=True, sample_prefix="sample ", collapse=True):
    gt = ts.genotype_matrix().T
    x = pd.DataFrame(gt)
    if collapse:
        x = x.apply(lambda row: "".join(row.values.astype(str)), axis=1)
    if sample_names:
        x.index = [f"{sample_prefix}{i}" for i in x.index]
    return x


def plot_tree(
    ts, *, id_string, show_sequences=True, node_labels=dict(), size=(250, 300), **kwargs
):
    css_extra = kwargs.pop("css_extra", "")
    css_string = (
        ".edge {stroke: black; stroke-width: 3px}"
        ".node > .lab {text-anchor: end; transform: rotate(-45deg) translate(-5px, 8px);}"
        ".node > .sym, .node:not(.leaf) > .lab {display: none}"
        ".node:not(.leaf) > .lab {display: none}"
    ) + css_extra
    css = kwargs.pop("css_string", css_string)
    node_labels = kwargs.pop("node_labels", None)
    if show_sequences:
        node_labels = dict()
        for ind in range(ts.num_samples):
            node_labels[ind] = f"{ind}: " + "".join(
                [str(x) for x in ts.genotype_matrix()[:, ind]]
            )
    style = f"#{id_string} {{" + css + "}"
    return ts.draw_svg(
        size=size,
        node_labels=node_labels,
        style=style,
        root_svg_attributes={"id": id_string},
        **kwargs,
    )
