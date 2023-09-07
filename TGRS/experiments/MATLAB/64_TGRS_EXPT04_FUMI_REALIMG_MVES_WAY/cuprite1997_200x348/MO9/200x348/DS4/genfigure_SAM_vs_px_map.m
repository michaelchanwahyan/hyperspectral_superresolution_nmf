close all
clear
clc
%            FUMI
%                  GP     BBGP  FW
%                                     PG    FISTA
%                                                  HYBRID FW-FISTA
%colorArr = { 'k' , 'b' , 'b' , 'b' , 'r' , 'r' , 'm' } ;
%            FUMI
%                  FW
%                       FISTA
%                             HYBRID
colorArr = { 'k' , 'b' , 'r' , 'm' } ;
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
        % ---------------------- %
        % plot the SAM histogram %
        % ---------------------- %
        
        load( 'LOG_FUMI_subprobVar_-3.mat'                                       , 'A_FUMI' , 'S_FUMI' ) ; SAM_FUMI_vs_px                                          = real(acos(sum((A_FUMI*S_FUMI).*Y)./sqrt( sum((A_FUMI*S_FUMI).^2).*sum(Y.^2) ))) / pi * 180 ;
        load( 'LOG_MFbA_gpExlnsrch_subprobIt_1.mat'                              , 'A_MF'   , 'S_MF'   ) ; SAM_MFbA_gpExlnsrch_subprobIt_1_vs_px                   = real(acos(sum((A_MF  *S_MF  ).*Y)./sqrt( sum((A_MF  *S_MF  ).^2).*sum(Y.^2) ))) / pi * 180 ;
        load( 'LOG_MFbA_BB_betaMax1_subprobIt_1.mat'                             , 'A_MF'   , 'S_MF'   ) ; SAM_MFbA_BB_betaMax1_subprobIt_1_vs_px                  = real(acos(sum((A_MF  *S_MF  ).*Y)./sqrt( sum((A_MF  *S_MF  ).^2).*sum(Y.^2) ))) / pi * 180 ;
        load( 'LOG_MFbA_FW_subprobIt_1.mat'                                      , 'A_MF'   , 'S_MF'   ) ; SAM_MFbA_FW_subprobIt_1_vs_px                           = real(acos(sum((A_MF  *S_MF  ).*Y)./sqrt( sum((A_MF  *S_MF  ).^2).*sum(Y.^2) ))) / pi * 180 ;
        load( 'LOG_MFbA_proxGrad_subprobIt_1.mat'                                , 'A_MF'   , 'S_MF'   ) ; SAM_MFbA_proxGrad_subprobIt_1_vs_px                     = real(acos(sum((A_MF  *S_MF  ).*Y)./sqrt( sum((A_MF  *S_MF  ).^2).*sum(Y.^2) ))) / pi * 180 ;
        load( 'LOG_MFbA_fista_subprobIt_1.mat'                                   , 'A_MF'   , 'S_MF'   ) ; SAM_MFbA_fista_subprobIt_1_vs_px                        = real(acos(sum((A_MF  *S_MF  ).*Y)./sqrt( sum((A_MF  *S_MF  ).^2).*sum(Y.^2) ))) / pi * 180 ;
        load( 'LOG_MFbA_HYBRID_S_FW1_A_PG1_subprobIt_1.mat' , 'A_MF'   , 'S_MF'   ) ; SAM_MFbA_HYBRID_S_FW1_A_PG1_subprobIt_1_vs_px = real(acos(sum((A_MF  *S_MF  ).*Y)./sqrt( sum((A_MF  *S_MF  ).^2).*sum(Y.^2) ))) / pi * 180 ;
        fid1 = figure ;
        fSz = 10 ;
        maxSAM = 6 ;
        %%{
        % -------- %
        % SAM plot %
        % -------- %
        hold on ;
        k = 0 ; handle = cell(7,1) ;
        k = k + 1 ; [N,edges] = histcounts( SAM_FUMI_vs_px                                          , round(MS_pixelNum/1000) ) ; handle{k} = plot( mean([edges(2:end);edges(1:end-1)]) , 10*log10(N) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([0,maxSAM]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        %k = k + 1 ; [N,edges] = histcounts( SAM_MFbA_gpExlnsrch_subprobIt_1_vs_px                   , round(MS_pixelNum/1000) ) ; handle{k} = plot( mean([edges(2:end);edges(1:end-1)]) , 10*log10(N) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([0,maxSAM]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        %k = k + 1 ; [N,edges] = histcounts( SAM_MFbA_BB_betaMax1_subprobIt_1_vs_px                  , round(MS_pixelNum/1000) ) ; handle{k} = plot( mean([edges(2:end);edges(1:end-1)]) , 10*log10(N) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([0,maxSAM]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        k = k + 1 ; [N,edges] = histcounts( SAM_MFbA_FW_subprobIt_1_vs_px                           , round(MS_pixelNum/1000) ) ; handle{k} = plot( mean([edges(2:end);edges(1:end-1)]) , 10*log10(N) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([0,maxSAM]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        %k = k + 1 ; [N,edges] = histcounts( SAM_MFbA_proxGrad_subprobIt_1_vs_px                     , round(MS_pixelNum/1000) ) ; handle{k} = plot( mean([edges(2:end);edges(1:end-1)]) , 10*log10(N) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([0,maxSAM]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        k = k + 1 ; [N,edges] = histcounts( SAM_MFbA_fista_subprobIt_1_vs_px                        , round(MS_pixelNum/1000) ) ; handle{k} = plot( mean([edges(2:end);edges(1:end-1)]) , 10*log10(N) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([0,maxSAM]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        k = k + 1 ; [N,edges] = histcounts( SAM_MFbA_HYBRID_S_FW1_A_PG1_subprobIt_1_vs_px , round(MS_pixelNum/1000) ) ; handle{k} = plot( mean([edges(2:end);edges(1:end-1)]) , 10*log10(N) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([0,maxSAM]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        h = ylabel( 'Number of Pixels'         ) ; set( h , 'FontSize' , fSz ) ;
        h = xlabel( 'SAM (deg)' ) ; set( h , 'FontSize' , fSz ) ;
        H = [] ; for k = 1 : length(handle) ; H = [ H , handle{k} ] ; end ; %#ok<AGROW>
        %h = legend( H      , ...
        %          { 'FUMI' , ...
        %            'GP'   , ...
        %            'BBGP' , ...
        %            'FW'   , ...
        %            'PG'   , ...
        %            'FISTA', ...
        %            'HYBRID'} , 'Location' , 'best' , 'Orientation' , 'horizontal' ) ; set( h , 'FontSize' , 10 ) ;
        h = legend( H       , ...
                  { 'FUMI'  , ...
                    'FW'    , ...
                    'FISTA' , ...
                    'HYBRID'} , 'Location' , 'best' , 'Orientation' , 'horizontal' ) ; set( h , 'FontSize' , 10 ) ;
        set( gca , 'FontSize' , fSz ) ;
        set( fid1 , 'Position' , [0,0,600,150] ) ;
        grid on ;
        drawnow ;
        %%}
        % ------- %
        % SAM Map %
        % ------- %
        colormapChoice = 'hot' ; % 'cool' ; % 'hsv' ; % 'jet' ;
        fid2 = figure ;
        
        SAM_MAP_FUMI   = min( reshape(SAM_FUMI_vs_px                               ,200,348)/maxSAM , 1 ) ;
        SAM_MAP_PG     = min( reshape(SAM_MFbA_proxGrad_subprobIt_1_vs_px          ,200,348)/maxSAM , 1 ) ;
        SAM_MAP_FISTA  = min( reshape(SAM_MFbA_fista_subprobIt_1_vs_px             ,200,348)/maxSAM , 1 ) ;
        SAM_MAP_GP     = min( reshape(SAM_MFbA_gpExlnsrch_subprobIt_1_vs_px        ,200,348)/maxSAM , 1 ) ;
        SAM_MAP_FW     = min( reshape(SAM_MFbA_FW_subprobIt_1_vs_px                ,200,348)/maxSAM , 1 ) ;
        SAM_MAP_HYBRID = min( reshape(SAM_MFbA_HYBRID_S_FW1_A_PG1_subprobIt_1_vs_px,200,348)/maxSAM , 1 ) ;
        
        % ~ FUMI ~ %
        Z = false(10,16) ; Z(1:5,1:8) = true ;
        subplot(10,16,find(Z')) ;
        p = pcolor( flipud(SAM_MAP_FUMI) ) ; set( p , 'EdgeColor' , 'none' ) ; axis equal ; axis off ; colormap( colormapChoice ) ; tt = text(10,180,1,'FUMI') ; tt.FontSize = 12 ; tt.Color = 'w' ;
        % ~ PG ~ %
        Z = false(10,16) ; Z(6:10,1:8) = true ;
        subplot(10,16,find(Z')) ;
        p = pcolor( flipud( SAM_MAP_PG ) ) ; set( p , 'EdgeColor' , 'none' ) ; axis equal ; axis off ; colormap( colormapChoice ) ; tt = text(10,180,1,'PG'  ) ; tt.FontSize = 12 ; tt.Color = 'w' ;
        % ~ GP ~ %
        Z = false(10,16) ; Z(1:5,9:16) = true ;
        subplot(10,16,find(Z')) ;
        p = pcolor( flipud( SAM_MAP_GP ) ) ; set( p , 'EdgeColor' , 'none' ) ; axis equal ; axis off ; colormap( colormapChoice ) ; tt = text(10,180,1,'GP'  ) ; tt.FontSize = 12 ; tt.Color = 'w' ;
        % ~ HYBRID ~ %
        Z = false(10,16) ; Z(6:10,9:16) = true ;
        subplot(10,16,find(Z')) ;
        p = pcolor( flipud( SAM_MAP_HYBRID ) ) ; set( p , 'EdgeColor' , 'none' ) ; axis equal ; axis off ; colormap( colormapChoice ) ; tt = text(10,180,1,'HYBRID FW-FISTA'  ) ; tt.FontSize = 12 ; tt.Color = 'w' ;
        c = colorbar( 'Position' , [ 0.92 , 0.1 , 0.02 , 0.85 ] ) ; % hard-coded
        set(c,'YTick',linspace(0,1,7),'YTickLabel',strsplit(num2str(0:6),' ')) ;
        set( fid2 , 'Position' , [0,0,600,350] ) ;
    cd ..
cd ..
%%{
%fileName1 = 'results_cuprite_SAM_vs_px' ;
%saveas(fid1,[fileName1,'.epsc2']) ;
%unix(['mv ',fileName1,'.epsc2 ',fileName1,'.eps']) ;
%fileName2 = 'results_cuprite_SAM_map' ;
%saveas(fid2,[fileName2,'.epsc2']) ;
%unix(['mv ',fileName2,'.epsc2 ',fileName2,'.eps']) ;

epsFileName = 'SAM_MAP_FUMI'   ; sFUMI   = imgray2pcolor( SAM_MAP_FUMI   , colormapChoice , 255 ) ; imwrite(sFUMI  ,[epsFileName,'.png']) ; pause(1) ; unix(['convert ',epsFileName,'.png ',epsFileName,'.eps']) ;
epsFileName = 'SAM_MAP_PG'     ; sPG     = imgray2pcolor( SAM_MAP_PG     , colormapChoice , 255 ) ; imwrite(sPG    ,[epsFileName,'.png']) ; pause(1) ; unix(['convert ',epsFileName,'.png ',epsFileName,'.eps']) ;
epsFileName = 'SAM_MAP_FISTA'  ; sFISTA  = imgray2pcolor( SAM_MAP_FISTA  , colormapChoice , 255 ) ; imwrite(sFISTA ,[epsFileName,'.png']) ; pause(1) ; unix(['convert ',epsFileName,'.png ',epsFileName,'.eps']) ;
epsFileName = 'SAM_MAP_GP'     ; sGP     = imgray2pcolor( SAM_MAP_GP     , colormapChoice , 255 ) ; imwrite(sGP    ,[epsFileName,'.png']) ; pause(1) ; unix(['convert ',epsFileName,'.png ',epsFileName,'.eps']) ;
epsFileName = 'SAM_MAP_FW'     ; sFW     = imgray2pcolor( SAM_MAP_FW     , colormapChoice , 255 ) ; imwrite(sFW    ,[epsFileName,'.png']) ; pause(1) ; unix(['convert ',epsFileName,'.png ',epsFileName,'.eps']) ;
epsFileName = 'SAM_MAP_HYBRID' ; sHYBRID = imgray2pcolor( SAM_MAP_HYBRID , colormapChoice , 255 ) ; imwrite(sHYBRID,[epsFileName,'.png']) ; pause(1) ; unix(['convert ',epsFileName,'.png ',epsFileName,'.eps']) ;
delete SAM_MAP_*.png
%%}