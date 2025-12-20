# Metadata Directory

This directory is reserved for technical metadata files about the Jordan Administrative Boundaries dataset.

## Planned Metadata Files

### coordinate_reference_system.md
- **CRS**: WGS84 (EPSG:4326)
- **Proj4 string**: +proj=longlat +datum=WGS84 +no_defs
- **Authority**: EPSG
- **Units**: Decimal degrees
- **Recommended projection for area calculations**: UTM Zone 36N (EPSG:32636)

### source_information.md
- OpenStreetMap extraction details
- Overpass API queries used
- OSM changeset IDs
- Extraction timestamp
- Data quality notes from OSM

### lineage.md
- Data provenance tracking
- Processing steps with timestamps
- Software versions used
- Quality control checkpoints
- Validation results

## Current Status

This directory is currently **empty** and reserved for future metadata additions.

Users who need technical metadata should refer to:
- **CRS information**: See README.md (Quick Start section)
- **Processing details**: See `docs/processing_notes.md`
- **Column information**: See `docs/data_dictionary.md`

## Contributing Metadata

If you have suggestions for metadata files that would be useful, please:
1. Open an issue on GitHub describing the metadata need
2. Provide an example of the information that should be included
3. Reference any standards (ISO 19115, Dublin Core, etc.) that should be followed
