import os
from pathlib import Path

outdir = Path(os.getenv("QUARTO_PROJECT_OUTPUT_DIR"))
os.system(f"rsync -av img {outdir}")
os.system(f"rsync -av results {outdir}")
