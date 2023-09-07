rng('shuffle') ;
delete *.asv
delete m~

com.mathworks.mlservices.MLCommandHistoryServices.removeAll
close all
clear
clc

modelOrder  = dlmread( 'CONFIG.MODELORDER' ) ;
trialNum    = dlmread( 'CONFIG.TRIALNUM'   ) ;
dsRatio     = dlmread( 'CONFIG.DSRATIO'    ) ;
SNR_dB      = dlmread( 'CONFIG.SNR'        ) ;

load HSI_cuprite_200x350x224
HSI = HSI(:,1:348,[3:103,114:147,168:220]) ;

[ MS_imgSizeM , MS_imgSizeN , HS_bandNum ] = size( HSI ) ;
  MS_pixelNum = MS_imgSizeM * MS_imgSizeN ;

load F_CUPRITE1997
F = F(:,[3:103,114:147,168:220]) ;
F = F ./ repmat( sum(F,2) , 1 , size(F,2) ) ;
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
    if( ~exist(trialFolderName,'dir') ) ; mkdir( trialFolderName ) ; end ;
    cd( trialFolderName ) ;
        cd ;
        if( ~exist( 'finish.txt' , 'file' ) )
            if( ~exist( 'someOneIsHere.txt' , 'file' ) )
                unix( 'hostname > host' ) ;
                unix( 'echo s > someOneIsHere.txt' ) ;
                unix( 'cp ../HIS_*.m  ./' ) ;
                unix( 'cp ../DSP_*.m  ./' ) ;
                unix( 'cp ../FUNC_*.m ./' ) ;
                if( ~exist( 'ENVI_SYNT.mat' , 'file' ) )
                    Y_pure = Y ;
                    HSI = reshape( Y_pure' , [ MS_imgSizeM MS_imgSizeN HS_bandNum ] ) ;
                    Y_H = DSP_AWGN( Y_pure * G , SNR_dB )                             ;
                    Y_M = DSP_AWGN( F * ( Y_pure ) , SNR_dB )                         ;
                    HS  = reshape( Y_H' , HS_imgSizeM , HS_imgSizeN , HS_bandNum ) ;
                    MS  = reshape( Y_M' , MS_imgSizeM , MS_imgSizeN , MS_bandNum ) ;
                    A_init = DSP_SPA( Y_H , modelOrder ) ;
                    A_init = min( max( A_init , 0 ) , 1 ) ;
                    
                    S_init = ones( modelOrder , MS_pixelNum ) / modelOrder ;
                    save( 'ENVI_SYNT' , 'Y_H'                ) ;
                    save( 'ENVI_SYNT' , 'Y_M'    , '-append' ) ;
                    save( 'ENVI_SYNT' , 'A_init' , '-append' ) ;
                    save( 'ENVI_SYNT' , 'S_init' , '-append' ) ;
                    % log init performance %
                    RSNR_INIT     = 10*log10( mean2(HSI.^2) / mean2((reshape(S_init'*A_init',MS_imgSizeM,MS_imgSizeN,HS_bandNum)-HSI).^2) ) ;
                    RMSE_INIT     = 10*log10( sqrt( mean2( (Y - A_init*S_init).^2 ) ) ) ;
                    SAM_INIT      = mean( real( acos( sum( (A_init*S_init).*Y ) ./ sqrt( sum((A_init*S_init).^2) .* sum(Y.^2) ) ) ) ) / pi * 180 ;
                    D1 = max( Y , [] , 2 ).^2 ;
                    D2 = mean( ( Y - A_init*S_init ).^2 , 2 ) ;
                    PSNR_INIT     = mean( 10 * log10( D1./D2 ) ) ;
                    unix( ['echo ',num2str(RSNR_INIT)    ,' > RSNR_INIT'    ] ) ;
                    unix( ['echo ',num2str(RMSE_INIT)    ,' > RMSE_INIT'    ] ) ;
                    unix( ['echo ',num2str(SAM_INIT)     ,' > SAM_INIT'     ] ) ;
                    unix( ['echo ',num2str(PSNR_INIT)    ,' > PSNR_INIT'    ] ) ;
                    clear RSNR_INIT RMSE_INIT SAM_INIT D1 D2 PSNR_INIT
                else
                    load ENVI_SYNT
                    HS  = reshape( Y_H' , HS_imgSizeM , HS_imgSizeN , HS_bandNum ) ;
                    MS  = reshape( Y_M' , MS_imgSizeM , MS_imgSizeN , MS_bandNum ) ;
                    HSI = reshape( Y' , size(MS,1) , size(MS,2) , size(HS,3) ) ;
                end
                % =============== %
                % MFbA fista It 1 %
                % =============== %
                fprintf( 'HIS by MFbA fista It 1\n' ) ;
                logFileName = 'LOG_MFbA_fista_subprobIt_1.mat' ;
                if( ~exist( logFileName , 'file' ) )
                    if( exist( 'MF_opt' , 'var' ) )
                        clear MF_opt ;
                    end
                    MF_opt.F           = F       ; MF_opt.G              = G          ;
                    MF_opt.maxIteraNum = 3e4     ; MF_opt.convthresh     = 1e-4       ;
                    MF_opt.AStep       = 1       ;
                    MF_opt.SStep       = 1       ;
                    MF_opt.A_init      = A_init  ; MF_opt.S_init         = S_init     ;
                    [ HSI_MF , A_MF , S_MF , IT_used_MF , TIME_MF , returnInfo_MF ] = HIS_MFbA_fista( HS , MS , MF_opt ) ;
                    while( 1 )
                        try
                            save( logFileName , 'A_MF'          , '-v7.3'   ) ;
                            save( logFileName , 'S_MF'          , '-append' ) ;
                            save( logFileName , 'returnInfo_MF' , '-append' ) ;
                            save( logFileName , 'MF_opt'        , '-append' ) ;
                            save( logFileName , 'TIME_MF'       , '-append' ) ;
                            save( logFileName , 'IT_used_MF'    , '-append' ) ;
                        catch
                            fprintf( 'error in save file %s ...\n' , logFileName ) ;
                            delete( logFileName ) ;
                            pause(3) ;
                        end
                        if( exist( logFileName , 'file' ) )
                            break ;
                        end
                    end
                    RSNR_MFbA     = 10*log10( mean2(HSI.^2) / mean2((HSI_MF-HSI).^2) ) ;
                    RMSE_MFbA     = 10*log10( sqrt( mean2( (HSI_MF-HSI).^2 ) ) ) ;
                    SAM_MFbA      = mean( real( acos( sum( (A_MF*S_MF).*reshape(permute(HSI,[3,1,2]),HS_bandNum,MS_pixelNum) ) ./ sqrt( sum((A_MF*S_MF).^2) .* sum(reshape(permute(HSI,[3,1,2]),HS_bandNum,MS_pixelNum).^2) ) ) ) ) / pi * 180 ;
                    D1 = max( reshape(permute(HSI,[3,1,2]),HS_bandNum,MS_pixelNum) , [] , 2 ).^2 ;
                    D2 = mean( ( reshape(permute(HSI,[3,1,2]),HS_bandNum,MS_pixelNum) - A_MF*S_MF ).^2 , 2 ) ;
                    PSNR_MFbA     = mean( 10 * log10( D1./D2 ) ) ;
                    unix( ['echo ',num2str(RSNR_MFbA)    ,' > RSNR_MFbA_fista_subprobIt_1'    ] ) ;
                    unix( ['echo ',num2str(RMSE_MFbA)    ,' > RMSE_MFbA_fista_subprobIt_1'    ] ) ;
                    unix( ['echo ',num2str(SAM_MFbA)     ,' > SAM_MFbA_fista_subprobIt_1'     ] ) ;
                    unix( ['echo ',num2str(PSNR_MFbA)    ,' > PSNR_MFbA_fista_subprobIt_1'    ] ) ;
                    unix( ['echo ',num2str(TIME_MF)      ,' > TIME_MFbA_fista_subprobIt_1'    ] ) ;
                    unix( ['echo ',num2str(IT_used_MF)   ,' > IT_used_MFbA_fista_subprobIt_1' ] ) ;
                    clear NMSE_End_MFbA NMSE_Abu_MFbA B1 B2 MSE_End_MFbA C1 C2 MSE_Abu_MFbA RSNR_MFbA RMSE_MFbA SAM_MFbA D1 D2 PSNR_MFbA TIME_MF IT_used_MF
                end
                if( exist( 'stop.txt' , 'file' ) ) ; fprintf( 'stop signal received !!!\n@ dir : %s\n' , cd ) ; exit ; end ;
                % ===================== %
                % MFbA Frank Wolfe It 1 %
                % ===================== %
                fprintf( 'HIS by MFbA FW It 1\n' ) ;
                logFileName = 'LOG_MFbA_FW_subprobIt_1.mat' ;
                if( ~exist( logFileName , 'file' ) )
                    if( exist( 'MF_opt' , 'var' ) )
                        clear MF_opt ;
                    end
                    MF_opt.F           = F       ; MF_opt.G              = G          ;
                    MF_opt.maxIteraNum = 3e4     ; MF_opt.convthresh     = 1e-4       ;
                    MF_opt.AStep       = 1       ;
                    MF_opt.SStep       = 1       ;
                    MF_opt.A_init      = A_init  ; MF_opt.S_init         = S_init     ;
                    [ HSI_MF , A_MF , S_MF , IT_used_MF , TIME_MF , returnInfo_MF ] = HIS_MFbA_FW( HS , MS , MF_opt ) ;
                    while( 1 )
                        try
                            save( logFileName , 'A_MF'          , '-v7.3'   ) ;
                            save( logFileName , 'S_MF'          , '-append' ) ;
                            save( logFileName , 'returnInfo_MF' , '-append' ) ;
                            save( logFileName , 'MF_opt'        , '-append' ) ;
                            save( logFileName , 'TIME_MF'       , '-append' ) ;
                            save( logFileName , 'IT_used_MF'    , '-append' ) ;
                        catch
                            fprintf( 'error in save file %s ...\n' , logFileName ) ;
                            delete( logFileName ) ;
                            pause(3) ;
                        end
                        if( exist( logFileName , 'file' ) )
                            break ;
                        end
                    end
                    RSNR_MFbA     = 10*log10( mean2(HSI.^2) / mean2((HSI_MF-HSI).^2) ) ;
                    RMSE_MFbA     = 10*log10( sqrt( mean2( (HSI_MF-HSI).^2 ) ) ) ;
                    SAM_MFbA      = mean( real( acos( sum( (A_MF*S_MF).*reshape(permute(HSI,[3,1,2]),HS_bandNum,MS_pixelNum) ) ./ sqrt( sum((A_MF*S_MF).^2) .* sum(reshape(permute(HSI,[3,1,2]),HS_bandNum,MS_pixelNum).^2) ) ) ) ) / pi * 180 ;
                    D1 = max( reshape(permute(HSI,[3,1,2]),HS_bandNum,MS_pixelNum) , [] , 2 ).^2 ;
                    D2 = mean( ( reshape(permute(HSI,[3,1,2]),HS_bandNum,MS_pixelNum) - A_MF*S_MF ).^2 , 2 ) ;
                    PSNR_MFbA     = mean( 10 * log10( D1./D2 ) ) ;
                    unix( ['echo ',num2str(RSNR_MFbA)    ,' > RSNR_MFbA_FW_subprobIt_1'    ] ) ;
                    unix( ['echo ',num2str(RMSE_MFbA)    ,' > RMSE_MFbA_FW_subprobIt_1'    ] ) ;
                    unix( ['echo ',num2str(SAM_MFbA)     ,' > SAM_MFbA_FW_subprobIt_1'     ] ) ;
                    unix( ['echo ',num2str(PSNR_MFbA)    ,' > PSNR_MFbA_FW_subprobIt_1'    ] ) ;
                    unix( ['echo ',num2str(TIME_MF)      ,' > TIME_MFbA_FW_subprobIt_1'    ] ) ;
                    unix( ['echo ',num2str(IT_used_MF)   ,' > IT_used_MFbA_FW_subprobIt_1' ] ) ;
                    clear NMSE_End_MFbA NMSE_Abu_MFbA B1 B2 MSE_End_MFbA C1 C2 MSE_Abu_MFbA RSNR_MFbA RMSE_MFbA SAM_MFbA D1 D2 PSNR_MFbA TIME_MF IT_used_MF
                end
                if( exist( 'stop.txt' , 'file' ) ) ; fprintf( 'stop signal received !!!\n@ dir : %s\n' , cd ) ; exit ; end ;
                % =============================================== %
                % MFbA Hybrid BCD ( S : FW 1 , A : FISTA 1 ) It 1 %
                % =============================================== %
                fprintf( 'HIS by MFbA HYBRID ( S : FW 1 , A : FISTA 1 ) It = 1\n' ) ;
                if( ~exist( 'LOG_MFbA_HYBRID_S_FW1_A_FISTA1_subprobIt_1.mat' , 'file' ) )
                    if( exist( 'MF_opt' , 'var' ) )
                        clear MF_opt ;
                    end
                    MF_opt.F           = F       ; MF_opt.G              = G          ;
                    MF_opt.maxIteraNum = 3e4     ; MF_opt.convthresh     = 1e-4       ;
                    MF_opt.AStep       = 1       ;
                    MF_opt.SStep       = 1       ;
                    MF_opt.A_init      = A_init  ; MF_opt.S_init         = S_init     ;
                    MF_opt.A_HYBRID    = 'FISTA' ; MF_opt.S_HYBRID       = 'FW'       ;
                    [ HSI_MF , A_MF , S_MF , IT_used_MF , TIME_MF , returnInfo_MF ] = HIS_MFbA_HYBRID( HS , MS , MF_opt ) ;
                    logFileName = 'LOG_MFbA_HYBRID_S_FW1_A_FISTA1_subprobIt_1.mat' ;
                    while( 1 )
                        try
                            save( logFileName , 'A_MF'          , '-v7.3'   ) ;
                            save( logFileName , 'S_MF'          , '-append' ) ;
                            save( logFileName , 'returnInfo_MF' , '-append' ) ;
                            save( logFileName , 'MF_opt'        , '-append' ) ;
                            save( logFileName , 'TIME_MF'       , '-append' ) ;
                            save( logFileName , 'IT_used_MF'    , '-append' ) ;
                        catch
                            fprintf( 'error in save file %s ...\n' , logFileName ) ;
                            delete( logFileName ) ;
                            pause(3) ;
                        end
                        if( exist( logFileName , 'file' ) )
                            break ;
                        end
                    end                    
                    RSNR_MFbA     = 10*log10( mean2(HSI.^2) / mean2((HSI_MF-HSI).^2) ) ;
                    RMSE_MFbA     = 10*log10( sqrt( mean2( (HSI_MF-HSI).^2 ) ) ) ;
                    SAM_MFbA      = mean( real( acos( sum( (A_MF*S_MF).*reshape(permute(HSI,[3,1,2]),HS_bandNum,MS_pixelNum) ) ./ sqrt( sum((A_MF*S_MF).^2) .* sum(reshape(permute(HSI,[3,1,2]),HS_bandNum,MS_pixelNum).^2) ) ) ) ) / pi * 180 ;
                    D1 = max( reshape(permute(HSI,[3,1,2]),HS_bandNum,MS_pixelNum) , [] , 2 ).^2 ;
                    D2 = mean( ( reshape(permute(HSI,[3,1,2]),HS_bandNum,MS_pixelNum) - A_MF*S_MF ).^2 , 2 ) ;
                    PSNR_MFbA     = mean( 10 * log10( D1./D2 ) ) ;
                    unix( ['echo ',num2str(RSNR_MFbA)    ,' > RSNR_MFbA_HYBRID_S_FW1_A_FISTA1_subprobIt_1'    ] ) ;
                    unix( ['echo ',num2str(RMSE_MFbA)    ,' > RMSE_MFbA_HYBRID_S_FW1_A_FISTA1_subprobIt_1'    ] ) ;
                    unix( ['echo ',num2str(SAM_MFbA)     ,' > SAM_MFbA_HYBRID_S_FW1_A_FISTA1_subprobIt_1'     ] ) ;
                    unix( ['echo ',num2str(PSNR_MFbA)    ,' > PSNR_MFbA_HYBRID_S_FW1_A_FISTA1_subprobIt_1'    ] ) ;
                    unix( ['echo ',num2str(TIME_MF)      ,' > TIME_MFbA_HYBRID_S_FW1_A_FISTA1_subprobIt_1'    ] ) ;
                    unix( ['echo ',num2str(IT_used_MF)   ,' > IT_used_MFbA_HYBRID_S_FW1_A_FISTA1_subprobIt_1' ] ) ;
                    clear NMSE_End_MFbA NMSE_Abu_MFbA B1 B2 MSE_End_MFbA C1 C2 MSE_Abu_MFbA RSNR_MFbA RMSE_MFbA SAM_MFbA D1 D2 PSNR_MFbA TIME_MF IT_used_MF
                end
                if( exist( 'stop.txt' , 'file' ) ) ; fprintf( 'stop signal received !!!\n@ dir : %s\n' , cd ) ; exit ; end ;
                unix( 'rm -f someOneIsHere.txt' ) ;
                unix( 'echo f > finish.txt' ) ;
            end
        else
            fprintf( 'finished !\n' ) ;
        end
    cd ..
end
