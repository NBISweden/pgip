import os
from pathlib import Path

import pytest


def pytest_configure(config):
    pytest.dname = Path(os.path.dirname(__file__))
    pytest.project = Path(os.path.dirname(pytest.dname))
