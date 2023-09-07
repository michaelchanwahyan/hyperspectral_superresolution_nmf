close all
clear
clc
%            FUMI
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
        % ---------------------- %
        % plot the SAM histogram %
        % ---------------------- %
        load( 'LOG_CNMF_subprobIt_100_convth_1em2.mat'                  , 'A_CNMF' , 'S_CNMF' ) ;
        A_CNMF_times_S_CNMF = A_CNMF * S_CNMF ;
        SAM_CNMF_vs_px = real(acos(sum(A_CNMF_times_S_CNMF.*Y)./sqrt( sum(A_CNMF_times_S_CNMF.^2).*sum(Y.^2) ))) / pi * 180 ;
        load( 'LOG_MFnAS_fista_subprobIt_1_convth_1em2.mat'              , 'A_MF'   , 'S_MF'   ) ; SAM_MFnAS_fista_subprobIt_1_vs_px              = real(acos(sum((A_MF  *S_MF  ).*Y)./sqrt( sum((A_MF  *S_MF  ).^2).*sum(Y.^2) ))) / pi * 180 ;
        fid1 = figure ;
        fSz = 10 ;
        % -------- %
        % SAM plot %
        % -------- %
        hold on ;
        k = 0 ; handle = cell(7,1) ;
        maxSAM = 6 ;
        k = k + 1 ; [N,edges] = histcounts( SAM_CNMF_vs_px                                , round(MS_pixelNum/1000) ) ; handle{k} = plot( mean([edges(2:end);edges(1:end-1)]) , 10*log10(N) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([0,maxSAM]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        k = k + 1 ; [N,edges] = histcounts( SAM_MFnAS_fista_subprobIt_1_vs_px              , round(MS_pixelNum/1000) ) ; handle{k} = plot( mean([edges(2:end);edges(1:end-1)]) , 10*log10(N) , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([0,maxSAM]) ; yticks([0,10,20,30,40]) ; yticklabels({'10^0','10^1','10^2','10^3','10^4'}) ;
        h = ylabel( 'Number of Pixels'         ) ; set( h , 'FontSize' , fSz ) ;
        h = xlabel( 'SAM (deg)' ) ; set( h , 'FontSize' , fSz ) ;
        H = [] ; for k = 1 : length(handle) ; H = [ H , handle{k} ] ; end ; %#ok<AGROW>
        h = legend( H , 'CNMF' , 'FISTA' , 'Location' , 'best' , 'Orientation' , 'horizontal' ) ; set( h , 'FontSize' , 10 ) ;
        set( gca , 'FontSize' , fSz ) ;
        set( fid1 , 'Position' , [0,0,600,150] ) ;
        grid on ;
        drawnow ;
        % ------- %
        % SAM Map %
        % ------- %
        colormapChoice = 'hot' ; % 'cool' ; % 'hsv' ; % 'jet' ;
        fid2 = figure ;
        
        SAM_MAP_CNMF   = min( reshape(SAM_CNMF_vs_px                               ,1000,1000)/maxSAM , 1 ) ;
        SAM_MAP_FISTA  = min( reshape(SAM_MFnAS_fista_subprobIt_1_vs_px             ,1000,1000)/maxSAM , 1 ) ;
        
        % ~ CNMF ~ %
        subplot(1,2,1) ;
        p = pcolor( flipud(SAM_MAP_CNMF) ) ; set( p , 'EdgeColor' , 'none' ) ; axis equal ; axis off ; colormap( colormapChoice ) ; tt = text(10,180,1,'CNMF') ; tt.FontSize = 12 ; tt.Color = 'w' ;
        % ~ FISTA ~ %
        subplot(1,2,2) ;
        p = pcolor( flipud( SAM_MAP_FISTA ) ) ; set( p , 'EdgeColor' , 'none' ) ; axis equal ; axis off ; colormap( colormapChoice ) ; tt = text(10,180,1,'PG'  ) ; tt.FontSize = 12 ; tt.Color = 'w' ;
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

epsFileName = 'SAM_MAP_CNMF'   ; sCNMF   = imgray2pcolor( SAM_MAP_CNMF   , colormapChoice , 255 ) ; imwrite(sCNMF  ,[epsFileName,'.png']) ; pause(1) ; unix(['convert ',epsFileName,'.png ',epsFileName,'.eps']) ;
epsFileName = 'SAM_MAP_FISTA'  ; sFISTA  = imgray2pcolor( SAM_MAP_FISTA  , colormapChoice , 255 ) ; imwrite(sFISTA ,[epsFileName,'.png']) ; pause(1) ; unix(['convert ',epsFileName,'.png ',epsFileName,'.eps']) ;
delete SAM_MAP*.png
%%}
