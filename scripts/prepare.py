import os
from pathlib import Path

if not os.getenv("QUARTO_PROJECT_RENDER_ALL"):
    exit()

print(os.getenv("QUARTO_PROJECT_RENDER_ALL"))
print(os.getenv("QUARTO_PROJECT_OUTPUT_DIR"))

outdir = Path(os.getenv("QUARTO_PROJECT_OUTPUT_DIR"))
os.system(f"rsync -av img {outdir}")
os.system(
    'rsync -av --include "*/" --include "*gz" '
    f'--exclude "*.trees" --exclude "*" data/results {outdir}'
)
