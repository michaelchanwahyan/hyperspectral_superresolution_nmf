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

if( ~exist( 'HSI' , 'var' ) )
load HSI_chikusei2014_1000x1000
end

[ MS_imgSizeM , MS_imgSizeN , HS_bandNum ] = size( HSI ) ;
  MS_pixelNum = MS_imgSizeM * MS_imgSizeN ;

load F_CHIKUSEI2014
G = construct_G_Gaussian_FUMI( MS_imgSizeM , MS_imgSizeN , 11 , 1.7 , dsRatio ) ;
[~,B] = Construct_HySureB(         MS_imgSizeM , MS_imgSizeN , 11 , 1.7 , dsRatio ) ;

HS_imgSizeM = MS_imgSizeM / dsRatio ;
HS_imgSizeN = MS_imgSizeN / dsRatio ;
HS_pixelNum = HS_imgSizeM * HS_imgSizeN ;
MS_bandNum  = size( F,1 ) ;

Y = reshape( permute(HSI,[3,1,2]) , HS_bandNum , MS_pixelNum ) ;

for k = 1 : trialNum
    trialFolderName = sprintf( 'trial%04d' , k ) ;
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
                % ================= %
                % DRFUMI Var < 1e-9 %
                % ================= %
                fprintf( 'HIS by DRFUMI Var < 1e-9\n' ) ;
                logFileName = 'LOG_DRFUMI.mat' ;
                if( ~exist( logFileName , 'file' ) )
                    if( exist( 'DRFUMI_opt' , 'var' ) )
                        clear DRFUMI_opt ;
                    end
                    DRFUMI_opt.MS_bandNum   = MS_bandNum ; DRFUMI_opt.MS_imgSizeM  = MS_imgSizeM ; DRFUMI_opt.MS_imgSizeN = MS_imgSizeN     ;
                    DRFUMI_opt.HS_bandNum   = HS_bandNum ; DRFUMI_opt.HS_imgSizeM  = HS_imgSizeM ; DRFUMI_opt.HS_imgSizeN = HS_imgSizeN     ;
                    DRFUMI_opt.dsRatio      = dsRatio    ; DRFUMI_opt.modelOrder   = modelOrder  ;
                    DRFUMI_opt.F            = F          ; DRFUMI_opt.G_sigma      = 1.7         ; DRFUMI_opt.G_kerSiz    = 11              ;
                    DRFUMI_opt.maxIteraNum  = 1e4        ; DRFUMI_opt.convthresh   = 1e-9        ;
                    DRFUMI_opt.It_ADMM_EEA  = 30         ; DRFUMI_opt.Th_ADMM_EEA  = 1e-3        ;
                    DRFUMI_opt.It_ADMM_ABUN = 30         ; DRFUMI_opt.Th_ADMM_ABUN = 1e-3        ;
                    DRFUMI_opt.A_init       = A_init     ;
                    clear HSI_DRFUMI
                    [ HSI_DRFUMI , A_DRFUMI , S_DRFUMI , IT_used_DRFUMI , TIME_DRFUMI , returnInfo_DRFUMI ] = HIS_DRFUMI( HS , MS , DRFUMI_opt ) ;
                    while( 1 )
                        try
                            save( logFileName , 'A_DRFUMI'          , '-v7.3'   ) ;
                            save( logFileName , 'S_DRFUMI'          , '-append' ) ;
                            save( logFileName , 'returnInfo_DRFUMI' , '-append' ) ;
                            save( logFileName , 'DRFUMI_opt'        , '-append' ) ;
                            save( logFileName , 'TIME_DRFUMI'       , '-append' ) ;
                            save( logFileName , 'IT_used_DRFUMI'    , '-append' ) ;
                        catch
                            fprintf( 'error in save file %s ...\n' , logFileName ) ;
                            delete( logFileName ) ;
                            pause(3) ;
                        end
                        if( exist( logFileName , 'file' ) )
                            break ;
                        end
                    end
                    RSNR_DRFUMI     = 10*log10( mean2(HSI.^2) / mean2((HSI_DRFUMI-HSI).^2) ) ;
                    RMSE_DRFUMI     = 10*log10( sqrt( mean2( (HSI_DRFUMI-HSI).^2 ) ) ) ;
                    SAM_DRFUMI      = mean( real( acos( sum( reshape(permute(HSI_DRFUMI,[3,1,2]),HS_bandNum,MS_pixelNum).*reshape(permute(HSI,[3,1,2]),HS_bandNum,MS_pixelNum) ) ./ sqrt( sum(reshape(permute(HSI_DRFUMI,[3,1,2]),HS_bandNum,MS_pixelNum).^2) .* sum(reshape(permute(HSI,[3,1,2]),HS_bandNum,MS_pixelNum).^2) ) ) ) ) / pi * 180 ;
                    D1 = max( reshape(permute(HSI,[3,1,2]),HS_bandNum,MS_pixelNum) , [] , 2 ).^2 ;
                    D2 = mean( ( reshape(permute(HSI,[3,1,2]),HS_bandNum,MS_pixelNum) - reshape(permute(HSI_DRFUMI,[3,1,2]),HS_bandNum,MS_pixelNum) ).^2 , 2 ) ;
                    PSNR_DRFUMI     = mean( 10 * log10( D1./D2 ) ) ;
                    unix( ['echo ',num2str(RSNR_DRFUMI)    ,' > RSNR_DRFUMI'    ] ) ;
                    unix( ['echo ',num2str(RMSE_DRFUMI)    ,' > RMSE_DRFUMI'    ] ) ;
                    unix( ['echo ',num2str(SAM_DRFUMI)     ,' > SAM_DRFUMI'     ] ) ;
                    unix( ['echo ',num2str(PSNR_DRFUMI)    ,' > PSNR_DRFUMI'    ] ) ;
                    unix( ['echo ',num2str(TIME_DRFUMI)    ,' > TIME_DRFUMI'    ] ) ;
                    unix( ['echo ',num2str(IT_used_DRFUMI) ,' > IT_used_DRFUMI' ] ) ;
                    clear NMSE_End_DRFUMI NMSE_Abu_DRFUMI B1 B2 MSE_End_DRFUMI C1 C2 MSE_Abu_DRFUMI RSNR_DRFUMI RMSE_DRFUMI SAM_DRFUMI D1 D2 PSNR_DRFUMI TIME_DRFUMI IT_used_DRFUMI
                end
                if( exist( 'stop.txt' , 'file' ) ) ; fprintf( 'stop signal received !!!\n@ dir : %s\n' , cd ) ; exit ; end ;
                % =============================== %
                % CNMF subprob It 100 convth 1e-9 %
                % =============================== %
                fprintf( 'HIS by CNMF subprobIt 100 convth 1e-9\n' ) ;
                logFileName = 'LOG_CNMF.mat' ;
                if( ~exist( logFileName , 'file' ) )
                    if( exist( 'CNMF_opt' , 'var' ) )
                        clear CNMF_opt ;
                    end
                    CNMF_opt.A_init       = A_init ; CNMF_opt.S_init       = S_init ;
                    CNMF_opt.F            = F      ; CNMF_opt.G            = G      ;
                    CNMF_opt.maxIteraNum  = 1e4    ; CNMF_opt.convThresh   = 1e-9   ;
                    CNMF_opt.AStep        = 100    ; CNMF_opt.convTh_hyper = 1e-8   ;
                    CNMF_opt.SStep        = 100    ; CNMF_opt.convTh_multi = 1e-8   ;
                    [ A_CNMF , S_CNMF , IT_used_CNMF , TIME_CNMF , returnInfo_CNMF ] = HIS_CNMF6( HS , MS , CNMF_opt ) ;
                    while( 1 )
                        try
                            save( logFileName , 'A_CNMF'          , '-v7.3'   ) ;
                            save( logFileName , 'S_CNMF'          , '-append' ) ;
                            save( logFileName , 'returnInfo_CNMF' , '-append' ) ;
                            save( logFileName , 'CNMF_opt'        , '-append' ) ;
                            save( logFileName , 'TIME_CNMF'       , '-append' ) ;
                            save( logFileName , 'IT_used_CNMF'    , '-append' ) ;
                        catch
                            fprintf( 'error in save file %s ...\n' , logFileName ) ;
                            delete( logFileName ) ;
                            pause(3) ;
                        end
                        if( exist( logFileName , 'file' ) )
                            break ;
                        end
                    end
                    RSNR_CNMF     = 10*log10( mean2(HSI.^2) / mean2((reshape(S_CNMF'*A_CNMF',MS_imgSizeM,MS_imgSizeN,HS_bandNum)-HSI).^2) ) ;
                    RMSE_CNMF     = 10*log10( sqrt( mean2( (reshape(S_CNMF'*A_CNMF',MS_imgSizeM,MS_imgSizeN,HS_bandNum)-HSI).^2 ) ) ) ;
                    SAM_CNMF_realArr = real( acos( sum( (A_CNMF*S_CNMF).*(Y) ) ./ sqrt( sum((A_CNMF*S_CNMF).^2) .* sum((Y).^2) ) ) ) ;
                    SAM_CNMF      = mean( SAM_CNMF_realArr( ~isnan(SAM_CNMF_realArr) ) ) / pi * 180 ;
                    D1 = max( reshape(permute(HSI,[3,1,2]),HS_bandNum,MS_pixelNum) , [] , 2 ).^2 ;
                    D2 = mean( ( reshape(permute(HSI,[3,1,2]),HS_bandNum,MS_pixelNum) - A_CNMF*S_CNMF ).^2 , 2 ) ;
                    PSNR_CNMF     = mean( 10 * log10( D1./D2 ) ) ;
                    unix( ['echo ',num2str(RSNR_CNMF)    ,' > RSNR_CNMF'    ] ) ;
                    unix( ['echo ',num2str(RMSE_CNMF)    ,' > RMSE_CNMF'    ] ) ;
                    unix( ['echo ',num2str(SAM_CNMF)     ,' > SAM_CNMF'     ] ) ;
                    unix( ['echo ',num2str(PSNR_CNMF)    ,' > PSNR_CNMF'    ] ) ;
                    unix( ['echo ',num2str(TIME_CNMF)    ,' > TIME_CNMF'    ] ) ;
                    unix( ['echo ',num2str(IT_used_CNMF) ,' > IT_used_CNMF' ] ) ;
                    clear NMSE_End_CNMF NMSE_Abu_CNMF B1 B2 MSE_End_CNMF C1 C2 MSE_Abu_CNMF RSNR_CNMF RMSE_CNMF SAM_CNMF D1 D2 PSNR_CNMF TIME_CNMF IT_used_CNMF
                end
                %{
                % ============ %
                % MFbA PG It 1 %
                % ============ %
                fprintf( 'HIS by MFbA PG It 1\n' ) ;
                logFileName = 'LOG_MFbA_PG.mat' ;
                if( ~exist( logFileName , 'file' ) )
                    if( exist( 'MF_opt' , 'var' ) )
                        clear MF_opt ;
                    end
                    MF_opt.F           = F       ; MF_opt.G              = G          ;
                    MF_opt.maxIteraNum = 1e4     ; MF_opt.convthresh     = 1e-9       ;
                    MF_opt.AStep       = 1       ;
                    MF_opt.SStep       = 1       ;
                    MF_opt.A_init      = A_init  ; MF_opt.S_init         = S_init     ;
                    [ HSI_MF , A_MF , S_MF , IT_used_MF , TIME_MF , returnInfo_MF ] = HIS_MFbA_PG( HS , MS , MF_opt ) ;
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
                    unix( ['echo ',num2str(RSNR_MFbA)    ,' > RSNR_MFbA_PG'    ] ) ;
                    unix( ['echo ',num2str(RMSE_MFbA)    ,' > RMSE_MFbA_PG'    ] ) ;
                    unix( ['echo ',num2str(SAM_MFbA)     ,' > SAM_MFbA_PG'     ] ) ;
                    unix( ['echo ',num2str(PSNR_MFbA)    ,' > PSNR_MFbA_PG'    ] ) ;
                    unix( ['echo ',num2str(TIME_MF)      ,' > TIME_MFbA_PG'    ] ) ;
                    unix( ['echo ',num2str(IT_used_MF)   ,' > IT_used_MFbA_PG' ] ) ;
                    clear NMSE_End_MFbA NMSE_Abu_MFbA B1 B2 MSE_End_MFbA C1 C2 MSE_Abu_MFbA RSNR_MFbA RMSE_MFbA SAM_MFbA D1 D2 PSNR_MFbA TIME_MF IT_used_MF
                end
                if( exist( 'stop.txt' , 'file' ) ) ; fprintf( 'stop signal received !!!\n@ dir : %s\n' , cd ) ; exit ; end ;
                %}
                % =============== %
                % MFbA FISTA It 1 %
                % =============== %
                fprintf( 'HIS by MFbA FISTA It 1\n' ) ;
                logFileName = 'LOG_MFbA_FISTA.mat' ;
                if( ~exist( logFileName , 'file' ) )
                    if( exist( 'MF_opt' , 'var' ) )
                        clear MF_opt ;
                    end
                    MF_opt.F           = F       ; MF_opt.G              = G          ;
                    MF_opt.maxIteraNum = 1e4     ; MF_opt.convthresh     = 1e-9       ;
                    MF_opt.AStep       = 1       ;
                    MF_opt.SStep       = 1       ;
                    MF_opt.A_init      = A_init  ; MF_opt.S_init         = S_init     ;
                    [ HSI_MF , A_MF , S_MF , IT_used_MF , TIME_MF , returnInfo_MF ] = HIS_MFbA_FISTA( HS , MS , MF_opt ) ;
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
                    unix( ['echo ',num2str(RSNR_MFbA)    ,' > RSNR_MFbA_FISTA'    ] ) ;
                    unix( ['echo ',num2str(RMSE_MFbA)    ,' > RMSE_MFbA_FISTA'    ] ) ;
                    unix( ['echo ',num2str(SAM_MFbA)     ,' > SAM_MFbA_FISTA'     ] ) ;
                    unix( ['echo ',num2str(PSNR_MFbA)    ,' > PSNR_MFbA_FISTA'    ] ) ;
                    unix( ['echo ',num2str(TIME_MF)      ,' > TIME_MFbA_FISTA'    ] ) ;
                    unix( ['echo ',num2str(IT_used_MF)   ,' > IT_used_MFbA_FISTA' ] ) ;
                    clear NMSE_End_MFbA NMSE_Abu_MFbA B1 B2 MSE_End_MFbA C1 C2 MSE_Abu_MFbA RSNR_MFbA RMSE_MFbA SAM_MFbA D1 D2 PSNR_MFbA TIME_MF IT_used_MF
                end
                if( exist( 'stop.txt' , 'file' ) ) ; fprintf( 'stop signal received !!!\n@ dir : %s\n' , cd ) ; exit ; end ;
                % ============ %
                % Ex.BCD FISTA %
                % ============ %
                fprintf( 'HIS by Ex.BCD FISTA\n' ) ;
                logFileName = 'LOG_MFbA_ExFISTA.mat' ;
                if( ~exist( logFileName , 'file' ) )
                    if( exist( 'MF_opt' , 'var' ) )
                        clear MF_opt ;
                    end
                    MF_opt.F           = F       ; MF_opt.G              = G          ;
                    MF_opt.maxIteraNum = 1e4     ; MF_opt.convthresh     = 1e-9       ;
                    MF_opt.AStep       = 1e4     ;
                    MF_opt.SStep       = 1e4     ;
                    MF_opt.A_init      = A_init  ; MF_opt.S_init         = S_init     ;
                    [ HSI_MF , A_MF , S_MF , IT_used_MF , TIME_MF , returnInfo_MF ] = HIS_MFbA_FISTA( HS , MS , MF_opt ) ;
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
                    unix( ['echo ',num2str(RSNR_MFbA)    ,' > RSNR_MFbA_ExFISTA'    ] ) ;
                    unix( ['echo ',num2str(RMSE_MFbA)    ,' > RMSE_MFbA_ExFISTA'    ] ) ;
                    unix( ['echo ',num2str(SAM_MFbA)     ,' > SAM_MFbA_ExFISTA'     ] ) ;
                    unix( ['echo ',num2str(PSNR_MFbA)    ,' > PSNR_MFbA_ExFISTA'    ] ) ;
                    unix( ['echo ',num2str(TIME_MF)      ,' > TIME_MFbA_ExFISTA'    ] ) ;
                    unix( ['echo ',num2str(IT_used_MF)   ,' > IT_used_MFbA_ExFISTA' ] ) ;
                    clear NMSE_End_MFbA NMSE_Abu_MFbA B1 B2 MSE_End_MFbA C1 C2 MSE_Abu_MFbA RSNR_MFbA RMSE_MFbA SAM_MFbA D1 D2 PSNR_MFbA TIME_MF IT_used_MF
                end
                if( exist( 'stop.txt' , 'file' ) ) ; fprintf( 'stop signal received !!!\n@ dir : %s\n' , cd ) ; exit ; end ;
                %{
                % ============================================ %
                % MFbA Hybrid BCD ( S : FW 1 , A : PG 1 ) It 1 %
                % ============================================ %
                fprintf( 'HIS by MFbA HYBRID ( S : FW 1 , A : PG 1 ) It = 1\n' ) ;
                logFileName = 'LOG_MFbA_HYBRID_SFW_APG.mat' ;
                if( ~exist( logFileName , 'file' ) )
                    if( exist( 'MF_opt' , 'var' ) )
                        clear MF_opt ;
                    end
                    MF_opt.F           = F       ; MF_opt.G              = G          ;
                    MF_opt.maxIteraNum = 1e4     ; MF_opt.convthresh     = 1e-9       ;
                    MF_opt.AStep       = 1       ;
                    MF_opt.SStep       = 1       ;
                    MF_opt.A_init      = A_init  ; MF_opt.S_init         = S_init     ;
                    MF_opt.A_HYBRID    = 'PG'    ; MF_opt.S_HYBRID       = 'FW'       ;
                    [ HSI_MF , A_MF , S_MF , IT_used_MF , TIME_MF , returnInfo_MF ] = HIS_MFbA_HYBRID( HS , MS , MF_opt ) ;
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
                    unix( ['echo ',num2str(RSNR_MFbA)    ,' > RSNR_MFbA_HYBRID_SFW_APG'    ] ) ;
                    unix( ['echo ',num2str(RMSE_MFbA)    ,' > RMSE_MFbA_HYBRID_SFW_APG'    ] ) ;
                    unix( ['echo ',num2str(SAM_MFbA)     ,' > SAM_MFbA_HYBRID_SFW_APG'     ] ) ;
                    unix( ['echo ',num2str(PSNR_MFbA)    ,' > PSNR_MFbA_HYBRID_SFW_APG'    ] ) ;
                    unix( ['echo ',num2str(TIME_MF)      ,' > TIME_MFbA_HYBRID_SFW_APG'    ] ) ;
                    unix( ['echo ',num2str(IT_used_MF)   ,' > IT_used_MFbA_HYBRID_SFW_APG' ] ) ;
                    clear NMSE_End_MFbA NMSE_Abu_MFbA B1 B2 MSE_End_MFbA C1 C2 MSE_Abu_MFbA RSNR_MFbA RMSE_MFbA SAM_MFbA D1 D2 PSNR_MFbA TIME_MF IT_used_MF
                end
                if( exist( 'stop.txt' , 'file' ) ) ; fprintf( 'stop signal received !!!\n@ dir : %s\n' , cd ) ; exit ; end ;
                %}
                % =============================================== %
                % MFbA Hybrid BCD ( S : FW 1 , A : FISTA 1 ) It 1 %
                % =============================================== %
                fprintf( 'HIS by MFbA HYBRID ( S : FW 1 , A : FISTA 1 ) It = 1\n' ) ;
                logFileName = 'LOG_MFbA_HYBRID_SFW_AFISTA.mat' ;
                if( ~exist( logFileName , 'file' ) )
                    if( exist( 'MF_opt' , 'var' ) )
                        clear MF_opt ;
                    end
                    MF_opt.F           = F       ; MF_opt.G              = G          ;
                    MF_opt.maxIteraNum = 1e4     ; MF_opt.convthresh     = 1e-9       ;
                    MF_opt.AStep       = 1       ;
                    MF_opt.SStep       = 1       ;
                    MF_opt.A_init      = A_init  ; MF_opt.S_init         = S_init     ;
                    MF_opt.A_HYBRID    = 'FISTA' ; MF_opt.S_HYBRID       = 'FW'       ;
                    [ HSI_MF , A_MF , S_MF , IT_used_MF , TIME_MF , returnInfo_MF ] = HIS_MFbA_HYBRID( HS , MS , MF_opt ) ;
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
                    unix( ['echo ',num2str(RSNR_MFbA)    ,' > RSNR_MFbA_HYBRID_SFW_AFISTA'    ] ) ;
                    unix( ['echo ',num2str(RMSE_MFbA)    ,' > RMSE_MFbA_HYBRID_SFW_AFISTA'    ] ) ;
                    unix( ['echo ',num2str(SAM_MFbA)     ,' > SAM_MFbA_HYBRID_SFW_AFISTA'     ] ) ;
                    unix( ['echo ',num2str(PSNR_MFbA)    ,' > PSNR_MFbA_HYBRID_SFW_AFISTA'    ] ) ;
                    unix( ['echo ',num2str(TIME_MF)      ,' > TIME_MFbA_HYBRID_SFW_AFISTA'    ] ) ;
                    unix( ['echo ',num2str(IT_used_MF)   ,' > IT_used_MFbA_HYBRID_SFW_AFISTA' ] ) ;
                    clear NMSE_End_MFbA NMSE_Abu_MFbA B1 B2 MSE_End_MFbA C1 C2 MSE_Abu_MFbA RSNR_MFbA RMSE_MFbA SAM_MFbA D1 D2 PSNR_MFbA TIME_MF IT_used_MF
                end
                if( exist( 'stop.txt' , 'file' ) ) ; fprintf( 'stop signal received !!!\n@ dir : %s\n' , cd ) ; exit ; end ;
                %{
                % ================================================= %
                % MFbA Hybrid LFW BCD ( S : LFW 1 , A : PG 1 ) It 1 %
                % ================================================= %
                fprintf( 'HIS by MFbA HYBRID_LFW ( S : LFW 1 , A : PG 1 ) It = 1\n' ) ;
                logFileName = 'LOG_MFbA_HYBRID_SLFW_APG.mat' ;
                if( ~exist( logFileName , 'file' ) )
                    if( exist( 'MF_opt' , 'var' ) )
                        clear MF_opt ;
                    end
                    MF_opt.F           = F       ; MF_opt.G              = G          ;
                    MF_opt.maxIteraNum = 1e4     ; MF_opt.convthresh     = 1e-9       ;
                    MF_opt.AStep       = 1       ;
                    MF_opt.SStep       = 1       ;
                    MF_opt.A_init      = A_init  ; MF_opt.S_init         = S_init     ;
                    MF_opt.A_HYBRID    = 'PG'    ; MF_opt.S_HYBRID       = 'FW'       ;
                    [ HSI_MF , A_MF , S_MF , IT_used_MF , TIME_MF , returnInfo_MF ] = HIS_MFbA_HYBRID_LFW( HS , MS , MF_opt ) ;
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
                    unix( ['echo ',num2str(RSNR_MFbA)    ,' > RSNR_MFbA_HYBRID_SLFW_APG'    ] ) ;
                    unix( ['echo ',num2str(RMSE_MFbA)    ,' > RMSE_MFbA_HYBRID_SLFW_APG'    ] ) ;
                    unix( ['echo ',num2str(SAM_MFbA)     ,' > SAM_MFbA_HYBRID_SLFW_APG'     ] ) ;
                    unix( ['echo ',num2str(PSNR_MFbA)    ,' > PSNR_MFbA_HYBRID_SLFW_APG'    ] ) ;
                    unix( ['echo ',num2str(TIME_MF)      ,' > TIME_MFbA_HYBRID_SLFW_APG'    ] ) ;
                    unix( ['echo ',num2str(IT_used_MF)   ,' > IT_used_MFbA_HYBRID_SLFW_APG' ] ) ;
                    clear NMSE_End_MFbA NMSE_Abu_MFbA B1 B2 MSE_End_MFbA C1 C2 MSE_Abu_MFbA RSNR_MFbA RMSE_MFbA SAM_MFbA D1 D2 PSNR_MFbA TIME_MF IT_used_MF
                end
                if( exist( 'stop.txt' , 'file' ) ) ; fprintf( 'stop signal received !!!\n@ dir : %s\n' , cd ) ; exit ; end ;
                % ==================================================== %
                % MFbA Hybrid LFW BCD ( S : LFW 1 , A : FISTA 1 ) It 1 %
                % ==================================================== %
                fprintf( 'HIS by MFbA HYBRID_LFW ( S : LFW 1 , A : FISTA 1 ) It = 1\n' ) ;
                logFileName = 'LOG_MFbA_HYBRID_SLFW_AFISTA.mat' ;
                if( ~exist( logFileName , 'file' ) )
                    if( exist( 'MF_opt' , 'var' ) )
                        clear MF_opt ;
                    end
                    MF_opt.F           = F       ; MF_opt.G              = G          ;
                    MF_opt.maxIteraNum = 1e4     ; MF_opt.convthresh     = 1e-9       ;
                    MF_opt.AStep       = 1       ;
                    MF_opt.SStep       = 1       ;
                    MF_opt.A_init      = A_init  ; MF_opt.S_init         = S_init     ;
                    MF_opt.A_HYBRID    = 'FISTA' ; MF_opt.S_HYBRID       = 'FW'       ;
                    [ HSI_MF , A_MF , S_MF , IT_used_MF , TIME_MF , returnInfo_MF ] = HIS_MFbA_HYBRID_LFW( HS , MS , MF_opt ) ;
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
                    unix( ['echo ',num2str(RSNR_MFbA)    ,' > RSNR_MFbA_HYBRID_SLFW_AFISTA'    ] ) ;
                    unix( ['echo ',num2str(RMSE_MFbA)    ,' > RMSE_MFbA_HYBRID_SLFW_AFISTA'    ] ) ;
                    unix( ['echo ',num2str(SAM_MFbA)     ,' > SAM_MFbA_HYBRID_SLFW_AFISTA'     ] ) ;
                    unix( ['echo ',num2str(PSNR_MFbA)    ,' > PSNR_MFbA_HYBRID_SLFW_AFISTA'    ] ) ;
                    unix( ['echo ',num2str(TIME_MF)      ,' > TIME_MFbA_HYBRID_SLFW_AFISTA'    ] ) ;
                    unix( ['echo ',num2str(IT_used_MF)   ,' > IT_used_MFbA_HYBRID_SLFW_AFISTA' ] ) ;
                    clear NMSE_End_MFbA NMSE_Abu_MFbA B1 B2 MSE_End_MFbA C1 C2 MSE_Abu_MFbA RSNR_MFbA RMSE_MFbA SAM_MFbA D1 D2 PSNR_MFbA TIME_MF IT_used_MF
                end
                if( exist( 'stop.txt' , 'file' ) ) ; fprintf( 'stop signal received !!!\n@ dir : %s\n' , cd ) ; exit ; end ;
                % ryan hybrid SLFW_APG
                fprintf( 'HIS by Ryan hybrid S : LFW 1 , A : PG 1\n' ) ;
                logFileName = 'LOG_hybrid_ryan_SLFW_APG.mat' ;
                if( ~exist( logFileName , 'file' ) )
                    Setting.MS_imgSizeM = MS_imgSizeM;
                    Setting.MS_imgSizeN = MS_imgSizeN;
                    Setting.HS_imgSizeM = MS_imgSizeM/dsRatio;
                    Setting.HS_imgSizeN = MS_imgSizeN/dsRatio;
                    Setting.maxIteraNum = 1e4; 
                    Setting.convthresh = 1e-9;
                    Setting.F = F;
                    Setting.G = G;
                    Setting.modelOrder = modelOrder;
                    Setting.dsRatio = dsRatio;
                    Setting.A_init  = A_init ;
                    Setting.S_init  = S_init ;
                    Setting.AfistaStep = 1 ;
                    Setting.SfistaStep = 1 ;
                    [A_ryan,S_ryan,obj,t] = HIS_hybrid_SLFW_APG(Y_H,Y_M,Setting);
                    while( 1 )
                        try
                            save( logFileName , 'A_ryan'  , '-v7.3'   ) ;
                            save( logFileName , 'S_ryan'  , '-append' ) ;
                            save( logFileName , 'obj'     , '-append' ) ;
                            save( logFileName , 't'       , '-append' ) ;
                            save( logFileName , 'Setting' , '-append' ) ;
                        catch
                            fprintf( 'error in save file %s ...\n' , logFileName ) ;
                            delete( logFileName ) ;
                            pause(3) ;
                        end
                        if( exist( logFileName , 'file' ) )
                            break ;
                        end
                    end  
                    HSI_ryan = reshape( S_ryan' * A_ryan' , 1000 , 1000 , 128 ) ;
                    RSNR_ryan     = 10*log10( mean2(HSI.^2) / mean2((HSI_ryan-HSI).^2) ) ;
                    RMSE_ryan     = 10*log10( sqrt( mean2( (HSI_ryan-HSI).^2 ) ) ) ;
                    SAM_ryan      = mean( real( acos( sum( (A_ryan*S_ryan).*reshape(permute(HSI,[3,1,2]),HS_bandNum,MS_pixelNum) ) ./ sqrt( sum((A_ryan*S_ryan).^2) .* sum(reshape(permute(HSI,[3,1,2]),HS_bandNum,MS_pixelNum).^2) ) ) ) ) / pi * 180 ;
                    D1 = max( reshape(permute(HSI,[3,1,2]),HS_bandNum,MS_pixelNum) , [] , 2 ).^2 ;
                    D2 = mean( ( reshape(permute(HSI,[3,1,2]),HS_bandNum,MS_pixelNum) - A_ryan*S_ryan ).^2 , 2 ) ;
                    PSNR_ryan     = mean( 10 * log10( D1./D2 ) ) ;
                    unix( ['echo ',num2str(RSNR_ryan)    ,' > RSNR_hybrid_ryan_SLFW_APG'    ] ) ;
                    unix( ['echo ',num2str(RMSE_ryan)    ,' > RMSE_hybrid_ryan_SLFW_APG'    ] ) ;
                    unix( ['echo ',num2str(SAM_ryan)     ,' > SAM_hybrid_ryan_SLFW_APG'     ] ) ;
                    unix( ['echo ',num2str(PSNR_ryan)    ,' > PSNR_hybrid_ryan_SLFW_APG'    ] ) ;
                    unix( ['echo ',num2str(max(t))       ,' > TIME_hybrid_ryan_SLFW_APG'    ] ) ;
                    unix( ['echo ',num2str(numel(obj))   ,' > IT_used_hybrid_ryan_SLFW_APG' ] ) ;
                end
                if( exist( 'stop.txt' , 'file' ) ) ; fprintf( 'stop signal received !!!\n@ dir : %s\n' , cd ) ; exit ; end ;
                % ryan hybrid SLFW_AFISTA
                fprintf( 'HIS by Ryan hybrid S : LFW 1 , A : FISTA 1\n' ) ;
                logFileName = 'LOG_hybrid_ryan_SLFW_AFISTA.mat' ;
                if( ~exist( logFileName , 'file' ) )
                    Setting.MS_imgSizeM = MS_imgSizeM;
                    Setting.MS_imgSizeN = MS_imgSizeN;
                    Setting.HS_imgSizeM = MS_imgSizeM/dsRatio;
                    Setting.HS_imgSizeN = MS_imgSizeN/dsRatio;
                    Setting.maxIteraNum = 1e4; 
                    Setting.convthresh = 1e-9;
                    Setting.F = F;
                    Setting.G = G;
                    Setting.modelOrder = modelOrder;
                    Setting.dsRatio = dsRatio;
                    Setting.A_init  = A_init ;
                    Setting.S_init  = S_init ;
                    Setting.AfistaStep = 1 ;
                    Setting.SfistaStep = 1 ;
                    [A_ryan,S_ryan,obj,t] = HIS_hybrid_SLFW_AFISTA(Y_H,Y_M,Setting);
                    while( 1 )
                        try
                            save( logFileName , 'A_ryan'  , '-v7.3'   ) ;
                            save( logFileName , 'S_ryan'  , '-append' ) ;
                            save( logFileName , 'obj'     , '-append' ) ;
                            save( logFileName , 't'       , '-append' ) ;
                            save( logFileName , 'Setting' , '-append' ) ;
                        catch
                            fprintf( 'error in save file %s ...\n' , logFileName ) ;
                            delete( logFileName ) ;
                            pause(3) ;
                        end
                        if( exist( logFileName , 'file' ) )
                            break ;
                        end
                    end  
                    HSI_ryan = reshape( S_ryan' * A_ryan' , 1000 , 1000 , 128 ) ;
                    RSNR_ryan     = 10*log10( mean2(HSI.^2) / mean2((HSI_ryan-HSI).^2) ) ;
                    RMSE_ryan     = 10*log10( sqrt( mean2( (HSI_ryan-HSI).^2 ) ) ) ;
                    SAM_ryan      = mean( real( acos( sum( (A_ryan*S_ryan).*reshape(permute(HSI,[3,1,2]),HS_bandNum,MS_pixelNum) ) ./ sqrt( sum((A_ryan*S_ryan).^2) .* sum(reshape(permute(HSI,[3,1,2]),HS_bandNum,MS_pixelNum).^2) ) ) ) ) / pi * 180 ;
                    D1 = max( reshape(permute(HSI,[3,1,2]),HS_bandNum,MS_pixelNum) , [] , 2 ).^2 ;
                    D2 = mean( ( reshape(permute(HSI,[3,1,2]),HS_bandNum,MS_pixelNum) - A_ryan*S_ryan ).^2 , 2 ) ;
                    PSNR_ryan     = mean( 10 * log10( D1./D2 ) ) ;
                    unix( ['echo ',num2str(RSNR_ryan)    ,' > RSNR_hybrid_ryan_SLFW_AFISTA'    ] ) ;
                    unix( ['echo ',num2str(RMSE_ryan)    ,' > RMSE_hybrid_ryan_SLFW_AFISTA'    ] ) ;
                    unix( ['echo ',num2str(SAM_ryan)     ,' > SAM_hybrid_ryan_SLFW_AFISTA'     ] ) ;
                    unix( ['echo ',num2str(PSNR_ryan)    ,' > PSNR_hybrid_ryan_SLFW_AFISTA'    ] ) ;
                    unix( ['echo ',num2str(max(t))       ,' > TIME_hybrid_ryan_SLFW_AFISTA'    ] ) ;
                    unix( ['echo ',num2str(numel(obj))   ,' > IT_used_hybrid_ryan_SLFW_AFISTA' ] ) ;
                end
                if( exist( 'stop.txt' , 'file' ) ) ; fprintf( 'stop signal received !!!\n@ dir : %s\n' , cd ) ; exit ; end ;
                %}
                % ====== %
                % HySure %
                % ====== %
                fprintf( 'HIS by HySure\n' ) ;
                logFileName = 'LOG_HySure.mat' ;
                if( ~exist( logFileName , 'file' ) )
                    HySure_opt.dsRatio     = dsRatio    ; HySure_opt.modelOrder  = modelOrder ;
                    HySure_opt.F           = F          ; HySure_opt.B           = B          ;
                    HySure_opt.subspDetect = 'VCA'      ; HySure_opt.iters       = 100        ;
                    HySure_opt.lamb_phi    = 5e-4       ; HySure_opt.lamb_m      = 1          ;
                    [ HSI_HySure , A_HySure , S_HySure , IT_used_HySure , TIME_HySure , returnInfo_HySure ] = HIS_HySure( HS , MS , HySure_opt ) ;
                    while( 1 )
                        try
                            save( logFileName , 'A_HySure'          , '-v7.3'   ) ;
                            save( logFileName , 'S_HySure'          , '-append' ) ;
                            save( logFileName , 'returnInfo_HySure' , '-append' ) ;
                            save( logFileName , 'TIME_HySure'       , '-append' ) ;
                            save( logFileName , 'IT_used_HySure'    , '-append' ) ;
                        catch
                            fprintf( 'error in save file %s ...\n' , logFileName ) ;
                            delete( logFileName ) ;
                            pause(3) ;
                        end
                        if( exist( logFileName , 'file' ) )
                            break ;
                        end
                    end               
                    RSNR_HySure     = 10*log10( mean2(HSI.^2) / mean2((HSI_HySure-HSI).^2) ) ;
                    RMSE_HySure     = 10*log10( sqrt( mean2( (HSI_HySure-HSI).^2 ) ) ) ;
                    SAM_HySure      = mean( real( acos( sum( (A_HySure*S_HySure).*reshape(permute(HSI,[3,1,2]),HS_bandNum,MS_pixelNum) ) ./ sqrt( sum((A_HySure*S_HySure).^2) .* sum(reshape(permute(HSI,[3,1,2]),HS_bandNum,MS_pixelNum).^2) ) ) ) ) / pi * 180 ;
                    D1 = max( reshape(permute(HSI,[3,1,2]),HS_bandNum,MS_pixelNum) , [] , 2 ).^2 ;
                    D2 = mean( ( reshape(permute(HSI,[3,1,2]),HS_bandNum,MS_pixelNum) - A_HySure*S_HySure ).^2 , 2 ) ;
                    PSNR_HySure     = mean( 10 * log10( D1./D2 ) ) ;
                    unix( ['echo ',num2str(RSNR_HySure)    ,' > RSNR_HySure'    ] ) ;
                    unix( ['echo ',num2str(RMSE_HySure)    ,' > RMSE_HySure'    ] ) ;
                    unix( ['echo ',num2str(SAM_HySure)     ,' > SAM_HySure'     ] ) ;
                    unix( ['echo ',num2str(PSNR_HySure)    ,' > PSNR_HySure'    ] ) ;
                    unix( ['echo ',num2str(TIME_HySure)    ,' > TIME_HySure'    ] ) ;
                    unix( ['echo ',num2str(IT_used_HySure) ,' > IT_used_HySure' ] ) ;
                    clear NMSE_End_HySure NMSE_Abu_HySure B1 B2 MSE_End_HySure C1 C2 MSE_Abu_HySure RSNR_HySure RMSE_HySure SAM_HySure D1 D2 PSNR_HySure TIME_HySure IT_used_HySure
                end
                unix( 'rm -f someOneIsHere.txt' ) ;
                unix( 'echo f > finish.txt' ) ;
            end
        else
            fprintf( 'finished !\n' ) ;
        end
    cd ..
end
