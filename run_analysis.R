# 0 Preparation steps
##The script requires packages "dplyr" and "tidyr"
##Download the datasets and unzip them into the specified sub-folder in the WD
URL<- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
temp <- tempfile()
download.file(URL,temp, method = "curl")
unzip (temp,exdir = "./getdata-012")
rm(URL,temp)
##Load the datasets into R and label the columns accordingly
features <- read.table("./getdata-012/UCI HAR Dataset/features.txt")
activity_labels <- read.table("./getdata-012/UCI HAR Dataset/activity_labels.txt",col.names = c("activity_code","activity_name"))
X_train <- read.table("./getdata-012/UCI HAR Dataset/train/X_train.txt",col.names = features[,2])
y_train <- read.table("./getdata-012/UCI HAR Dataset/train/y_train.txt",col.names = "activity_code")
subject_train <- read.table("./getdata-012/UCI HAR Dataset/train/subject_train.txt",col.names = "subject")
X_test <- read.table("./getdata-012/UCI HAR Dataset/test/X_test.txt",col.names = features[,2])
y_test <- read.table("./getdata-012/UCI HAR Dataset/test/y_test.txt",col.names = "activity_code")
subject_test <- read.table("./getdata-012/UCI HAR Dataset/test/subject_test.txt",col.names = "subject")

# 1 Merge the training and the test sets
##Merge the datasets of "train" into a single table
train <- cbind(subject_train,y_train,X_train)
##Merge the datasets of "test" into a single table
test <- cbind(subject_test,y_test,X_test)
##Merge the training and test sets and clear redundant tables
dataset <- rbind(train,test)
rm(train,test,X_test,y_test,X_train,y_train,subject_test,subject_train)

# 2 Extract the measurements on the mean & standard deviation
library(dplyr)
data_selected <- select(dataset,grep("*[Mm]ean*|*std*",features$V2))

# 3 Use descriptive activity names to name the activities in the data set
data_selected <- merge(data_selected,activity_labels,by = "activity_code")
data_selected <- select(data_selected,subject,activity_name,3:86)

# 4 Appropriately label the data set with descriptive variable names
## Already carried out when importing the data sets. The dataframe "data_selected"
## has descriptive column names

# 5 Create a second, independent tidy data set with the average of each variable
# for each activity and each subject.
##Gather the columns of the measurements into a single column
library(tidyr)
data_tidy <- gather(data_selected,measurements,value,3:86)
##Group the tidy data set by measurements, subject, and activity
data_tidy_grouped <- group_by(data_tidy,measurements,activity_name,subject)
##Get the average for the grouped data
average <- summarize(data_tidy_grouped,mean(value))
write.table(average, file = "./getdata-012/getdata-012_course-project.txt", row.name = FALSE)
