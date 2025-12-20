"""
Jordan Administrative Boundaries - Python Usage Examples

Demonstrates how to load, visualize, and analyze Jordan administrative boundaries
using GeoPandas, Matplotlib, and Pandas.

Requirements:
    pip install geopandas matplotlib pandas
"""

import geopandas as gpd
import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path

# Set up paths (adjust to your local directory)
DATA_DIR = Path("../data")
GPKG_DIR = DATA_DIR / "gpkg"

# ==============================================================================
# Example 1: Load and display governorate boundaries
# ==============================================================================

print("=" * 80)
print("Example 1: Load Governorate Boundaries")
print("=" * 80)

governorates = gpd.read_file(GPKG_DIR / "gov_simpl_20m.gpkg")
print(f"\nLoaded {len(governorates)} governorates")
print(f"CRS: {governorates.crs}")
print(f"\nFirst 3 governorates:")
print(governorates[['name_en', 'name_ar', 'wikidata']].head(3))

# Plot governorates
fig, ax = plt.subplots(figsize=(10, 10))
governorates.plot(ax=ax, edgecolor='black', facecolor='lightblue', linewidth=1.5)
governorates.apply(lambda x: ax.annotate(text=x['name_en'],
                                          xy=x.geometry.centroid.coords[0],
                                          ha='center', fontsize=8), axis=1)
ax.set_title("Jordan Governorates", fontsize=14, fontweight='bold')
ax.axis('off')
plt.tight_layout()
plt.savefig("governorates_map.png", dpi=150)
print("\nSaved map to: governorates_map.png")

# ==============================================================================
# Example 2: Load and visualize districts
# ==============================================================================

print("\n" + "=" * 80)
print("Example 2: District Visualization")
print("=" * 80)

# Load districts (spatial)
districts = gpd.read_file(GPKG_DIR / "dis_simpl_20m.gpkg")
print(f"\nLoaded {len(districts)} districts from GPKG")
print(f"\nAvailable columns: {', '.join(districts.columns[:10])}...")

# Plot districts colored by governorate
fig, ax = plt.subplots(figsize=(12, 10))
districts.plot(
    column='name_en_2',  # Parent governorate name
    ax=ax,
    legend=True,
    cmap='tab12',
    edgecolor='black',
    linewidth=0.5,
    legend_kwds={'title': "Governorate", 'bbox_to_anchor': (1.05, 1), 'loc': 'upper left'}
)
ax.set_title("Jordan Districts Colored by Governorate",
             fontsize=14, fontweight='bold')
ax.axis('off')
plt.tight_layout()
plt.savefig("districts_by_governorate.png", dpi=150, bbox_inches='tight')
print("\nSaved district map to: districts_by_governorate.png")

# Print summary by governorate
print(f"\nDistricts per Governorate:")
districts_per_gov = districts.groupby('name_en_2').size().sort_values(ascending=False)
for gov, count in districts_per_gov.items():
    print(f"  {gov}: {count} districts")

# ==============================================================================
# Example 3: Spatial joins - Find which governorate each district belongs to
# ==============================================================================

print("\n" + "=" * 80)
print("Example 3: Spatial Join (Districts to Governorates)")
print("=" * 80)

# Perform spatial join
districts_with_gov = gpd.sjoin(
    districts[['name_en', 'geometry']],
    governorates[['name_en', 'geometry']],
    how='left',
    predicate='within'
)

# Show first few results
print("\nDistricts and their parent governorates:")
print(districts_with_gov[['name_en_left', 'name_en_right']].head(10).to_string(index=False))

# ==============================================================================
# Example 4: Calculate area and population density
# ==============================================================================

print("\n" + "=" * 80)
print("Example 4: Calculate Area and Population Density")
print("=" * 80)

# Project to UTM Zone 36N (EPSG:32636) for accurate area calculation
districts_utm = districts.to_crs("EPSG:32636")

# Calculate area in km²
districts_utm['area_km2'] = districts_utm.geometry.area / 1_000_000

# Merge with population data
if 'districts_for_suave_with100K_2_no_wkt_Population 2024#number' in districts.columns:
    districts_utm['population'] = districts['districts_for_suave_with100K_2_no_wkt_Population 2024#number']
    districts_utm['pop_density_per_km2'] = districts_utm['population'] / districts_utm['area_km2']

    print(f"\nArea and Population Density Statistics:")
    print(f"  Total area: {districts_utm['area_km2'].sum():.0f} km²")
    print(f"  Mean district area: {districts_utm['area_km2'].mean():.0f} km²")
    print(f"  Total population: {districts_utm['population'].sum():,.0f}")
    print(f"  Mean population density: {districts_utm['pop_density_per_km2'].mean():.0f} per km²")

    # Find most and least dense districts
    most_dense = districts_utm.nlargest(3, 'pop_density_per_km2')
    print(f"\nMost densely populated districts:")
    for idx, row in most_dense.iterrows():
        print(f"  {row['name_en']}: {row['pop_density_per_km2']:.0f} per km²")

# ==============================================================================
# Example 5: Export to other formats
# ==============================================================================

print("\n" + "=" * 80)
print("Example 5: Export to Other Formats")
print("=" * 80)

# Export governorates to Shapefile
governorates.to_file("governorates.shp")
print("Exported governorates to: governorates.shp")

# Export districts to GeoJSON
districts.to_file("districts.geojson", driver="GeoJSON")
print("Exported districts to: districts.geojson")

# Export district attributes to CSV (without geometry)
districts_df = pd.DataFrame(districts.drop(columns='geometry'))
districts_df.to_csv("districts_attributes.csv", index=False)
print("Exported district attributes to: districts_attributes.csv")

# ==============================================================================
# Example 6: Filter and subset
# ==============================================================================

print("\n" + "=" * 80)
print("Example 6: Filter Districts by Governorate")
print("=" * 80)

# Filter districts in Amman governorate
amman_districts = districts[districts['name_en_2'] == 'Amman']
print(f"\nFound {len(amman_districts)} districts in Amman Governorate:")
print(amman_districts['name_en'].tolist())

# Plot only Amman governorate districts
fig, ax = plt.subplots(figsize=(10, 10))
amman_districts.plot(ax=ax, edgecolor='black', cmap='Set3')
ax.set_title("Districts in Amman Governorate", fontsize=14, fontweight='bold')
ax.axis('off')
plt.tight_layout()
plt.savefig("amman_districts.png", dpi=150)
print("\nSaved Amman districts map to: amman_districts.png")

print("\n" + "=" * 80)
print("All examples completed successfully!")
print("=" * 80)
