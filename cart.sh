#!/bin/bash

START_TIME=$(date +%s)
# This script installs MongoDB on a Linux system

cartID=$(id -u)
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
SCRIPT_DIR=$PWD 

mkdir -p $LOGS_FOLDER
echo "script started executing at: $(date)" &>>$LOG_FILE

if [ $cartID -ne 0 ]

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

    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "disabling nodejs module"

    dnf module enable nodejs:20 -y &>>$LOG_FILE
    VALIDATE $? "enabling nodejs version 20 module"

    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "installing nodejs"


    id roboshop
    if [ $? -ne 0 ]
    then 
        cartadd --system --home /app --shell /sbin/nologin --comment "roboshop system cart" roboshop &>>$LOG_FILE
        VALIDATE $? "creating roboshop cart"
    else
        echo -e "$Y roboshop cart is already created $N" | tee -a $LOG_FILE
    fi
    # Check if roboshop cart exists, if not create it
    # If it exists, skip cart creation

    mkdir -p /app &>>$LOG_FILE
    VALIDATE $? "creating app directory"

    curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$LOG_FILE
    VALIDATE $? "downloading cart zip file"

    rm -rf /app/* &>>$LOG_FILE
    cd /app
    unzip /tmp/cart.zip &>>$LOG_FILE
    VALIDATE $? "unzipping cart zip file"

    npm install &>>$LOG_FILE
    VALIDATE $? "installing nodejs dependencies"

    cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service &>>$LOG_FILE
    VALIDATE $? "copying cart service file"

    systemctl daemon-reload &>>$LOG_FILE
    VALIDATE $? "reloading systemd daemon"

    systemctl enable cart &>>$LOG_FILE
    systemctl start cart &>>$LOG_FILE
    VALIDATE $? "enabling and starting cart service"

   

  END_TIME=$(date +%s)
  TOTAL_TIME=$(( $END_TIME - $START_TIME ))
     echo -e "script execution completed successfully , $Y time taken : $TOTAL_TIME Sec $N"
        



