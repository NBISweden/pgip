#!/usr/bin/env python
import errno
import logging
import os
import shutil


def safe_copy(src, dst):
    logging.debug(f"Copy {dst} -> {src}")
    if not os.path.exists(src):
        raise FileNotFoundError(errno.ENOENT, os.strerror(errno.ENOENT), src)
    try:
        shutil.copy(src, dst)
    except FileExistsError:
        logging.debug(f"Path {dst} exists; skipping")
    except Exception as e:
        print(e)
        raise


try:
    qpd = os.environ["QUARTO_PROJECT_DIR"]
except Exception as e:
    print(e)
    raise

SITE_DIR = os.path.join(qpd, "_site")

files = [
    "slides/demography/part1-pop-gen-demography-lecture.pdf",
    "slides/demography/part2-psmc-pop-gen-demography-lecture.pdf",
    "slides/selection/selection.pdf",
    "exercises/population_structure/pca_admixture_1000G.ipynb",
    "exercises/population_structure/pca_mds_toy_example.ipynb",
]

for fn in files:
    src = os.path.join(qpd, fn)
    dst = os.path.join(SITE_DIR, fn)
    safe_copy(src, dst)
