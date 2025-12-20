# Changelog

All notable changes to the Jordan Administrative Boundaries dataset will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-12-19

### Added
- Initial release of Jordan administrative boundaries dataset
- Governorate boundaries (12 features) in GeoPackage format
- District boundaries (51 features) in GeoPackage format
- Subdistrict boundaries (89 features) in GeoPackage format
- District attributes CSV with disease surveillance data
- Subdistrict attributes CSV with disease surveillance data
- Bilingual names (Arabic and English) for all administrative units
- Wikidata identifiers for integration with external datasets
- Population estimates (2024) for districts and subdistricts
- Disease incidence rates (per 100K) for 7 infectious diseases
- 20m geometric simplification for performance optimization
- Comprehensive documentation (README, data dictionary, examples)
- Python and R usage examples
- Processing pipeline documentation
- ODbL license compliance with OSM attribution

### Data Quality
- All boundaries spatially aligned across three administrative levels
- No gaps or overlaps between adjacent units
- Manual verification of governorate-district-subdistrict nesting
- Arabic text cleaned using HTML entity decoder
- Cross-validated names against Wikidata

### Known Issues
- Small administrative enclaves (<0.1 km²) may be simplified out due to 20m tolerance
- Some district-level columns have auto-generated names from spatial joins (to be cleaned in v1.1)

## [Unreleased]

### Planned for v1.1.0
- Clean up auto-generated column names in district GPKG
- Add original (unsimplified) boundaries as optional downloads
- Include historical administrative changes (2015-2024)
- Add healthcare facility locations by district
- Include road network data for travel time calculations
- Add English translations for all metadata columns

### Under Consideration
- Subdistrict population estimates (currently only districts have population)
- Monthly disease time series (currently annual rates only)
- Lower administrative levels (neighborhoods, villages) where available
- Integration with census tract boundaries
