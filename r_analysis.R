#Load required libraries
library(dplyr)

#Check if the dataset zip is downloaded, if not then download
if(!file.exists("MyData.zip")){
  fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileUrl, "MyData.zip")
}

##Check if the zip file is extracted, if not extract it
if(!file.exists("./UCI HAR Dataset")){
  unzip("MyData.zip")
  message("MyData.zip successfully unziped")
}

activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt",
                             col.names = c("activityID", "Activity"))
features <- read.table("UCI HAR Dataset/features.txt", 
                       col.names = c("index", "features"))
#Read the training data
x_train <- read.table("UCI HAR Dataset/train/X_train.txt")
#The column names are the features
colnames(x_train) <- features$features
y_train <- read.table("UCI HAR Dataset/train/y_train.txt",
                      col.names = "Activity")
sub_train <- read.table("UCI HAR Dataset/train/subject_train.txt",
                        col.names = "Subject")
#Combine the training data
train_data <- cbind(y_train, sub_train, x_train)

#We don't need these anymore so we delete them
rm("x_train")
rm("y_train")
rm("sub_train")

#Read the test data
x_test <- read.table("UCI HAR Dataset/test/X_test.txt")
colnames(x_test) <- features$features
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", 
                     col.names = "Activity")
sub_test <- read.table("UCI HAR Dataset/test/subject_test.txt",
                       col.names = "Subject")
#Combine the test data
test_data <- cbind(y_test, sub_test, x_test)

#Remove the redundant variables
rm("x_test")
rm("y_test")
rm("sub_test")

##1. Merges the training and the test sets to create one data set.
mergeDataSet <- rbind(test_data, train_data)

#Remove redundant variables
rm("test_data")
rm("train_data")
##2. Extracts only the measurements on the mean and 
##  standard deviation for each measurement.

reqCols <- grep("Activity|Subject|mean\\(\\)|std\\(\\)", colnames(mergeDataSet))
cleanDataSet <- mergeDataSet[, reqCols]
rm("mergeDataSet")
##3. Uses descriptive activity names to name the activities in the data set
cleanDataSet$Activity <- factor(cleanDataSet$Activity,
                                levels = activityLabels$activityID,
                                labels = activityLabels$Activity)
##4. Appropriately labels the data set with descriptive variable names.
colnames(cleanDataSet) <- gsub("^t", "Time", colnames(cleanDataSet))
colnames(cleanDataSet) <- gsub("^f", "Frequency", colnames(cleanDataSet))
colnames(cleanDataSet) <- gsub("mean", "Mean", colnames(cleanDataSet))
colnames(cleanDataSet) <- gsub("std", "Std", colnames(cleanDataSet))
colnames(cleanDataSet) <- gsub("Mag", "Magnitude", colnames(cleanDataSet))
colnames(cleanDataSet) <- gsub("[-()]", "", colnames(cleanDataSet))

##5. From the data set in step 4, creates a second, independent tidy data 
##  set with the average of each variable for each activity 
##  and each subject.
tidyData <- cleanDataSet %>%
  group_by(Activity, Subject) %>%
  summarise_all(mean)

rm("activityLabels")
rm("features")
rm("reqCols")

##Write the tidy data to a text file
write.table(tidyData, "./tidyData.txt", row.names = FALSE)
message("The tidyData is written to tidyData.txt in the directory")