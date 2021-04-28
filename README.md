# rw-i2c
I2C read-write script

Used for read/write data via the I2C bus with writing/reading from/to binary file.

## Dependencies
- I2C Tools for Linux `sudo apt install i2c-tools`

## Usage
- List all I2C buses in yur PC
  - `sudo i2cdetect -l`
  
## Examples
- Read data from I2C device via bus `i2c-1` on address `0xA0` and write them to file `out.bin`
  - `rw-i2c -r -b 1 -c 0xA0 -f out.bin`
- Write data to I2C device via bus `i2c-2` on address `0x60` from file `in.bin`
  - `rw-i2c -w -b 2 -f in.bin`
- Write data to I2C device via bus `i2c-2` and device start address `10` from `stdin`
  - `rw-i2c -w -b 2 -s 10`

> The default chip address is 0x50.  
> The default start address is 0.

## Exit codes
1: Argument parsing error  
2: Neither `r` not `w` option was specified  
3: I2c communication bus missing  
4: Start address format error  
5: Input file handling error

