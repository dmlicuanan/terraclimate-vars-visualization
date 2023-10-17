# working directory
setwd("D:/Documents/Side projects/terraclimate/")

# packages needed
library(sp)
library(raster)
library(ncdf4)

# terraclimate variables 
vars <- data.frame(name1 = c("aet", "ppt", "soil", "tmax", "tmin"))
vars$name2 <- c("actual evapotranspiration", "precipitation", "soil moisture", "maximum temperature", "minimum temperature")

# variable of interest {1:5}
# for-loop does not work
n <- 5

# list of .nc files to be processed
files <- list.files(pattern = paste0(vars$name1[n],".*nc$"))

# years of files
yrs <- as.numeric(unlist(regmatches(files, gregexpr("[[:digit:]]+", files))))

# empty list to store CV rasters
stat <- list()
# store min and max values
# ext <- data.frame(i = 1:12, min = NA, max = NA)

# compute coefficient of variance across same months
for(i in 1:12) {
  #  read in files 
  ras <- lapply(files, raster, band = i)
  # stack rasters
  stack <- stack(ras)
  # subset stack to just the Philippines
  sub <- crop(stack, y = extent(116,127,4,22))
  
  # calculate coefficient of variation 
  cv <- function(x) { (sd(x, na.rm = TRUE)/mean(x, na.rm = TRUE))}
  # new raster for CV
  stat[[i]] <- calc(sub, fun = cv)
  
  # get minimum and maximum values of stat
  # ext$min[i] <- stat[[i]]@data@min
  # ext$max[i] <- stat[[i]]@data@max
}

# stack layers
s <- stack(stat)
# change layer names 
names(s) <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sept", "Oct", "Nov", "Dec")

# open graphics device
pdf(file = paste0(vars$name1[n], ".pdf"))

# title of plot
title <- paste0("CV of ", vars$name2[n], " (", min(yrs), "-", max(yrs), ")")
# plot layers
spplot(s, col.regions = hcl.colors(99, palette = "Viridis"), main = title)

# turn-off graphics device
dev.off()
