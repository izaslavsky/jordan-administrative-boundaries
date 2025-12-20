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
CSV_DIR = DATA_DIR / "csv"

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
# Example 2: Load and analyze districts with disease data
# ==============================================================================

print("\n" + "=" * 80)
print("Example 2: District Disease Analysis")
print("=" * 80)

# Load districts (spatial)
districts = gpd.read_file(GPKG_DIR / "dis_simpl_20m.gpkg")
print(f"\nLoaded {len(districts)} districts from GPKG")

# Load district attributes (CSV with disease data)
districts_csv = pd.read_csv(CSV_DIR / "Districts.csv")
print(f"Loaded {len(districts_csv)} districts from CSV")

# Merge GPKG and CSV using wikidata as key
# First, clean up the long column name in GPKG
if 'districts_for_suave_with100K_2_no_wkt_wikidata#hiddenmore' in districts.columns:
    districts['wikidata_join'] = districts['districts_for_suave_with100K_2_no_wkt_wikidata#hiddenmore']
else:
    districts['wikidata_join'] = districts['wikidata']

# Merge on wikidata
districts_merged = districts.merge(
    districts_csv[['wikidata', 'Diarrheal Diseases per 100K']],
    left_on='wikidata_join',
    right_on='wikidata',
    how='left'
)

# Plot diarrheal disease rates
fig, ax = plt.subplots(figsize=(12, 10))
districts_merged.plot(
    column='Diarrheal Diseases per 100K',
    ax=ax,
    legend=True,
    cmap='YlOrRd',
    edgecolor='black',
    linewidth=0.5,
    legend_kwds={'label': "Diarrheal Disease Incidence (per 100K)", 'shrink': 0.6}
)
ax.set_title("Diarrheal Disease Incidence by District (per 100,000)",
             fontsize=14, fontweight='bold')
ax.axis('off')
plt.tight_layout()
plt.savefig("diarrheal_disease_map.png", dpi=150)
print("\nSaved disease map to: diarrheal_disease_map.png")

# Print summary statistics
print(f"\nDiarrheal Disease Statistics:")
print(f"  Mean: {districts_csv['Diarrheal Diseases per 100K'].mean():.1f} per 100K")
print(f"  Median: {districts_csv['Diarrheal Diseases per 100K'].median():.1f} per 100K")
print(f"  Min: {districts_csv['Diarrheal Diseases per 100K'].min():.1f} per 100K")
print(f"  Max: {districts_csv['Diarrheal Diseases per 100K'].max():.1f} per 100K")

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

# Export district attributes to Excel
districts_csv.to_excel("districts_data.xlsx", index=False)
print("Exported district data to: districts_data.xlsx")

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
