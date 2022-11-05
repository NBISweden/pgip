"""pgip slim simulator CLI.

Wrapper that runs slim on SLIM controlfile.

"""
import logging
import os
import pathlib
import random
import shutil
import subprocess as sp
import tempfile
import time
from datetime import datetime
from multiprocessing.dummy import Pool

import click
import msprime
import numpy as np
import pyslim
import tskit
from pgip.logging import setup_logging


logger = logging.getLogger(__name__)


@click.command(help=__doc__)
@click.argument("slim", type=click.Path(exists=True))
@click.option(
    "--outdir",
    "-o",
    type=click.Path(),
    default=os.curdir + os.sep,
    help="Output directory",
)
@click.option(
    "N", "--population-size", "-N", type=int, default=1e4, help="Population size"
)
@click.option(
    "rho",
    "--recombination_rate",
    "-r",
    type=float,
    default=1e-8,
    help="Recombination rate",
)
@click.option(
    "mu", "--mutation_rate", "-m", type=float, default=1e-7, help="Mutation rate"
)
@click.option(
    "seqlength",
    "--sequence_length",
    "-l",
    type=int,
    default=1e6,
    help="Sequence length",
)
@click.option(
    "--repetitions",
    "-n",
    type=click.IntRange(
        1,
    ),
    default=1,
    help="Number of repetitions",
)
@click.option("--seed", help="Random seed", default=datetime.now())
@click.option(
    "--threads",
    help="Number of parallel threads to run",
    default=1,
    type=click.IntRange(
        1,
    ),
)
@click.option("--prefix", help="File output prefix", default="slim", type=str)
@click.option(
    "--no-recapitate", help="Don't do recapitation", default=False, is_flag=True
)
@click.option("--debug", help="Print debugging info", is_flag=True)
def cli(
    slim,
    outdir,
    repetitions,
    seed,
    threads,
    mu,
    rho,
    N,
    seqlength,
    prefix,
    no_recapitate,
    debug,
):
    setup_logging(debug)
    random.seed(seed)

    defs = []
    defs.extend(["-d", f"mu={mu}"])
    defs.extend(["-d", f"rho={rho}"])
    defs.extend(["-d", f"N={N}"])
    defs.extend(["-d", f"seqlength={seqlength}"])

    def run_slim(repetition):
        start_time = time.time()
        logger.info(f"Running repetition {repetition}...")
        slimseed = random.randint(1, 1e8)
        cmdlist = ["slim", "-s", str(slimseed)] + defs
        # FIXME: change to tempfile.NamedTemporaryFile
        with tempfile.TemporaryDirectory() as tmpdirname:
            treefile = f"{prefix}.{repetition}.trees"
            tmpfile = pathlib.Path(tmpdirname) / f"{treefile}"
            outfile = pathlib.Path(outdir) / f"{treefile}"
            cmd = " ".join(
                cmdlist
                + ["-d", f"\"outdir='{tmpdirname}'\""]
                + ["-d", f"\"outfile='{tmpfile}'\""]
                + [slim]
            )
            try:
                logger.debug(f"running {cmd}")
                res = sp.run(cmd, check=True, shell=True, capture_output=True)
            except sp.CalledProcessError:
                logger.error(f"{cmd} failed")
                logger.error(res.stderr)
                raise
            if no_recapitate:
                shutil.copy(tmpfile, outfile)
            else:
                logger.info(f"Recapitating trees for repetition {repetition}...")
                ts = tskit.load(tmpfile)
                tsrecap = pyslim.recapitate(
                    ts,
                    ancestral_Ne=N,  # NB: diploids; assume same size throughout
                    recombination_rate=rho,
                    random_seed=random.randint(1, 1e8),
                )
                next_id = pyslim.next_slim_mutation_id(tsrecap)
                tsmut = msprime.sim_mutations(
                    tsrecap,
                    rate=mu,
                    model=msprime.SLiMMutationModel(type=0, next_id=next_id),
                    keep=True,
                    random_seed=random.randint(1, 1e8),
                )
                tsmut.dump(outfile)
                logger.debug(
                    f"The tree sequence now has {tsmut.num_mutations} mutations,\n"
                    "and mean pairwise nucleotide diversity is "
                    f"{tsmut.diversity():0.3e}."
                )
        execution_time = time.time() - start_time
        logger.info(f"repetition {repetition} finished in {execution_time} seconds...")

    p = Pool(threads)
    for _ in p.imap(run_slim, np.arange(repetitions)):
        pass
