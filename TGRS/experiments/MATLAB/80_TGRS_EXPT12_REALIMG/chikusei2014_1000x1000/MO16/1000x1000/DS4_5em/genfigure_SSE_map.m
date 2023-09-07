close all
%clear
clc
%            DRFUMI , CNMF , HySure , HAGO-FPG , HAGO-FPG-FW
cd SNR_40dB
    if( ~exist( 'HSI' , 'var' ) )
    load HSI_chikusei2014_1000x1000
    end
    HS_bandNum  = 128       ;
    MS_pixelNum = 1000 * 1000 ;
    Y   = reshape(permute(HSI,[3,1,2]),HS_bandNum,MS_pixelNum) ;
    cd trial0001
        fprintf( 'DRFUMI\n'      ) ; load( 'LOG_DRFUMI'                      , 'A_DRFUMI' , 'S_DRFUMI' ) ; HSI_DRFUMI       = reshape( S_DRFUMI'*A_DRFUMI' , 1000 , 1000 , 128 ) ;
        fprintf( 'CNMF\n'        ) ; load( 'LOG_CNMF.mat'                    , 'A_CNMF'   , 'S_CNMF'   ) ; HSI_CNMF         = reshape( S_CNMF'  *A_CNMF'   , 1000 , 1000 , 128 ) ;
        fprintf( 'HySure\n'      ) ; load( 'LOG_HySure.mat'                  ,'A_HySure'  , 'S_HySure' ) ; HSI_HySure       = reshape( S_HySure'*A_HySure' , 1000 , 1000 , 128 ) ;
        fprintf( 'ExFPG\n'       ) ; load( 'LOG_MFbA_ExFISTA.mat'            , 'A_MF'     , 'S_MF'     ) ; HSI_MFbA_ExFISTA = reshape( S_MF'    *A_MF'     , 1000 , 1000 , 128 ) ;
        fprintf( 'HAGO-FPG\n'    ) ; load( 'LOG_MFbA_FISTA.mat'              , 'A_MF'     , 'S_MF'     ) ; HSI_MFbA_FISTA   = reshape( S_MF'    *A_MF'     , 1000 , 1000 , 128 ) ;
        fprintf( 'HAGO-FPG-FW\n' ) ; load( 'LOG_MFbA_HYBRID_SFW_AFISTA.mat'  , 'A_MF'     , 'S_MF'     ) ; HSI_MFbA_HYBRID  = reshape( S_MF'    *A_MF'     , 1000 , 1000 , 128 ) ;
    cd ..
cd ..
% ----------------- %
% Sum Squared Error %
% ----------------- %
colormapChoice = 'jet' ;%'hot' ; % 'cool' ; % 'hsv' ; % 'jet' ;
fid2 = figure ;
IMG_DRFUMI_SSE      = 10*log10( sum( ( HSI_DRFUMI      - HSI ).^2 , 3 ) ) ;
IMG_CNMF_SSE        = 10*log10( sum( ( HSI_CNMF        - HSI ).^2 , 3 ) ) ;
IMG_MFbA_FISTA_SSE  = 10*log10( sum( ( HSI_MFbA_FISTA  - HSI ).^2 , 3 ) ) ;
IMG_MFbA_HYBRID_SSE = 10*log10( sum( ( HSI_MFbA_HYBRID - HSI ).^2 , 3 ) ) ;
IMG_HySure_SSE      = 10*log10( sum( ( HSI_HySure      - HSI ).^2 , 3 ) ) ;

IMGmax = 5.5 ;
IMGmin = -45 ;
%IMGmax = max(IMG(:)) ;
%IMGmin = min(IMG(:)) ;

IM_DRFUMI_SSE       = imgray2pcolor( ( IMG_DRFUMI_SSE      -IMGmin)/(IMGmax-IMGmin) , colormapChoice , 255 ) ;
IM_CNMF_SSE         = imgray2pcolor( ( IMG_CNMF_SSE        -IMGmin)/(IMGmax-IMGmin) , colormapChoice , 255 ) ;
IM_HySure_SSE       = imgray2pcolor( ( IMG_HySure_SSE      -IMGmin)/(IMGmax-IMGmin) , colormapChoice , 255 ) ;
IM_MFbA_FISTA_SSE   = imgray2pcolor( ( IMG_MFbA_FISTA_SSE  -IMGmin)/(IMGmax-IMGmin) , colormapChoice , 255 ) ;
IM_MFbA_HYBRID_SSE  = imgray2pcolor( ( IMG_MFbA_HYBRID_SSE -IMGmin)/(IMGmax-IMGmin) , colormapChoice , 255 ) ;

figure ; imshow( IM_DRFUMI_SSE      ) ; title( sprintf( 'DRFUMI' ) ) ; pause(0.2) ;
figure ; imshow( IM_CNMF_SSE        ) ; title( sprintf( 'CNMF' ) ) ; pause(0.2) ;
figure ; imshow( IM_HySure_SSE      ) ; title( sprintf( 'HySure' ) ) ; pause(0.2) ;
figure ; imshow( IM_MFbA_FISTA_SSE  ) ; title( sprintf( 'FISTA' ) ) ; pause(0.2) ;
figure ; imshow( IM_MFbA_HYBRID_SSE ) ; title( sprintf( 'HYBRID' ) ) ; pause(0.2) ;
imwrite( IM_DRFUMI_SSE      , 'IM_DRFUMI_SSE.png'      ) ;
imwrite( IM_CNMF_SSE        , 'IM_CNMF_SSE.png'        ) ;
imwrite( IM_HySure_SSE      , 'IM_HySure_SSE.png'      ) ;
imwrite( IM_MFbA_FISTA_SSE  , 'IM_MFbA_FISTA_SSE.png'  ) ;
imwrite( IM_MFbA_HYBRID_SSE , 'IM_MFbA_HYBRID_SSE.png' ) ;
%end

figure ; p = pcolor( IMG_FUMI_SSE ) ;
colormap( colormapChoice ) ;
axis equal ;
set( p , 'EdgeColor' , 'none' ) ;
c = colorbar('horizontal') ;
set( c , 'XTick' , IMGmin:5:IMGmax ) ;
set( c , 'XTickLabel' , {'0','0.2','0.4','0.6','0.8','1'} ) ;
