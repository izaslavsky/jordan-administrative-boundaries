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
# Example 3: Analyze district attributes
# ==============================================================================

cat("\n================================================================================\n")
cat("Example 3: Analyze District Attributes\n")
cat("================================================================================\n\n")

# Count districts per governorate
districts_summary <- districts %>%
  st_drop_geometry() %>%
  group_by(name_en_2) %>%
  summarise(n_districts = n()) %>%
  arrange(desc(n_districts))

cat("Number of districts per governorate:\n")
print(districts_summary)

# Create a bar plot
p_bar <- ggplot(districts_summary, aes(x = reorder(name_en_2, n_districts), y = n_districts)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(title = "Number of Districts per Governorate",
       x = "Governorate",
       y = "Number of Districts") +
  theme_minimal() +
  theme(axis.text.y = element_text(size = 10))

ggsave("districts_per_governorate_bar.png", p_bar, width = 8, height = 6, dpi = 150)
cat("\nSaved bar chart to: districts_per_governorate_bar.png\n")

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
