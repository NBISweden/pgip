import os
from pathlib import Path

if not os.getenv("QUARTO_PROJECT_RENDER_ALL"):
    exit()


outdir = Path(os.getenv("QUARTO_PROJECT_OUTPUT_DIR"))
os.system(
    'rsync -av --include "*/" --include "*gz" '
    f'--exclude "*.trees" --exclude "*" data/results {outdir}'
)
os.system(
    'rsync -av --include "*/" --include "*.slim" ' f'--exclude "*" recipes {outdir}'
)
