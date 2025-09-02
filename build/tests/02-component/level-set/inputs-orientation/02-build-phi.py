import sys
import numpy as np
from PIL import Image
import rasterio
from rasterio.transform import from_origin

# ===============================
# CONFIGURATION
# ===============================

png_path = sys.argv[1]
output_tif = sys.argv[2]
domain_size  = float(sys.argv[3])
cell_size    = float(sys.argv[4])
crs_code     = sys.argv[5]

# ===============================
# LOAD PNG
# ===============================

img = Image.open(png_path).convert("RGB")
img_arr = np.array(img)

# Define phi field:
# - Black pixels = inside fireline -> PHI = -1.0
# - Elsewhere   = unburned         -> PHI = +1.0

is_black = np.all(img_arr == [0, 0, 0], axis=-1)
phi = np.where(is_black, -1.0, 1.0).astype(np.float32)

# ===============================
# Define GeoTIFF Metadata
# ===============================

n_rows, n_cols = phi.shape
transform = from_origin(
    -0.5 * domain_size,  # top-left X
     0.5 * domain_size,  # top-left Y
     cell_size,
     cell_size
)

# ===============================
# Save as GeoTIFF
# ===============================

with rasterio.open(
    output_tif, 'w',
    driver='GTiff',
    height=n_rows,
    width=n_cols,
    count=1,
    dtype='float32',
    crs=crs_code,
    transform=transform,
    compress='DEFLATE'
) as dst:
    dst.write(phi, 1)

print(f"PHI raster saved to: {output_tif}")
