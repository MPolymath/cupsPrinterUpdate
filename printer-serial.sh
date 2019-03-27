#!/bin/bash

#Using lpinfo verify that cups detects a printer connected via usb
LpInfoPrinter=$(lpinfo -v | awk '{print $2}' | grep usb | awk '{split($0, a, "="); print a[1]}')
#If a printer was found
if [ ! -z "$LpInfoPrinter" ]
then
    #Stores serial number for connected printer
    LpInfoFullString=$(lpinfo -v | awk '{print $2}' | grep usb)
    LpInfoSerial=$(IFS='=' read -r id string <<< $LpInfoFullString; echo $string;)
    if [ ! -z "$LpInfoSerial" ]
    then
        PrinterConfFound=$(cat /etc/cups/printers.conf | awk '{print $2}' | grep $LpInfoPrinter | awk '{split($0, a, "="); print a[1]}')
        #If the same model as connected printer is already installed on cups
        if [ ! -z "$PrinterConfFound" ]
        then
            echo "Printer "$PrinterConfFound" with serial "$LpInfoSerial" is now ready for use"
            Date=`date +%d-%m-%Y`
            #Erases previous /etc/cups/printer.conf backup created by script
            if [ -f /etc/cups/printers.conf.bk* ]; then
              /usr/bin/rm /etc/cups/printers.conf.bk*
            fi
            #Creates a backup of /etc/cups/printer.conf
            /usr/bin/rsync /etc/cups/printers.conf /etc/cups/printers.conf.bk.$Date
            #Replaces serial number in printer.conf file with that of connected printer
            sed -i "s,$LpInfoPrinter.*,$LpInfoPrinter," /etc/cups/printers.conf
            sed -i "s,$LpInfoPrinter,&=$LpInfoSerial," /etc/cups/printers.conf
            #Restarts cups once new settings has been applied
            systemctl restart org.cups.cupsd.service
        else
            echo "USB printer not found in /etc/cups/printers.conf"
            exit 1
        fi
    else
        echo "No SERIAL NUMBER for USB printer detected"
        exit 1
    fi
else
    echo "No USB printer detected"
    exit 1
fi
