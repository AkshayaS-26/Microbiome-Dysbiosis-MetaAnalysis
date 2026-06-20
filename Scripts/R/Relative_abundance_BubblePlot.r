install.packages("readxl")
install.packages("tidyverse")
install.packages("ggrepel")

library(readxl)
library(tidyverse)
library(ggrepel)


data <- read_excel("bubble_plot-input.xlsx") #input file contain Taxa and respective relative abundance value for both healthy and diseased samples

# Reshape to long format
data_long <- pivot_longer(data, cols = c(Diseased, Healthy),
                          names_to = "Group", values_to = "Abundance")
data_long$Taxa <- gsub(".*s__", "", data_long$Taxa)  # Remove long prefixes
data_long$Taxa <- gsub("g__", "", data_long$Taxa)    # Clean "g__"

ggplot(data_long, aes(x = Abundance, y = reorder(Taxa, Abundance))) +
  geom_point(aes(size = Abundance, color = Group), alpha = 0.7) +
  scale_color_manual(values = c("Healthy" = "#1f78b4", "Diseased" = "#e31a1c")) +
  scale_size(range = c(3, 12)) +
  theme_minimal(base_size = 14) +
  labs(
    title = "Comparison of Taxa Abundance in Healthy vs Diseased",
    x = "Relative Abundance",
    y = "Taxa",
    size = "Abundance",
    color = "Group"
  )

ggsave("bubble_plot_by_group.png", width = 12, height = 8, dpi = 300)
