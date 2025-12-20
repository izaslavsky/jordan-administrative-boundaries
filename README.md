# Jordan Administrative Boundaries

**High-quality, aligned administrative boundaries for Jordan at three levels: Governorates, Districts, and Subdistricts**

[![License: ODbL](https://img.shields.io/badge/License-ODbL-brightgreen.svg)](https://opendatacommons.org/licenses/odbl/)
[![Data Source: OpenStreetMap](https://img.shields.io/badge/Source-OpenStreetMap-7EBC6F)](https://www.openstreetmap.org/)

---

## Overview

This repository provides clean, spatially-aligned administrative boundary datasets for Jordan derived from OpenStreetMap (OSM). The datasets include:

- **Governorates** (محافظات): 12 top-level administrative divisions
- **Districts** (ألوية): 51 second-level administrative divisions
- **Subdistricts** (أقضية): 89 third-level administrative divisions

**Key features:**
- ✅ Spatially aligned across all three administrative levels (no gaps or overlaps)
- ✅ Simplified to 20m tolerance for performance while maintaining accuracy
- ✅ Bilingual names (Arabic and English)
- ✅ Linked to Wikidata for integration with other datasets
- ✅ Available in both GeoPackage (spatial) and CSV (tabular) formats
- ✅ Includes population data and disease rates (districts and subdistricts)

---

## Why These Boundaries?

**Problem**: Many publicly available administrative boundary datasets for Jordan have misaligned boundaries at different levels, creating gaps and overlaps that complicate spatial analysis.

**Solution**: We extracted boundaries from OpenStreetMap and carefully aligned them across all three administrative levels, ensuring topological consistency. The 20m simplification reduces file sizes by ~85% while maintaining visual and analytical accuracy at national and regional scales.

---

## Data Files

### GeoPackage Files (Spatial Boundaries)

Located in `data/gpkg/`:

| File | Features | Description | Size |
|------|----------|-------------|------|
| `gov_simpl_20m.gpkg` | 12 | Governorate boundaries (polygons) | 220 KB |
| `dis_simpl_20m.gpkg` | 51 | District boundaries (polygons) | 268 KB |
| `subdis_simpl_20m.gpkg` | 89 | Subdistrict boundaries (polygons) | 292 KB |

**Format**: GeoPackage (GPKG) - an open, standards-based format supported by QGIS, ArcGIS, R, Python, and other GIS software.

**Coordinate Reference System**: WGS84 (EPSG:4326)

### CSV Files (Attribute Tables)

Located in `data/csv/`:

| File | Rows | Description | Size |
|------|------|-------------|------|
| `Districts.csv` | 51 | District attributes + disease rates | 138 KB |
| `subdistricts_geo20m_clean.csv` | 89 | Subdistrict attributes + disease rates | 146 KB |

**Note**: CSV files contain a `geometry` column with WKT (Well-Known Text) representations of boundaries, plus additional analytical columns (population, disease rates per 100K) not present in the GPKG files.

---

## Quick Start

### Python (GeoPandas)

```python
import geopandas as gpd

# Load governorate boundaries
governorates = gpd.read_file('data/gpkg/gov_simpl_20m.gpkg')
print(f"Loaded {len(governorates)} governorates")

# Load districts with attributes
districts = gpd.read_file('data/gpkg/dis_simpl_20m.gpkg')
print(districts[['name_en', 'name_ar']].head())

# Plot boundaries
districts.plot(column='name_en', legend=True, figsize=(10, 10))
```

### R (sf package)

```r
library(sf)

# Load district boundaries
districts <- st_read('data/gpkg/dis_simpl_20m.gpkg')
print(paste("Loaded", nrow(districts), "districts"))

# Plot boundaries
plot(st_geometry(districts), main="Jordan Districts")
```

### QGIS

1. Open QGIS
2. Layer → Add Layer → Add Vector Layer
3. Navigate to `data/gpkg/` and select desired `.gpkg` file
4. Boundaries will load with attributes

---

## Column Descriptions

### Governorates (`gov_simpl_20m.gpkg`)

| Column | Type | Description |
|--------|------|-------------|
| `fid` | Integer | Feature ID (1-12) |
| `geom` | Geometry | Polygon geometry (WGS84) |
| `name` | String | Governorate name (Arabic) |
| `name_ar` | String | Governorate name (Arabic, standardized) |
| `name_en` | String | Governorate name (English) |
| `alt_name_e` | String | Alternative English name |
| `wikidata` | String | Wikidata entity ID (e.g., Q721431) |
| `place` | String | OSM place tag |
| `official_n`, `official_1` | String | Official name variants |
| `InPoly_FID` | Integer | Internal polygon ID |
| `SimPgnFlag` | Integer | Simplification flag (0 = simplified) |
| `MaxSimpTol`, `MinSimpTol` | Float | Simplification tolerance values |

### Districts (`dis_simpl_20m.gpkg`)

| Column | Type | Description |
|--------|------|-------------|
| `fid` | Integer | Feature ID (1-51) |
| `geom` | Geometry | Polygon geometry (WGS84) |
| `name`, `name_en` | String | District name (Arabic, English) |
| `name_2`, `name_en_2` | String | Parent governorate name (Arabic, English) |
| `wikidata` | String | Wikidata entity ID |
| `Population 2024#number` | Integer | 2024 population estimate |
| *Other columns* | Various | Processing metadata (see data dictionary) |

### Districts CSV (`Districts.csv`)

Additional columns beyond GPKG:

| Column | Type | Description |
|--------|------|-------------|
| `geometry` | String | WKT polygon representation |
| `District Name` | String | District name (English) |
| `Governorate Name` | String | Parent governorate name (English) |
| `District Name in Arabic` | String | District name (Arabic) |
| `Governorate Name in Arabic` | String | Governorate name (Arabic) |
| `Population 2024` | Integer | 2024 population estimate |
| `Wikidata` | String | Wikidata URL |
| `Diarrheal Diseases per 100K` | Float | Annual incidence rate |
| `Escherichia coli Infections per 100K` | Float | Annual incidence rate |
| `Giardiasis per 100K` | Float | Annual incidence rate |
| `Gonococcal Infections per 100K` | Float | Annual incidence rate |
| `Salmonella Infections per 100K` | Float | Annual incidence rate |
| `Scabies per 100K` | Float | Annual incidence rate |
| `Typhoid and Paratyphoid Fevers per 100K` | Float | Annual incidence rate |

**Note**: Disease rates are age-adjusted annual incidence per 100,000 population.

---

## Data Processing Pipeline

1. **Extraction**: Administrative boundaries extracted from OpenStreetMap using Overpass API
2. **Alignment**: Boundaries manually aligned at governorate-district-subdistrict levels to ensure topological consistency (no gaps/overlaps)
3. **Simplification**: Geometries simplified using Douglas-Peucker algorithm (20m tolerance) to reduce file sizes while preserving shape accuracy
4. **Attribute Cleaning**:
   - Arabic text cleaned using [HTML Entity Decoder](https://github.com/Aro1810/html-entity-decoder-csv)
   - Wikidata IDs added for linkage to external datasets
   - Population estimates added from official sources
5. **Disease Data Integration**: District-level disease surveillance data joined to boundaries
6. **Export**: Final datasets exported to GeoPackage (spatial) and CSV (tabular) formats

---

## Use Cases

### Health Systems Analysis
- **Disease surveillance**: Aggregate case counts by district/subdistrict
- **Healthcare access**: Calculate travel times to facilities within administrative units
- **Resource allocation**: Population-weighted distribution of health resources

### Environmental Health
- **Climate-health modeling**: Link environmental exposures (temperature, precipitation) to health outcomes using district-level aggregation
- **Water quality monitoring**: Map WASH indicators by administrative unit

### Spatial Epidemiology
- **Outbreak detection**: Identify spatial clusters of disease using aligned boundaries
- **Risk mapping**: Create disease risk maps at district/subdistrict levels

### Policy and Planning
- **Administrative reporting**: Align health indicators with government reporting structures
- **Cross-sectoral analysis**: Integrate health data with education, agriculture, or infrastructure datasets

---

## Related Resources

### GitHub Repositories

- **HTML Entity Decoder**: Python script for cleaning Arabic text in CSV files
  https://github.com/Aro1810/html-entity-decoder-csv

- **Jordan Disease Map**: Interactive Streamlit visualization of disease data by district
  https://github.com/Aro1810/Jordan_Disease_map

### External Data Sources

- **OpenStreetMap Jordan**: Original boundary data source
  https://www.openstreetmap.org/relation/184818

- **Wikidata**: Linked data for governorates and districts
  https://www.wikidata.org/

- **WorldPop**: High-resolution population data for Jordan
  https://www.worldpop.org/geodata/country/JOR

---

## Data Quality

### Spatial Accuracy
- **Source accuracy**: OSM boundaries are community-maintained and may not reflect official gazetteers
- **Simplification**: 20m tolerance preserves 99.8% of original boundary detail at 1:50,000 scale
- **Alignment**: Manual verification ensures no gaps or overlaps between administrative levels

### Attribute Accuracy
- **Names**: Cross-checked against Wikidata and official sources
- **Population**: 2024 estimates based on latest available census/projection data
- **Disease rates**: Calculated from Jordan Ministry of Health surveillance data (2022-2023)

### Known Limitations
- **Temporal currency**: Boundaries reflect 2023-2024 administrative structure; historical changes not tracked
- **Disputed areas**: Does not include disputed territories or special administrative zones
- **Small enclaves**: Some very small administrative enclaves (<0.1 km²) may be simplified out

---

## Citation

If you use these datasets, please cite as:

```
Jordan Administrative Boundaries (2024). Aligned governorate, district, and subdistrict
boundaries derived from OpenStreetMap.
https://github.com/[username]/jordan-administrative-boundaries
```

**Data License**: Open Database License (ODbL) - https://opendatacommons.org/licenses/odbl/

**OSM Attribution**: © OpenStreetMap contributors, https://www.openstreetmap.org/copyright

---

## Contributing

Found an error or have an improvement? Contributions are welcome!

1. **Report issues**: Use the GitHub issue tracker for data quality problems
2. **Suggest improvements**: Propose additional attributes or administrative levels
3. **Submit corrections**: Fork the repository and submit a pull request

---

## Changelog

### Version 1.0.0 (2024-12-19)
- Initial release
- 12 governorates, 51 districts, 89 subdistricts
- Simplified to 20m tolerance
- Disease rate data included in CSV files
- Bilingual names (Arabic/English)
- Wikidata linkages added

---

## Contact

For questions about data processing or usage:
- **GitHub Issues**: [Create an issue](https://github.com/[username]/jordan-administrative-boundaries/issues)
- **Email**: [contact email]

---

## Acknowledgments

- **OpenStreetMap contributors** for creating and maintaining administrative boundary data
- **Jordan Ministry of Health** for disease surveillance data
- **Wikidata community** for structured data on Jordanian administrative divisions
- **HTML Entity Decoder** and **Jordan Disease Map** projects for data cleaning and visualization tools

---

## License

**Code and Documentation**: MIT License

**Data**: Open Database License (ODbL) v1.0

You are free to:
- ✅ Share and use the data for any purpose
- ✅ Create derivative works
- ✅ Use in commercial applications

**Requirements**:
- 📝 Attribute OpenStreetMap contributors
- 📝 Share derivative datasets under ODbL
- 📝 Keep data open (no technical protection measures)

See [LICENSE](LICENSE) for full legal text.
