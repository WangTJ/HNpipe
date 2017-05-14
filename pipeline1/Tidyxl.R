args = commandArgs(trailingOnly=TRUE)
filename=args[1]
library(readxl)
#Mouse Info
#=================================================================================
## read in sheet Measurement upper left right cell is B-E 29
rawtable1 <- read_excel(path = filename, sheet = "Measurements",
                        col_names = FALSE,
                        range = cell_limits(c(29,2),c(NA,5)))
## tidy the Mouse info
n = dim(rawtable1)[1] / 2
rawtable1 <- data.frame(cbind(rawtable1[rep(seq(1,n*2,2),each=2),1:3],rawtable1[,4]))
colnames(rawtable1) <- c("Mouse", "Cage", "Treatment", "Side")
#=================================================================================

#Date Info
#=================================================================================
rawtable2 <- read_excel(path = filename, sheet = "Measurements",
                        col_names = FALSE, col_types = "date",
                        range = cell_limits(c(26,5),c(26,NA)))
p = dim(rawtable2)[2] / 2
date = rawtable2[,seq(2,2*p,2)]
#=================================================================================

#Measurement Info
#=================================================================================
## read in sheet Measurement upper left cell is F29
rawtable3 <- read_excel(path = filename, sheet = "Measurements",
                       col_names = FALSE, col_types = "numeric",
                       range = cell_limits(c(29,6),c(NA,29+2*p-1)))

## clean the measurement data (all is real number, convert NA to 0)
rawtable3 <- data.frame(rawtable3)
rawtable3[rawtable3==0] <- NA
#=================================================================================

#Puzzle
#=================================================================================
axis1raw <- data.frame(rawtable3[,((1:p)*2-1)])
axis2raw <- data.frame(rawtable3[,(1:p)*2])

shortraw <- pmin(axis1raw,axis2raw)
colnames(shortraw) <- format(date, format = "%m/%d/%y")
shortmature <- cbind(rawtable1 , shortraw)

longraw <- pmax(axis1raw,axis2raw)
colnames(longraw) <- format(date, format = "%m/%d/%y")
longmature <- cbind(rawtable1 , longraw)
rm(date); rm(rawtable1); rm(rawtable2); rm(rawtable3); rm(shortraw); rm(longraw);rm(axis1raw, axis2raw)
#=================================================================================


#add more PDX-wise info
#=================================================================================
library(tidyr)
library(dplyr)
mature <- left_join(gather(longmature, Date, long.axis, -Mouse, -Cage, -Treatment, -Side) ,
     gather(shortmature, Date, short.axis, -Mouse, -Cage, -Treatment, -Side) )
rawinfo <-  read_excel(path = filename, sheet = "Measurements",
                       col_names = FALSE,
                       range = "B2:B3")
PDX <- as.character(rawinfo[1,])
Passage <- as.numeric(rawinfo[2,])
rawinfo <-  read_excel(path = filename, sheet = "Measurements",
                       col_names = FALSE, col_types = "date",
                       range = "B4")
Engraftment.Date <- as.character(format(rawinfo[1,], format = "%m/%d/%y"))
rawinfo <-  read_excel(path = filename, sheet = "Measurements",
                       col_names = FALSE, col_types = "date",
                       range = "B11")
Trt.start <-as.character(format(rawinfo[1,], format = "%m/%d/%y"))
mature <- data.frame(mature, PDX, Passage, Engraftment.Date, Trt.start)
rm(PDX, Passage, Engraftment.Date, Trt.start,rawinfo,longmature,shortmature)
#=================================================================================

#weight info
#=================================================================================
rawcol4 <- read_excel(path = filename, sheet = "Weights",
                      col_names = FALSE,
                      range = cell_rows(4)  )
tmpcol <- c(as.character(rawcol4[,1:2]), as.character(format(rawcol4[,-(1:2)], format = "%m/%d/%y")))
rawtable4 <- read_excel(path = filename, sheet = "Weights",
                        col_names = FALSE,
                        range = cell_rows(5:(4+n) )  )
rawtable4 <- data.frame(rawtable4)
colnames(rawtable4) <- tmpcol
mature <- left_join(mature, gather(rawtable4 , Date, Weight, -Mouse, -Cage) )
rm(rawcol4,rawtable4,tmpcol)
#=================================================================================

#clean(remove record without measurement)
#=================================================================================
mature <- filter(mature, !((is.na(long.axis))&(is.na(short.axis))&(is.na(Weight))))
#=================================================================================

#Calculated field
#=================================================================================
mature <- mutate(mature,
       Volume = (pi/6)*(long.axis)*short.axis^2,
       Days.post.engraftment = as.Date(Date, format ="%m/%d/%y") -
         as.Date(Engraftment.Date, format ="%m/%d/%y"),
       Days.post.trt = as.Date(mature$Date, format ="%m/%d/%y") -
         as.Date(Trt.start, format ="%m/%d/%y")
)
#=================================================================================

#Finishing
#=================================================================================
mature$Cage <- as.factor(mature$Cage);
mature$Treatment <- as.factor(mature$Treatment);
mature$Side <- as.factor(mature$Side);
mature$Date <- as.Date(mature$Date, format ="%m/%d/%y")
mature$PDX <- as.character(mature$PDX)
mature$Passage <- as.factor(mature$Passage)
mature$Engraftment.Date <- as.Date(mature$Engraftment.Date, format ="%m/%d/%y")
mature$Trt.start <- as.Date(mature$Trt.start, format ="%m/%d/%y")
mature$Days.post.engraftment <- as.numeric(mature$Days.post.engraftment)
mature$Days.post.trt <- as.numeric(mature$Days.post.trt)

FormatData <- mature[c("Mouse", "PDX", "Cage", "Passage", "Engraftment.Date", "Trt.start", "Side", "Treatment",
                  "Days.post.engraftment", "Days.post.trt", "long.axis", "short.axis", "Volume", "Weight")]
rm(mature)
#=================================================================================

write.csv(FormatData, file = paste(strsplit(filename,split="[.]")[[1]][1], ".csv", sep=""), row.names = FALSE)
str(FormatData)
