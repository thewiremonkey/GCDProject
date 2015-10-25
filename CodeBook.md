---
title: "CodeBook.md"
author: "thewiremonkey"
date: "October 22, 2015"
output: html_document
---

# Getting the Data
The data for this project can be found at

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

About the Data
===============

##From the readme.txt file in the above zip file:


The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain. See 'features_info.txt' for more details. 

###For each record it is provided:

- Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.
- Triaxial Angular velocity from the gyroscope. 
- A 561-feature vector with time and frequency domain variables. 
- Its activity label. 
- An identifier of the subject who carried out the experiment.

###The dataset includes the following files:

- 'README.txt'

- 'features_info.txt': Shows information about the variables used on the feature vector.

- 'features.txt': List of all features.

- 'activity_labels.txt': Links the class labels with their activity name.

- 'train/X_train.txt': Training set.

- 'train/y_train.txt': Training labels.

- 'test/X_test.txt': Test set.

- 'test/y_test.txt': Test labels.

The following files are available for the train and test data. Their descriptions are equivalent. 

- 'train/subject_train.txt': Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 

- 'train/Inertial Signals/total_acc_x_train.txt': The acceleration signal from the smartphone accelerometer X axis in standard gravity units 'g'. Every row shows a 128 element vector. The same description applies for the 'total_acc_x_train.txt' and 'total_acc_z_train.txt' files for the Y and Z axis. 

- 'train/Inertial Signals/body_acc_x_train.txt': The body acceleration signal obtained by subtracting the gravity from the total acceleration. 

- 'train/Inertial Signals/body_gyro_x_train.txt': The angular velocity vector measured by the gyroscope for each window sample. The units are radians/second. 

##From features_info.txt:


###Feature Selection 

The features selected for this database come from the accelerometer and gyroscope 3-axial raw signals tAcc-XYZ and tGyro-XYZ. These time domain signals (prefix 't' to denote time) were captured at a constant rate of 50 Hz. Then they were filtered using a median filter and a 3rd order low pass Butterworth filter with a corner frequency of 20 Hz to remove noise. Similarly, the acceleration signal was then separated into body and gravity acceleration signals (tBodyAcc-XYZ and tGravityAcc-XYZ) using another low pass Butterworth filter with a corner frequency of 0.3 Hz. 

Subsequently, the body linear acceleration and angular velocity were derived in time to obtain Jerk signals (tBodyAccJerk-XYZ and tBodyGyroJerk-XYZ). Also the magnitude of these three-dimensional signals were calculated using the Euclidean norm (tBodyAccMag, tGravityAccMag, tBodyAccJerkMag, tBodyGyroMag, tBodyGyroJerkMag). 

Finally a Fast Fourier Transform (FFT) was applied to some of these signals producing fBodyAcc-XYZ, fBodyAccJerk-XYZ, fBodyGyro-XYZ, fBodyAccJerkMag, fBodyGyroMag, fBodyGyroJerkMag. (Note the 'f' to indicate frequency domain signals). 

These signals were used to estimate variables of the feature vector for each pattern:  
'-XYZ' is used to denote 3-axial signals in the X, Y and Z directions.

tBodyAcc-XYZ
tGravityAcc-XYZ
tBodyAccJerk-XYZ
tBodyGyro-XYZ
tBodyGyroJerk-XYZ
tBodyAccMag
tGravityAccMag
tBodyAccJerkMag
tBodyGyroMag
tBodyGyroJerkMag
fBodyAcc-XYZ
fBodyAccJerk-XYZ
fBodyGyro-XYZ
fBodyAccMag
fBodyAccJerkMag
fBodyGyroMag
fBodyGyroJerkMag

The set of variables that were estimated from these signals are: 

mean(): Mean value
std(): Standard deviation
mad(): Median absolute deviation 
max(): Largest value in array
min(): Smallest value in array
sma(): Signal magnitude area
energy(): Energy measure. Sum of the squares divided by the number of values. 
iqr(): Interquartile range 
entropy(): Signal entropy
arCoeff(): Autorregresion coefficients with Burg order equal to 4
correlation(): correlation coefficient between two signals
maxInds(): index of the frequency component with largest magnitude
meanFreq(): Weighted average of the frequency components to obtain a mean frequency
skewness(): skewness of the frequency domain signal 
kurtosis(): kurtosis of the frequency domain signal 
bandsEnergy(): Energy of a frequency interval within the 64 bins of the FFT of each window.
angle(): Angle between to vectors.

Additional vectors obtained by averaging the signals in a signal window sample. These are used on the angle() variable:

gravityMean
tBodyAccMean
tBodyAccJerkMean
tBodyGyroMean
tBodyGyroJerkMean

The complete list of variables of each feature vector is available in 'features.txt'


What **run_analysis.R** Does
-------------

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement. 
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names. 
5. From the data set in step 4, creates a second, independent tidy data set with the average of each 6. variable for each activity and each subject.

load the dplyr package

```{R}
library(dplyr)
```

check to see if the zip file has already been downloaded, if so, skip this step

```{R}
if(!file.exists("raw.zip")){
getD<-download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",destfile = "raw.zip")
}
```


Note that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot.


load the dplyr package

```{R}
library(dplyr)
```

check to see if the file has been unzipped, if so, skip this step

```{r}
if(!file.exists("UCI HAR Dataset")){
rawdata<-unzip("raw.zip")
}
```

read in each table to its own data.frame
start with the files in the root of the data set
assign them to the variables *activity* and *features*

```{r}
activity<-read.table('UCI HAR Dataset/activity_labels.txt')
features<-read.table('UCI HAR Dataset/features.txt')
```

##Read the Files in the Subdirectories

Read the training files and assign them to variables *x_train* and *y_train*:
```{R}
x_train<-read.table('UCI HAR Dataset/train/X_train.txt')
y_train<-read.table('UCI HAR Dataset/train/y_train.txt')
subject_train<-read.table('UCI HAR Dataset/train/subject_train.txt')
```


...and the the test files, assign *x_test*, *y_test* and *subject_test*.
```{R}
x_test<-read.table('UCI HAR Dataset/test/X_test.txt')
y_test<-read.table('UCI HAR Dataset/test/y_test.txt')
subject_test<-read.table('UCI HAR Dataset/test/subject_test.txt')
```

Bind the test and train data frames rows--Item 1 (Question 1)

```{R}
subject<-rbind(subject_train, subject_test)
y<-rbind(y_train, y_test)
```

**x becomes d as it contains the collected data**
```{R}
d<-rbind(x_train, X_test)
```

Pull out the second column of the features data set which contains the actual feature descriptions

```{R}
features<-select(features, V2)
```

Rename the value column in each data frame to ham (human and machine) readable with the items in the subject vector
.
```{R}
names(subject)<-"subject"
```

Apply the name from the list of activities to its matching number in the y dataset

```{R}
y[, 1] <- activity[y[, 1], 2]
names(y)<-"activity"
```

Uses grep to find all the columns that have mean() and std() in the column name and save into variable *feat*

```{R}
feat<-as.vector(features[grep("-(mean|std)\\(\\)", features$V2),])
```

Use match to find the index of the items that match

```{R}
colNums<-match(features$V2,feat)
```

Tidy up the name data set labels to all lower case, removing any non-alpha-numerics.
**NOTE** The naming convention I used is based on the discussion in the course forum.  The names are still quite long, but by being in all lower case and without non-alpha numeric characters, make it 
less likely that someone would type in the incorrect name due to case error.

```{R}
names(d)<-as.vector(tolower(features$V2))
names(d)<-gsub(pattern = "\\(|\\)|\\-","",names(d))
```

*Part of Item 1, building the final data set*

Use the column numbers extracted above to choose data set columns by index number. Make sure to remove any that do not match

```{R}
d<-d[,!is.na(colNums)]
```

Finally, bind all the data frames together into the data frame *d*:
-y representing activity
-subject is subject
-d is data

```{R}
d<-cbind(y, subject, d)
```

##Use chaining to create the tidy data set for item 5
1. start by grouping the data first by activity, then by subject with the group_by() function
2. Find the mean of each group with the summarise_each() function

```{R}
mean_data<-d%>%
        group_by(activity, subject) %>%
                summarise_each(funs(mean), c(3:68))
```
##output the table

```{R}
write.table(mean_data, "mean_data.txt", row.name=FALSE, sep = " ")
```
