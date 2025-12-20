# Jordan Administrative Boundaries - R Usage Examples
#
# Demonstrates how to load, visualize, and analyze Jordan administrative boundaries
# using sf, ggplot2, and dplyr packages.
#
# Requirements:
#   install.packages(c("sf", "ggplot2", "dplyr", "readr"))

library(sf)
library(ggplot2)
library(dplyr)
library(readr)

# Set up paths (adjust to your local directory)
DATA_DIR <- "../data"
GPKG_DIR <- file.path(DATA_DIR, "gpkg")
CSV_DIR <- file.path(DATA_DIR, "csv")

# ==============================================================================
# Example 1: Load and display governorate boundaries
# ==============================================================================

cat("================================================================================\n")
cat("Example 1: Load Governorate Boundaries\n")
cat("================================================================================\n\n")

governorates <- st_read(file.path(GPKG_DIR, "gov_simpl_20m.gpkg"), quiet = TRUE)
cat(sprintf("Loaded %d governorates\n", nrow(governorates)))
cat(sprintf("CRS: %s\n\n", st_crs(governorates)$input))

# Display first few rows
cat("First 3 governorates:\n")
print(governorates %>% select(name_en, name_ar, wikidata) %>% head(3))

# Plot governorates
png("governorates_map_R.png", width = 10, height = 10, units = "in", res = 150)
plot(st_geometry(governorates), main = "Jordan Governorates",
     col = "lightblue", border = "black", lwd = 1.5)
# Add labels at centroids
centroids <- st_centroid(governorates)
text(st_coordinates(centroids), labels = governorates$name_en, cex = 0.7)
dev.off()
cat("Saved map to: governorates_map_R.png\n")

# ==============================================================================
# Example 2: Load and visualize districts
# ==============================================================================

cat("\n================================================================================\n")
cat("Example 2: District Visualization with ggplot2\n")
cat("================================================================================\n\n")

districts <- st_read(file.path(GPKG_DIR, "dis_simpl_20m.gpkg"), quiet = TRUE)
cat(sprintf("Loaded %d districts\n", nrow(districts)))

# Create a simple map with ggplot2
p <- ggplot(districts) +
  geom_sf(aes(fill = name_en_2), color = "black", size = 0.3) +
  labs(title = "Jordan Districts by Governorate",
       fill = "Governorate") +
  theme_minimal() +
  theme(legend.position = "bottom",
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        panel.grid = element_blank())

ggsave("districts_by_governorate.png", p, width = 10, height = 12, dpi = 150)
cat("Saved map to: districts_by_governorate.png\n")

# ==============================================================================
# Example 3: Load CSV data and merge with spatial boundaries
# ==============================================================================

cat("\n================================================================================\n")
cat("Example 3: Merge Disease Data with Boundaries\n")
cat("================================================================================\n\n")

# Load district CSV with disease data
districts_csv <- read_csv(file.path(CSV_DIR, "Districts.csv"),
                          show_col_types = FALSE)
cat(sprintf("Loaded CSV with %d rows\n", nrow(districts_csv)))

# Merge spatial data with CSV data using wikidata as key
# First prepare the join key from districts
districts <- districts %>%
  mutate(wikidata_join = ifelse(
    "districts_for_suave_with100K_2_no_wkt_wikidata#hiddenmore" %in% names(.),
    .data[[`districts_for_suave_with100K_2_no_wkt_wikidata#hiddenmore`]],
    wikidata
  ))

# Join
districts_merged <- districts %>%
  left_join(
    districts_csv %>% select(wikidata, `Diarrheal Diseases per 100K`),
    by = c("wikidata_join" = "wikidata")
  )

# Plot disease rates
p_disease <- ggplot(districts_merged) +
  geom_sf(aes(fill = `Diarrheal Diseases per 100K`),
          color = "black", size = 0.3) +
  scale_fill_gradient(low = "yellow", high = "red",
                      name = "Incidence\nper 100K",
                      na.value = "grey80") +
  labs(title = "Diarrheal Disease Incidence by District",
       subtitle = "Age-adjusted annual incidence per 100,000 population") +
  theme_minimal() +
  theme(axis.text = element_blank(),
        axis.ticks = element_blank(),
        panel.grid = element_blank())

ggsave("diarrheal_disease_map_R.png", p_disease, width = 10, height = 12, dpi = 150)
cat("Saved disease map to: diarrheal_disease_map_R.png\n")

# Print summary statistics
cat("\nDiarrheal Disease Statistics:\n")
cat(sprintf("  Mean: %.1f per 100K\n",
            mean(districts_csv$`Diarrheal Diseases per 100K`, na.rm = TRUE)))
cat(sprintf("  Median: %.1f per 100K\n",
            median(districts_csv$`Diarrheal Diseases per 100K`, na.rm = TRUE)))
cat(sprintf("  Min: %.1f per 100K\n",
            min(districts_csv$`Diarrheal Diseases per 100K`, na.rm = TRUE)))
cat(sprintf("  Max: %.1f per 100K\n",
            max(districts_csv$`Diarrheal Diseases per 100K`, na.rm = TRUE)))

# ==============================================================================
# Example 4: Spatial operations - Calculate area and buffer
# ==============================================================================

cat("\n================================================================================\n")
cat("Example 4: Spatial Operations\n")
cat("================================================================================\n\n")

# Project to UTM Zone 36N for accurate area calculation
districts_utm <- st_transform(districts, crs = 32636)

# Calculate area in km²
districts_utm <- districts_utm %>%
  mutate(area_km2 = as.numeric(st_area(.)) / 1e6)

cat(sprintf("Total area of Jordan: %.0f km²\n", sum(districts_utm$area_km2)))
cat(sprintf("Mean district area: %.0f km²\n", mean(districts_utm$area_km2)))
cat(sprintf("Largest district: %.0f km²\n", max(districts_utm$area_km2)))
cat(sprintf("Smallest district: %.0f km²\n", min(districts_utm$area_km2)))

# Create 10km buffer around first district (for demonstration)
district_buffer <- st_buffer(districts_utm[1, ], dist = 10000)  # 10km in meters

# Plot original district and buffer
png("district_buffer_example.png", width = 8, height = 8, units = "in", res = 150)
plot(st_geometry(district_buffer), col = "lightblue", border = "blue",
     main = "10km Buffer Around Sample District")
plot(st_geometry(districts_utm[1, ]), col = "darkblue", border = "black", add = TRUE)
legend("topright", legend = c("Original District", "10km Buffer"),
       fill = c("darkblue", "lightblue"))
dev.off()
cat("\nSaved buffer example to: district_buffer_example.png\n")

# ==============================================================================
# Example 5: Spatial joins
# ==============================================================================

cat("\n================================================================================\n")
cat("Example 5: Spatial Join - Districts to Governorates\n")
cat("================================================================================\n\n")

# Join districts to governorates (find which governorate each district is in)
districts_with_gov <- st_join(
  districts %>% select(name_en, geometry),
  governorates %>% select(gov_name = name_en, geometry),
  join = st_within
)

# Count districts per governorate
districts_per_gov <- districts_with_gov %>%
  st_drop_geometry() %>%
  count(gov_name, name = "n_districts") %>%
  arrange(desc(n_districts))

cat("Districts per governorate:\n")
print(districts_per_gov)

# ==============================================================================
# Example 6: Export to different formats
# ==============================================================================

cat("\n================================================================================\n")
cat("Example 6: Export to Different Formats\n")
cat("================================================================================\n\n")

# Export to Shapefile
st_write(governorates, "governorates_R.shp", quiet = TRUE, delete_dsn = TRUE)
cat("Exported governorates to: governorates_R.shp\n")

# Export to GeoJSON
st_write(districts, "districts_R.geojson", driver = "GeoJSON", quiet = TRUE, delete_dsn = TRUE)
cat("Exported districts to: districts_R.geojson\n")

# Export to CSV (without geometry)
districts_no_geom <- districts %>%
  st_drop_geometry() %>%
  select(name_en, name_en_2, wikidata)

write_csv(districts_no_geom, "districts_attributes_R.csv")
cat("Exported district attributes to: districts_attributes_R.csv\n")

# ==============================================================================
# Example 7: Filter and subset
# ==============================================================================

cat("\n================================================================================\n")
cat("Example 7: Filter and Subset\n")
cat("================================================================================\n\n")

# Filter districts in Zarqa governorate
zarqa_districts <- districts %>%
  filter(name_en_2 == "Zarqa")

cat(sprintf("Found %d districts in Zarqa Governorate:\n", nrow(zarqa_districts)))
cat(paste("  -", zarqa_districts$name_en, collapse = "\n"), "\n")

# Plot Zarqa districts
p_zarqa <- ggplot(zarqa_districts) +
  geom_sf(aes(fill = name_en), color = "black", size = 0.5) +
  labs(title = "Districts in Zarqa Governorate") +
  theme_minimal() +
  theme(legend.position = "bottom",
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        panel.grid = element_blank())

ggsave("zarqa_districts.png", p_zarqa, width = 8, height = 8, dpi = 150)
cat("\nSaved Zarqa districts map to: zarqa_districts.png\n")

cat("\n================================================================================\n")
cat("All examples completed successfully!\n")
cat("================================================================================\n")
