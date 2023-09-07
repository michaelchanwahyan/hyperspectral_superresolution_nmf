close all
%clear
clc
%            DRFUMI  CNMF , FISTA   Hybrid   HySure
colorArr = { 'k'   , 'g'  , 'b'   , 'r'    , 'm'  } ;
lnstyArr = { '--'  , '--' , '-'   , '-'    , '--' } ;
lineWidthVal = 2 ;
cd SNR_40dB
    if( ~exist( 'HSI' , 'var' ) )
    load HSI_chikusei2014_1000x1000
    end
    HS_bandNum  = 128       ;
    MS_pixelNum = 1000 * 1000 ;
    Y   = reshape(permute(HSI,[3,1,2]),HS_bandNum,MS_pixelNum) ;
    cd trial0001
        % ---------------------- %
        % plot the SAM histogram %
        % ---------------------- %
        fprintf( 'load fumi ...\n'        ) ; load( 'LOG_DRFUMI'                     , 'A_DRFUMI' , 'S_DRFUMI' ) ; RMSE_DRFUMI_vs_px        = 10*log10( sqrt(mean(((A_DRFUMI*S_DRFUMI)-Y).^2)) ) ;
        fprintf( 'load cnmf ...\n'        ) ; load( 'LOG_CNMF.mat'                   , 'A_CNMF'   , 'S_CNMF'   ) ; RMSE_CNMF_vs_px          = 10*log10( sqrt(mean(((A_CNMF  *S_CNMF  )-Y).^2)) ) ;
        fprintf( 'load hago-fpg ...\n'    ) ; load( 'LOG_MFbA_FISTA.mat'             , 'A_MF'     , 'S_MF'     ) ; RMSE_MFbA_FISTA_vs_px    = 10*log10( sqrt(mean(((A_MF    *S_MF    )-Y).^2)) ) ;
        fprintf( 'load hago-hybrid ...\n' ) ; load( 'LOG_MFbA_HYBRID_SFW_AFISTA.mat' , 'A_MF'     , 'S_MF'     ) ; RMSE_MFbA_HYBRID_vs_px   = 10*log10( sqrt(mean(((A_MF    *S_MF    )-Y).^2)) ) ;
        fprintf( 'load hysure ...\n'      ) ; load( 'LOG_HySure.mat'                 , 'A_HySure' ,'S_HySure'  ) ; RMSE_HySure_vs_px        = 10*log10( sqrt(mean(((A_HySure*S_HySure)-Y).^2)) ) ;
        fid1 = figure ;
        fSz = 18 ;
        % -------- %
        % SAM plot %
        % -------- %
        hold on ;
        k = 0 ; handle = cell(7,1) ;
        maxRMSE = -20 ;
        minRMSE = -33 ;
        k = k + 1 ; [N,edges] = histcounts( RMSE_DRFUMI_vs_px      , round(MS_pixelNum/1000) ) ; handle{k} = plot( mean([edges(2:end);edges(1:end-1)]) , 10*log10(N) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([minRMSE,maxRMSE]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        k = k + 1 ; [N,edges] = histcounts( RMSE_CNMF_vs_px        , round(MS_pixelNum/1000) ) ; handle{k} = plot( mean([edges(2:end);edges(1:end-1)]) , 10*log10(N) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([minRMSE,maxRMSE]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        k = k + 1 ; [N,edges] = histcounts( RMSE_MFbA_FISTA_vs_px  , round(MS_pixelNum/1000) ) ; handle{k} = plot( mean([edges(2:end);edges(1:end-1)]) , 10*log10(N) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([minRMSE,maxRMSE]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        k = k + 1 ; [N,edges] = histcounts( RMSE_MFbA_HYBRID_vs_px , round(MS_pixelNum/1000) ) ; handle{k} = plot( mean([edges(2:end);edges(1:end-1)]) , 10*log10(N) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([minRMSE,maxRMSE]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        k = k + 1 ; [N,edges] = histcounts( RMSE_HySure_vs_px      , round(MS_pixelNum/1000) ) ; handle{k} = plot( mean([edges(2:end);edges(1:end-1)]) , 10*log10(N) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([minRMSE,maxRMSE]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        h = ylabel( 'Number of Pixels'         ) ; set( h , 'FontSize' , fSz ) ;
        h = xlabel( 'SAM (deg)' ) ; set( h , 'FontSize' , fSz ) ;
        H = [] ; for k = 1 : length(handle) ; H = [ H , handle{k} ] ; end ; %#ok<AGROW>
        h = legend( H , 'FUMI' , ...
                        'CNMF' , ...
                        'HAGO: FPG A, FPG S' , ...
                        'HAGO: FPG A, FW S'  , ...
                        'HySure' , ...
                        'Location' , 'southeast' , ...
                        'Orientation' , 'vertical' ) ;
        set( h    , 'FontSize' , fSz ) ;
        set( gca  , 'FontSize' , fSz ) ;
        set( fid1 , 'Position' , [0,0,900,450] ) ;
        grid on ;
        drawnow ;
        % ------- %
        % SAM Map %
        % ------- %
        colormapChoice = 'jet' ;
        fid2 = figure ;
        
        RMSE_MAP_DRFUMI = min( reshape(RMSE_DRFUMI_vs_px      ,1000,1000)/maxSAM , 1 ) ;        RMSE_MAP_CNMF   = min( reshape(RMSE_CNMF_vs_px                               ,1000,1000)/maxSAM , 1 ) ;
        RMSE_MAP_CNMF   = min( reshape(RMSE_CNMF_vs_px        ,1000,1000)/maxSAM , 1 ) ;
        RMSE_MAP_FISTA  = min( reshape(RMSE_MFbA_FISTA_vs_px  ,1000,1000)/maxSAM , 1 ) ;
        RMSE_MAP_HYBRID = min( reshape(RMSE_MFbA_HYBRID_vs_px ,1000,1000)/maxSAM , 1 ) ;
        RMSE_MAP_HySure = min( reshape(RMSE_HySure_vs_px      ,1000,1000)/maxSAM , 1 ) ;
        
        subplot(2,3,2) ; p = pcolor( flipud( RMSE_MAP_DRFUMI ) ) ; set( p , 'EdgeColor' , 'none' ) ; axis equal ; axis off ; colormap( colormapChoice ) ; tt = text(10,180,1,'DRFUMI') ; tt.FontSize = 12 ; tt.Color = 'w' ;
        subplot(2,3,3) ; p = pcolor( flipud( RMSE_MAP_CNMF   ) ) ; set( p , 'EdgeColor' , 'none' ) ; axis equal ; axis off ; colormap( colormapChoice ) ; tt = text(10,180,1,'CNMF'  ) ; tt.FontSize = 12 ; tt.Color = 'w' ;
        subplot(2,3,4) ; p = pcolor( flipud( RMSE_MAP_FISTA  ) ) ; set( p , 'EdgeColor' , 'none' ) ; axis equal ; axis off ; colormap( colormapChoice ) ; tt = text(10,180,1,'FISTA' ) ; tt.FontSize = 12 ; tt.Color = 'w' ;
        subplot(2,3,5) ; p = pcolor( flipud( RMSE_MAP_HYBRID ) ) ; set( p , 'EdgeColor' , 'none' ) ; axis equal ; axis off ; colormap( colormapChoice ) ; tt = text(10,180,1,'HYBRID') ; tt.FontSize = 12 ; tt.Color = 'w' ;
        subplot(2,3,6) ; p = pcolor( flipud( RMSE_MAP_HySure ) ) ; set( p , 'EdgeColor' , 'none' ) ; axis equal ; axis off ; colormap( colormapChoice ) ; tt = text(10,180,1,'HySure') ; tt.FontSize = 12 ; tt.Color = 'w' ;
        c = colorbar( 'Position' , [ 0.92 , 0.1 , 0.02 , 0.85 ] ) ; % hard-coded
        set(c,'YTick',linspace(0,1,maxSAM+1),'YTickLabel',strsplit(num2str(0:maxSAM),' ')) ;
        set( fid2 , 'Position' , [0,0,900,600] ) ;
    cd ..
cd ..
if( ~exist( 'plot_results' , 'dir' ) )
    mkdir plot_results ;
end
cd plot_results
    fileName1 = 'results_chikusei_RMSE_vs_px' ;
    saveas(fid1,[fileName1,'.epsc2']) ;
    unix(['mv ',fileName1,'.epsc2 ',fileName1,'.eps']) ;
cd ..
%fileName2 = 'results_chikusei_RMSE_map' ;
%saveas(fid2,[fileName2,'.epsc2']) ;
%unix(['mv ',fileName2,'.epsc2 ',fileName2,'.eps']) ;
%epsFileName = 'RMSE_MAP_CNMF'   ; sCNMF   = imgray2pcolor( RMSE_MAP_CNMF   , colormapChoice , 255 ) ; imwrite(sCNMF  ,[epsFileName,'.png']) ; pause(1) ; unix(['convert ',epsFileName,'.png ',epsFileName,'.eps']) ;
%epsFileName = 'RMSE_MAP_FISTA'  ; sFISTA  = imgray2pcolor( RMSE_MAP_FISTA  , colormapChoice , 255 ) ; imwrite(sFISTA ,[epsFileName,'.png']) ; pause(1) ; unix(['convert ',epsFileName,'.png ',epsFileName,'.eps']) ;
%delete RMSE_MAP*.png