import logging


def setup_logging(debug=False):
    logging.basicConfig(
        level=logging.INFO, format="%(levelname)s [%(name)s:%(funcName)s]: %(message)s"
    )
    if debug:
        logging.getLogger().setLevel(logging.DEBUG)
