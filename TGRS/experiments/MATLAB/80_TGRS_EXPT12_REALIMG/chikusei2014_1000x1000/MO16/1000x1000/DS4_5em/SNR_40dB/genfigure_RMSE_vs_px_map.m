close all
clear
clc
%            CNMF
%                  GP     BBGP  FW
%                                     PG    FISTA
%                                                  HYBRID FW-FISTA
colorArr = { 'b' , 'r' } ;
lnstyArr = { '-.' , '--' } ;
lineWidthVal = 1 ;
cd SNR_40dB
    load HSI_chikusei2014_1000x1000
    HS_bandNum  = 128       ;
    MS_pixelNum = 1000 * 1000 ;
    Y   = reshape(permute(HSI,[3,1,2]),HS_bandNum,MS_pixelNum) ;
    cd trial0001
        % ----------------------- %
        % plot the RMSE histogram %
        % ----------------------- %
        load( 'LOG_CNMF_subprobIt_100_convth_1em2.mat'                  , 'A_CNMF' , 'S_CNMF' ) ;
        A_CNMF_times_S_CNMF = A_CNMF * S_CNMF ;
        RMSE_CNMF_vs_px = 10*log10( sqrt(mean((A_CNMF_times_S_CNMF-Y).^2)) ) ;
        load( 'LOG_MFnAS_fista_subprobIt_1_convth_1em2.mat'              , 'A_MF'   , 'S_MF'   ) ; RMSE_MFnAS_fista_subprobIt_1_vs_px                        = 10*log10( sqrt(mean(((A_MF  *S_MF  )-Y).^2)) ) ;
        fid1 = figure ;
        fSz = 10 ;
        % --------- %
        % RMSE plot %
        % --------- %
        hold on ;
        k = 0 ; handle = cell(7,1) ;
        minRMSE = -30 ;
        maxRMSE = -9 ;
        k = k + 1 ; [N,edges] = histcounts( RMSE_CNMF_vs_px                                , round(MS_pixelNum/2000) ) ; handle{k} = plot( mean([edges(2:end);edges(1:end-1)]) , 10*log10(N) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([minRMSE,maxRMSE]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        k = k + 1 ; [N,edges] = histcounts( RMSE_MFnAS_fista_subprobIt_1_vs_px              , round(MS_pixelNum/2000) ) ; handle{k} = plot( mean([edges(2:end);edges(1:end-1)]) , 10*log10(N) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([minRMSE,maxRMSE]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        h = ylabel( 'Number of Pixels'         ) ; set( h , 'FontSize' , fSz ) ;
        h = xlabel( 'RMSE (dB)' ) ; set( h , 'FontSize' , fSz ) ;
        H = [] ; for k = 1 : length(handle) ; H = [ H , handle{k} ] ; end ; %#ok<AGROW>
        h = legend( H , 'CNMF' , 'FISTA' , 'Location' , 'best' , 'Orientation' , 'horizontal' ) ; set( h , 'FontSize' , 10 ) ;
        set( gca , 'FontSize' , fSz ) ;
        set( fid1 , 'Position' , [0,0,600,150] ) ;
        grid on ;
        drawnow ;
        % -------- %
        % RMSE Map %
        % -------- %
        colormapChoice = 'jet' ;
        fid2 = figure ;
        RMSE_MAP_CNMF   = (reshape(RMSE_CNMF_vs_px                               ,1000,1000)-minRMSE)/(maxRMSE-minRMSE) ;
        RMSE_MAP_FISTA  = (reshape(RMSE_MFnAS_fista_subprobIt_1_vs_px             ,1000,1000)-minRMSE)/(maxRMSE-minRMSE) ;
        
        % ~ CNMF ~ %
        subplot(1,2,1) ;
        p = pcolor( flipud( RMSE_MAP_CNMF ) ) ; set( p , 'EdgeColor' , 'none' ) ; axis equal ; axis off ; colormap( colormapChoice ) ; tt = text(10,180,1,'CNMF') ; tt.FontSize = 12 ; tt.Color = 'k' ;
        % ~ FISTA ~ %
        subplot(1,2,2) ;
        p = pcolor( flipud( RMSE_MAP_FISTA ) ) ; set( p , 'EdgeColor' , 'none' ) ; axis equal ; axis off ; colormap( colormapChoice ) ; tt = text(10,180,1,'PG'  ) ; tt.FontSize = 12 ; tt.Color = 'k' ;
        c = colorbar( 'Position' , [ 0.92 , 0.1 , 0.02 , 0.85 ] ) ; % hard-coded
        set(c,'YTick',linspace(0,1,length(minRMSE:2:maxRMSE)),'YTickLabel',strsplit(num2str(minRMSE:2:maxRMSE),' ')) ;
        set( fid2 , 'Position' , [0,0,700,500] ) ;
    cd ..
cd ..
%%{
fileName1 = 'results_chikusei_RMSE_vs_px' ;
saveas(fid1,[fileName1,'.epsc2']) ;
unix(['mv ',fileName1,'.epsc2 ',fileName1,'.eps']) ;
%fileName2 = 'results_chikusei_RMSE_map' ;
%saveas(fid2,[fileName2,'.epsc2']) ;
%unix(['mv ',fileName2,'.epsc2 ',fileName2,'.eps']) ;

epsFileName = 'RMSE_MAP_CNMF'   ; rCNMF   = imgray2pcolor( RMSE_MAP_CNMF   , colormapChoice , 255 ) ; imwrite(rCNMF  ,[epsFileName,'.png']) ; pause(1) ; unix(['convert ',epsFileName,'.png ',epsFileName,'.eps']) ;
epsFileName = 'RMSE_MAP_FISTA' ; rFISTA  = imgray2pcolor( RMSE_MAP_FISTA  , colormapChoice , 255 ) ; imwrite(rFISTA ,[epsFileName,'.png']) ; pause(1) ; unix(['convert ',epsFileName,'.png ',epsFileName,'.eps']) ;
delete RMSE_MAP_*png
%%}
