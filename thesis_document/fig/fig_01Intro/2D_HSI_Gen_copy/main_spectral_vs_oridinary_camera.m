close all
clear
clc
% load image data
load HSI_AVIRIS_CUPRITE                             % loaded variable : HSI
HSI            = HSI(:,:,[3:103,114:147,168:220]) ; % trancate noisy and
                                                    % water absorption band
HSI            = HSI - min(HSI(:)) ;
view_alpha     = 0.7 ;
HSI            = HSI / ([view_alpha  , (1-view_alpha)]*...
                        [min(HSI(:)) ; mean(HSI(:))]   ) ;
% load wavelength data
load HSI_AVIRIS_wavelength % loaded variable : "wavelength"
useRGB = false ;

% -------------------------------
% multi-spectral resolution image
% -------------------------------
wavelength_idx = [ 7     , 10 , 15   , 18 , 21    , 27   , 33  , 39 , 48 , 55 ] ; % TM sensor spec
%the band in nm :  0.465 , 0.540 , 0.605 , 0.660 , 0.740 , 0.810 ] ;
wavelength_MS  = wavelength( wavelength_idx ) ;
MS             = HSI(:,:,wavelength_idx) ;
view_alpha     = 0.6 ;
MS             = MS / ([view_alpha , (1-view_alpha)]*...
                       [min(MS(:)) ; max(MS(:))]     ) ;
band_separat   = 40 ;
MS_3D_PERSP    = GEN_2DHSI( MS , wavelength_MS , band_separat , useRGB ) ;
figure , imshow( MS_3D_PERSP ) ;
imwrite( MS_3D_PERSP , 'spectral_IMG.png' ) ;
unix( 'convert spectral_IMG.png spectral_IMG.eps' ) ;


% -------------------------------
% multi-spectral resolution image
% -------------------------------
wavelength_idx = [ 7     , 15   , 23 ] ; % TM sensor spec
%the band in nm :  0.465 , 0.540 , 0.605 , 0.660 , 0.740 , 0.810 ] ;
wavelength_MS  = wavelength( wavelength_idx ) ;
MS             = HSI(:,:,wavelength_idx) ;
view_alpha     = 0.6 ;
MS             = MS / ([view_alpha , (1-view_alpha)]*...
                       [min(MS(:)) ; max(MS(:))]     ) ;
band_separat   = 80 ;
MS_3D_PERSP    = GEN_2DHSI( MS , wavelength_MS , band_separat , useRGB ) ;
figure , imshow( MS_3D_PERSP ) ;
imwrite( MS_3D_PERSP , 'oridinary_RGB.png' ) ;
unix( 'convert oridinary_RGB.png oridinary_RGB.eps' ) ;