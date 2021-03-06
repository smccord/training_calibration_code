##---- Preface ----
#Title: AIM Core Method Training Calibration Analysis 2020
#Author: Catherine Dillon, Data Analyst, NMSU
#Contact: Catherine Dillon
#CELL: (917)922-0516 
#EMAIL: cdillon@nmsu.edu
#Rough Copy as of 5/8/2020

#---- I. Setting File Paths, Loading Data, Loading Packages ----
#loading all required packages
library(dplyr)
library(tidyr)
library(utils)
library(grDevices)
library(cowplot)
library(data.table)
library(DescTools)
library(grDevices)
library(ggplot2)
library(magrittr)
library(tibble)
library(stringr)

#Read in the LPI, Height, Canopy Gap, and Spp. Richness data (from the tempate.csv)
#input path (to the CSV file data sheet, including the .csv name and file extension)
input_path <- "C:/training_2020/crew_calibration_results_presentation/reno_2020/calibration_data_2020-06-07.csv"

#output folder (this is the folder where the figures will be stored as images)
output_path <- "C:/training_2020/crew_calibration_results_presentation/reno_2020"

#read in the data from the input path created in the previous step
#blank values will be assigned NA values for missing data entries
#when inputting data, you should be placing NA values anyway
data <- read.csv(input_path,
                 header = T, na.strings=c("","NA"))

#---- II. Load Packages and Functions ----
#load the function that will be used for analysis and visualization 
#Now you can highlight the rest of the script and then press control, enter
#everything will be done for you :)
method_success <- function(method_report){
  method_results <- data.frame("ind_pass_freq" = apply(method_report,
                                                        2, function (x) sum (x == "PASS")))
  method_results[["method_status"]] <- ifelse(method_results[,"ind_pass_freq"] == nrow(method_report),
                                              "METHOD SUCCESS","METHOD FAIL")  
  return(method_results)
}

#to display indicator success within a method
#the function outputs need to be labelled, in the title with the method
gap_title <- "Canopy Gap Calibration"
lpi_title <- "Line Point Intercept Calibration"
spp_title <- "Species Calibration"
hgt_title <- "Vegetation Height Calibration"

indicator_success_ct <- function(method_report, method_title){
  require(grDevices)
  require(ggplot2)
  test <- method_report
  test[test == "PASS"] <- as.numeric(1)
  test[test == "FAIL"] <- as.numeric(0)
  test <- data.frame(apply(test,2,function(x) as.numeric(x)))
  test$success_ct <- rowSums(test)
  test[["indicator"]] <- row.names(method_report)
  #automating the title for the output
  title <- paste(method_title, "Indicator Success Count",
                 sep = " ")
  #making the output
  figure <- ggplot2::ggplot(data = test, aes(x = indicator,
                                             y = success_ct))+
    geom_bar(stat = "identity")+
    geom_text(aes(label = test$success_ct), size = 6,
              position=position_dodge(width=0.9), vjust=-0.25)+
    xlab("Indicator") + ylab("Number of Crews")+ 
    theme(legend.background = element_rect(colour = 'black',
                                           fill = 'white', size = 1, linetype='solid'))+
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          axis.line = element_line(colour = "black"),
          axis.text.y = element_blank(),axis.ticks = element_blank()) +
    labs(title = title)
  
  png(paste0(output_path,
             "/",
             method_title,
             ".png", sep = ""), width = 1200)
  print(figure)
  dev.off()
  return(figure)
}
#species inv. gets its own function, because it's special
spp_indicator_success_ct <- function(spp_report, spp_title){
  require(grDevices)
  require(ggplot2)
  require(magrittr)
  require(dplyr)
  test <- spp_report
  test[test == "PASS"] <- as.numeric(1)
  test[test == "FAIL"] <- as.numeric(0)
  test <- data.frame(apply(test,2,function(x) as.numeric(x)))
  test[["ind_success_ct"]] <- rowSums(test)
  test[["indicator"]] <- "Absolute Difference of Number of Species Recorded Less than or Equal to 2 Records"
  test <- test[,c(2:3)]
  test[["crew_success_count"]] <- sum(as.vector(test[,"ind_success_ct"]))
  title <- paste(spp_title, "Indicator Success Count",
                 sep = " ")
  #making the output
  figure <- ggplot2::ggplot(data = test %>% dplyr::distinct()%>%
                              subset(ind_success_ct > 0), aes(x = indicator,
                                                              y = ind_success_ct))+
    geom_bar(stat = "identity")+
    geom_text(data = test %>% dplyr::distinct()%>%
                subset(ind_success_ct > 0),
              aes(label = crew_success_count),
              vjust = -0.25, size = 6)+
    xlab("Indicator") + ylab("Number of Crews")+ 
    theme(legend.background = element_rect(colour = 'black',
                                           fill = 'white', size = 1, linetype='solid'))+
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          axis.line = element_line(colour = "black"),
          axis.text.y = element_blank(),axis.ticks = element_blank()) +
    labs(title = title)
  #writes to designated folder
  png(paste0(output_path,
             "/species_ind_success",
             ".png", sep = ""))
  print(figure)
  dev.off()
  return(figure)

}
#class results
class_results <- function(method_results, method_title){
  require(DescTools)
  method_results <- DescTools::Freq(method_results[,"method_status"])
  class_results <- ggplot(data = method_results, aes( x = level, y = freq, fill = level)) + 
    geom_bar(stat = "identity", color = NA,
             show.legend = FALSE)+
    geom_text(aes(label = method_results$freq), size = 6,
              position=position_dodge(width=0.9), vjust=-0.25)+
    scale_fill_manual(values = c("gray64", "gray29" ))+
    xlab("Method Calibration Status") + ylab("Number of Crews")+ 
    theme(legend.background = element_rect(colour = 'black',
                                           fill = 'white', size = 1, linetype='solid'))+
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          axis.text.y = element_blank(),axis.ticks = element_blank(),
          axis.line = element_line(colour = "black")) +
    labs(title = paste(method_title,
                       "Method Status of Entire Class", sep = ": "))
 #writing the output
png(paste0(output_path,
           "/",
           method_title,
             " 2",
             ".png", sep = ""))
  print(class_results)
  dev.off()
  return(class_results)
}


##---- III. Subsetting the data ----
#subsetting data sheet, all lpi relevant variables
lpi_data <- data[,c(1:8)]

#finding the absolute difference across indicators per crew
lpi_indicator_status <- lpi_data %>%
  tidyr::gather(., indicator, value, pct_foliar:pct_rock, na.rm = TRUE) %>%
  dplyr::group_by(., crew, indicator) %>%
  dplyr::summarise("abs_diff" = max(value) - min(value))

#Determining if the indicator was passed or failed according to 10 2 2 rule
lpi_indicator_status[["indicator_status"]] <- ifelse(lpi_indicator_status[,"abs_diff"] > 10,
                                                         "FAIL", "PASS")

#Can share this with crews or display on slide to see where they failed
#This assumes set up is correct in the field, which is a big assumtion

lpi_report <- data.frame(lpi_indicator_status) %>%
  select(., crew, indicator,indicator_status) %>%
  spread(., crew, indicator_status)%>%
  column_to_rownames(., "indicator")

#subsetting height data in the same style as previously demonstrated
hgt_data <- data[,c(1,2,13:20)]

hgt_indicator_status <- hgt_data %>%
  gather(., indicator, value, woody_0_50_ct:herb_50_ct,na.rm = TRUE) %>%
  group_by(., crew, indicator) %>%
  summarise("abs_diff" = max(value) - min(value))

#determining if the indicator was passed or failed according to 10 2 2
hgt_indicator_status[["indicator_status"]] <- ifelse(hgt_indicator_status[,"abs_diff"] > 2,
                                                     "FAIL", "PASS")

#Another indicator per crew report for a potential output
hgt_report <- hgt_indicator_status %>%
  select(., crew, indicator,indicator_status) %>%
  spread(., crew, indicator_status)%>%
  column_to_rownames(., "indicator")

#subsetting for gap data
gap_data <- data[,c(1,2,9:12)]

#finding the absolute difference across indicators per crew
gap_indicator_status <- gap_data %>%
  gather(., indicator, value, gaps_25_50_pct:gaps_201_pct, na.rm = TRUE) %>%
  group_by(., crew, indicator) %>%
  summarise("abs_diff" = max(value) - min(value))

#determining if the indicator was passed or failed according to 10 2 2
gap_indicator_status[["indicator_status"]] <- ifelse(gap_indicator_status[,"abs_diff"] > 10,
                                                     "FAIL", "PASS")

gap_report <- gap_indicator_status %>%
  select(., crew, indicator,indicator_status) %>%
  spread(., crew, indicator_status)%>%
  column_to_rownames(., "indicator")

#species inventory data
spp_data <- data[,c(1,2,21)]

spp_indicator_status <- spp_data %>%
  gather(., indicator, value, spp_ct, na.rm = TRUE) %>%
  group_by(., crew, indicator) %>%
  summarise("abs_diff" = max(value) - min(value))

spp_indicator_status[["indicator_status"]] <- ifelse(spp_indicator_status[,"abs_diff"] > 2,
                                                     "FAIL", "PASS")

spp_report <- spp_indicator_status %>%
  select(., crew, indicator,indicator_status) %>%
  spread(., crew, indicator_status)%>%
  column_to_rownames(., "indicator")

#---- IV. Analysis ----
#finding total method success per crew per class
gap_results <- method_success(gap_report)
hgt_results <- method_success(hgt_report)
spp_results <- method_success(spp_report)
lpi_results <- method_success(lpi_report)

#---- V. Visualizing the data w/ F(x) ----
#Making a graph for indicator success per method
#saving figures as objects
#these objects can be loaded into the console 
#just by typing their names and pressing enter
#so that you may copy and paste them into the slideshow


#indicator success in a method
row.names(lpi_report) <- str_replace_all(row.names(lpi_report),
                                         "pct_",
                                         "%")
row.names(gap_report) <- str_replace_all(row.names(gap_report),
                                                  c("pct" = "cm (% Cover of Transect)",
                                                    "gaps" = "Gap Size",
                                                    "_" = " "))

row.names(hgt_report) <-  str_replace_all(row.names(hgt_report),
                                                   c("herb" = "Herb.",
                                                     "woody" = "Woody",
                                                     "ct" = "cm Record Count",
                                                     "_" = " "))
row.names(spp_report) <- str_replace(row.names(spp_report),
                                              "spp_ct",
                                              "Number of Spp. Recorded")

lpi_ind_success_fig <- indicator_success_ct(lpi_report, lpi_title)
gap_ind_success_fig <- indicator_success_ct(gap_report, gap_title)
spp_ind_success_fig <- spp_indicator_success_ct(spp_report, spp_title)
hgt_ind_success_fig <- indicator_success_ct(hgt_report, hgt_title)
print(hgt_ind_success_fig)
#method status across the class

class_results(lpi_results,lpi_title)
class_results(gap_results,gap_title)
class_results(spp_results,spp_title)
class_results(hgt_results,hgt_title)


##---- VI. More Figures to map Absolute Value per Method----
#These figs. have to be done outside of the function
#First, let's make the indicator strings understandable
gap_indicator_status$indicator <- str_replace_all(gap_indicator_status$indicator,
                                                  c("pct" = "cm (% Cover of Transect)",
                                                    "gaps" = "Gap Size",
                                                    "_" = " "))


hgt_indicator_status$indicator <-  str_replace_all(hgt_indicator_status$indicator,
                                                   c("herb" = "Herb.",
                                                    "woody" = "Woody",
                                                    "ct" = "cm Record Count",
                                                                  "_" = " "))

spp_indicator_status$indicator <- str_replace(spp_indicator_status$indicator,
                                              "spp_ct",
                                              "Number of Spp. Recorded")

lpi_indicator_status$indicator <- str_replace_all(lpi_indicator_status$indicator,
                                                  "pct_",
                                                  "%")
#Now let's make the figures :)
lpi_abs_diff_fig <- ggplot(data = lpi_indicator_status, aes( x = indicator,
                                         y = abs_diff))+
  geom_rect(aes(xmin = -Inf, xmax = Inf, ymin = 10, ymax = Inf),
            fill = "gray88", alpha = 0.03) +
  geom_rect(aes(xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = 10),
            fill = "gray100", alpha = 0.03,
            color = NA)  +
  geom_point(aes(shape = factor(lpi_indicator_status$indicator_status)),
              position = position_jitterdodge(jitter.width = 0.5, dodge.width = 0.2),
              size = 8, show.legend = FALSE) + 
  scale_shape_manual(values = c(4,1))+
 
  theme(legend.background = element_rect(colour = 'black',
                                         fill = 'white', size = 1, linetype='solid'))+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.line = element_line(colour = "black"))+
  geom_hline(yintercept = 10,size = 1.25,
             linetype = "longdash",
             color = "black") +
xlab("Indicator") + ylab("Indicator Absolute Difference per Crew")+
  labs(title = "LPI Indicator Absolute Difference Values by Crew")

png(paste0(output_path,
           "/",
           "lpi_abs_diff_fig",
           ".png", sep = ""), 
    width = 900)
print(lpi_abs_diff_fig)
dev.off()


gap_abs_diff_fig <- ggplot(data = gap_indicator_status, aes( x = indicator,
                                                             y = abs_diff))+
  geom_rect(aes(xmin = -Inf, xmax = Inf, ymin = 10, ymax = Inf),
            fill = "gray88", alpha = 0.05) +
  geom_rect(aes(xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = 10),
            fill = "gray100", alpha = 0.05,
            color = NA)  +
  geom_point(aes(shape = factor(gap_indicator_status$indicator_status)),
              position = position_jitterdodge(jitter.width = 0.5, dodge.width = 0.2),
              size = 8, show.legend = FALSE) + 
  scale_shape_manual(values = c(4,1))+
  
  theme(legend.background = element_rect(colour = 'black',
                                         fill = 'white', size = 1, linetype='solid'))+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.line = element_line(colour = "black"))+
  geom_hline(yintercept = 10,
             size = 1.25,
             linetype = "longdash",
             color = "black") +
  xlab("Indicator") + ylab("Indicator Absolute Difference per Crew")+
  labs(title = "Gap Indicator Absolute Difference Values by Crew")

png(paste0(output_path,
           "/",
           "gap_abs_diff_fig",
           ".png", sep = ""), 
    width = 900)
print(gap_abs_diff_fig)
dev.off()


spp_abs_diff_fig <- ggplot(data = spp_indicator_status, aes( x = indicator,
                                                             y = abs_diff)) +
  geom_rect(aes(xmin = -Inf, xmax = Inf, ymin = 2, ymax = Inf),
            fill = "gray88", alpha = 0.2) +
  geom_rect(aes(xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = 2),
            fill = "gray100", alpha = 0.2,
            color = NA)  +
  geom_point(aes(shape = factor(spp_indicator_status$indicator_status)),
              position = position_jitterdodge(jitter.width = 0.5, dodge.width = 0.2),
              size = 8, show.legend = FALSE) + 
  scale_shape_manual(values = c(4,1))+
  scale_color_manual(values = c("#000000"))+
  theme(legend.background = element_rect(colour = 'black',
                                         fill = 'white', size = 1, linetype='solid'))+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.line = element_line(colour = "black"))+
  geom_hline(yintercept = 2, 
             size = 1.25,
             linetype = "longdash",
             color = "black") +
  xlab("Indicator") + ylab("Indicator Absolute Difference per Crew")+
  labs(title = "Species Count Absolute Difference Values by Crew")

png(paste0(output_path,
           "/",
           "spp_abs_diff_fig",
           ".png", sep = ""), width = 480)
print(spp_abs_diff_fig)

dev.off()

hgt_abs_diff_fig <- ggplot(data = hgt_indicator_status, aes( x = indicator,
                                                             y = abs_diff))+
  geom_rect(aes(xmin = -Inf, xmax = Inf, ymin = 2, ymax = Inf),
            fill = "gray88", alpha = 0.03) +
  geom_rect(aes(xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = 2),
            fill = "gray100", alpha = 0.03,
            color = NA)  +
  geom_point(aes(shape = factor(hgt_indicator_status$indicator_status)),
              position = position_jitterdodge(jitter.width = 0.5, dodge.width = 0.5),
              size = 6,
              show.legend = FALSE) + 
  #geom_text(aes(label=hgt_indicator_status$crew),hjust=0, vjust= 10)+
  scale_shape_manual(values = c(4,1))+
  theme(legend.background = element_rect(colour = 'black',
                                         fill = 'white', size = 1, linetype='solid'))+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.line = element_line(colour = "black"))+
  geom_hline(yintercept = 2,
             size = 1.25,
             linetype = "longdash",
             color = "black") +
  xlab("Indicator") + ylab("Indicator Absolute Difference per Crew")+
  labs(title = "Vegetation Height Count Absolute Difference Values by Crew",
       shape = "Indicator Status per Crew") 

png(paste0(output_path,
           "/",
           "hgt_abs_diff_fig",
           ".png", sep = ""),
    width = 1300)
print(hgt_abs_diff_fig)
paste(hgt_abs_diff_fig)
dev.off()

#Final CSV for each crew's success record: 
report_qual <- rbind(spp_report,gap_report,lpi_report,hgt_report)
report_quant <- rbind(lpi_indicator_status,gap_indicator_status,
                      hgt_indicator_status, spp_indicator_status)
#For calibration success across all methods
final_calibration_status <- as.data.frame((apply(report_qual,2,table)))
final_calibration_status["Final Status",]<- ifelse(final_calibration_status[1,] > 1,
                                                   "Failed Calibration","Passes Calibration")
write.csv(final_calibration_status,paste0(output_path,
                                          "/","calibration_status.csv"))
write.csv(report_qual, paste0(output_path,
                              "/", "qualitative_report.csv"))
write.csv(report_quant, paste0(output_path,
                               "/", "quantitative_report.csv"))
#---- END OF SCRIPT ----
#Check for outputs in your designated output folder
#You designated where that is in Step I of this script...
#There are 3 Figures per Method
#2 larger spreadsheet with all indicator scores
#One more brief spreadsheet with pass per method
#Happy Training!









