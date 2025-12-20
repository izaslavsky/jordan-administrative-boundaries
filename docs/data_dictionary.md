# Data Dictionary

Complete reference for all columns in the Jordan Administrative Boundaries dataset.

---

## Governorates (`gov_simpl_20m.gpkg`)

| Column Name | Data Type | Description | Example | Source |
|-------------|-----------|-------------|---------|--------|
| `fid` | Integer | Feature ID (primary key, 1-12) | `1` | Auto-generated |
| `geom` | Geometry | Polygon geometry in WGS84 (EPSG:4326) | `POLYGON((...))` | OSM |
| `name` | String(50) | Governorate name (Arabic original) | `البلقاء` | OSM |
| `name_ar` | String(50) | Governorate name (Arabic, standardized) | `البلقاء` | OSM, cleaned |
| `name_en` | String(50) | Governorate name (English) | `Balqa` | OSM |
| `alt_name_e` | String(100) | Alternative English name | `Jerash Governorate` | OSM |
| `official_n` | String(100) | Official name (if different from `name`) | `NULL` | OSM |
| `official_1` | String(100) | Alternative official name | `NULL` | OSM |
| `place` | String(20) | OSM place tag (usually NULL for governorates) | `NULL` | OSM |
| `wikidata` | String(20) | Wikidata entity ID | `Q721431` | Wikidata |
| `InPoly_FID` | Integer | Internal polygon feature ID | `0` | Processing |
| `SimPgnFlag` | Integer | Simplification flag (0=simplified, 1=original) | `0` | Processing |
| `MaxSimpTol` | Float | Maximum simplification tolerance applied | `0.00017986` | Processing |
| `MinSimpTol` | Float | Minimum simplification tolerance applied | `0.00017986` | Processing |

**Notes**:
- `wikidata` can be used to construct URLs: `https://www.wikidata.org/wiki/{wikidata}`
- Simplification tolerance is in map units (decimal degrees for WGS84)
- 20m simplification = ~0.00018 decimal degrees at Jordan's latitude

---

## Districts (`dis_simpl_20m.gpkg`)

| Column Name | Data Type | Description | Example | Source |
|-------------|-----------|-------------|---------|--------|
| `fid` | Integer | Feature ID (primary key, 1-51) | `1` | Auto-generated |
| `geom` | Geometry | Polygon geometry in WGS84 | `POLYGON((...))` | OSM |
| `name` | String(100) | District name (Arabic original) | `لواء ماحص والفحيص` | OSM |
| `name_en` | String(100) | District name (English) | `Mahes and Fuhais District` | OSM |
| `wikidata` | String(20) | Wikidata entity ID | `Q27126262` | Wikidata |
| `name_3` | String(100) | District name (variant 3, Arabic) | Same as `name` | OSM |
| `name_ar_3` | String(100) | District name (Arabic, variant 3) | Same as `name` | OSM |
| `name_en_3` | String(100) | District name (English, variant 3) | Same as `name_en` | OSM |
| `name_id` | String(50) | Name identifier (usually NULL) | `NULL` | OSM |
| `official_n` | String(100) | Official name (if different) | `NULL` | OSM |
| `alt_name` | String(100) | Alternative name | `NULL` | OSM |
| `alt_name_2` | String(100) | Alternative name (variant 2) | `NULL` | OSM |
| `name_2` | String(50) | Parent governorate name (Arabic) | `البلقاء` | OSM |
| `name_ar_2` | String(50) | Parent governorate name (Arabic) | `البلقاء` | OSM |
| `name_en_2` | String(50) | Parent governorate name (English) | `Balqa` | OSM |
| `InPoly_FID` | Integer | Internal polygon feature ID | `1` | Processing |
| `SimPgnFlag` | Integer | Simplification flag | `0` | Processing |
| `MaxSimpTol` | Float | Maximum simplification tolerance | `0.00017986` | Processing |
| `MinSimpTol` | Float | Minimum simplification tolerance | `0.00017986` | Processing |
| `districts_for_suave_with100K_2_no_wkt_District Name in Arabic` | String(100) | District name (Arabic, from joined dataset) | `لواء ماحص والفحيص` | MoH data |
| `districts_for_suave_with100K_2_no_wkt_Governorate Name in Arabic` | String(50) | Governorate name (Arabic, from joined dataset) | `البلقاء` | MoH data |
| `districts_for_suave_with100K_2_no_wkt_wikidata#hiddenmore` | String(20) | Wikidata ID (from joined dataset) | `Q27126262` | Wikidata |
| `districts_for_suave_with100K_2_no_wkt_Wikidata#link` | String(200) | Wikidata URL with label | `https://www.wikidata.org/wiki/...` | Wikidata |
| `districts_for_suave_with100K_2_no_wkt_Population 2024#number` | Integer | 2024 population estimate | `45020` | Census/projection |

**Notes**:
- Columns with prefix `districts_for_suave_with100K_2_no_wkt_` are from a spatial join with district attribute table
- These long column names will be cleaned in a future release (v1.1)
- `name_2`, `name_ar_2`, `name_en_2` refer to the parent governorate
- Population estimates are for 2024, based on latest census data with projections

---

## Districts CSV (`Districts.csv`)

This is a cleaned, analysis-ready version of the district data with disease surveillance information.

| Column Name | Data Type | Description | Example | Source |
|-------------|-----------|-------------|---------|--------|
| `geometry` | String | WKT polygon representation | `POLYGON((36.1...))` | OSM |
| `District Name` | String | District name (English) | `Mahes and Fuhais District` | OSM |
| `Governorate Name` | String | Parent governorate (English) | `Balqa` | OSM |
| `District Name in Arabic` | String | District name (Arabic) | `لواء ماحص والفحيص` | OSM, cleaned |
| `Governorate Name in Arabic` | String | Governorate name (Arabic) | `البلقاء` | OSM, cleaned |
| `wikidata` | String | Wikidata entity ID | `Q27126262` | Wikidata |
| `name` | String | District name (Arabic, original) | `لواء ماحص والفحيص` | OSM |
| `href` | String | External reference URL (if any) | URL or NULL | External |
| `Wikidata` | String | Wikidata URL | `https://www.wikidata.org/wiki/...` | Wikidata |
| `Population 2024` | Integer | 2024 population estimate | `45020` | Census |
| `img` | String | Image URL (if available) | URL or NULL | External |
| `Diarrheal Diseases per 100K` | Float | Annual incidence per 100,000 | `127.5` | MoH surveillance |
| `Escherichia coli Infections per 100K` | Float | Annual incidence per 100,000 | `15.3` | MoH surveillance |
| `Giardiasis per 100K` | Float | Annual incidence per 100,000 | `8.7` | MoH surveillance |
| `Gonococcal Infections per 100K` | Float | Annual incidence per 100,000 | `2.1` | MoH surveillance |
| `Salmonella Infections per 100K` | Float | Annual incidence per 100,000 | `12.4` | MoH surveillance |
| `Scabies per 100K` | Float | Annual incidence per 100,000 | `45.8` | MoH surveillance |
| `Typhoid and Paratyphoid Fevers per 100K` | Float | Annual incidence per 100,000 | `3.2` | MoH surveillance |

**Notes**:
- Disease rates are **age-adjusted** annual incidence per 100,000 population
- Disease data period: 2022-2023 (latest available)
- Rates calculated from Jordan Ministry of Health surveillance system
- Missing values (if any) indicate no cases reported or data unavailable
- `geometry` column is WKT text, not binary geometry (use `gpd.GeoDataFrame.from_wkt()` to convert)

---

## Subdistricts GPKG (`subdis_simpl_20m.gpkg`)

| Column Name | Data Type | Description | Example | Source |
|-------------|-----------|-------------|---------|--------|
| `fid` | Integer | Feature ID (primary key, 1-89) | `1` | Auto-generated |
| `geom` | Geometry | Polygon geometry in WGS84 | `POLYGON((...))` | OSM |
| `name` | String | Subdistrict name (Arabic) | Similar structure to districts | OSM |
| `name_en` | String | Subdistrict name (English) | Similar structure to districts | OSM |
| `wikidata` | String | Wikidata entity ID (where available) | `Q...` | Wikidata |
| *(other columns)* | Various | Similar structure to districts | - | - |

**Note**: Subdistrict GPKG follows same structure as districts GPKG

---

## Subdistricts CSV (`subdistricts_geo20m_clean.csv`)

| Column Name | Data Type | Description | Example | Source |
|-------------|-----------|-------------|---------|--------|
| `geometry` | String | WKT polygon representation | `POLYGON((36.1...))` | OSM |
| *(names and IDs)* | Various | Similar to districts CSV | - | - |
| *(disease rates)* | Float | Annual incidence per 100K (if available) | - | MoH |

**Note**: Subdistrict CSV follows same structure as districts CSV, with 89 rows

---

## Common Abbreviations

- **OSM**: OpenStreetMap
- **MoH**: Jordan Ministry of Health
- **WKT**: Well-Known Text (geometry format)
- **GPKG**: GeoPackage (spatial data format)
- **WGS84**: World Geodetic System 1984 (EPSG:4326)
- **FID**: Feature ID (unique identifier)

---

## Data Types Reference

- **Integer**: Whole numbers (e.g., 1, 51, 45020)
- **Float**: Decimal numbers (e.g., 127.5, 0.00018)
- **String(n)**: Text up to n characters
- **Geometry**: Spatial data (polygons, points, lines)

---

## Missing Data Conventions

- **NULL**: No data available
- **0**: Explicitly zero (e.g., zero disease cases)
- **Empty string**: Field not applicable

---

## Update Frequency

- **Boundaries**: Updated as needed (administrative changes are infrequent in Jordan)
- **Population**: Annually (based on census projections)
- **Disease rates**: Annually (based on MoH surveillance data release schedule)

---

## Quality Flags

Future versions may include quality flags:
- **boundary_quality**: Confidence in boundary location (high/medium/low)
- **name_verified**: Whether name cross-checked with official sources (yes/no)
- **population_source**: Source of population estimate (census/projection/estimate)

---

## Contact

For questions about specific columns or data values, please open an issue on GitHub.
