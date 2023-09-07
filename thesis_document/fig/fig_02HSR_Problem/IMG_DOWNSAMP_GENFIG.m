close all
clear
clc
load IMG_DOWNSAMP_ENVI
figure ;
subplot(1,3,1) ; imshow( IMG ) ; title( 'ori' ) ;
H        = fspecial( 'Gaussian' , 25 , 3 ) ;
IMG_blur = IMG ;
for k = 1 : 3
    IMG_blur(:,:,k) = filter2( H , IMG(:,:,k) ) ;
end
subplot(1,3,2) ; imshow( IMG_blur ) ; title( 'blur' ) ;
dsRatio = 8 ;
IMG_dspl = IMG_blur( floor(dsRatio/2)+1 : dsRatio : end , ...
                     floor(dsRatio/2)+1 : dsRatio : end , : ) ;
subplot(1,3,3) ; imshow( IMG_dspl ) ; title( 'dnSmpl') ;

imwrite( IMG      , 'IMG_DOWNSAMP_full400x400.png' ) ;
imwrite( IMG_blur , 'IMG_DOWNSAMP_blur400x400.png' ) ;
imwrite( IMG_dspl , 'IMG_DOWNSAMP_down50x50.png'   ) ;
unix( 'convert IMG_DOWNSAMP_full400x400.png IMG_DOWNSAMP_full400x400.eps' ) ;
unix( 'convert IMG_DOWNSAMP_blur400x400.png IMG_DOWNSAMP_blur400x400.eps' ) ;
unix( 'convert IMG_DOWNSAMP_down50x50.png   IMG_DOWNSAMP_down50x50.eps'   ) ;