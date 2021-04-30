# rw-i2c
I2C read-write script

Used for read/write data via the I2C bus, and write/read from/to binary file.

# Before
Need to install I2tool package: `sudo apt install i2c-tool`

Next, use the `sudo i2cdetect -l` for list of all I2C buses in your PC

# Usage

Read from I2C device and write to the file:

 `rw-i2c -r -b bus [-c chip_address] -s start_addr [-l size] -f filename`

Write to I2C device from the file:

 `rw-i2c -w -b bus [-c chip_address] -s start_addr [-l size] [-f filename]`
 
 default chip address is 0x50

# Exit codes:
 1: Input file does not exist or can't be found
 
 2: Input file can be found but can not be read
 
 3: Argument parsing error
 
 4: Multiple files specified
 
 5: Neither R not W option is applied
 
 6: BOTH R and W options are applied
 
 7: For read mode: no file to write the dump to was specified
 
 8: No Bus was specified
 
42: Size parameter is not yet implemented. Sorry. 

