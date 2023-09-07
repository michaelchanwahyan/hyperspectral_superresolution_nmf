close all
clear
clc
%            FUMI
%                  GP     BBGP  FW
%                                     PG    FISTA
%                                                  HYBRID FW-FISTA
colorArr = { 'k' , 'b' , 'b' , 'b' , 'r' , 'r' , 'm' } ;
mkstyArr = { '^' , 'o' , '^' , 'x' , '^' , '^' , '+' } ;
lnstyArr = { '-' , '-' , '-.', '--', '-' , '-.', '--'} ;
lineWidthVal = 1 ;
cd SNR_40dB
    load HSI_cuprite_200x350x224
    HS_bandNum  = 188       ;
    MS_pixelNum = 200 * 348 ;
    usedBand    = [3:103,114:147,168:220] ; % 101bands - 34bands - 53bands
    HSI = HSI(:,1:348,usedBand) ;
    Y   = reshape(permute(HSI,[3,1,2]),HS_bandNum,MS_pixelNum) ;
    cd trial0001
        % ----------------------- %
        % plot the RMSE histogram %
        % ----------------------- %
        
        load( 'LOG_FUMI_subprobVar_-3.mat'                                       , 'A_FUMI' , 'S_FUMI' ) ; RMSE_FUMI_vs_px                                          = 10*log10( sqrt(mean(((A_FUMI*S_FUMI)-Y).^2)) ) ;
        load( 'LOG_MFbA_gpExlnsrch_subprobIt_1.mat'                              , 'A_MF'   , 'S_MF'   ) ; RMSE_MFbA_gpExlnsrch_subprobIt_1_vs_px                   = 10*log10( sqrt(mean(((A_MF  *S_MF  )-Y).^2)) ) ;
        load( 'LOG_MFbA_BB_betaMax1_subprobIt_1.mat'                             , 'A_MF'   , 'S_MF'   ) ; RMSE_MFbA_BB_betaMax1_subprobIt_1_vs_px                  = 10*log10( sqrt(mean(((A_MF  *S_MF  )-Y).^2)) ) ;
        load( 'LOG_MFbA_FW_subprobIt_1.mat'                                      , 'A_MF'   , 'S_MF'   ) ; RMSE_MFbA_FW_subprobIt_1_vs_px                           = 10*log10( sqrt(mean(((A_MF  *S_MF  )-Y).^2)) ) ;
        load( 'LOG_MFbA_proxGrad_subprobIt_1.mat'                                , 'A_MF'   , 'S_MF'   ) ; RMSE_MFbA_proxGrad_subprobIt_1_vs_px                     = 10*log10( sqrt(mean(((A_MF  *S_MF  )-Y).^2)) ) ;
        load( 'LOG_MFbA_fista_subprobIt_1.mat'                                   , 'A_MF'   , 'S_MF'   ) ; RMSE_MFbA_fista_subprobIt_1_vs_px                        = 10*log10( sqrt(mean(((A_MF  *S_MF  )-Y).^2)) ) ;
        load( 'LOG_MFbA_HYBRID_S_FW1_A_PG1_subprobIt_1.mat' , 'A_MF'   , 'S_MF'   ) ; RMSE_MFbA_HYBRID_S_FW1_A_PG1_subprobIt_1_vs_px = 10*log10( sqrt(mean(((A_MF  *S_MF  )-Y).^2)) ) ;
        fid1 = figure ;
        fSz = 10 ;
        % --------- %
        % RMSE plot %
        % --------- %
        hold on ;
        k = 0 ; handle = cell(7,1) ;
        minRMSE = -30 ;
        maxRMSE = -10 ;
        k = k + 1 ; [N,edges] = histcounts( RMSE_FUMI_vs_px                                          , round(MS_pixelNum/2000) ) ; handle{k} = plot( mean([edges(2:end);edges(1:end-1)]) , 10*log10(N) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([minRMSE,maxRMSE]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        k = k + 1 ; [N,edges] = histcounts( RMSE_MFbA_gpExlnsrch_subprobIt_1_vs_px                   , round(MS_pixelNum/2000) ) ; handle{k} = plot( mean([edges(2:end);edges(1:end-1)]) , 10*log10(N) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([minRMSE,maxRMSE]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        k = k + 1 ; [N,edges] = histcounts( RMSE_MFbA_BB_betaMax1_subprobIt_1_vs_px                  , round(MS_pixelNum/2000) ) ; handle{k} = plot( mean([edges(2:end);edges(1:end-1)]) , 10*log10(N) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([minRMSE,maxRMSE]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        k = k + 1 ; [N,edges] = histcounts( RMSE_MFbA_FW_subprobIt_1_vs_px                           , round(MS_pixelNum/2000) ) ; handle{k} = plot( mean([edges(2:end);edges(1:end-1)]) , 10*log10(N) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([minRMSE,maxRMSE]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        k = k + 1 ; [N,edges] = histcounts( RMSE_MFbA_proxGrad_subprobIt_1_vs_px                     , round(MS_pixelNum/2000) ) ; handle{k} = plot( mean([edges(2:end);edges(1:end-1)]) , 10*log10(N) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([minRMSE,maxRMSE]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        k = k + 1 ; [N,edges] = histcounts( RMSE_MFbA_fista_subprobIt_1_vs_px                        , round(MS_pixelNum/2000) ) ; handle{k} = plot( mean([edges(2:end);edges(1:end-1)]) , 10*log10(N) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([minRMSE,maxRMSE]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        k = k + 1 ; [N,edges] = histcounts( RMSE_MFbA_HYBRID_S_FW1_A_PG1_subprobIt_1_vs_px , round(MS_pixelNum/2000) ) ; handle{k} = plot( mean([edges(2:end);edges(1:end-1)]) , 10*log10(N) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([minRMSE,maxRMSE]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        h = ylabel( 'Number of Pixels'         ) ; set( h , 'FontSize' , fSz ) ;
        h = xlabel( 'RMSE (dB)' ) ; set( h , 'FontSize' , fSz ) ;
        H = [] ; for k = 1 : length(handle) ; H = [ H , handle{k} ] ; end ; %#ok<AGROW>
        h = legend( H      , ...
                  { 'FUMI' , ...
                    'GP'   , ...
                    'BBGP' , ...
                    'FW'   , ...
                    'PG'   , ...
                    'FISTA', ...
                    'HYBRID'} , 'Location' , 'best' , 'Orientation' , 'horizontal' ) ; set( h , 'FontSize' , 10 ) ;
        set( gca , 'FontSize' , fSz ) ;
        set( fid1 , 'Position' , [0,0,600,150] ) ;
        grid on ;
        drawnow ;
        % -------- %
        % RMSE Map %
        % -------- %
        colormapChoice = 'jet' ;
        fid2 = figure ;
        RMSE_MAP_FUMI   = (reshape(RMSE_FUMI_vs_px                               ,200,348)-minRMSE)/(maxRMSE-minRMSE) ;
        RMSE_MAP_PG     = (reshape(RMSE_MFbA_proxGrad_subprobIt_1_vs_px          ,200,348)-minRMSE)/(maxRMSE-minRMSE) ;
        RMSE_MAP_FISTA  = (reshape(RMSE_MFbA_fista_subprobIt_1_vs_px             ,200,348)-minRMSE)/(maxRMSE-minRMSE) ;
        RMSE_MAP_GP     = (reshape(RMSE_MFbA_gpExlnsrch_subprobIt_1_vs_px        ,200,348)-minRMSE)/(maxRMSE-minRMSE) ;
        RMSE_MAP_FW     = (reshape(RMSE_MFbA_FW_subprobIt_1_vs_px                ,200,348)-minRMSE)/(maxRMSE-minRMSE) ;
        RMSE_MAP_HYBRID = (reshape(RMSE_MFbA_HYBRID_S_FW1_A_PG1_subprobIt_1_vs_px,200,348)-minRMSE)/(maxRMSE-minRMSE) ;
        
        % ~ FUMI ~ %
        Z = false(10,16) ; Z(1:5,1:8) = true ;
        subplot(10,16,find(Z')) ;
        p = pcolor( flipud( RMSE_MAP_FUMI ) ) ; set( p , 'EdgeColor' , 'none' ) ; axis equal ; axis off ; colormap( colormapChoice ) ; tt = text(10,180,1,'FUMI') ; tt.FontSize = 12 ; tt.Color = 'k' ;
        % ~ PG ~ %
        Z = false(10,16) ; Z(6:10,1:8) = true ;
        subplot(10,16,find(Z')) ;
        p = pcolor( flipud( RMSE_MAP_PG ) ) ; set( p , 'EdgeColor' , 'none' ) ; axis equal ; axis off ; colormap( colormapChoice ) ; tt = text(10,180,1,'PG'  ) ; tt.FontSize = 12 ; tt.Color = 'k' ;
        % ~ GP ~ %
        Z = false(10,16) ; Z(1:5,9:16) = true ;
        subplot(10,16,find(Z')) ;
        p = pcolor( flipud( RMSE_MAP_GP ) ) ; set( p , 'EdgeColor' , 'none' ) ; axis equal ; axis off ; colormap( colormapChoice ) ; tt = text(10,180,1,'GP'  ) ; tt.FontSize = 12 ; tt.Color = 'k' ;
        % ~ HYBRID ~ %
        Z = false(10,16) ; Z(6:10,9:16) = true ;
        subplot(10,16,find(Z')) ;
        p = pcolor( flipud( RMSE_MAP_HYBRID ) ) ; set( p , 'EdgeColor' , 'none' ) ; axis equal ; axis off ; colormap( colormapChoice ) ; tt = text(10,180,1,'HYBRID FW-FISTA'  ) ; tt.FontSize = 12 ; tt.Color = 'k' ;
        c = colorbar( 'Position' , [ 0.92 , 0.1 , 0.02 , 0.85 ] ) ; % hard-coded
        set(c,'YTick',linspace(0,1,11),'YTickLabel',strsplit(num2str(minRMSE:2:maxRMSE),' ')) ;
        set( fid2 , 'Position' , [0,0,600,350] ) ;
    cd ..
cd ..
%%{
%fileName1 = 'results_cuprite_RMSE_vs_px' ;
%saveas(fid1,[fileName1,'.epsc2']) ;
%unix(['mv ',fileName1,'.epsc2 ',fileName1,'.eps']) ;
%fileName2 = 'results_cuprite_RMSE_map' ;
%saveas(fid2,[fileName2,'.epsc2']) ;
%unix(['mv ',fileName2,'.epsc2 ',fileName2,'.eps']) ;

epsFileName = 'RMSE_MAP_FUMI'   ; rFUMI   = imgray2pcolor( RMSE_MAP_FUMI   , colormapChoice , 255 ) ; imwrite(rFUMI  ,[epsFileName,'.png']) ; pause(1) ; unix(['convert ',epsFileName,'.png ',epsFileName,'.eps']) ;
epsFileName = 'RMSE_MAP_PG'     ; rPG     = imgray2pcolor( RMSE_MAP_PG     , colormapChoice , 255 ) ; imwrite(rPG    ,[epsFileName,'.png']) ; pause(1) ; unix(['convert ',epsFileName,'.png ',epsFileName,'.eps']) ;
epsFileName = 'RMSE_MAP_FISTA'  ; rFISTA  = imgray2pcolor( RMSE_MAP_FISTA  , colormapChoice , 255 ) ; imwrite(rFISTA ,[epsFileName,'.png']) ; pause(1) ; unix(['convert ',epsFileName,'.png ',epsFileName,'.eps']) ;
epsFileName = 'RMSE_MAP_GP'     ; rGP     = imgray2pcolor( RMSE_MAP_GP     , colormapChoice , 255 ) ; imwrite(rGP    ,[epsFileName,'.png']) ; pause(1) ; unix(['convert ',epsFileName,'.png ',epsFileName,'.eps']) ;
epsFileName = 'RMSE_MAP_FW'     ; rFW     = imgray2pcolor( RMSE_MAP_FW     , colormapChoice , 255 ) ; imwrite(rFW    ,[epsFileName,'.png']) ; pause(1) ; unix(['convert ',epsFileName,'.png ',epsFileName,'.eps']) ;
epsFileName = 'RMSE_MAP_HYBRID' ; rHYBRID = imgray2pcolor( RMSE_MAP_HYBRID , colormapChoice , 255 ) ; imwrite(rHYBRID,[epsFileName,'.png']) ; pause(1) ; unix(['convert ',epsFileName,'.png ',epsFileName,'.eps']) ;
delete RMSE_MAP_*.png
%%}