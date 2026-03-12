import numpy as np
import rasterio
import matplotlib.pyplot as plt
import glob
import os

# -------------------------------------------------
# Locate the time-of-arrival raster automatically
# -------------------------------------------------

toa_files = glob.glob("../../../../../tutorials/00-circular-no-wind/outputs/time_of_arrival*.tif")

if len(toa_files) == 0:
    raise RuntimeError("No time_of_arrival raster found")

toa_file = toa_files[0]
print("Using file:", toa_file)

# -------------------------------------------------
# Read raster
# -------------------------------------------------

with rasterio.open(toa_file) as src:
    toa = src.read(1)
    transform = src.transform

# -------------------------------------------------
# Build coordinate grid
# -------------------------------------------------

rows, cols = np.indices(toa.shape)
xs, ys = rasterio.transform.xy(transform, rows, cols)

xs = np.array(xs).flatten()
ys = np.array(ys).flatten()
t = toa.flatten()

# Remove nodata / zero cells
mask = t > 0
xs = xs[mask]
ys = ys[mask]
t = t[mask]

# -------------------------------------------------
# Ignition location (meters)
# -------------------------------------------------

x_ign = 0.0
y_ign = 3000.0

# -------------------------------------------------
# Compute radius from ignition
# -------------------------------------------------

r = np.sqrt((xs - x_ign)**2 + (ys - y_ign)**2)

# Sort by time
idx = np.argsort(t)
t = t[idx]
r = r[idx]

# -------------------------------------------------
# Plot radius vs time
# -------------------------------------------------

plt.figure(figsize=(6,4))
plt.scatter(t/3600.0, r/1000.0, s=1)

plt.xlabel("Time (hours)")
plt.ylabel("Radius (km)")
plt.title("Fire radius vs time")
plt.grid(True)

# -------------------------------------------------
# Save figure to report
# -------------------------------------------------

output_path = "../report/figures/radius_vs_time.png"
os.makedirs("../report/figures", exist_ok=True)

plt.savefig(output_path, dpi=300)
print("Saved figure:", output_path)

plt.show()
