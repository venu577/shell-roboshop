#!/bin/bash

START_TIME=$(date +%s)
# This script installs MongoDB on a Linux system
USERID=$(id -u)
# Check if the script is run with root access
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
#colours R is for error G is for success Y is for installation N is for normal text

LOGS_FOLDER="/var/log/shellscript-logs" 
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
# Extract the script name without the extension
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
# Define the log file path
# Create the logs folder if it doesn't exist 

mkdir -p $LOGS_FOLDER
echo "script started executing at: $(date)" &>>$LOG_FILE

if [ $USERID -ne 0 ]

then
    echo -e "$R error: run with root access $N" | tee -a $LOG_FILE
    exit 1
    else 
    echo -e "$G you are running with root access $N" | tee -a $LOG_FILE
    fi

    VALIDATE(){
        if [ $1 -eq 0 ]
        then 
         echo -e "$2 is $G success $N" | tee -a $LOG_FILE
         else 
         echo -e "$2 is $R not success $N" | tee -a $LOG_FILE
         exit 1
         fi
        }

    dnf module disable redis -y &>>$LOG_FILE
    VALIDATE $? "disabling redis module"

    dnf module enable redis:7 -y &>>$LOG_FILE
    VALIDATE $? "enabling redis version 7 module"

    dnf install redis -y &>>$LOG_FILE
    VALIDATE $? "installing redis"

    sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c/protected-mode no' /etc/redis/redis.conf &>>$LOG_FILE
    VALIDATE $? "updating redis config file"
    #when doing multiple sed commands, use -e option to specify each command
    
    systemctl start redis &>>$LOG_FILE 
    VALIDATE $? "enabling redis service"

    systemctl enable redis &>>$LOG_FILE
    VALIDATE $? "starting redis service"

    systemctl restart redis &>>$LOG_FILE 
    VALIDATE $? "enabling redis service"


    END_TIME=$(date +%s)
    TOTAL_TIME=$(( $END_TIME - $START_TIME ))
    echo -e "script execution completed successfully , $Y time taken : $TOTAL_TIME Sec $N"
        
