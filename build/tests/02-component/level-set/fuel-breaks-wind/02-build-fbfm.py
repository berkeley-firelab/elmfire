import numpy as np
import pandas as pd
import rasterio
from rasterio.transform import from_origin
import sys

# Inputs
csv_path = sys.argv[1]           # e.g. fuelmap.csv
out_path = sys.argv[2]           # e.g. inputs/fbfm40.tif
domain_size = int(sys.argv[3])   # meters (e.g. 1000)
cell_size = float(sys.argv[4])   # meters (e.g. 10)

# Load CSV
data = pd.read_csv(csv_path, header=None).values.astype(np.int16)
nrows, ncols = data.shape

# Confirm dimensions match expected
expected = int(domain_size / cell_size)
assert nrows == expected and ncols == expected, "Grid size mismatch!"

# GeoTIFF metadata
transform = from_origin(
    -0.5 * domain_size,
     0.5 * domain_size,
     cell_size, cell_size
)

with rasterio.open(
    out_path, 'w',
    driver='GTiff',
    height=nrows, width=ncols,
    count=1,
    dtype=data.dtype,
    crs='EPSG:32610',
    transform=transform,
    compress='DEFLATE'
) as dst:
    dst.write(data, 1)

print(f"FBFM raster saved to: {out_path}")