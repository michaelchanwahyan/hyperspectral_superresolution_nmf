close all
clear
clc
%            FUMI
%                  GP     BBGP  FW
%                                     PG    FISTA
%                                                  HYBRID FW-FISTA
colorArr = { 'b' , 'r' } ;
lnstyArr = { '-.' , '--' } ;
%colorArr = { 'k' , 'b' , 'b' , 'b' , 'r' , 'r' , 'm' } ;
%mkstyArr = { '^' , 'o' , '^' , 'x' , '^' , '^' , '+' } ;
%lnstyArr = { '-' , '-' , '-.', '--', '-' , '-.', '--'} ;
lineWidthVal = 1 ;
cd SNR_40dB
    load HSI_chikusei2014_1000x1000
    HS_bandNum  = 128       ;
    MS_pixelNum = 1000 * 1000 ;
    Y   = reshape(permute(HSI,[3,1,2]),HS_bandNum,MS_pixelNum) ;
    cd trial0001
        % ---------------------- %
        % plot the SAM histogram %
        % ---------------------- %
        load( 'LOG_FUMI_subprobVar_-2' , 'A_FUMI' , 'S_FUMI' ) ;
        HSI_FUMI = cat( 1 , cat( 2 , reshape(( A_FUMI{ 1,1}*S_FUMI{ 1,1} )',100,100,128) , reshape(( A_FUMI{ 1,2}*S_FUMI{ 1,2} )',100,100,128) , reshape(( A_FUMI{ 1,3}*S_FUMI{ 1,3} )',100,100,128) , reshape(( A_FUMI{ 1,4}*S_FUMI{ 1,4} )',100,100,128) , reshape(( A_FUMI{ 1,5}*S_FUMI{ 1,5} )',100,100,128) , reshape(( A_FUMI{ 1,6}*S_FUMI{ 1,6} )',100,100,128) , reshape(( A_FUMI{ 1,7}*S_FUMI{ 1,7} )',100,100,128) , reshape(( A_FUMI{ 1,8}*S_FUMI{ 1,8} )',100,100,128) , reshape(( A_FUMI{ 1,9}*S_FUMI{ 1,9} )',100,100,128) , reshape(( A_FUMI{ 1,10}*S_FUMI{ 1,10} )',100,100,128)  ) , ...
                            cat( 2 , reshape(( A_FUMI{ 2,1}*S_FUMI{ 2,1} )',100,100,128) , reshape(( A_FUMI{ 2,2}*S_FUMI{ 2,2} )',100,100,128) , reshape(( A_FUMI{ 2,3}*S_FUMI{ 2,3} )',100,100,128) , reshape(( A_FUMI{ 2,4}*S_FUMI{ 2,4} )',100,100,128) , reshape(( A_FUMI{ 2,5}*S_FUMI{ 2,5} )',100,100,128) , reshape(( A_FUMI{ 2,6}*S_FUMI{ 2,6} )',100,100,128) , reshape(( A_FUMI{ 2,7}*S_FUMI{ 2,7} )',100,100,128) , reshape(( A_FUMI{ 2,8}*S_FUMI{ 2,8} )',100,100,128) , reshape(( A_FUMI{ 2,9}*S_FUMI{ 2,9} )',100,100,128) , reshape(( A_FUMI{ 2,10}*S_FUMI{ 2,10} )',100,100,128)  ) , ...
                            cat( 2 , reshape(( A_FUMI{ 3,1}*S_FUMI{ 3,1} )',100,100,128) , reshape(( A_FUMI{ 3,2}*S_FUMI{ 3,2} )',100,100,128) , reshape(( A_FUMI{ 3,3}*S_FUMI{ 3,3} )',100,100,128) , reshape(( A_FUMI{ 3,4}*S_FUMI{ 3,4} )',100,100,128) , reshape(( A_FUMI{ 3,5}*S_FUMI{ 3,5} )',100,100,128) , reshape(( A_FUMI{ 3,6}*S_FUMI{ 3,6} )',100,100,128) , reshape(( A_FUMI{ 3,7}*S_FUMI{ 3,7} )',100,100,128) , reshape(( A_FUMI{ 3,8}*S_FUMI{ 3,8} )',100,100,128) , reshape(( A_FUMI{ 3,9}*S_FUMI{ 3,9} )',100,100,128) , reshape(( A_FUMI{ 3,10}*S_FUMI{ 3,10} )',100,100,128)  ) , ...
                            cat( 2 , reshape(( A_FUMI{ 4,1}*S_FUMI{ 4,1} )',100,100,128) , reshape(( A_FUMI{ 4,2}*S_FUMI{ 4,2} )',100,100,128) , reshape(( A_FUMI{ 4,3}*S_FUMI{ 4,3} )',100,100,128) , reshape(( A_FUMI{ 4,4}*S_FUMI{ 4,4} )',100,100,128) , reshape(( A_FUMI{ 4,5}*S_FUMI{ 4,5} )',100,100,128) , reshape(( A_FUMI{ 4,6}*S_FUMI{ 4,6} )',100,100,128) , reshape(( A_FUMI{ 4,7}*S_FUMI{ 4,7} )',100,100,128) , reshape(( A_FUMI{ 4,8}*S_FUMI{ 4,8} )',100,100,128) , reshape(( A_FUMI{ 4,9}*S_FUMI{ 4,9} )',100,100,128) , reshape(( A_FUMI{ 4,10}*S_FUMI{ 4,10} )',100,100,128)  ) , ...
                            cat( 2 , reshape(( A_FUMI{ 5,1}*S_FUMI{ 5,1} )',100,100,128) , reshape(( A_FUMI{ 5,2}*S_FUMI{ 5,2} )',100,100,128) , reshape(( A_FUMI{ 5,3}*S_FUMI{ 5,3} )',100,100,128) , reshape(( A_FUMI{ 5,4}*S_FUMI{ 5,4} )',100,100,128) , reshape(( A_FUMI{ 5,5}*S_FUMI{ 5,5} )',100,100,128) , reshape(( A_FUMI{ 5,6}*S_FUMI{ 5,6} )',100,100,128) , reshape(( A_FUMI{ 5,7}*S_FUMI{ 5,7} )',100,100,128) , reshape(( A_FUMI{ 5,8}*S_FUMI{ 5,8} )',100,100,128) , reshape(( A_FUMI{ 5,9}*S_FUMI{ 5,9} )',100,100,128) , reshape(( A_FUMI{ 5,10}*S_FUMI{ 5,10} )',100,100,128)  ) , ...
                            cat( 2 , reshape(( A_FUMI{ 6,1}*S_FUMI{ 6,1} )',100,100,128) , reshape(( A_FUMI{ 6,2}*S_FUMI{ 6,2} )',100,100,128) , reshape(( A_FUMI{ 6,3}*S_FUMI{ 6,3} )',100,100,128) , reshape(( A_FUMI{ 6,4}*S_FUMI{ 6,4} )',100,100,128) , reshape(( A_FUMI{ 6,5}*S_FUMI{ 6,5} )',100,100,128) , reshape(( A_FUMI{ 6,6}*S_FUMI{ 6,6} )',100,100,128) , reshape(( A_FUMI{ 6,7}*S_FUMI{ 6,7} )',100,100,128) , reshape(( A_FUMI{ 6,8}*S_FUMI{ 6,8} )',100,100,128) , reshape(( A_FUMI{ 6,9}*S_FUMI{ 6,9} )',100,100,128) , reshape(( A_FUMI{ 6,10}*S_FUMI{ 6,10} )',100,100,128)  ) , ...
                            cat( 2 , reshape(( A_FUMI{ 7,1}*S_FUMI{ 7,1} )',100,100,128) , reshape(( A_FUMI{ 7,2}*S_FUMI{ 7,2} )',100,100,128) , reshape(( A_FUMI{ 7,3}*S_FUMI{ 7,3} )',100,100,128) , reshape(( A_FUMI{ 7,4}*S_FUMI{ 7,4} )',100,100,128) , reshape(( A_FUMI{ 7,5}*S_FUMI{ 7,5} )',100,100,128) , reshape(( A_FUMI{ 7,6}*S_FUMI{ 7,6} )',100,100,128) , reshape(( A_FUMI{ 7,7}*S_FUMI{ 7,7} )',100,100,128) , reshape(( A_FUMI{ 7,8}*S_FUMI{ 7,8} )',100,100,128) , reshape(( A_FUMI{ 7,9}*S_FUMI{ 7,9} )',100,100,128) , reshape(( A_FUMI{ 7,10}*S_FUMI{ 7,10} )',100,100,128)  ) , ...
                            cat( 2 , reshape(( A_FUMI{ 8,1}*S_FUMI{ 8,1} )',100,100,128) , reshape(( A_FUMI{ 8,2}*S_FUMI{ 8,2} )',100,100,128) , reshape(( A_FUMI{ 8,3}*S_FUMI{ 8,3} )',100,100,128) , reshape(( A_FUMI{ 8,4}*S_FUMI{ 8,4} )',100,100,128) , reshape(( A_FUMI{ 8,5}*S_FUMI{ 8,5} )',100,100,128) , reshape(( A_FUMI{ 8,6}*S_FUMI{ 8,6} )',100,100,128) , reshape(( A_FUMI{ 8,7}*S_FUMI{ 8,7} )',100,100,128) , reshape(( A_FUMI{ 8,8}*S_FUMI{ 8,8} )',100,100,128) , reshape(( A_FUMI{ 8,9}*S_FUMI{ 8,9} )',100,100,128) , reshape(( A_FUMI{ 8,10}*S_FUMI{ 8,10} )',100,100,128)  ) , ...
                            cat( 2 , reshape(( A_FUMI{ 9,1}*S_FUMI{ 9,1} )',100,100,128) , reshape(( A_FUMI{ 9,2}*S_FUMI{ 9,2} )',100,100,128) , reshape(( A_FUMI{ 9,3}*S_FUMI{ 9,3} )',100,100,128) , reshape(( A_FUMI{ 9,4}*S_FUMI{ 9,4} )',100,100,128) , reshape(( A_FUMI{ 9,5}*S_FUMI{ 9,5} )',100,100,128) , reshape(( A_FUMI{ 9,6}*S_FUMI{ 9,6} )',100,100,128) , reshape(( A_FUMI{ 9,7}*S_FUMI{ 9,7} )',100,100,128) , reshape(( A_FUMI{ 9,8}*S_FUMI{ 9,8} )',100,100,128) , reshape(( A_FUMI{ 9,9}*S_FUMI{ 9,9} )',100,100,128) , reshape(( A_FUMI{ 9,10}*S_FUMI{ 9,10} )',100,100,128)  ) , ...
                            cat( 2 , reshape(( A_FUMI{10,1}*S_FUMI{10,1} )',100,100,128) , reshape(( A_FUMI{10,2}*S_FUMI{10,2} )',100,100,128) , reshape(( A_FUMI{10,3}*S_FUMI{10,3} )',100,100,128) , reshape(( A_FUMI{10,4}*S_FUMI{10,4} )',100,100,128) , reshape(( A_FUMI{10,5}*S_FUMI{10,5} )',100,100,128) , reshape(( A_FUMI{10,6}*S_FUMI{10,6} )',100,100,128) , reshape(( A_FUMI{10,7}*S_FUMI{10,7} )',100,100,128) , reshape(( A_FUMI{10,8}*S_FUMI{10,8} )',100,100,128) , reshape(( A_FUMI{10,9}*S_FUMI{10,9} )',100,100,128) , reshape(( A_FUMI{10,10}*S_FUMI{10,10} )',100,100,128)  ) ) ;
        A_FUMI_times_S_FUMI = reshape( permute(HSI_FUMI,[3,1,2]) , 128 , [] ) ;
        load( 'LOG_FUMI_subprobVar_-2.mat'                  , 'A_FUMI' , 'S_FUMI' ) ; SAM_FUMI_vs_px                                = real(acos(sum(A_FUMI_times_S_FUMI.*Y)./sqrt( sum(A_FUMI_times_S_FUMI.^2).*sum(Y.^2) ))) / pi * 180 ;
        load( 'LOG_MFbA_gpExlnsrch_subprobIt_1.mat'         , 'A_MF'   , 'S_MF'   ) ; SAM_MFbA_gpExlnsrch_subprobIt_1_vs_px         = real(acos(sum((A_MF  *S_MF  ).*Y)./sqrt( sum((A_MF  *S_MF  ).^2).*sum(Y.^2) ))) / pi * 180 ;
        load( 'LOG_MFbA_BB_betaMax1_subprobIt_1.mat'        , 'A_MF'   , 'S_MF'   ) ; SAM_MFbA_BB_betaMax1_subprobIt_1_vs_px        = real(acos(sum((A_MF  *S_MF  ).*Y)./sqrt( sum((A_MF  *S_MF  ).^2).*sum(Y.^2) ))) / pi * 180 ;
        load( 'LOG_MFbA_FW_subprobIt_1.mat'                 , 'A_MF'   , 'S_MF'   ) ; SAM_MFbA_FW_subprobIt_1_vs_px                 = real(acos(sum((A_MF  *S_MF  ).*Y)./sqrt( sum((A_MF  *S_MF  ).^2).*sum(Y.^2) ))) / pi * 180 ;
        load( 'LOG_MFbA_proxGrad_subprobIt_1.mat'           , 'A_MF'   , 'S_MF'   ) ; SAM_MFbA_proxGrad_subprobIt_1_vs_px           = real(acos(sum((A_MF  *S_MF  ).*Y)./sqrt( sum((A_MF  *S_MF  ).^2).*sum(Y.^2) ))) / pi * 180 ;
        load( 'LOG_MFbA_fista_subprobIt_1.mat'              , 'A_MF'   , 'S_MF'   ) ; SAM_MFbA_fista_subprobIt_1_vs_px              = real(acos(sum((A_MF  *S_MF  ).*Y)./sqrt( sum((A_MF  *S_MF  ).^2).*sum(Y.^2) ))) / pi * 180 ;
        load( 'LOG_MFbA_HYBRID_S_FW1_A_PG1_subprobIt_1.mat' , 'A_MF'   , 'S_MF'   ) ; SAM_MFbA_HYBRID_S_FW1_A_PG1_subprobIt_1_vs_px = real(acos(sum((A_MF  *S_MF  ).*Y)./sqrt( sum((A_MF  *S_MF  ).^2).*sum(Y.^2) ))) / pi * 180 ;
        fid1 = figure ;
        fSz = 10 ;
        % -------- %
        % SAM plot %
        % -------- %
        hold on ;
        k = 0 ; handle = cell(7,1) ;
        maxSAM = 6 ;
        k = k + 1 ; [N,edges] = histcounts( SAM_FUMI_vs_px                                , round(MS_pixelNum/1000) ) ; handle{k} = plot( mean([edges(2:end);edges(1:end-1)]) , 10*log10(N) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([0,maxSAM]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        %k = k + 1 ; [N,edges] = histcounts( SAM_MFbA_gpExlnsrch_subprobIt_1_vs_px         , round(MS_pixelNum/1000) ) ; handle{k} = plot( mean([edges(2:end);edges(1:end-1)]) , 10*log10(N) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([0,maxSAM]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        %k = k + 1 ; [N,edges] = histcounts( SAM_MFbA_BB_betaMax1_subprobIt_1_vs_px        , round(MS_pixelNum/1000) ) ; handle{k} = plot( mean([edges(2:end);edges(1:end-1)]) , 10*log10(N) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([0,maxSAM]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        %k = k + 1 ; [N,edges] = histcounts( SAM_MFbA_FW_subprobIt_1_vs_px                 , round(MS_pixelNum/1000) ) ; handle{k} = plot( mean([edges(2:end);edges(1:end-1)]) , 10*log10(N) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([0,maxSAM]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        %k = k + 1 ; [N,edges] = histcounts( SAM_MFbA_proxGrad_subprobIt_1_vs_px           , round(MS_pixelNum/1000) ) ; handle{k} = plot( mean([edges(2:end);edges(1:end-1)]) , 10*log10(N) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([0,maxSAM]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        k = k + 1 ; [N,edges] = histcounts( SAM_MFbA_fista_subprobIt_1_vs_px              , round(MS_pixelNum/1000) ) ; handle{k} = plot( mean([edges(2:end);edges(1:end-1)]) , 10*log10(N) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([0,maxSAM]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        %k = k + 1 ; [N,edges] = histcounts( SAM_MFbA_HYBRID_S_FW1_A_PG1_subprobIt_1_vs_px , round(MS_pixelNum/1000) ) ; handle{k} = plot( mean([edges(2:end);edges(1:end-1)]) , 10*log10(N) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([0,maxSAM]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
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
        h = legend( H , 'FUMI' , 'FISTA' , 'Location' , 'best' , 'Orientation' , 'horizontal' ) ; set( h , 'FontSize' , 10 ) ;
        set( gca , 'FontSize' , fSz ) ;
        set( fid1 , 'Position' , [0,0,600,150] ) ;
        grid on ;
        drawnow ;
        % ------- %
        % SAM Map %
        % ------- %
        colormapChoice = 'hot' ; % 'cool' ; % 'hsv' ; % 'jet' ;
        fid2 = figure ;
        
        SAM_MAP_FUMI   = min( reshape(SAM_FUMI_vs_px                               ,1000,1000)/maxSAM , 1 ) ;
        SAM_MAP_PG     = min( reshape(SAM_MFbA_proxGrad_subprobIt_1_vs_px          ,1000,1000)/maxSAM , 1 ) ;
        SAM_MAP_FISTA  = min( reshape(SAM_MFbA_fista_subprobIt_1_vs_px             ,1000,1000)/maxSAM , 1 ) ;
        SAM_MAP_GP     = min( reshape(SAM_MFbA_gpExlnsrch_subprobIt_1_vs_px        ,1000,1000)/maxSAM , 1 ) ;
        SAM_MAP_FW     = min( reshape(SAM_MFbA_FW_subprobIt_1_vs_px                ,1000,1000)/maxSAM , 1 ) ;
        SAM_MAP_HYBRID = min( reshape(SAM_MFbA_HYBRID_S_FW1_A_PG1_subprobIt_1_vs_px,1000,1000)/maxSAM , 1 ) ;
        
        % ~ FUMI ~ %
        subplot(2,2,1) ;
        p = pcolor( flipud(SAM_MAP_FUMI) ) ; set( p , 'EdgeColor' , 'none' ) ; axis equal ; axis off ; colormap( colormapChoice ) ; tt = text(10,180,1,'FUMI') ; tt.FontSize = 12 ; tt.Color = 'w' ;
        % ~ PG ~ %
        subplot(2,2,3) ;
        p = pcolor( flipud( SAM_MAP_PG ) ) ; set( p , 'EdgeColor' , 'none' ) ; axis equal ; axis off ; colormap( colormapChoice ) ; tt = text(10,180,1,'PG'  ) ; tt.FontSize = 12 ; tt.Color = 'w' ;
        % ~ GP ~ %
        subplot(2,2,2) ;
        p = pcolor( flipud( SAM_MAP_GP ) ) ; set( p , 'EdgeColor' , 'none' ) ; axis equal ; axis off ; colormap( colormapChoice ) ; tt = text(10,180,1,'GP'  ) ; tt.FontSize = 12 ; tt.Color = 'w' ;
        % ~ HYBRID ~ %
        subplot(2,2,4) ;
        p = pcolor( flipud( SAM_MAP_HYBRID ) ) ; set( p , 'EdgeColor' , 'none' ) ; axis equal ; axis off ; colormap( colormapChoice ) ; tt = text(10,180,1,'HYBRID FW-FISTA'  ) ; tt.FontSize = 12 ; tt.Color = 'w' ;
        c = colorbar( 'Position' , [ 0.92 , 0.1 , 0.02 , 0.85 ] ) ; % hard-coded
        set(c,'YTick',linspace(0,1,maxSAM+1),'YTickLabel',strsplit(num2str(0:maxSAM),' ')) ;
        set( fid2 , 'Position' , [0,0,700,500] ) ;
    cd ..
cd ..
%%{
fileName1 = 'results_chikusei_SAM_vs_px' ;
saveas(fid1,[fileName1,'.epsc2']) ;
unix(['mv ',fileName1,'.epsc2 ',fileName1,'.eps']) ;
%fileName2 = 'results_chikusei_SAM_map' ;
%saveas(fid2,[fileName2,'.epsc2']) ;
%unix(['mv ',fileName2,'.epsc2 ',fileName2,'.eps']) ;

epsFileName = 'SAM_MAP_FUMI'   ; sFUMI   = imgray2pcolor( SAM_MAP_FUMI   , colormapChoice , 255 ) ; imwrite(sFUMI  ,[epsFileName,'.png']) ; pause(1) ; unix(['convert ',epsFileName,'.png ',epsFileName,'.eps']) ;
epsFileName = 'SAM_MAP_PG'     ; sPG     = imgray2pcolor( SAM_MAP_PG     , colormapChoice , 255 ) ; imwrite(sPG    ,[epsFileName,'.png']) ; pause(1) ; unix(['convert ',epsFileName,'.png ',epsFileName,'.eps']) ;
epsFileName = 'SAM_MAP_FISTA'  ; sFISTA  = imgray2pcolor( SAM_MAP_FISTA  , colormapChoice , 255 ) ; imwrite(sFISTA ,[epsFileName,'.png']) ; pause(1) ; unix(['convert ',epsFileName,'.png ',epsFileName,'.eps']) ;
epsFileName = 'SAM_MAP_GP'     ; sGP     = imgray2pcolor( SAM_MAP_GP     , colormapChoice , 255 ) ; imwrite(sGP    ,[epsFileName,'.png']) ; pause(1) ; unix(['convert ',epsFileName,'.png ',epsFileName,'.eps']) ;
epsFileName = 'SAM_MAP_FW'     ; sFW     = imgray2pcolor( SAM_MAP_FW     , colormapChoice , 255 ) ; imwrite(sFW    ,[epsFileName,'.png']) ; pause(1) ; unix(['convert ',epsFileName,'.png ',epsFileName,'.eps']) ;
epsFileName = 'SAM_MAP_HYBRID' ; sHYBRID = imgray2pcolor( SAM_MAP_HYBRID , colormapChoice , 255 ) ; imwrite(sHYBRID,[epsFileName,'.png']) ; pause(1) ; unix(['convert ',epsFileName,'.png ',epsFileName,'.eps']) ;
delete SAM_MAP*.png
%%}
