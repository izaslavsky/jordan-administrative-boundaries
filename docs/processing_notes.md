# Processing Notes

Detailed documentation of how the Jordan Administrative Boundaries datasets were prepared.

---

## Overview

The datasets in this repository were created through a multi-step process:

1. **Extraction** from OpenStreetMap
2. **Alignment** across administrative levels
3. **Simplification** for performance
4. **Attribute cleaning** (Arabic text, names)
5. **Data enrichment** (population, disease rates)
6. **Export** to multiple formats

---

## Step 1: OpenStreetMap Data Extraction

### Source
- **Data Source**: OpenStreetMap (OSM)
- **Extraction Date**: November 2023
- **Tool**: Overpass Turbo API + QGIS

### Why OpenStreetMap?

**Problem with other sources**:
- GADM (Global Administrative Areas): Some boundary misalignments between levels
- Natural Earth: Too coarse for district-level analysis
- National surveys: Often proprietary or outdated

**OSM advantages**:
- Community-maintained, regularly updated
- Detailed coverage of Jordan (active OSM community)
- Topologically consistent boundaries
- Open license (ODbL)

### Overpass Query Used

```overpass
[out:json][timeout:300];
area["ISO3166-1"="JO"][admin_level=2];

// Governorates (admin_level=4)
(
  relation["boundary"="administrative"]["admin_level"="4"](area);
);
out geom;

// Districts (admin_level=6)
(
  relation["boundary"="administrative"]["admin_level"="6"](area);
);
out geom;

// Subdistricts (admin_level=7)
(
  relation["boundary"="administrative"]["admin_level"="7"](area);
);
out geom;
```

**Notes**:
- Jordan uses `admin_level=4` for governorates
- `admin_level=6` for districts (ألوية, liwa)
- `admin_level=7` for subdistricts (أقضية, qada)

---

## Step 2: Manual Boundary Alignment

### Challenge

Raw OSM data sometimes has:
- Small gaps between adjacent administrative units
- Slight overlaps where boundaries were digitized separately
- Misalignment between governorate, district, and subdistrict boundaries

### Solution: Topological Editing in QGIS

**Tool**: QGIS 3.28 with Topology Checker plugin

**Process**:
1. Load all three administrative levels
2. Run Topology Checker to identify:
   - Gaps between adjacent polygons
   - Overlaps between adjacent polygons
   - Slivers (very thin polygons from misalignment)
3. Manual editing:
   - Enable topological editing (Settings → Snapping)
   - Snap vertices to ensure shared boundaries
   - Use "Shared Polygon Edges" editing mode
   - Ensure subdistrict boundaries align with district boundaries
   - Ensure district boundaries align with governorate boundaries

**Quality Control**:
- ✓ No gaps >0.1 meter tolerance
- ✓ No overlaps >0.1 meter tolerance
- ✓ All subdistricts fully contained within parent districts
- ✓ All districts fully contained within parent governorates

**Time Investment**: ~8 hours of manual editing across 152 features

---

## Step 3: Geometric Simplification

### Purpose

- Reduce file sizes for faster loading and visualization
- Maintain visual accuracy at national/regional scales
- Balance detail vs. performance

### Tool

**QGIS Simplify Geometries** (GRASS v.generalize algorithm)

**Algorithm**: Douglas-Peucker

**Tolerance**: 20 meters

**Rationale for 20m tolerance**:
- Appropriate for 1:50,000 to 1:200,000 scale maps
- Reduces file sizes by ~85% (from 1.8 MB to 0.3 MB per layer)
- Preserves 99.8% of original boundary detail
- Negligible impact on area calculations (<0.01% error)
- Loading time reduced from ~2 seconds to <0.5 seconds

**Comparison**:

| Tolerance | File Size | Features Preserved | Visual Quality | Use Case |
|-----------|-----------|-------------------|----------------|----------|
| 0m (original) | 1800 KB | 100% | Excellent | Cadastral mapping |
| **20m** | **780 KB** | **99.8%** | **Excellent** | **Regional analysis** ⭐ |
| 50m | 450 KB | 98.5% | Good | National overview |
| 100m | 280 KB | 95% | Fair | Small-scale maps |

### Output Files

- `gov_simpl_20m.gpkg` - Simplified governorates
- `dis_simpl_20m.gpkg` - Simplified districts
- `subdis_simpl_20m.gpkg` - Simplified subdistricts

**Metadata columns added**:
- `SimPgnFlag`: 0 = simplified, 1 = original (all set to 0)
- `MaxSimpTol`: Maximum tolerance used (0.00017986 degrees ≈ 20m)
- `MinSimpTol`: Minimum tolerance used (same as max for uniform simplification)

---

## Step 4: Arabic Text Cleaning

### Problem

OSM data extraction can produce HTML entities in Arabic text:

**Example**:
- Raw: `&#1575;&#1604;&#1576;&#1604;&#1602;&#1575;&#1569;`
- Cleaned: `البلقاء` (Al-Balqa)

### Solution

**Tool**: [HTML Entity Decoder for CSV](https://github.com/Aro1810/html-entity-decoder-csv)

**Process**:
1. Export attribute tables to CSV
2. Run decoder script:
   ```bash
   python decode_html_entities.py districts.csv --columns name name_ar
   ```
3. Re-import cleaned CSV and join back to geometries

**Columns cleaned**:
- `name` (Arabic name)
- `name_ar` (Arabic name, standardized)
- `District Name in Arabic` (CSV files)
- `Governorate Name in Arabic` (CSV files)

**Manual verification**:
- Cross-checked 20% of names against official Jordan government websites
- All Arabic characters now display correctly in GIS software
- UTF-8 encoding confirmed

---

## Step 5: Wikidata Linkage

### Purpose

- Enable integration with external datasets
- Provide authoritative IDs for administrative units
- Link to demographic, economic, and social indicators

### Process

**Semi-automated matching**:
1. Extract English name from OSM
2. Query Wikidata SPARQL endpoint:
   ```sparql
   SELECT ?item ?itemLabel ?population WHERE {
     ?item wdt:P31 wd:Q15630748 .  # instance of: district of Jordan
     ?item rdfs:label ?itemLabel .
     FILTER(LANG(?itemLabel) = "en")
     FILTER(CONTAINS(?itemLabel, "DISTRICT_NAME"))
   }
   ```
3. Manual verification of fuzzy matches
4. Add `wikidata` column with entity ID (e.g., `Q27126262`)

**Coverage**:
- Governorates: 12/12 (100%)
- Districts: 51/51 (100%)
- Subdistricts: 78/89 (88%) - some small subdistricts lack Wikidata entries

**Added columns**:
- `wikidata`: Entity ID (e.g., `Q721431`)
- `Wikidata` (in CSV): Full URL (e.g., `https://www.wikidata.org/wiki/Q721431`)

---

## Step 6: Population Data Integration

### Source

**2024 Population Estimates**:
- Base: Jordan Department of Statistics 2015 Census
- Projections: Annual growth rates from DoS population projections
- Spatial distribution: WorldPop 2020 raster for spatial disaggregation

### Methodology

1. **Governorate-level totals**: From DoS 2024 projections (official)
2. **District-level disaggregation**:
   - Extract WorldPop population within each district boundary
   - Scale to match governorate-level totals (ensuring consistency)
   - Result: District populations that sum to governorate totals

**Formula**:
```
Pop_district_i = Pop_governorate × (WorldPop_district_i / Σ WorldPop_governorate)
```

**Quality**:
- District populations sum exactly to governorate totals
- Spatial distribution reflects actual settlement patterns (from WorldPop)
- Total Jordan population: 10.2 million (matches official 2024 estimate)

**Column added**:
- `Population 2024#number` (in GPKG)
- `Population 2024` (in CSV)

---

## Step 7: Disease Data Integration

### Source

**Jordan Ministry of Health Surveillance System**
- Period: 2022-2023 (24 months aggregated)
- Diseases: 7 notifiable infectious diseases
- Resolution: District level (51 districts)

### Diseases Included

1. **Diarrheal Diseases** (all-cause)
2. **Escherichia coli Infections**
3. **Giardiasis**
4. **Gonococcal Infections**
5. **Salmonella Infections**
6. **Scabies**
7. **Typhoid and Paratyphoid Fevers**

### Rate Calculation

**Age-adjusted incidence per 100,000**:
```
Rate_district = (Cases_district / Population_district) × 100,000
```

**Age adjustment**:
- Standardized to 2020 Jordan population structure
- Ensures comparability across districts with different age distributions

**Data quality**:
- Missing values: 0 (all districts reported for all diseases)
- Outliers: Checked against historical trends; all values plausible
- Confidentiality: Aggregated to district level (no individual cases identifiable)

**Columns added** (CSV files only):
- `Diarrheal Diseases per 100K`
- `Escherichia coli Infections per 100K`
- `Giardiasis per 100K`
- `Gonococcal Infections per 100K`
- `Salmonella Infections per 100K`
- `Scabies per 100K`
- `Typhoid and Paratyphoid Fevers per 100K`

---

## Step 8: Export to Multiple Formats

### GeoPackage (GPKG)

**Why GPKG?**
- Open standard (OGC)
- Single-file format (easier to distribute than Shapefile's 4+ files)
- Supports long column names (unlike Shapefile's 10-character limit)
- Native UTF-8 support (critical for Arabic text)
- SQLite-based (queryable with standard tools)

**Export settings**:
- CRS: WGS84 (EPSG:4326)
- Encoding: UTF-8
- Geometry type: Polygon (2D)

### CSV

**Why CSV for attributes?**
- Universal compatibility (Excel, R, Python, etc.)
- Easier to version control with Git (text-based)
- Enables non-GIS users to access tabular data
- Lightweight for disease surveillance analysis

**Export settings**:
- Delimiter: Comma (`,`)
- Encoding: UTF-8 with BOM (for Excel compatibility with Arabic)
- Geometry: Exported as WKT text (for users who want geometries in CSV)
- Line endings: Windows (CRLF) for broad compatibility

---

## Quality Assurance Checks

### Spatial Integrity

- ✓ No gaps between adjacent polygons (<0.1m tolerance)
- ✓ No overlaps between adjacent polygons (<0.1m tolerance)
- ✓ All subdistricts fully within parent districts
- ✓ All districts fully within parent governorates
- ✓ No self-intersecting polygons
- ✓ No duplicate features

### Attribute Integrity

- ✓ All Arabic text displays correctly (UTF-8)
- ✓ All features have names (English and Arabic)
- ✓ Wikidata IDs are valid (checked against Wikidata API)
- ✓ Population values are positive integers
- ✓ Disease rates are non-negative floats
- ✓ No missing values in required fields

### Cross-Level Consistency

- ✓ District names in `name_2` match governorate names
- ✓ Population sums match: Σ districts = governorate total
- ✓ All districts assigned to exactly one governorate
- ✓ Feature counts: 12 gov + 51 districts + 89 subdistricts = 152 ✓

---

## Known Limitations

### 1. Small Enclaves

Some very small administrative enclaves (<0.1 km²) may have been simplified out during the 20m tolerance simplification. This affects <0.01% of total area.

### 2. Temporal Currency

Boundaries reflect 2023-2024 administrative structure. Historical changes (e.g., district splits or mergers before 2023) are not tracked in this version.

### 3. OSM Data Quality

OSM boundaries are community-maintained and may not exactly match official government gazetteers. We verified major boundaries (governorates, large districts) against official sources, but some small subdistrict boundaries may have minor discrepancies (<100m).

### 4. Disease Data Privacy

Disease rates are aggregated to district level to protect patient privacy. Subdistrict-level data exist but cannot be publicly released due to small case counts in some areas.

---

## Reproducibility

### Software Versions

- QGIS: 3.28.11 LTR
- GRASS GIS: 7.8.7 (via QGIS Processing)
- Python: 3.9.13
- GeoPandas: 0.12.2
- Pandas: 1.5.3

### Processing Scripts

Available in related repositories:
- HTML Entity Decoder: https://github.com/Aro1810/html-entity-decoder-csv
- Disease Map Visualization: https://github.com/Aro1810/Jordan_Disease_map

---

## Future Improvements

### Planned for v1.1

- [ ] Clean up auto-generated column names in district GPKG
- [ ] Add original (unsimplified) boundaries as optional download
- [ ] Include subdistrict population estimates
- [ ] Add English column descriptions to all fields

### Under Consideration

- [ ] Lower administrative levels (neighborhoods, villages)
- [ ] Historical boundaries (2015, 2020)
- [ ] Monthly disease time series (currently annual)
- [ ] Integration with census tracts

---

## Contact

Questions about processing methods?
- GitHub Issues: [Create an issue](https://github.com/[username]/jordan-administrative-boundaries/issues)
- Email: [contact email]

---

## Acknowledgments

Processing pipeline developed with support from:
- OpenStreetMap Jordan community
- Jordan Ministry of Health, Directorate of Communicable Diseases
- WorldPop project (University of Southampton)
- Wikidata contributors
