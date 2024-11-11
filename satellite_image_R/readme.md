This script processes satellite imagery data to calculate the deforestation rate in the Amazon biome using a set of raster files and shapefiles. The analysis involves various steps, including subsetting raster data, identifying legacy forest areas, calculating forest cover, and analyzing deforestation rates.

## Description

This script is divided into five main parts:
1. **Subsetting TIF files**: The script crops the raster files to the region of interest in the Amazon biome.
2. **Identifying Legacy Forest**: The code identifies areas of legacy forest in the raster data based on pre-defined color codes.
3. **Calculating Legacy Forest Area**: The actual area of legacy forest is calculated in hectares.
4. **Deforestation Rate Calculation**: The script identifies human-covered areas and calculates the deforestation rate.
5. **Visualization**: The code generates two graphs comparing the legacy forest in the initial year and deforested areas in 1987.
