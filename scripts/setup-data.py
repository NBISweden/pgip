#!/usr/bin/env python
import argparse
import errno
import logging
import os

import yaml

ROOT = os.path.normpath(os.path.join(os.path.dirname(__file__), os.pardir))

DATAROOT = os.environ.get("DATA_SOURCE", "pgip_data/data")


def abspath(path):
    return os.path.normpath(os.path.abspath(path))


def safe_link(src, dst, dir_fd):
    logging.debug(f"Link {dst} -> {src}")
    if not os.path.exists(src):
        raise FileNotFoundError(errno.ENOENT, os.strerror(errno.ENOENT), src)
    try:
        os.symlink(src, dst, dir_fd=dir_fd)
    except FileExistsError:
        logging.debug(f"Path {dst} exists; skipping")
    except Exception as e:
        print(e)
        raise


def main():
    parser = argparse.ArgumentParser(
        prog="setup-data.py",
        description="Setup data examples for rendering exercises and lectures",
    )
    parser.add_argument("-c", "--config", type=str, default="_data.yml")
    parser.add_argument(
        "-log", "--loglevel", default="warning", help="Provide logging level."
    )
    args = parser.parse_args()

    logging.basicConfig(level=args.loglevel.upper())

    with open(args.config, "r") as fh:
        pgip_data = yaml.safe_load(fh)

    # Loop through data and link files
    for session, dataset in pgip_data.items():
        if session.startswith("__"):
            continue
        logging.info(f"Setting up links for {session}")
        data = dict()
        for x in dataset:
            if isinstance(x, dict):
                data.update(**x)
                continue
            if x.startswith("__"):
                objlist = pgip_data[x]
                for item in objlist:
                    if isinstance(item, str):
                        data[os.path.basename(item)] = item
                    elif isinstance(item, dict):
                        data.update(**item)
            else:
                if isinstance(x, str):
                    data[os.path.basename(x)] = x
                elif isinstance(x, dict):
                    data.update(**x)
        for dst, src in data.items():
            session = os.path.join(session, os.path.dirname(dst))
            os.makedirs(session, exist_ok=True)
            dir_fd = os.open(session, os.O_RDONLY)
            src = abspath(os.path.join(DATAROOT, src))
            safe_link(src, os.path.basename(dst), dir_fd)


if __name__ == "__main__":
    main()
