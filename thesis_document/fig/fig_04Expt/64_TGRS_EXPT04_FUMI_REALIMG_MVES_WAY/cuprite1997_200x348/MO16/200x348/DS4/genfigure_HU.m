close all
clear
clc

load SNR_40dB/trial0001/HU_results.mat
USGS_LIB_SYNT_12          = USGS_LIB_SYNT_12( usedBand , : ) ;
USGS_LIB_SYNT_12          = bsxfun( @rdivide , USGS_LIB_SYNT_12          , sqrt( sum( USGS_LIB_SYNT_12.^2          ) ) ) ;
ENDMEM_FUMI_CUPRITE_MO16  = bsxfun( @rdivide , ENDMEM_FUMI_CUPRITE_MO16  , sqrt( sum( ENDMEM_FUMI_CUPRITE_MO16.^2  ) ) ) ;
ENDMEM_FISTA_CUPRITE_MO16 = bsxfun( @rdivide , ENDMEM_FISTA_CUPRITE_MO16 , sqrt( sum( ENDMEM_FISTA_CUPRITE_MO16.^2 ) ) ) ;

sim_FUMI = ENDMEM_FUMI_CUPRITE_MO16' * USGS_LIB_SYNT_12 ;
[ maxVal , maxIdx ] = max( sim_FUMI , [] , 2 ) ;
figure , hold on ;
    plot( ENDMEM_FUMI_CUPRITE_MO16(:,1) , 'b' ) ;
    plot( USGS_LIB_SYNT_12(:,12) , 'r' ) ;
hold off ;
figure , hold on ;
    plot( ENDMEM_FUMI_CUPRITE_MO16(:,16) , 'b' ) ;
    plot( USGS_LIB_SYNT_12(:,8) , 'r' ) ;
hold off ;