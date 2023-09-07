import os
dir = os.getcwd()      ;
dir = dir.split('/',7) ;
dir = dir[-1]          ;
srd = '/lan/dspIceberg/pikachu/Documents/Michael/HYPERSPEC/' + dir + '/' ;
os.system('cp '+srd+'results.m   ./') ;
os.system('cp '+srd+'results.txt ./') ;
os.system('cp '+srd+'TEMP.mat    ./') ;
print srd
