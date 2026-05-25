# ==========================================
# PROJECT: Food Nutrition Analysis & Clustering
# GOAL: Analyze USDA data and group foods by nutrients
# ==========================================

# 1. LOAD LIBRARIES
library(tidyverse)
library(data.table)
library(corrplot)

# 2. LOAD DATA
# Ensure these 3 files are in your working directory
food <- fread("food.csv")
food_nutrient <- fread("food_nutrient.csv")
nutrient <- fread("nutrient.csv")

# 3. DATA CLEANING & MERGING
needed_ids <- c(1008, 1003, 1004, 1005) # Energy, Protein, Fat, Carbs
filtered <- food_nutrient[nutrient_id %in% needed_ids]

merged <- merge(filtered, food, by = "fdc_id")
merged <- merge(merged, nutrient, by.x = "nutrient_id", by.y = "id")

# Create the final wide-format dataset
final_data <- merged %>%
  select(description, name, amount) %>%
  group_by(description, name) %>%
  summarise(amount = mean(amount, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(names_from = name, values_from = amount) %>%
  na.omit() %>%
  unique()

# 4. STEP 3d: CORRELATION ANALYSIS
numeric_cols <- final_data %>% 
  select(Energy, Protein, `Total lipid (fat)`, `Carbohydrate, by difference`)

cor_matrix <- cor(numeric_cols, use = "complete.obs")
corrplot(cor_matrix, method = "color", addCoef.col = "black", type = "upper", 
         title = "Nutrient Correlation Matrix", mar = c(0,0,1,0))

# 5. STEP 4: K-MEANS CLUSTERING (MACHINE LEARNING)
set.seed(123)
cluster_prep <- scale(numeric_cols) # Scale data for K-means
clusters <- kmeans(cluster_prep, centers = 5)
final_data$cluster <- as.factor(clusters$cluster)

# 6. STEP 5: VISUALIZATION & OUTPUT
# Create the Cluster Map
ggplot(final_data, aes(x = `Total lipid (fat)`, y = Protein, color = cluster)) +
  geom_point(size = 3, alpha = 0.7) +
  geom_text(aes(label = description), check_overlap = TRUE, vjust = 1.5, size = 2) +
  labs(title = "Food Clusters Based on Nutrients",
       subtitle = "Grouped by K-means Clustering",
       x = "Total Fat (g)", y = "Protein (g)") +
  theme_minimal()

# Save the final results to a CSV
write.csv(final_data, "FINAL_Nutrient_Analysis_Results.csv", row.names = FALSE)

# Generate and print the executive summary table
cluster_summary <- final_data %>%
  group_by(cluster) %>%
  summarise(
    Avg_Calories = round(mean(Energy), 1),
    Avg_Protein  = round(mean(Protein), 1),
    Avg_Fat      = round(mean(`Total lipid (fat)`), 1),
    Food_Count   = n()
  )

print("--- FINAL PROJECT SUMMARY ---")
print(cluster_summary)
