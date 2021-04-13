#!/bin/bash

# I2C read-write script made by Peter Fabian for Peter Janis
# Full disclaimer: I DON'T DO MICROELECTRONICS.
# Use at your own risk
# Complaints send to: edizontn@gmail.com
# Questions about bash part you can send to: peter.fabian@papaphi.com (response not guaranteed)

#based on following write-edid script:
#
# Created by Dr. Ace Jeangle (support@chalk-elec.com) 
# based on script from Tom Kazimiers (https://github.com/tomka/write-edid)
#
# Writes EDID information over a given I2C-Bus to a monitor.
# The scripts expects root permissions.
#
# You can find out the bus number with ic2detect -l. Address 0x50
# should be available as the EDID data goes there.



#usage:
# rw-i2c -r -b bus [-c chip_address] [-l size] -f filename
# rw-i2c -w -b bus [-c chip_address] -s start_addr [-l size] [-f filename]
# default chip address is 0x50

#exit codes:
# 1: Input file does not exist or can't be found
# 2: Input file can be found but can not be read
# 3: Argument parsing error
# 4: Multiple files specified
# 5: Neither R not W option is applied
# 6: BOTH R and W options are applied
# 7: For read mode: no file to write the dump to was specified
# 8: No Bus was specified

#42: Size parameter is not yet implemented. Sorry. 





OPTIONS=rwb:c:s:l:f:
LONGOPTS=read,write,bus:,chip:,start:,size:,length:,file:,chip_addr:,start_addr:,filename:

# -regarding ! and PIPESTATUS see above
# -temporarily store output to be able to check for errors
# -activate quoting/enhanced mode (e.g. by writing out “--options”)
# -pass arguments only via   -- "$@"   to separate them correctly
! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    # e.g. return value is 1
    #  then getopt has complained about wrong arguments to stdout
    exit 2
fi
# read getopt’s output this way to handle the quoting right:
eval set -- "$PARSED"


r=0 w=0 bus="" chip="0x50" start=0 size=0 file=""
# now enjoy the options in order and nicely split until we see --
while true; do
    case "$1" in
        -r|--read)
            r=1
            shift
            ;;
        -w|--write)
            w=1
            shift
            ;;
        -b|--bus)
            bus="$2"
            shift 2
            ;;
        -c|--chip|--chip_addr)
            chip="$2"
            shift 2
            ;;
		-s|--start|--start_addr)
			start="$2"
			shift 2
			;;
		-l|--length|--size)
			size="$2"
			shift 2
			;;
		-f|--file|--filename)
			file="$2"
			shift 2
			;;
        --)
            shift 2
            break
            ;;
        *)
            echo "Programming error"
            exit 3
            ;;
    esac
done

# handle non-option arguments
if [[ $# -ne 1 ]]
then
    echo "$0: A single input file is required."
    exit 4
fi


#if there is no read and no write
if [[ $r -eq 0 && $w -eq 0 ]]
then
	echo "Read or Write option must be specified"
	exit 5
fi

#if there is both read and write
if [[ $r -eq 1 && $w -eq 1 ]]
then
	echo "Both Read and Write can not be specified. Choose one."
	exit 6
fi

#if there is no bus
if [[ -z $bus  ]]
then
	echo "Bus must be specified."
	exit 8
fi

#if there is a size param set
if [[ $size -ne 0 ]]
then
	echo "You have specified a size of the program to read/write."
	echo "Too bad. This function is not implemented yet."
	echo " "
	echo "Sorry."
	exit 42
fi



#PROGRAM_STRING=write
 
# i2c bus
BUS=$bus

# File name
FILE=$file

#ARGS=$(getopt -o "bh" --longoptions "binary,hexadecimal" -n "$PROGRAM_STRING" -- "$@") || exit
#eval set -- $ARGS

binaryMode=1 #hex mode disabled

reDec='^[0-9]+$'
reHex='^0x[0-9A-F]+$'
#echo $start
if [[ $start =~ $reDec ]] ; then
   echo "Start address is a decimal number, continuing" 
fi
if [[ $start =~ $reHex ]] ; then
	echo "Start address is a hex number, converting "$start" to:"
	start=$((start))
	echo $start "and continuing"
fi




# Make sure we get a file name as command line argument.
# If not, read it from std. 
echo $file
if [[ -z $file ]]; then
  FILE="/dev/stdin"
  #echo "if"
else
  # "else"
  FILE=$file
  # make sure file exists and is readable
  if [ \! -f "$FILE" ]; then
    echo "$FILE : does not exist or can't be reached" >&2
    exit 1
  elif [ \! -r "$FILE" ]; then
    echo "$FILE : can not be read" >&2
    exit 2
  fi
fi

# Set loop separators to end of line and space
IFSBAK=$IFS
export IFS=$' \n\t\r'
# some field
edidLength=128
#count=0
count=$start


#if there is no chip address set default 0x50 else set value from params
if [[ -z $chip  ]]
then
	chipAddress="0x50"
else
	chipAddress=$chip
fi







if [[ $w -eq 1 ]]
then

getOneLine ()
{
   line=$(line) || [ \! -z "$line" ]
}

if [ "$binaryMode" -eq 0 ] ; then
  cat "$FILE"
else
  xxd -p -g 0 -u -c 1 -l 128 "$FILE"
#fi | while getOneLine ; do
fi | while read line ; do
  for chunk in $line
  do
    # if we have reached 128 byte, stop
    if [ "$count" -eq "$edidLength" ]; then
      echo "done" >&2
      break
    fi
    # convert counter to hex numbers of lentgh two, padded with zeros
    h=$(printf "%02x" "$count")
    dataAddress="0x$h"
    dataValue="0x$chunk"
    # give some feedback
    echo "Writing byte $dataValue to bus $BUS, chip-adress $chipAddress, data-adress $dataAddress" >&2
    # write date to bus (with interactive mode disabled)
    echo "simulated writing " $dataValue #i2cset -y "$BUS" "$chipAddress" "$dataAddress" "$dataValue"
    # increment counter
    count=$((count+1))
    # sleep a moment
    sleep 0.1s
  done
done

# restore backup IFS
IFS=$IFSBAK

echo "Writing done, here is the output of i2cdump -y $BUS $chipAddress:" >&2
i2cdump -y "$BUS" "$chipAddress"
exit

fi

if [[ $r -eq 1 ]]
then
	#if there is no file to write to
	if [[ -z $file ]]
	then
		echo "File must be specified for writing"
		exit 7
	fi
	echo "Here is the output of i2cdump -y $BUS $chipAddress"
	i2cdump -y "$BUS" "$chipAddress"
	echo "Now we write it to $file"
	i2cdump -y "$BUS" "$chipAddress" > $FILE
	exit
fi
