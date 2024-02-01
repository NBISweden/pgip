#!/usr/bin/env python
"""Perform post rendering tasks"""
import errno
import logging
import os
import shutil


def safe_mkdir(dname):
    """Make directory if it doesn't exist"""
    logging.debug("Making directory %s", dname)
    if not os.path.exists(dname):
        try:
            os.mkdir(dname)
        except FileNotFoundError as exc:
            print(exc)
            raise


def safe_copy(source, destination):
    """Copy source to destination"""
    logging.debug("Copy %s -> %s", destination, source)
    if not os.path.exists(source):
        raise FileNotFoundError(errno.ENOENT, os.strerror(errno.ENOENT), source)
    try:
        shutil.copy(source, destination)
    except FileExistsError:
        logging.debug("Path %s exists; skipping", destination)
    except Exception as exc:
        print(exc)
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
    "slides/guest_lecture/webster_bumbles_NGIcourse_nov23.pdf",
    "archive/.footer.html",
    "archive/.header.html",
]

for fn in files:
    src = os.path.join(qpd, fn)
    dst = os.path.join(SITE_DIR, fn)
    dirname = os.path.dirname(dst)
    safe_mkdir(dirname)
    safe_copy(src, dst)
