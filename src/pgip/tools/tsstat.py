"""pgip tsstat - compile summary statistics from tree sequence file(s).

Parse TSFILE and compile summary statistics. Setting --sample-size
selects equal number of samples from all populations. Per-population
sample sizes can be set by providing (population_name, sample_size)
pairs to the --sample-sets option.

Note that S includes *hidden mutations* which means that it may
actually be lower than the total number of sites with mutations.

"""
import itertools
import logging
import random
from datetime import datetime
from inspect import signature
from multiprocessing.dummy import Pool

import click
import numpy as np
import pandas as pd
import tskit
from pgip.logging import setup_logging
from tqdm import tqdm

logger = logging.getLogger(__name__)


SSTAT = {
    "afs": "allele_frequency_spectrum",
    "sfs": "allele_frequency_spectrum",
    "pi": "diversity",
    "diversity": "diversity",
    "S": "segregating_sites",
    "segregating_sites": "segregating_sites",
    "TajD": "Tajimas_D",
}

MSTAT = {
    "Fst": "Fst",
    "dxy": "divergence",
    "divergence": "divergence",
    "Y1": "Y1",
    "Y2": "Y2",
    "f2": "f2",
    "f3": "f3",
    "f4": "f4",
    "gnn": "genealogical_nearest_neighbours",
}

MSITE = {
    "ld": "LdCalculator",
}

ALLSTAT = SSTAT | MSTAT | MSITE
stats = list(ALLSTAT.keys())


def calc_ld(windows, **kwargs):
    pass


def make_sample_sets(ts, sample_sets, sample_size, sample_seed):
    pmap = {
        p.metadata.get("name", None): p.id
        for p in ts.populations()
        if p.metadata is not None
    }

    random.seed(sample_seed)
    if sample_sets is not None:
        labels = [item[0] for item in sample_sets]
        sizes = [item[1] for item in sample_sets]
        data = list()
        for pop, sample_size in sample_sets:
            data.append(
                random.sample(list(ts.samples(population_id=pmap[pop])), sample_size)
            )
        return (labels, sizes, data)

    if sample_size is not None:
        return (
            ["ALL"],
            [sample_size],
            [random.sample(list(ts.samples()), sample_size)],
        )
    return ["ALL"], [len(ts.samples())], None


def make_windows(ts, num_windows, window_size):
    if num_windows is not None:
        windows = np.linspace(0, ts.sequence_length, num_windows + 1)
    elif window_size is not None:
        num_windows = int(ts.sequence_length / window_size)
        windows = np.linspace(0, ts.sequence_length, num_windows + 1)
    else:
        windows = None
    return windows


@click.command(help=__doc__)
@click.argument("tsfile", nargs=-1)
@click.option(
    "--threads",
    help="Number of parallel threads to run",
    default=1,
    type=click.IntRange(
        1,
    ),
)
@click.option(
    "--num-windows",
    "-w",
    help="Number of windows",
    type=click.IntRange(
        1,
    ),
)
@click.option(
    "--window_size",
    "-W",
    help="Window size",
    type=click.IntRange(
        1,
    ),
)
@click.option("--seed", help="Random seed", default=datetime.now())
@click.option(
    "--sample-sets",
    "-S",
    help="Sample sets provided as POPULATION_NAME SAMPLE_SIZE pairs",
    type=(str, int),
    multiple=True,
)
@click.option(
    "--statistic",
    "-s",
    help="Statistic to calculate",
    type=click.Choice(stats),
    multiple=True,
    required=True,
)
@click.option(
    "--sample-size",
    "-n",
    help="Number of samples per population. ",
    type=int,
    default=None,
)
@click.option("Ne", "--ne", help="Known effective population size (diploid)", type=int)
@click.option("--mu", "-m", help="Known mutation rate", type=float)
@click.option("--rho", "-r", help="Known recombination rate", type=float)
@click.option("--span-normalise", help="Normalise by window", is_flag=True)
@click.option("--debug", help="Print debugging info", is_flag=True)
def cli(
    tsfile,
    seed,
    num_windows,
    threads,
    Ne,
    mu,
    rho,
    sample_sets,
    statistic,
    window_size,
    sample_size,
    span_normalise,
    debug,
):
    setup_logging(debug)
    random.seed(seed)

    if len(sample_sets) == 0:
        sample_sets = None

    sample_seeds = dict(zip(tsfile, random.sample(range(int(1e9)), len(tsfile))))

    items = list(itertools.product(tsfile, [sample_sets], [sample_size]))
    functions = [ALLSTAT[s] for s in statistic]
    res = dict()

    def summary_statistic(tsfile, sample_sets, sample_size):
        logger.debug(f"compiling stats for {tsfile}...")
        kwargs = {}
        ts = tskit.load(tsfile)
        sample_set_labels, sample_size, kwargs["sample_sets"] = make_sample_sets(
            ts, sample_sets, sample_size, sample_seeds[tsfile]
        )
        windows = make_windows(ts, num_windows, window_size)
        if windows is not None:
            res[tsfile] = {"windows": np.tile(windows[:-1], len(sample_set_labels))}
        else:
            res[tsfile] = {"windows": np.tile([None], len(sample_set_labels))}
        # FIXME: Need to treat single population and multiple population separately
        for stat, f in zip(statistic, functions):
            if stat == "ld":
                fun = calc_ld
                logger.warning("ld as of yet unsupported")
                continue
            else:
                try:
                    fun = getattr(ts, f)
                except AttributeError as e:
                    print(e)
            if isinstance(fun, int):
                res[tsfile][stat] = fun
                res[tsfile]["sample_set"] = sample_set_labels[0]
                res[tsfile]["sample_size"] = sample_size
            else:
                t = signature(fun)
                if "span_normalise" in t.parameters:
                    data = fun(windows=windows, span_normalise=span_normalise, **kwargs)
                else:
                    data = fun(windows=windows, **kwargs)
                if windows is None:
                    res[tsfile][stat] = data
                    res[tsfile]["sample_set"] = sample_set_labels
                    res[tsfile]["sample_size"] = sample_size
                else:
                    res[tsfile][stat] = data.flatten()
                    res[tsfile]["sample_set"] = np.repeat(
                        sample_set_labels, len(windows) - 1
                    )
                    res[tsfile]["sample_size"] = np.repeat(
                        sample_size, len(windows) - 1
                    )
        logger.debug(f"done compiling stats for {tsfile}")

    def compile_summary_statistic(args):
        return summary_statistic(*args)

    with Pool(threads) as p:
        _ = list(tqdm(p.imap(compile_summary_statistic, items), total=len(items)))

    dflist = []
    for k, v in res.items():
        try:
            # Need to reorganize
            x = pd.DataFrame(v)
            x["fn"] = k
            x.set_index("fn", inplace=True)
        except ValueError:
            v["fn"] = k
            x = pd.DataFrame(v, index=["fn"]).set_index("fn")
        finally:
            pass
        dflist.append(x)
    X = pd.concat(dflist)
    print(X.to_csv(), sep="\t")
