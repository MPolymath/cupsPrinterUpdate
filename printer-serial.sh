#Steps for script#
#!/bin/bash
# Step 1 check if device is connected
# Step 2 check printer.conf for line
# If line exists replace it with apropriate info

#Test#
# Try the script on 2 different epson

#Useful commands#
#See if printer is connected or not
#Get string until = or / if no = via lpinfo ( missing from below command )
#From lpinfo -v

# ----                  THIS HAS BEEN CHECKED                ----#
#Get Printer make find way to make array if multiple printers connected and loop that
LpInfoPrinter=$(lpinfo -v | awk '{print $2}' | grep usb | awk '{split($0, a, "="); print a[1]}')
if [ ! -z "$LpInfoPrinter" ]
then
    echo $LpInfoPrinter
    LpInfoSerial=$(lpinfo -v | awk '{print $2}' | grep usb | awk '{split($0, a, "="); print a[2]}')
    if [ ! -z "$LpInfoSerial" ]
    then
        echo $LpInfoSerial
        PrinterConfFound=$(cat /etc/cups/printers.conf | awk '{print $2}' | grep $LpInfoPrinter | awk '{split($0, a, "="); print a[1]}')
        if [ ! -z "$PrinterConfFound" ]
        then
            echo $PrinterConfFound
            Date=`date +%d-%m-%Y`
            /usr/bin/rm /etc/cups/printers.conf.bk*
            /usr/bin/rsync /etc/cups/printers.conf /etc/cups/printers.conf.bk.$Date
            sed -i 's/$LpInfoPrinter.*/$LpInfoPrinter/' /etc/cups/printers.conf
            sed -i "s/$LpInfoPrinter/&=$LpInfoSerial/" /etc/cups/printers.conf
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

# ----                  THIS HAS BEEN CHECKED                ----#

# ----                           TO DO                       ----#
# 1. Compare serials of info output, and printer.conf before replacing with sed
# 2. Verify online that there arent printer.conf printer variations that do not work with this script
# 3. See how to restart service once that is done
# 4. Comment script
# 5. Test script on live machine
# 6. Push on git with other scripts you worked on
# ----                                                       ----#

#if $LpInfoPrinter!=null
#    LpInfoSerial=$(lpinfo -v | awk '{print $2}' | grep usb | awk '{split($0, a, "="); print a[2]}')
#    PrinterConfFound=$(cat /etc/cups/printers.conf | awk '{print $2}' | grep usb | awk '{split($0, a, "="); print a[1]}')
#    if PrinterConfFound!=null && LpInfoPrinter==PrinterConfFound
#	create .bk of printer.conf
#	sed -i 's/$LpInfoPrinter.*/$LpInfoPrinter/' /etc/cups/printers.conf
#	sed -i 's/$LpInfoPrinter$/$LpInfoPrinter$LpInfoSerial/'

#Make sure that
#Reboot service

#From printer.conf


#If equal then
#Remove end of line ex: sed 's/\.com.*/.com/' file.txt converts google.com/funny to google.com
#Concactenate string with sed '/:[0-9]*$/ ! s/$/:80/' ips.txt > new-ips.txt 0-9 becomes Get printer make :80 becomes get serial
#Replace string with other string in printer.conf
