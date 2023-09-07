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
        fprintf( 'load fumi ...\n'        ) ; load( 'LOG_DRFUMI'                     , 'A_DRFUMI' , 'S_DRFUMI' ) ; SAM_DRFUMI_vs_px        = real(acos(sum((A_DRFUMI*S_DRFUMI).*Y)./sqrt( sum((A_DRFUMI*S_DRFUMI).^2).*sum(Y.^2) ))) / pi * 180 ;
        fprintf( 'load cnmf ...\n'        ) ; load( 'LOG_CNMF.mat'                   , 'A_CNMF'   , 'S_CNMF'   ) ; SAM_CNMF_vs_px          = real(acos(sum((A_CNMF  * S_CNMF ).*Y)./sqrt( sum((A_CNMF  *S_CNMF  ).^2).*sum(Y.^2) ))) / pi * 180 ;
        fprintf( 'load hago-fpg ...\n'    ) ; load( 'LOG_MFbA_FISTA.mat'             , 'A_MF'     , 'S_MF'     ) ; SAM_MFbA_FISTA_vs_px    = real(acos(sum((A_MF    *S_MF    ).*Y)./sqrt( sum((A_MF    *S_MF    ).^2).*sum(Y.^2) ))) / pi * 180 ;
        fprintf( 'load hago-hybrid ...\n' ) ; load( 'LOG_MFbA_HYBRID_SFW_AFISTA.mat' , 'A_MF'     , 'S_MF'     ) ; SAM_MFbA_HYBRID_vs_px   = real(acos(sum((A_MF    *S_MF    ).*Y)./sqrt( sum((A_MF    *S_MF    ).^2).*sum(Y.^2) ))) / pi * 180 ;
        fprintf( 'load hysure ...\n'      ) ; load( 'LOG_HySure.mat'                 , 'A_HySure' ,'S_HySure'  ) ; SAM_HySure_vs_px        = real(acos(sum((A_HySure*S_HySure).*Y)./sqrt( sum((A_HySure*S_HySure).^2).*sum(Y.^2) ))) / pi * 180 ;
        fid1 = figure ;
        fSz = 18 ;
        % -------- %
        % SAM plot %
        % -------- %
        hold on ;
        k = 0 ; handle = cell(7,1) ;
        maxSAM = 6 ;
        k = k + 1 ; [N,edges] = histcounts( SAM_DRFUMI_vs_px      , round(MS_pixelNum/1000) ) ; handle{k} = plot( mean([edges(2:end);edges(1:end-1)]) , 10*log10(N) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([0,maxSAM]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        k = k + 1 ; [N,edges] = histcounts( SAM_CNMF_vs_px        , round(MS_pixelNum/1000) ) ; handle{k} = plot( mean([edges(2:end);edges(1:end-1)]) , 10*log10(N) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([0,maxSAM]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        k = k + 1 ; [N,edges] = histcounts( SAM_MFbA_FISTA_vs_px  , round(MS_pixelNum/1000) ) ; handle{k} = plot( mean([edges(2:end);edges(1:end-1)]) , 10*log10(N) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([0,maxSAM]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        k = k + 1 ; [N,edges] = histcounts( SAM_MFbA_HYBRID_vs_px , round(MS_pixelNum/1000) ) ; handle{k} = plot( mean([edges(2:end);edges(1:end-1)]) , 10*log10(N) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([0,maxSAM]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        k = k + 1 ; [N,edges] = histcounts( SAM_HySure_vs_px      , round(MS_pixelNum/1000) ) ; handle{k} = plot( mean([edges(2:end);edges(1:end-1)]) , 10*log10(N) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([0,maxSAM]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        h = ylabel( 'Number of Pixels'         ) ; set( h , 'FontSize' , fSz ) ;
        h = xlabel( 'SAM (deg)' ) ; set( h , 'FontSize' , fSz ) ;
        H = [] ; for k = 1 : length(handle) ; H = [ H , handle{k} ] ; end ; %#ok<AGROW>
        h = legend( H , 'FUMI' , ...
                        'CNMF' , ...
                        'HAGO: FPG A, FPG S' , ...
                        'HAGO: FPG A, FW S'  , ...
                        'HySure' , ...
                        'Location' , 'south' , ...
                        'Orientation' , 'vertical' ) ;
        set( h    , 'FontSize' , fSz ) ;
        set( gca  , 'FontSize' , fSz ) ;
        set( fid1 , 'Position' , [0,0,900,450] ) ;
        grid on ;
        drawnow ;
        % ------- %
        % SAM Map %
        % ------- %
        colormapChoice = 'hot' ; % 'cool' ; % 'hsv' ; % 'jet' ;
        fid2 = figure ;
        
        SAM_MAP_DRFUMI = min( reshape(SAM_DRFUMI_vs_px      ,1000,1000)/maxSAM , 1 ) ;        SAM_MAP_CNMF   = min( reshape(SAM_CNMF_vs_px                               ,1000,1000)/maxSAM , 1 ) ;
        SAM_MAP_CNMF   = min( reshape(SAM_CNMF_vs_px        ,1000,1000)/maxSAM , 1 ) ;
        SAM_MAP_FISTA  = min( reshape(SAM_MFbA_FISTA_vs_px  ,1000,1000)/maxSAM , 1 ) ;
        SAM_MAP_HYBRID = min( reshape(SAM_MFbA_HYBRID_vs_px ,1000,1000)/maxSAM , 1 ) ;
        SAM_MAP_HySure = min( reshape(SAM_HySure_vs_px      ,1000,1000)/maxSAM , 1 ) ;
        
        subplot(2,3,2) ; p = pcolor( flipud( SAM_MAP_DRFUMI ) ) ; set( p , 'EdgeColor' , 'none' ) ; axis equal ; axis off ; colormap( colormapChoice ) ; tt = text(10,180,1,'DRFUMI') ; tt.FontSize = 12 ; tt.Color = 'w' ;
        subplot(2,3,3) ; p = pcolor( flipud( SAM_MAP_CNMF   ) ) ; set( p , 'EdgeColor' , 'none' ) ; axis equal ; axis off ; colormap( colormapChoice ) ; tt = text(10,180,1,'CNMF'  ) ; tt.FontSize = 12 ; tt.Color = 'w' ;
        subplot(2,3,4) ; p = pcolor( flipud( SAM_MAP_FISTA  ) ) ; set( p , 'EdgeColor' , 'none' ) ; axis equal ; axis off ; colormap( colormapChoice ) ; tt = text(10,180,1,'FISTA' ) ; tt.FontSize = 12 ; tt.Color = 'w' ;
        subplot(2,3,5) ; p = pcolor( flipud( SAM_MAP_HYBRID ) ) ; set( p , 'EdgeColor' , 'none' ) ; axis equal ; axis off ; colormap( colormapChoice ) ; tt = text(10,180,1,'HYBRID') ; tt.FontSize = 12 ; tt.Color = 'w' ;
        subplot(2,3,6) ; p = pcolor( flipud( SAM_MAP_HySure ) ) ; set( p , 'EdgeColor' , 'none' ) ; axis equal ; axis off ; colormap( colormapChoice ) ; tt = text(10,180,1,'HySure') ; tt.FontSize = 12 ; tt.Color = 'w' ;
        c = colorbar( 'Position' , [ 0.92 , 0.1 , 0.02 , 0.85 ] ) ; % hard-coded
        set(c,'YTick',linspace(0,1,maxSAM+1),'YTickLabel',strsplit(num2str(0:maxSAM),' ')) ;
        set( fid2 , 'Position' , [0,0,900,600] ) ;
    cd ..
cd ..
if( ~exist( 'plot_results' , 'dir' ) )
    mkdir plot_results ;
end
cd plot_results
    fileName1 = 'results_chikusei_SAM_vs_px' ;
    saveas(fid1,[fileName1,'.epsc2']) ;
    unix(['mv ',fileName1,'.epsc2 ',fileName1,'.eps']) ;
cd ..
epsFileName = 'IM_DRFUMI_SAM'      ; sFUMI   = imgray2pcolor( flipud( SAM_MAP_DRFUMI ) , colormapChoice , 255 ) ; imwrite(sFUMI   ,[epsFileName,'.png']) ; pause(1) ; unix(['convert ',epsFileName,'.png ',epsFileName,'.eps']) ;
epsFileName = 'IM_CNMF_SAM'        ; sCNMF   = imgray2pcolor( flipud( SAM_MAP_CNMF   ) , colormapChoice , 255 ) ; imwrite(sCNMF   ,[epsFileName,'.png']) ; pause(1) ; unix(['convert ',epsFileName,'.png ',epsFileName,'.eps']) ;
epsFileName = 'IM_MFbA_FISTA_SAM'  ; sFISTA  = imgray2pcolor( flipud( SAM_MAP_FISTA  ) , colormapChoice , 255 ) ; imwrite(sFISTA  ,[epsFileName,'.png']) ; pause(1) ; unix(['convert ',epsFileName,'.png ',epsFileName,'.eps']) ;
epsFileName = 'IM_MFbA_HYBRID_SAM' ; sHYBRID = imgray2pcolor( flipud( SAM_MAP_HYBRID ) , colormapChoice , 255 ) ; imwrite(sHYBRID ,[epsFileName,'.png']) ; pause(1) ; unix(['convert ',epsFileName,'.png ',epsFileName,'.eps']) ;
epsFileName = 'IM_HySure_SAM'      ; sHySure = imgray2pcolor( flipud( SAM_MAP_HySure ) , colormapChoice , 255 ) ; imwrite(sHySure ,[epsFileName,'.png']) ; pause(1) ; unix(['convert ',epsFileName,'.png ',epsFileName,'.eps']) ;
unix( 'mv IM_*.png IM_*.eps ./plot_results/' ) ;