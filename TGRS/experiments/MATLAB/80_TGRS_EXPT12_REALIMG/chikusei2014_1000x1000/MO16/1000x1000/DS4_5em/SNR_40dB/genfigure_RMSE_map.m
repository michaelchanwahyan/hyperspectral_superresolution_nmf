close all
clear
clc
%            DRFUMI , CNMF , HySure , HAGO-FPG , HAGO-FPG-FW
cd SNR_40dB
    load HSI_chikusei2014_1000x1000
    HS_bandNum  = 128       ;
    MS_pixelNum = 1000 * 1000 ;
    Y   = reshape(permute(HSI,[3,1,2]),HS_bandNum,MS_pixelNum) ;
    cd trial0020
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
IMG_DRFUMI_RMSE       = 10*log10( sqrt( mean( ( HSI_DRFUMI       - HSI ).^2 , 3 ) ) ) ;
IMG_CNMF_RMSE         = 10*log10( sqrt( mean( ( HSI_CNMF         - HSI ).^2 , 3 ) ) ) ;
IMG_HySure_RMSE       = 10*log10( sqrt( mean( ( HSI_HySure       - HSI ).^2 , 3 ) ) ) ;
IMG_MFbA_ExFISTA_RMSE = 10*log10( sqrt( mean( ( HSI_MFbA_ExFISTA - HSI ).^2 , 3 ) ) ) ;
IMG_MFbA_FISTA_RMSE   = 10*log10( sqrt( mean( ( HSI_MFbA_FISTA   - HSI ).^2 , 3 ) ) ) ;
IMG_MFbA_HYBRID_RMSE  = 10*log10( sqrt( mean( ( HSI_MFbA_HYBRID  - HSI ).^2 , 3 ) ) ) ;
minRMSE = -30 ;
maxRMSE = -9 ;
IM_DRFUMI_RMSE        = imgray2pcolor( (IMG_DRFUMI_RMSE       -minRMSE)/(maxRMSE-minRMSE) , colormapChoice , 255 ) ;
IM_CNMF_RMSE          = imgray2pcolor( (IMG_CNMF_RMSE         -minRMSE)/(maxRMSE-minRMSE) , colormapChoice , 255 ) ;
IM_HySure_RMSE        = imgray2pcolor( (IMG_HySure_RMSE       -minRMSE)/(maxRMSE-minRMSE) , colormapChoice , 255 ) ;
IM_MFbA_ExFISTA_RMSE  = imgray2pcolor( (IMG_MFbA_ExFISTA_RMSE -minRMSE)/(maxRMSE-minRMSE) , colormapChoice , 255 ) ;
IM_MFbA_FISTA_RMSE    = imgray2pcolor( (IMG_MFbA_FISTA_RMSE   -minRMSE)/(maxRMSE-minRMSE) , colormapChoice , 255 ) ;
IM_MFbA_HYBRID_RMSE   = imgray2pcolor( (IMG_MFbA_HYBRID_RMSE  -minRMSE)/(maxRMSE-minRMSE) , colormapChoice , 255 ) ;


folderName = 'plot_results' ;
if( ~exist( folderName , 'dir' ) )
    mkdir( folderName ) ;
end
cd( folderName ) ;
    figure ; imshow( IM_DRFUMI_RMSE       ) ; title( sprintf( 'DRFUMI'  ) ) ; pause(0.2) ;
    figure ; imshow( IM_CNMF_RMSE         ) ; title( sprintf( 'CNMF'    ) ) ; pause(0.2) ;
    figure ; imshow( IM_HySure_RMSE       ) ; title( sprintf( 'HySure'  ) ) ; pause(0.2) ;
    figure ; imshow( IM_MFbA_ExFISTA_RMSE ) ; title( sprintf( 'ExFISTA' ) ) ; pause(0.2) ;
    figure ; imshow( IM_MFbA_FISTA_RMSE   ) ; title( sprintf( 'FISTA'   ) ) ; pause(0.2) ;
    figure ; imshow( IM_MFbA_HYBRID_RMSE  ) ; title( sprintf( 'HYBRID'  ) ) ; pause(0.2) ;
    imwrite( IM_DRFUMI_RMSE      , 'IM_DRFUMI_RMSE.png'        ) ;
    imwrite( IM_CNMF_RMSE        , 'IM_CNMF_RMSE.png'          ) ;
    imwrite( IM_HySure_RMSE      , 'IM_HySure_RMSE.png'        ) ;
    imwrite( IM_MFbA_FISTA_RMSE  , 'IM_MFbA_FISTA_RMSE.png'    ) ;
    imwrite( IM_MFbA_ExFISTA_RMSE, 'IM_MFbA_ExFISTA_RMSE.png'  ) ;
    imwrite( IM_MFbA_HYBRID_RMSE , 'IM_MFbA_HYBRID_RMSE.png'   ) ;
    figure ; p = pcolor( IMG_DRFUMI_RMSE) ;
    colormap( colormapChoice ) ;
    axis equal ;
    set( p , 'EdgeColor' , 'none' ) ;
    c = colorbar('horizontal') ;
    set( c , 'FontSize' , 14 ) ;
cd ..