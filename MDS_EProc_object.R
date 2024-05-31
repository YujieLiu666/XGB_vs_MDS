# This script is for gap-filling US-Bar data for IQR filtering, 
# ustar filtering, gapfilling using MDS, and night-time partitioning

project_dir <- "E:/13 Gapfill/"
data_dir <- project_dir
output_dir = project_dir

library(amerifluxr)
library(pander)
library(REddyProc)
library(lubridate)
library(tidyverse)

set.seed(2000)
setwd(data_dir)
file <- "US-Bar_for_gapfilling.txt"
base_df <- read.table(paste0(data_dir, file), header = T)
head(base_df)
base_df[base_df == -9999] <- NA
base_df <- base_df[base_df$Year > 2009, ]

# intialize EProc
{
  EddyData <- filterLongRuns(base_df, "NEE")
  EddyData$Year <- as.numeric(EddyData$Year)
  EddyData$Hour <- as.numeric(EddyData$Hour)
  EddyData$DoY <- as.numeric(EddyData$DoY)
  EddyDataWithPosix <- fConvertTimeToPosix(EddyData, 'YDH',
                                           Year = 'Year', Day = 'DoY', Hour  = 'Hour') 
  EProc <- sEddyProc$new('US-Bar', EddyDataWithPosix, c('NEE','Rg','Tair','VPD', 'Ustar'))
}

# IQR filtering - twice
{
  EProc$sMDSGapFill('NEE')
  
  residual<- EProc$sTEMP$NEE_orig - EProc$sTEMP$NEE_fall
  IQR <- IQR(residual,na.rm=TRUE)
  outlier=ifelse(abs(residual)>(IQR*6),1,0)
  
  EddieC<-  data.frame(EProc$sTEMP$sDateTime,EProc$sTEMP$NEE_orig,
                       EProc$sDATA$Ustar,EProc$sTEMP$NEE_fall,residual,outlier)
  colnames(EddieC)=c('sDateTime','NEE_orig','Ustar','NEE_fall','residual','outlier')
  EddieC$NEE_filt<- dplyr::if_else(EddieC$outlier > 0, NA_real_, EddieC$NEE_orig)
  EddieC$year=substr(EddieC[,1],1,4)
  EddieC$doy=strftime(EddieC[,1], format = "%j")
  
  # Re-run IQR filtering
  EddieC$residual2 = EddieC$NEE_filt - EddieC$NEE_fall
  EddieC$IQR2=IQR(EddieC$residual2, na.rm=TRUE)
  EddieC$outlier2 = ifelse(abs(EddieC$residual2) > EddieC$IQR2*6,1,0)
  EddieC$NEE_filt2 = ifelse(EddieC$outlier2==0,EddieC$NEE_filt,NA)
  
  # remove outliers
  EProc$sDATA$NEE <-  EddieC$NEE_filt2
}

# estimate u* distribution
{
  uStarThAgg<- EProc$sEstUstarThresholdDistribution(nSample = 1000L, probs = c(0.05, 0.5, 0.95)) 
}
   
# gapfilling  
{
  EProc$sGetUstarScenarios() # get current scenario, by default, singer value
  EProc$useAnnualUStarThresholds() # use annual thresholds
  EProc$sMDSGapFillUStarScens("NEE", FillAll = TRUE) # marginal distribution sampling
  print(EProc$sGetUstarScenarios()) # inspect the changed thresholds to be used
}
  
# partitioning
{
  EProc$sSetLocationInfo(LatDeg = 44.0646, LongDeg = -71.2881, TimeZoneHour = -5)
  EProc$sMDSGapFill('Tair', FillAll = FALSE,  minNWarnRunLength = NA)     
  EProc$sMDSGapFill('Rg', FillAll = FALSE,  minNWarnRunLength = NA) 
  EProc$sMDSGapFill('VPD', FillAll = FALSE,  minNWarnRunLength = NA) 
  EProc$sFillVPDFromDew() # fill longer gaps still present in VPD_f
  EProc$sMRFluxPartitionUStarScens() # night-time approach (Reichstein 2005)
  output_file <- paste0(output_dir, 'EProc_2010_2022.RDS')
  saveRDS(EProc, file = output_file)
}
  
  