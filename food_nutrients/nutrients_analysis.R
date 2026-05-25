# 1. LOAD LIBRARIES
library(tidyverse)
library(data.table)
library(ggplot2)

# 2. LOAD DATA
data <- fread("food.csv")
food_nutrient <- fread("food_nutrient.csv")
nutrient <- fread("nutrient.csv")

# 3. FILTER AND MERGE
needed_ids <- c(1008, 1003, 1004, 1005) # Energy, Protein, Fat, Carbs
filtered <- food_nutrient[nutrient_id %in% needed_ids]

merged <- merge(filtered, data, by = "fdc_id")
merged <- merge(merged, nutrient, by.x = "nutrient_id", by.y = "id")

# 4. CLEAN AND PIVOT
final_data <- merged %>%
  select(description, name, amount) %>%
  group_by(description, name) %>%
  summarise(amount = mean(amount, na.rm = TRUE), .groups = 'drop') %>%
  pivot_wider(names_from = name, values_from = amount) %>%
  na.omit() %>%
  unique()

# 5. PREPARE FOR K-MEANS
# We scale the data so large calorie numbers don't drown out small protein numbers
numeric_cols <- final_data %>%
  select(Energy, Protein, `Total lipid (fat)`, `Carbohydrate, by difference`)

cluster_prep <- scale(numeric_cols) 

# 6. RUN K-MEANS (Using 5 Centers for better "Green/Yellow" separation)
set.seed(123)
clusters <- kmeans(cluster_prep, centers = 5)
final_data$cluster <- as.factor(clusters$cluster)

# 7. CLEAN NAMES FOR SHINY APP SEARCH
# This removes the "fuji, raw, with skin" parts
final_data_shiny <- final_data
final_data_shiny$description <- sub(",.*", "", final_data_shiny$description)

# Simplify column names for the App
final_data_shiny <- final_data_shiny %>%
  rename(
    Fat = `Total lipid (fat)`,
    Carbs = `Carbohydrate, by difference`
  )

# 8. SAVE THE FILE FOR THE APP
write.csv(final_data_shiny, "FINAL_Nutrient_Analysis_Results.csv", row.names = FALSE)

# 9. VISUAL CHECK
ggplot(final_data, aes(x = `Total lipid (fat)`, y = Protein, color = cluster)) +
  geom_point(size = 3, alpha = 0.7) +
  scale_color_brewer(palette = "Set1") +
  labs(title = "Food Clusters (5 Groups)", x = "Fat (g)", y = "Protein (g)") +
  theme_minimal()