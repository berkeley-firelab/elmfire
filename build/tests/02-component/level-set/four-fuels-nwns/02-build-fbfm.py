# build_fbfm40_quad.py
import numpy as np
import rasterio
from rasterio.transform import from_origin
import sys

out_path = sys.argv[1]
domain_size = int(sys.argv[2])
cell_size = float(sys.argv[3])

n = int(domain_size / cell_size)
fbfm = np.zeros((n, n), dtype=np.int16)

# Assign fuel model codes to quadrants
fbfm[:n//2, :n//2] = sys.argv[4]   # NW
fbfm[:n//2, n//2:] = sys.argv[5]   # NE
fbfm[n//2:, :n//2] = sys.argv[6]   # SW
fbfm[n//2:, n//2:] = sys.argv[7]   # SE

transform = from_origin(
    -0.5 * domain_size,
     0.5 * domain_size,
     cell_size, cell_size
)

with rasterio.open(
    out_path, 'w',
    driver='GTiff',
    height=n, width=n,
    count=1, dtype='int16',
    crs='EPSG:32610',
    transform=transform,
    compress='DEFLATE'
) as dst:
    dst.write(fbfm, 1)
