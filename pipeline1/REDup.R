args = commandArgs(trailingOnly=TRUE)
filename = args[1]

#filename = "combined.csv"

FormatData <- read.csv(filename, header = TRUE)
FormatData$PDX = as.character(FormatData$PDX)
FormatData$Passage = as.character(FormatData$Passage)
FormatData$Cage = as.character(FormatData$Cage)
FormatData$Engraftment.Date = as.character(FormatData$Engraftment.Date)
FormatData$Trt.start = as.character(FormatData$Trt.start)
FormatData$Side = as.character(FormatData$Side)
FormatData$Treatment = as.character(FormatData$Treatment)
FormatData$Date = as.character(FormatData$Date)
FormatData$Weight = as.numeric(FormatData$Weight)


Recordlist = distinct(FormatData,Mouse,PDX,Cage,Passage,Engraftment.Date,Trt.start,Treatment)
Output = NULL

for (i in 1:dim(Recordlist)[1])
{
  Measurementlist = select(filter(FormatData , Mouse == Recordlist[i,1]),
                           Side,Date,Days.post.engraftment, Days.post.trt,
                           long.axis,short.axis,Volume,Weight)
  Measurementlist$Side <- ifelse(Measurementlist$Side=="Lt",1,2)
  p = dim(Measurementlist)[1]
  df = matrix(ncol = 19, nrow = p+1)
  df <- data.frame(df)
  df[,1] <- Recordlist[i,1]
  df[2:(p+1),2] <- "measurement"
  df[2:(p+1),3] <- 1:p
  df[1,4:9] <- Recordlist[i,2:7]
  df[1,10] <- 2
  df[2:(p+1),11:18] <- Measurementlist
  df[2:(p+1),19] <- 2
  Output <- rbind(Output, df)
}

colnames(Output) <- c("record_id", "redcap_repeat_instrument", 
                      "redcap_repeat_instance" ,"pdx",	"cage",	"passage",
                      "engraftment_date",	"treatment_start_date",
                      "treatment",	"infomation_complete",
                      "side", "measurement_date",
                      "days_post_engraftment",	"days_post_treatment",	
                      "long_axis",	"short_axis",	"volume",	"weight",	"measurement_complete")


write.csv(Output , paste("REDcap",filename,sep="") , na="", row.names = FALSE)
  
  
  