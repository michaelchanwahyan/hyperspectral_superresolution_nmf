close all
clear
clc
%            FUMI
%                  GP     BBGP  FW
%                                     PG    FISTA
%                                                  HYBRID FW-FISTA
colorArr = { 'b' , 'r' } ;
lnstyArr = { '-.' , '--' , '-.', '--', '-' , '-.', '--'} ;
lineWidthVal = 1 ;
cd SNR_40dB
    load HSI_chikusei2014_1000x1000
    HS_bandNum  = 128       ;
    MS_pixelNum = 1000 * 1000 ;
    wavelength = [363       368.15    373.31    378.47    383.62    388.78    393.94    399.10    404.25    409.41    ...
                  414.57    419.73    424.88    430.04    435.20    440.36    445.51    450.67    455.83    460.99    ...
                  466.14    471.30    476.46    481.62    486.77    491.93    497.09    502.25    507.40    512.56    ...
                  517.72    522.88    528.03    533.19    538.35    543.51    548.66    553.82    558.98    564.14    ...
                  569.29    574.45    579.61    584.77    589.92    595.08    600.24    605.40    610.55    615.71    ...
                  620.87    626.03    631.18    636.34    641.50    646.66    651.81    656.97    662.13    667.29    ...
                  672.44    677.60    682.76    687.92    693.07    698.23    703.39    708.55    713.70    718.86    ...
                  724.02    729.18    734.33    739.49    744.65    749.81    754.96    760.12    765.28    770.44    ...
                  775.59    780.75    785.91    791.07    796.22    801.38    806.54    811.70    816.85    822.01    ...
                  827.17    832.33    837.48    842.64    847.80    852.96    858.11    863.27    868.43    873.59    ...
                  878.74    883.90    889.06    894.22    899.37    904.53    909.69    914.85    920.00    925.16    ...
                  930.32    935.48    940.63    945.79    950.95    956.11    961.26    966.42    971.58    976.74    ...
                  981.89    987.05    992.21    997.37    1002.52   1007.68   1012.84   1018    ] ;
    Y   = reshape(permute(HSI,[3,1,2]),HS_bandNum,MS_pixelNum) ;
    D1  = max( Y , [] , 2 ).^2 ;
    cd trial0001
        % -------------------- %
        % plot the PSNR curves %
        % -------------------- %
        load( 'LOG_CNMF_subprobIt_100_convth_1em2' , 'A_CNMF' , 'S_CNMF' ) ;
        A_CNMF_times_S_CNMF = A_CNMF * S_CNMF ;
        D2 = mean( ( Y - A_CNMF_times_S_CNMF).^2 , 2 ) ; PSNR_CNMF_vs_band = 10 * log10( D1./D2 ) ;
        load( 'LOG_MFnAS_fista_subprobIt_1_convth_1em2.mat' , 'A_MF'   , 'S_MF'   ) ; D2 = mean( ( Y - A_MF  *S_MF   ).^2 , 2 ) ; PSNR_MFbA_fista_subprobIt_1_vs_band                        = 10 * log10( D1./D2 ) ;
        minPSNR = 28 ;
        maxPSNR = 55 ;
        fid = figure ; hold on ;
        k = 0 ; handle = cell(7,1) ;
        k = k + 1 ; handle{k} = semilogy( wavelength , PSNR_CNMF_vs_band                                          , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([400,950]) ; ylim([minPSNR,maxPSNR]) ;
        k = k + 1 ; handle{k} = semilogy( wavelength , PSNR_MFbA_fista_subprobIt_1_vs_band                        , [colorArr{k},lnstyArr{k}] , 'LineWidth' , lineWidthVal ) ; xlim([400,950]) ; ylim([minPSNR,maxPSNR]) ;
        h = ylabel( 'PSNR (dB)'         ) ; set( h , 'FontSize' , 12 ) ;
        h = xlabel( 'Wavelength (nm)' ) ; set( h , 'FontSize' , 12 ) ;
        H = [] ; for k = 1 : length(handle) ; H = [ H , handle{k} ] ; end ; %#ok<AGROW>
        h = legend( H      , ...
                  { 'CNMF' , ...
                    'FISTA' } , 'Location' , 'best' , 'Orientation' , 'horizontal' ) ; set( h , 'FontSize' , 10 ) ;
        set( gca , 'FontSize' , 12 ) ;
        set( fid , 'Position' , [0,0,900,300] ) ;
        grid on ;
        drawnow ;
        % ----------------------------------- %
        % plot the Multispectral bands region %
        % ----------------------------------- %
        w = wavelength( 18: 31) ; outside = plot( w , 52.5*ones(1,length(w)) , 'b-' , 'LineWidth' , 3 ) ; ylim([minPSNR,maxPSNR]) ; set(outside,'Clipping','off') ;
        w = wavelength( 32: 46) ; outside = plot( w , 52.5*ones(1,length(w)) , 'b-' , 'LineWidth' , 3 ) ; ylim([minPSNR,maxPSNR]) ; set(outside,'Clipping','off') ;
        w = wavelength( 53: 64) ; outside = plot( w , 52.5*ones(1,length(w)) , 'b-' , 'LineWidth' , 3 ) ; ylim([minPSNR,maxPSNR]) ; set(outside,'Clipping','off') ;
        w = wavelength( 78:105) ; outside = plot( w , 52.5*ones(1,length(w)) , 'b-' , 'LineWidth' , 3 ) ; ylim([minPSNR,maxPSNR]) ; set(outside,'Clipping','off') ;
        text(450,53,'Multispectral bands'   , ...
             'VerticalAlignment'  ,'bottom' , ...
             'HorizontalAlignment','left'   , ...
             'FontSize'           ,10       ) ;
    cd ..
cd ..
fileName = 'results_chikusei_PSNR_vs_wavelength' ;
saveas(fid,[fileName,'.epsc2']) ;
unix(['mv ',fileName,'.epsc2 ',fileName,'.eps']) ;
