close all
clear
clc
%            FUMI
%                  GP     BBGP  FW
%                                     PG    FISTA
%                                                  HYBRID FW-FISTA
colorArr = { 'k' , 'b' , 'b' , 'b' , 'r' , 'r' , 'm' } ;
mkstyArr = { '^' , 'o' , '^' , 'x' , '^' , '^' , '+' } ;
lnstyArr = { '--', '-' , '-.', '--', '-' , '-.', '--'} ;
lineWidthVal = 1 ;
intvl_FUMI = 200 ;
intvl_MF   = 400 ;
cd SNR_40dB
    cd trial0001
        % ------------------- %
        % plot the obj curves %
        % ------------------- %
        load( 'LOG_FUMI_subprobVar_-3.mat'                                       , 'returnInfo_FUMI' ) ; obj = returnInfo_FUMI.obj_it ; obj_FUMI                                         = obj(obj>0) ;
        load( 'LOG_MFbA_gpExlnsrch_subprobIt_1.mat'                              , 'returnInfo_MF'   ) ; obj = returnInfo_MF.obj_it   ; obj_MFbA_gpExlnsrch_subprobIt_1                  = obj(obj>0) ;
        load( 'LOG_MFbA_BB_betaMax1_subprobIt_1.mat'                             , 'returnInfo_MF'   ) ; obj = returnInfo_MF.obj_it   ; obj_MFbA_BB_betaMax1_subprobIt_1                 = obj(obj>0) ;
        load( 'LOG_MFbA_FW_subprobIt_1.mat'                                      , 'returnInfo_MF'   ) ; obj = returnInfo_MF.obj_it   ; obj_MFbA_FW_subprobIt_1                          = obj(obj>0) ;
        load( 'LOG_MFbA_proxGrad_subprobIt_1.mat'                                , 'returnInfo_MF'   ) ; obj = returnInfo_MF.obj_it   ; obj_MFbA_proxGrad_subprobIt_1                    = obj(obj>0) ;
        load( 'LOG_MFbA_fista_subprobIt_1.mat'                                   , 'returnInfo_MF'   ) ; obj = returnInfo_MF.obj_it   ; obj_MFbA_fista_subprobIt_1                       = obj(obj>0) ;
        load( 'LOG_MFbA_HYBRID_S_FW1_A_PG1_subprobIt_1.mat' , 'returnInfo_MF'   ) ; obj = returnInfo_MF.obj_it   ; obj_MFbA_HYBRID_S_FW1_A_PG1_subprobIt_1 = obj(obj>0) ;
        fid = figure ;
        ax1 = axes('Position',[0.1300 0.1128 0.7750 0.8122]) ;
        hold on ;
        k = 0 ; handle = cell(7,1) ;
        k = k + 1 ; handle{k} = plot( 10*log10( obj_FUMI                                         ) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        k = k + 1 ; handle{k} = plot( 10*log10( obj_MFbA_gpExlnsrch_subprobIt_1                  ) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        k = k + 1 ; handle{k} = plot( 10*log10( obj_MFbA_BB_betaMax1_subprobIt_1                 ) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        k = k + 1 ; handle{k} = plot( 10*log10( obj_MFbA_FW_subprobIt_1                          ) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        k = k + 1 ; handle{k} = plot( 10*log10( obj_MFbA_proxGrad_subprobIt_1                    ) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        k = k + 1 ; handle{k} = plot( 10*log10( obj_MFbA_fista_subprobIt_1                       ) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        k = k + 1 ; handle{k} = plot( 10*log10( obj_MFbA_HYBRID_S_FW1_A_PG1_subprobIt_1 ) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        h = ylabel( 'Objective Value' ) ; set( h , 'FontSize' , 12 ) ;
        h = xlabel( 'Iteration' ) ; set( h , 'FontSize' , 12 ) ;
        H = [] ; for k = 1 : length(handle) ; H = [ H , handle{k} ] ; end ; %#ok<AGROW>
        h = legend( H      , ...
                  { 'FUMI' , ...
                    'GP'   , ...
                    'BBGP' , ...
                    'FW'   , ...
                    'PG'   , ...
                    'FISTA', ...
                    'HYBRID'} , 'Location' , 'northwest' ) ; set( h , 'FontSize' , 10 ) ;
        set( gca , 'FontSize' , 12 ) ;
        set( fid , 'Position' , [0,0,600,400] ) ;
        grid on ;
        hold off ;
        drawnow ;
        ax2 = axes('Position',[0.35 0.3 0.5 0.6]);
        itlim_small  = 300 ;
        objlim_small = 20 ;
        hold on ;
        k = 0 ; handle = cell(7,1) ;
        k = k + 1 ; handle{k} = plot( 10*log10( obj_FUMI                                         ) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([0,itlim_small]) ; ylim([5,objlim_small]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        k = k + 1 ; handle{k} = plot( 10*log10( obj_MFbA_gpExlnsrch_subprobIt_1                  ) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([0,itlim_small]) ; ylim([5,objlim_small]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        k = k + 1 ; handle{k} = plot( 10*log10( obj_MFbA_BB_betaMax1_subprobIt_1                 ) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([0,itlim_small]) ; ylim([5,objlim_small]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        k = k + 1 ; handle{k} = plot( 10*log10( obj_MFbA_FW_subprobIt_1                          ) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([0,itlim_small]) ; ylim([5,objlim_small]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        k = k + 1 ; handle{k} = plot( 10*log10( obj_MFbA_proxGrad_subprobIt_1                    ) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([0,itlim_small]) ; ylim([5,objlim_small]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        k = k + 1 ; handle{k} = plot( 10*log10( obj_MFbA_fista_subprobIt_1                       ) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([0,itlim_small]) ; ylim([5,objlim_small]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        k = k + 1 ; handle{k} = plot( 10*log10( obj_MFbA_HYBRID_S_FW1_A_PG1_subprobIt_1 ) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([0,itlim_small]) ; ylim([5,objlim_small]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        grid on ;
    cd ..
cd ..
fileName = 'results_cuprite_obj_vs_it' ;
saveas(fid,[fileName,'.epsc2']) ;
unix(['mv ',fileName,'.epsc2 ',fileName,'.eps']) ;
