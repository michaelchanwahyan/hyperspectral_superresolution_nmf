close all
clear
clc

trialNum    = dlmread( 'CONFIG.TRIALNUM'   ) ;
dsRatio     = dlmread( 'CONFIG.DSRATIO'    ) ;
SNR_dB      = dlmread( 'CONFIG.SNR'        ) ;

load HSI_chikusei2014_1000x1000

[ MS_imgSizeM , MS_imgSizeN , HS_bandNum ] = size( HSI ) ;
  MS_pixelNum = MS_imgSizeM * MS_imgSizeN ;

load F_CHIKUSEI2014
G = construct_G_Gaussian_FUMI( MS_imgSizeM , MS_imgSizeN , 11 , 1.7 , dsRatio ) ;

HS_imgSizeM = MS_imgSizeM / dsRatio ;
HS_imgSizeN = MS_imgSizeN / dsRatio ;
HS_pixelNum = HS_imgSizeM * HS_imgSizeN ;
MS_bandNum  = size( F,1 ) ;

Y = reshape( permute(HSI,[3,1,2]) , HS_bandNum , MS_pixelNum ) ;

for k = 1 : trialNum
    if    ( k < 10   ) ; trialFolderName = ['trial000',int2str(k)] ;
    elseif( k < 100  ) ; trialFolderName = ['trial00' ,int2str(k)] ;
    elseif( k < 1000 ) ; trialFolderName = ['trial0'  ,int2str(k)] ;
    elseif( k < 10000) ; trialFolderName = ['trial'   ,int2str(k)] ;
    end
    cd( trialFolderName ) ;
    cd ;
        load ENVI_SYNT
        HS  = reshape( Y_H' , HS_imgSizeM , HS_imgSizeN , HS_bandNum ) ;
        MS  = reshape( Y_M' , MS_imgSizeM , MS_imgSizeN , MS_bandNum ) ;
        HSI = reshape( Y' , size(MS,1) , size(MS,2) , size(HS,3) ) ;
        % MFnAS fista It 1 convth 1e-1 %
        load LOG_MFnAS_fista_subprobIt_1_convth_1em1
        SAM_MF_realArr = real( acos( sum( (A_MF*S_MF).*(Y) ) ./ sqrt( sum((A_MF*S_MF).^2) .* sum((Y).^2) ) ) ) ;
        SAM_MF      = mean( SAM_MF_realArr( ~isnan(SAM_MF_realArr) ) ) / pi * 180 ;
        unix( ['echo ',num2str(SAM_MF)     ,' > SAM_MFnAS_fista_subprobIt_1_convth_1em1'     ] ) ;
        % MFnAS proxGrad It 1 convth 1e-1 %
        load LOG_MFnAS_proxGrad_subprobIt_1_convth_1em1
        SAM_MF_realArr = real( acos( sum( (A_MF*S_MF).*(Y) ) ./ sqrt( sum((A_MF*S_MF).^2) .* sum((Y).^2) ) ) ) ;
        SAM_MF      = mean( SAM_MF_realArr( ~isnan(SAM_MF_realArr) ) ) / pi * 180 ;
        unix( ['echo ',num2str(SAM_MF)     ,' > SAM_MFnAS_proxGrad_subprobIt_1_convth_1em1'     ] ) ;
        % MFnAS BB betaMax1 It 1 convth 1e-1 %
        SAM_MF_realArr = real( acos( sum( (A_MF*S_MF).*(Y) ) ./ sqrt( sum((A_MF*S_MF).^2) .* sum((Y).^2) ) ) ) ;
        SAM_MF      = mean( SAM_MF_realArr( ~isnan(SAM_MF_realArr) ) ) / pi * 180 ;
        unix( ['echo ',num2str(SAM_MF)     ,' > SAM_MFnAS_BB_betaMax1_subprobIt_1_convth_1em1'     ] ) ;
    cd ..
end
