rng('shuffle') ;
delete *.asv
delete m~

com.mathworks.mlservices.MLCommandHistoryServices.removeAll
close all
clear
clc

modelOrder  = dlmread( 'CONFIG.MODELORDER' ) ;
trialNum    = dlmread( 'CONFIG.TRIALNUM'   ) ;
dsRatio     = dlmread( 'CONFIG.DSRATIO'    ) ;
SNR_dB      = dlmread( 'CONFIG.SNR'        ) ;

for k = 1 : trialNum
    trialFolderName = sprintf( 'trial%04d' , k ) ;
    if( ~exist(trialFolderName,'dir') ) ; mkdir( trialFolderName ) ; end ;
        cd( trialFolderName ) ;
        cd ;
        if( ~exist( 'finish.txt' , 'file' ) )
            if( ~exist( 'someOneIsHere.txt' , 'file' ) )
                unix( 'cp ../HIS_*.m  ./' ) ;
                unix( 'cp ../DSP_*.m  ./' ) ;
                unix( 'cp ../FUNC_*.m ./' ) ;
            end
        else
            fprintf( 'finished !\n' ) ;
        end
    cd ..
end
