##################################
#            Yunfeng Wu          #
#       yw4250@columbia.edu      #
#       Columbia University      #
#              Econ              #
#  satellite imagery processing  #
##################################

# This R.script contains codes to calculate the deforest rate of Amazon biome.
# I subset the tif file due to the large amount of data.
# The Part 1 contains the code to only include the pixels in the Amazon biome.
# The Part 2 contains the code to identify the areas of legacy forest.
# The Part 3 calculated the actual area of the legacy forest.
# The Part 4 contains the code to identify the human covered area and to calculate the deforest rate.
# The Part 5 contains the code to generate a graph of the legacy forest and the deforest area.


install.packages("sf")
install.packages("terra")
install.packages("ggplot2")
install.packages("raster")
install.packages("gridExtra")
install.packages("reshape")
install.packages("parallel")
install.packages("rasterVis")
library(sf)
library(ggplot2)
library(terra)
library(raster)
library(gridExtra)
library(reshape2)
library(parallel)
library(rasterVis)
#sample tif file
ext <- ext(-70, -65, -20, -15)
shapefile_path <- "/Users/leslie/Desktop/ra/TM/codingtest/codingtest/data/shapefile/amazon_sensulatissimo_gmm_v1.shp"
amazon_biome <- st_read(shapefile_path)
ggplot(data = amazon_biome) +
  geom_sf() +
  labs(title = "Amazon Biome" , x= "Longitude" , y = "Latitude") +
  theme_minimal()
raster_path <- "/Users/leslie/Desktop/ra/TM/codingtest/codingtest/data/coverage_brazil/brasil_coverage_1985.tif"
raster_data <- rast(raster_path)
sample_raster1985 <- crop(raster_data, ext)
#####unique_values <- unique(sample_raster1985)######
writeRaster(sample_raster1985, "/Users/leslie/Desktop/ra/TM/codingtest/codingtest/data/sample/sample_1985.tif", overwrite = TRUE)
plot(sample_raster1985, main = "Cropped Image from 65°W to 70°W and 15°S to 20°S")

raster_path <- "/Users/leslie/Desktop/ra/TM/codingtest/codingtest/data/coverage_brazil/brasil_coverage_1986.tif"
raster_data <- rast(raster_path)
sample_raster1986 <- crop(raster_data, ext)
writeRaster(sample_raster1986, "/Users/leslie/Desktop/ra/TM/codingtest/codingtest/data/sample/sample_1986.tif", overwrite = TRUE)
plot(sample_raster1986, main = "Cropped Image from 65°W to 70°W and 15°S to 20°S")

raster_path <- "/Users/leslie/Desktop/ra/TM/codingtest/codingtest/data/coverage_brazil/brasil_coverage_1987.tif"
raster_data <- rast(raster_path)
sample_raster1987 <- crop(raster_data, ext)
writeRaster(sample_raster1987, "/Users/leslie/Desktop/ra/TM/codingtest/codingtest/data/sample/sample_1987.tif", overwrite = TRUE)
plot(sample_raster1987, main = "Cropped Image from 65°W to 70°W and 15°S to 20°S")

##Part1
##crop
raster_path <- "/Users/leslie/Desktop/ra/TM/codingtest/codingtest/data/sample/sample_1985.tif"
shapefile_path <- "/Users/leslie/Desktop/ra/TM/codingtest/codingtest/data/shapefile/amazon_sensulatissimo_gmm_v1.shp"
output_path <- "/Users/leslie/Desktop/ra/TM/codingtest/codingtest/result"

shapefile <- st_read(shapefile_path)
  
raster_data <- raster(raster_path)

masked_raster <- mask(raster_data, shapefile) #crop
  
writeRaster(masked_raster, file.path(output_path, "cropped_1985.tif"), format = "GTiff", otherwise = TRUE)

raster_path <- "/Users/leslie/Desktop/ra/TM/codingtest/codingtest/data/sample/sample_1986.tif"
shapefile <- st_read(shapefile_path)

raster_data <- raster(raster_path)

masked_raster <- mask(raster_data, shapefile) #crop

writeRaster(masked_raster, file.path(output_path, "cropped_1986.tif"), format = "GTiff", otherwise = TRUE)
raster_path <- "/Users/leslie/Desktop/ra/TM/codingtest/codingtest/data/sample/sample_1987.tif"
shapefile <- st_read(shapefile_path)

raster_data <- raster(raster_path)

masked_raster <- mask(raster_data, shapefile) #crop

writeRaster(masked_raster, file.path(output_path, "cropped_1987.tif"), format = "GTiff", otherwise = TRUE)

#Part2
forest_color_codes <- c(1, 3, 4, 5, 6, 49, 10, 11, 12, 32, 29, 50, 13)
cropped_1985 <- raster("/Users/leslie/Desktop/ra/TM/codingtest/codingtest/result/cropped_1985.tif")
cropped_1986 <- raster("/Users/leslie/Desktop/ra/TM/codingtest/codingtest/result/cropped_1986.tif")
######unique_values <- unique(cropped_1985[])##
initial_forest_stock1985 <- cropped_1985[] %in% forest_color_codes 
summary(initial_forest_stock1985)
initial_forest_stock1986 <- cropped_1986[] %in% forest_color_codes

output_legacy <- setValues(cropped_1985, as.numeric(initial_forest_stock) * 1) #set forest pixel to 1
writeRaster(output_legacy,"/Users/leslie/Desktop/ra/TM/codingtest/codingtest/result/output_legacy.tif", format = "GTiff", overwrite = TRUE)


#Part3
legacy <- raster("/Users/leslie/Desktop/ra/TM/codingtest/codingtest/result/output_legacy.tif")

forest_pixels <- sum(values(legacy) == 1 )  # the forest pixel is 1
forest_area_hectares <- forest_pixels * 0.09  

#Part4
#Here is the code for 1987
human_cover_code <- c(14, 15, 18, 19, 39, 20, 40, 62, 41, 36, 46, 47, 35, 48, 9, 21, 24, 30)
yeartif_path <- "/Users/leslie/Desktop/ra/TM/codingtest/codingtest/result/cropped_1987.tif"

legacy_code = 1 # the forest pixel is 1
raster_data <- raster(yeartif_path)

deforest <- raster_data[] %in% human_cover_color_codes #a set of deforest
deforest_1987 <- setValues(legacy, as.numeric(deforest) * 2) #set deforest pixel to 2
deforest_1987_pixels <- sum(values(deforest_1987) == 2 ) #calculate the deforested pixels
deforest_rate = forest_pixels/ deforest_1987_pixels

writeRaster(deforst_1987,"/Users/leslie/Desktop/ra/TM/codingtest/codingtest/result", format = "GTiff", overwrite = TRUE)

#Part5
legacy_df <- as.data.frame(rasterToPoints(legacy), xy = TRUE)
latest_df <- as.data.frame(rasterToPoints(deforest_1987), xy = TRUE)

legacy_df$forest <- ifelse(legacy_df$layer == 1, "Legacy Forest", "Other")
latest_df$forest <- ifelse(latest_df$layer == 1, "Legacy Forest",
                           ifelse(latest_df$layer == 2 , "Deforested", "Other"))

legacy_sampled <- legacy_df[sample(nrow(legacy_df), 500000), ]
latest_sampled <- latest_df[sample(nrow(latest_df), 500000), ]
p1 <- ggplot(data = legacy_sampled, aes(x = x, y = y, color = forest)) +
  geom_point(size = 0.1) +  
  scale_color_manual(values = c("Legacy Forest" = "green", "Other" = "gray")) +
  ggtitle("Amazon Biome - Legacy Forest (Initial Stock)") +
  theme_minimal() +
  theme(legend.position = "bottom")

p2 <- ggplot(data = latest_sampled, aes(x = x, y = y, color = forest)) +
  geom_point(size = 0.1) +  
  scale_color_manual(values = c("Legacy Forest" = "green", "Deforested" = "yellow", "Other" = "gray")) +
  ggtitle("Amazon Biome - 1987 Coverage") +
  theme_minimal() +
  theme(legend.position = "bottom")

grid.arrange(p1, p2, ncol = 2)