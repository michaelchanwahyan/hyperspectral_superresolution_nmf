close all
clear
clc
%            FUMI
%                  ExBCD-FISTA
%                        HAGO-FPG
%                              HAGO-FPG&FW
colorArr = { 'k' , 'm' , 'b' , 'r' } ;
mkstyArr = { '^' , 'x' , 'o' , 's' } ;
lnstyArr = { '-' , '-' , '--', '--'} ;
lineWidthVal = 1 ;
intvl_FUMI = 200 ;
intvl_ExBCD= 200 ;
intvl_MF   = 200 ;
cd SNR_40dB
    cd trial0001
        % ------------------- %
        % plot the obj curves %
        % ------------------- %
        load( 'LOG_DRFUMI.mat'                 , 'returnInfo_DRFUMI' ) ; obj = returnInfo_DRFUMI.obj_it ; obj_FUMI            = obj(obj>0) ; l = sum(obj>0) ; t = returnInfo_DRFUMI.time_it ; time_FUMI            = t(1:l) ;
        load( 'LOG_MFbA_ExFISTA.mat'           , 'returnInfo_MF'     ) ; obj = returnInfo_MF.obj_it     ; obj_ExFISTA         = obj(obj>0) ; l = sum(obj>0) ; t = returnInfo_MF.time_it     ; time_ExFISTA         = t(1:l) ;
        load( 'LOG_MFbA_FISTA.mat'             , 'returnInfo_MF'     ) ; obj = returnInfo_MF.obj_it     ; obj_HAGO_FISTA      = obj(obj>0) ; l = sum(obj>0) ; t = returnInfo_MF.time_it     ; time_HAGO_FISTA      = t(1:l) ;
        load( 'LOG_MFbA_HYBRID_SFW_AFISTA.mat' , 'returnInfo_MF'     ) ; obj = returnInfo_MF.obj_it     ; obj_HAGO_SFW_AFISTA = obj(obj>0) ; l = sum(obj>0) ; t = returnInfo_MF.time_it     ; time_HAGO_SFW_AFISTA = t(1:l) ;
        fid = figure ;
        ax1 = axes('Position',[0.1300 0.1128 0.7750 0.8122]) ;
        hold on ;
        k = 0 ; handle = cell(7,1) ;
        k = k + 1 ; handle{k} = plot( time_FUMI            , 10*log10( obj_FUMI            ) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; handle{k} = plot( time_FUMI(1:intvl_FUMI:end)          , 10*log10( obj_FUMI(1:intvl_FUMI:end)          ) , [mkstyArr{k},colorArr{k}] , 'LineWidth' , lineWidthVal ) ; handle{k} = plot( time_FUMI(1)             , 10*log10( obj_FUMI(1)            ) , [lnstyArr{k},mkstyArr{k},colorArr{k}] , 'LineWidth' , lineWidthVal ) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        k = k + 1 ; handle{k} = plot( time_ExFISTA         , 10*log10( obj_ExFISTA         ) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; handle{k} = plot( time_ExFISTA(1:intvl_ExBCD:end)      , 10*log10( obj_ExFISTA(1:intvl_ExBCD:end)      ) , [mkstyArr{k},colorArr{k}] , 'LineWidth' , lineWidthVal ) ; handle{k} = plot( time_ExFISTA(1)          , 10*log10( obj_ExFISTA(1)         ) , [lnstyArr{k},mkstyArr{k},colorArr{k}] , 'LineWidth' , lineWidthVal ) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        k = k + 1 ; handle{k} = plot( time_HAGO_FISTA      , 10*log10( obj_HAGO_FISTA      ) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; handle{k} = plot( time_HAGO_FISTA(1:intvl_MF:end)      , 10*log10( obj_HAGO_FISTA(1:intvl_MF:end)      ) , [mkstyArr{k},colorArr{k}] , 'LineWidth' , lineWidthVal ) ; handle{k} = plot( time_HAGO_FISTA(1)       , 10*log10( obj_HAGO_FISTA(1)      ) , [lnstyArr{k},mkstyArr{k},colorArr{k}] , 'LineWidth' , lineWidthVal ) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        k = k + 1 ; handle{k} = plot( time_HAGO_SFW_AFISTA , 10*log10( obj_HAGO_SFW_AFISTA ) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; handle{k} = plot( time_HAGO_SFW_AFISTA(1:intvl_MF:end) , 10*log10( obj_HAGO_SFW_AFISTA(1:intvl_MF:end) ) , [mkstyArr{k},colorArr{k}] , 'LineWidth' , lineWidthVal ) ; handle{k} = plot( time_HAGO_SFW_AFISTA (1) , 10*log10( obj_HAGO_SFW_AFISTA(1) ) , [lnstyArr{k},mkstyArr{k},colorArr{k}] , 'LineWidth' , lineWidthVal ) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        h = ylabel( 'Objective Value' ) ; set( h , 'FontSize' , 18 ) ;
        h = xlabel( 'Time (sec)' ) ; set( h , 'FontSize' , 14 ) ;
        H = [] ; for k = 1 : length(handle) ; H = [ H , handle{k} ] ; end ; %#ok<AGROW>
        h = legend( H                            , ...
                  { 'FUMI (or Exact AO by ADMM)' , ...
                    'Exact AO by FPG'            , ...
                    'HAGO by FPG'                , ...
                    'HAGO by FPG-FW'             } , 'Location' , 'best' ) ; set( h , 'FontSize' , 10 ) ;
        set( h   , 'FontSize' , 14 ) ;
        set( gca , 'FontSize' , 10 ) ;
        set( fid , 'Position' , [0,0,1200,400] ) ;
        xlim( [ 0 , 1200 ] ) ;
        grid on ;
        hold off ;
        drawnow ;
    cd ..
cd ..
folderName = 'plot_results' ;
if( ~exist( folderName , 'dir' ) )
    mkdir( folderName ) ;
end
cd( folderName ) ;
    fileName = 'results_chikusei_obj_vs_time' ;
    saveas(fid,[fileName,'.png']) ;
    saveas(fid,[fileName,'.epsc2']) ;
    unix(['mv ',fileName,'.epsc2 ',fileName,'.eps']) ;
cd ..
