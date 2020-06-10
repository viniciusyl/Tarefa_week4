# Download data -----------------------------------------------------------

        # Check if already have data directory and download the data project
        
        if(!file.exists("data")){dir.create("data")}
        fileUrl = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(fileUrl, destfile = "./data/projectfile.zip",
                      method = "curl")
        list.files("./data")
        unzip("./data/projectfile.zip", exdir = getwd())


# Input data --------------------------------------------------------------

        # Reading train data
        train_x = read.csv("./UCI HAR Dataset/train/X_train.txt", header = F, sep = "")
        train_activity = read.csv("./UCI HAR Dataset/train/y_train.txt", header = F, sep = "")
        train_subject = read.csv("./UCI HAR Dataset/train/subject_train.txt", header = F, sep = "")        
        
        # Reading test data
        test_x = read.csv("./UCI HAR Dataset/test/X_test.txt", header = F, sep = "")
        test_activity = read.csv("./UCI HAR Dataset/test/y_test.txt", header = F, sep = "")
        test_subject = read.csv("./UCI HAR Dataset/test/subject_test.txt", header = F, sep = "")        
        
        # Reading features data
        features = read.csv("./UCI HAR Dataset/features.txt", header = F, sep = "")
        features = as.character(features[,2]) 
        
        # Activity labels
        activity = read.csv("./UCI HAR Dataset/activity_labels.txt", header = F, sep = "")

        
# 1.Combine train/test data columns, merge the both data and name columns ----

        # Combine columns
        train_set = as.data.frame(c(train_activity, train_subject, train_x))
        test_set = as.data.frame(c(test_activity, test_subject, test_x))

        # Merge train_set and test_set
        data_set = rbind(train_set, test_set)
        
        # Name columns
        names(data_set) = c(c("activity", "subject"), features)


# 2.Extracting mean and std for each measurement -------------------------

        mean_std = grep("mean|std", features)
        sub_data_set = data_set[,c(1,2,mean_std + 2)]

        
# 3.Name the activities in the data set -----------------------------------

        library(dplyr)
        sub_data_set = left_join(sub_data_set, activity,
                                 by = c("activity" = "V1"))
        sub_data_set = sub_data_set[,c(82,2:81)]
        sub_data_set = rename(sub_data_set, activity = V2)

        
# 4.Labels the data set with descriptive variable names -------------------

        name = names(sub_data_set)
        name = gsub("[(][)]", "", name)
        name = gsub("^t", "TimeDomain_", name)
        name = gsub("^f", "FrequencyDomain_", name)
        name = gsub("Acc", "Accelerometer", name)
        name = gsub("Gyro", "Gyroscope", name)
        name = gsub("Mag", "Magnitude", name)
        name = gsub("-mean-", "_Mean_", name)
        name = gsub("-std-", "_StandardDeviation_", name)
        name = gsub("-", "_", name)
        names(sub_data_set) = name

        
# 5.Tidy data set with the average of each variable, activity and subject ------

        data_set_final = sub_data_set %>%
                group_by(subject, activity) %>%
                summarize_each(funs(mean))
        
        
# 6. Exporting table ------------------------------------------------------

        write.table(x = data_set_final, file = "data_set_final.txt", row.names = FALSE)

        
        
        
        
        
        
        
        
        
        
        
        
        