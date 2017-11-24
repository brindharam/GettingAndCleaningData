####################################################################################################

## Coursera Data Science - Course 3: Getting and Cleaning Data
## Final Project

## One of the most exciting areas in all of data science right now is wearable computing - 
## see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop
## the most advanced algorithms to attract new users. The data linked to from the course website 
## represent data collected from the accelerometers from the Samsung Galaxy S smartphone. 
## A full description is available at the site where the data was obtained:
## http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

##Here are the data for the project:
## https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

## You should create one R script called run_analysis.R that does the following.

## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive variable names.
## 5. From the data set in step 4, creates a second, independent tidy data set with the average 
##    of each variable for each activity and each subject.

###################################################################################################

library(reshape2)
#library(stringr) # useful for string manipulations
#library(plyr)

# Clean up workspace
rm(list=ls())

#get current working directory
currentdir <- getwd();

# variable containing path to data files
datadir <- file.path(currentdir, 'UCI HAR Dataset')

# retrieve all data
features <- read.table(file.path(datadir, 'features.txt'));

# Create a vector containing the columns we want (mean, std deviation)

# tidyFeatures <- grep("*mean*|*std*", features[,2])
tidyFeatures <- grep(".*mean.*|.*std.*", features[,2])
print(tidyFeatures)
# print(tidyFeatures.names) # for testing; error as expected
tidyFeatures.names <- features[tidyFeatures,2]
#print(tidyFeatures.names)
tidyFeatures.names <- gsub('-mean', 'Mean', tidyFeatures.names)
#print(tidyFeatures.names)
tidyFeatures.names <- gsub('-std', 'Std', tidyFeatures.names)
#print(tidyFeatures.names)
tidyFeatures.names <- gsub('[-()]', '', tidyFeatures.names)
#print(tidyFeatures.names)

activityLabels <- read.table(file.path(datadir, 'activity_labels.txt'));
subjectTrain <- read.table(file.path(datadir, 'train', 'subject_train.txt'));

xTrain <- read.table(
        file.path(datadir, 'train', 'x_train.txt')
        )[tidyFeatures]; # retrieve only needed mean & std dev columns

yTrain <- read.table(file.path(datadir, 'train', 'y_train.txt'));

# cCreate the final training set by merging yTrain, subjectTrain, and xTrain
trainingData <- cbind(subjectTrain,yTrain, xTrain);

# Read in the test data
subjectTest <- read.table(file.path(datadir, 'test', 'subject_test.txt'));
xTest <- read.table(
        file.path(datadir, 'test', 'x_test.txt')
        )[tidyFeatures]; # retrieve only needed mean & std dev columns

yTest <- read.table(file.path(datadir, 'test', 'y_test.txt'));

# create a data frame comprising of subject, x and y test data sets
testData <- cbind(subjectTest,yTest, xTest);

# Merge training and test data sets
mergedData <- rbind(trainingData,testData);

colnames(mergedData) <- c("Subject", "Activity", tidyFeatures.names)

# turn activities & subjects into factors
mergedData$Activity <- factor(mergedData$Activity, levels = activityLabels[,1], labels = activityLabels[,2])
mergedData$Subject <- as.factor(mergedData$Subject)

mergedData.melted <- melt(mergedData, id = c("Subject", "Activity"))
mergedData.mean <- dcast(mergedData.melted, Subject + Activity ~ variable, mean)

write.table(mergedData.mean, file.path(datadir, 'tidyData.txt'), row.names = FALSE, quote = FALSE)

# restore current directory
# setwd(currentdir)