#load the dplyr package
library(dplyr)

#check to see if the zip file has already been downloaded, if so, skip this step
if(!file.exists("raw.zip")){
getD<-download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",destfile = "raw.zip")
}

#check to see if the file has been unzipped, if so, skip this step
if(!file.exists("UCI HAR Dataset")){
rawdata<-unzip("raw.zip")
}

#read in each table to its own data.frame
#start with the files in the root of the data set

activity<-read.table('UCI HAR Dataset/activity_labels.txt')
features<-read.table('UCI HAR Dataset/features.txt')

#read files in subdirectories
#train
x_train<-read.table('UCI HAR Dataset/train/X_train.txt')
y_train<-read.table('UCI HAR Dataset/train/y_train.txt')
subject_train<-read.table('UCI HAR Dataset/train/subject_train.txt')

#test
X_test<-read.table('UCI HAR Dataset/test/X_test.txt')
y_test<-read.table('UCI HAR Dataset/test/y_test.txt')
subject_test<-read.table('UCI HAR Dataset/test/subject_test.txt')

#bind the test and train data frames rows--Item 1 (Question 1)

subject<-rbind(subject_train, subject_test)
y<-rbind(y_train, y_test)

#x becomes d as it contains the collected data
d<-rbind(x_train, X_test)

#pull out the second column of the features data set
features<-select(features, V2)

#rename the value column in each data frame to ham readable
names(subject)<-"subject"


#apply the name from the list of activities to its matching number in the y dataset --Item 4 (Question 4)
y[, 1] <- activity[y[, 1], 2]
names(y)<-"activity"

#uses grep to find all the columns that have mean() and std() in the column name --Item 2 (Question 2)
feat<-as.vector(features[grep("-(mean|std)\\(\\)", features$V2),])

#use match to find the index of the items that match
colNums<-match(features$V2,feat)

#tidy up the name data set labels to all lower case, removing any non-alpha-numerics --Item 3 (Question 3)
names(d)<-as.vector(tolower(features$V2))
names(d)<-gsub(pattern = "\\(|\\)|\\-","",names(d))

#part of Item 1, building the final data set (Question 1)
#use the column numbers extracted above to choose data set columns by index number
d<-d[,!is.na(colNums)]

#bind together the activity, subject and the data collected from the devices
d<-cbind(y, subject, d)

#use chaining to create the tidy data set for item 5
mean_data<-d%>%
        #start by grouping the data first by activity, then by subject
        group_by(activity, subject) %>%
        #use the summarise_each function in dplyr to find the mean for each grouped item
        summarise_each(funs(mean), c(3:68))

#output the table
write.table(mean_data, "mean_data.txt", row.name=FALSE, sep = " ")
