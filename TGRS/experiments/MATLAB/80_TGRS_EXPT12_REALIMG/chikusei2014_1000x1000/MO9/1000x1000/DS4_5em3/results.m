close all
clear
clc
SNRArr     = [ 40 , 30 , 20 ] ;
trialNum   = 100 ;

if( ~exist('TEMP.mat','file') )

RSNR_DRFUMI                          = zeros(trialNum,length(SNRArr)) ;
RMSE_DRFUMI                          = zeros(trialNum,length(SNRArr)) ;
SAM_DRFUMI                           = zeros(trialNum,length(SNRArr)) ;
PSNR_DRFUMI                          = zeros(trialNum,length(SNRArr)) ;
TIMEUSE_DRFUMI                       = zeros(trialNum,length(SNRArr)) ;
ITUSE_DRFUMI                         = zeros(trialNum,length(SNRArr)) ;

RSNR_CNMF                            = zeros(trialNum,length(SNRArr)) ;
RMSE_CNMF                            = zeros(trialNum,length(SNRArr)) ;
SAM_CNMF                             = zeros(trialNum,length(SNRArr)) ;
PSNR_CNMF                            = zeros(trialNum,length(SNRArr)) ;
TIMEUSE_CNMF                         = zeros(trialNum,length(SNRArr)) ;
ITUSE_CNMF                           = zeros(trialNum,length(SNRArr)) ;

RSNR_MFbA_ExFISTA                    = zeros(trialNum,length(SNRArr)) ;
RMSE_MFbA_ExFISTA                    = zeros(trialNum,length(SNRArr)) ;
SAM_MFbA_ExFISTA                     = zeros(trialNum,length(SNRArr)) ;
PSNR_MFbA_ExFISTA                    = zeros(trialNum,length(SNRArr)) ;
TIMEUSE_MFbA_ExFISTA                 = zeros(trialNum,length(SNRArr)) ;
ITUSE_MFbA_ExFISTA                   = zeros(trialNum,length(SNRArr)) ;

RSNR_MFbA_FISTA                      = zeros(trialNum,length(SNRArr)) ;
RMSE_MFbA_FISTA                      = zeros(trialNum,length(SNRArr)) ;
SAM_MFbA_FISTA                       = zeros(trialNum,length(SNRArr)) ;
PSNR_MFbA_FISTA                      = zeros(trialNum,length(SNRArr)) ;
TIMEUSE_MFbA_FISTA                   = zeros(trialNum,length(SNRArr)) ;
ITUSE_MFbA_FISTA                     = zeros(trialNum,length(SNRArr)) ;

RSNR_MFbA_HYBRID_SFW_APG             = zeros(trialNum,length(SNRArr)) ;
RMSE_MFbA_HYBRID_SFW_APG             = zeros(trialNum,length(SNRArr)) ;
SAM_MFbA_HYBRID_SFW_APG              = zeros(trialNum,length(SNRArr)) ;
PSNR_MFbA_HYBRID_SFW_APG             = zeros(trialNum,length(SNRArr)) ;
TIMEUSE_MFbA_HYBRID_SFW_APG          = zeros(trialNum,length(SNRArr)) ;
ITUSE_MFbA_HYBRID_SFW_APG            = zeros(trialNum,length(SNRArr)) ;

RSNR_MFbA_HYBRID_SFW_AFISTA          = zeros(trialNum,length(SNRArr)) ;
RMSE_MFbA_HYBRID_SFW_AFISTA          = zeros(trialNum,length(SNRArr)) ;
SAM_MFbA_HYBRID_SFW_AFISTA           = zeros(trialNum,length(SNRArr)) ;
PSNR_MFbA_HYBRID_SFW_AFISTA          = zeros(trialNum,length(SNRArr)) ;
TIMEUSE_MFbA_HYBRID_SFW_AFISTA       = zeros(trialNum,length(SNRArr)) ;
ITUSE_MFbA_HYBRID_SFW_AFISTA         = zeros(trialNum,length(SNRArr)) ;

RSNR_MFbA_HYBRID_SLFW_APG            = zeros(trialNum,length(SNRArr)) ;
RMSE_MFbA_HYBRID_SLFW_APG            = zeros(trialNum,length(SNRArr)) ;
SAM_MFbA_HYBRID_SLFW_APG             = zeros(trialNum,length(SNRArr)) ;
PSNR_MFbA_HYBRID_SLFW_APG            = zeros(trialNum,length(SNRArr)) ;
TIMEUSE_MFbA_HYBRID_SLFW_APG         = zeros(trialNum,length(SNRArr)) ;
ITUSE_MFbA_HYBRID_SLFW_APG           = zeros(trialNum,length(SNRArr)) ;

RSNR_MFbA_HYBRID_SLFW_AFISTA         = zeros(trialNum,length(SNRArr)) ;
RMSE_MFbA_HYBRID_SLFW_AFISTA         = zeros(trialNum,length(SNRArr)) ;
SAM_MFbA_HYBRID_SLFW_AFISTA          = zeros(trialNum,length(SNRArr)) ;
PSNR_MFbA_HYBRID_SLFW_AFISTA         = zeros(trialNum,length(SNRArr)) ;
TIMEUSE_MFbA_HYBRID_SLFW_AFISTA      = zeros(trialNum,length(SNRArr)) ;
ITUSE_MFbA_HYBRID_SLFW_AFISTA        = zeros(trialNum,length(SNRArr)) ;

RSNR_HYSURE                          = zeros(trialNum,length(SNRArr)) ;
RMSE_HYSURE                          = zeros(trialNum,length(SNRArr)) ;
SAM_HYSURE                           = zeros(trialNum,length(SNRArr)) ;
PSNR_HYSURE                          = zeros(trialNum,length(SNRArr)) ;
TIMEUSE_HYSURE                       = zeros(trialNum,length(SNRArr)) ;
ITUSE_HYSURE                         = zeros(trialNum,length(SNRArr)) ;

if( exist( 'exceptionLog.txt' , 'file' ) ) ; delete exceptionLog.txt ; end
diary( 'exceptionLog.txt' ) ;
for SNRCnt = 1:length(SNRArr)
    SNR_dB = SNRArr( SNRCnt ) ;
    for trialCnt = 1 : trialNum
        trialStr = sprintf( 'trial%04d' , trialCnt ) ;
        logPathName = ['SNR_',int2str(SNR_dB),'dB/',trialStr,'/'] ;
        disp( logPathName ) ;
        oriDir = cd ;
        cd( logPathName ) ;
            try
            
            try RSNR_DRFUMI(                     trialCnt , SNRCnt ) = dlmread( 'RSNR_DRFUMI' )                      ; catch ; pause(1) ; RSNR_DRFUMI(                      trialCnt , SNRCnt ) = dlmread( 'RSNR_DRFUMI' )                      ; end ; pause(0.01) ;  
            try RMSE_DRFUMI(                     trialCnt , SNRCnt ) = dlmread( 'RMSE_DRFUMI' )                      ; catch ; pause(1) ; RMSE_DRFUMI(                      trialCnt , SNRCnt ) = dlmread( 'RMSE_DRFUMI' )                      ; end ; pause(0.01) ;  
            try SAM_DRFUMI(                      trialCnt , SNRCnt ) = dlmread( 'SAM_DRFUMI' )                       ; catch ; pause(1) ; SAM_DRFUMI(                       trialCnt , SNRCnt ) = dlmread( 'SAM_DRFUMI' )                       ; end ; pause(0.01) ;  
            try PSNR_DRFUMI(                     trialCnt , SNRCnt ) = dlmread( 'PSNR_DRFUMI' )                      ; catch ; pause(1) ; PSNR_DRFUMI(                      trialCnt , SNRCnt ) = dlmread( 'PSNR_DRFUMI' )                      ; end ; pause(0.01) ;  
            try TIMEUSE_DRFUMI(                  trialCnt , SNRCnt ) = dlmread( 'TIME_DRFUMI')                       ; catch ; pause(1) ; TIMEUSE_DRFUMI(                   trialCnt , SNRCnt ) = dlmread( 'TIME_DRFUMI')                       ; end ; pause(0.01) ;  
            try ITUSE_DRFUMI(                    trialCnt , SNRCnt ) = dlmread( 'IT_used_DRFUMI')                    ; catch ; pause(1) ; ITUSE_DRFUMI(                     trialCnt , SNRCnt ) = dlmread( 'IT_used_DRFUMI')                    ; end ; pause(0.01) ;  
                
            try RSNR_CNMF(                       trialCnt , SNRCnt ) = dlmread( 'RSNR_CNMF' )                        ; catch ; pause(1) ; RSNR_CNMF(                        trialCnt , SNRCnt ) = dlmread( 'RSNR_CNMF' )                        ; end ; pause(0.01) ;  
            try RMSE_CNMF(                       trialCnt , SNRCnt ) = dlmread( 'RMSE_CNMF' )                        ; catch ; pause(1) ; RMSE_CNMF(                        trialCnt , SNRCnt ) = dlmread( 'RMSE_CNMF' )                        ; end ; pause(0.01) ;  
            try SAM_CNMF(                        trialCnt , SNRCnt ) = dlmread( 'SAM_CNMF' )                         ; catch ; pause(1) ; SAM_CNMF(                         trialCnt , SNRCnt ) = dlmread( 'SAM_CNMF' )                         ; end ; pause(0.01) ;  
            try PSNR_CNMF(                       trialCnt , SNRCnt ) = dlmread( 'PSNR_CNMF' )                        ; catch ; pause(1) ; PSNR_CNMF(                        trialCnt , SNRCnt ) = dlmread( 'PSNR_CNMF' )                        ; end ; pause(0.01) ;  
            try TIMEUSE_CNMF(                    trialCnt , SNRCnt ) = dlmread( 'TIME_CNMF')                         ; catch ; pause(1) ; TIMEUSE_CNMF(                     trialCnt , SNRCnt ) = dlmread( 'TIME_CNMF')                         ; end ; pause(0.01) ;  
            try ITUSE_CNMF(                      trialCnt , SNRCnt ) = dlmread( 'IT_used_CNMF')                      ; catch ; pause(1) ; ITUSE_CNMF(                       trialCnt , SNRCnt ) = dlmread( 'IT_used_CNMF')                      ; end ; pause(0.01) ;  

            try RSNR_MFbA_ExFISTA(               trialCnt , SNRCnt ) = dlmread( 'RSNR_MFbA_ExFISTA' )                ; catch ; pause(1) ; RSNR_MFbA_ExFISTA(                trialCnt , SNRCnt ) = dlmread( 'RSNR_MFbA_ExFISTA' )                ; end ; pause(0.01) ;
            try RMSE_MFbA_ExFISTA(               trialCnt , SNRCnt ) = dlmread( 'RMSE_MFbA_ExFISTA' )                ; catch ; pause(1) ; RMSE_MFbA_ExFISTA(                trialCnt , SNRCnt ) = dlmread( 'RMSE_MFbA_ExFISTA' )                ; end ; pause(0.01) ;
            try SAM_MFbA_ExFISTA(                trialCnt , SNRCnt ) = dlmread( 'SAM_MFbA_ExFISTA' )                 ; catch ; pause(1) ; SAM_MFbA_ExFISTA(                 trialCnt , SNRCnt ) = dlmread( 'SAM_MFbA_ExFISTA' )                 ; end ; pause(0.01) ;
            try PSNR_MFbA_ExFISTA(               trialCnt , SNRCnt ) = dlmread( 'PSNR_MFbA_ExFISTA' )                ; catch ; pause(1) ; PSNR_MFbA_ExFISTA(                trialCnt , SNRCnt ) = dlmread( 'PSNR_MFbA_ExFISTA' )                ; end ; pause(0.01) ;
            try TIMEUSE_MFbA_ExFISTA(            trialCnt , SNRCnt ) = dlmread( 'TIME_MFbA_ExFISTA' )                ; catch ; pause(1) ; TIMEUSE_MFbA_ExFISTA(             trialCnt , SNRCnt ) = dlmread( 'TIME_MFbA_ExFISTA' )                ; end ; pause(0.01) ;
            try ITUSE_MFbA_ExFISTA(              trialCnt , SNRCnt ) = dlmread( 'IT_used_MFbA_ExFISTA' )             ; catch ; pause(1) ; ITUSE_MFbA_ExFISTA(               trialCnt , SNRCnt ) = dlmread( 'IT_used_MFbA_ExFISTA' )             ; end ; pause(0.01) ;

            try RSNR_MFbA_FISTA(                 trialCnt , SNRCnt ) = dlmread( 'RSNR_MFbA_FISTA' )                  ; catch ; pause(1) ; RSNR_MFbA_FISTA(                  trialCnt , SNRCnt ) = dlmread( 'RSNR_MFbA_FISTA' )                  ; end ; pause(0.01) ;
            try RMSE_MFbA_FISTA(                 trialCnt , SNRCnt ) = dlmread( 'RMSE_MFbA_FISTA' )                  ; catch ; pause(1) ; RMSE_MFbA_FISTA(                  trialCnt , SNRCnt ) = dlmread( 'RMSE_MFbA_FISTA' )                  ; end ; pause(0.01) ;
            try SAM_MFbA_FISTA(                  trialCnt , SNRCnt ) = dlmread( 'SAM_MFbA_FISTA' )                   ; catch ; pause(1) ; SAM_MFbA_FISTA(                   trialCnt , SNRCnt ) = dlmread( 'SAM_MFbA_FISTA' )                   ; end ; pause(0.01) ;
            try PSNR_MFbA_FISTA(                 trialCnt , SNRCnt ) = dlmread( 'PSNR_MFbA_FISTA' )                  ; catch ; pause(1) ; PSNR_MFbA_FISTA(                  trialCnt , SNRCnt ) = dlmread( 'PSNR_MFbA_FISTA' )                  ; end ; pause(0.01) ;
            try TIMEUSE_MFbA_FISTA(              trialCnt , SNRCnt ) = dlmread( 'TIME_MFbA_FISTA' )                  ; catch ; pause(1) ; TIMEUSE_MFbA_FISTA(               trialCnt , SNRCnt ) = dlmread( 'TIME_MFbA_FISTA' )                  ; end ; pause(0.01) ;
            try ITUSE_MFbA_FISTA(                trialCnt , SNRCnt ) = dlmread( 'IT_used_MFbA_FISTA' )               ; catch ; pause(1) ; ITUSE_MFbA_FISTA(                 trialCnt , SNRCnt ) = dlmread( 'IT_used_MFbA_FISTA' )               ; end ; pause(0.01) ;

            try RSNR_MFbA_HYBRID_SFW_APG(        trialCnt , SNRCnt ) = dlmread( 'RSNR_MFbA_HYBRID_SFW_APG' )         ; catch ; pause(1) ; RSNR_MFbA_HYBRID_SFW_APG(         trialCnt , SNRCnt ) = dlmread( 'RSNR_MFbA_HYBRID_SFW_APG' )         ; end ; pause(0.01) ;
            try RMSE_MFbA_HYBRID_SFW_APG(        trialCnt , SNRCnt ) = dlmread( 'RMSE_MFbA_HYBRID_SFW_APG' )         ; catch ; pause(1) ; RMSE_MFbA_HYBRID_SFW_APG(         trialCnt , SNRCnt ) = dlmread( 'RMSE_MFbA_HYBRID_SFW_APG' )         ; end ; pause(0.01) ;
            try SAM_MFbA_HYBRID_SFW_APG(         trialCnt , SNRCnt ) = dlmread( 'SAM_MFbA_HYBRID_SFW_APG' )          ; catch ; pause(1) ; SAM_MFbA_HYBRID_SFW_APG(          trialCnt , SNRCnt ) = dlmread( 'SAM_MFbA_HYBRID_SFW_APG' )          ; end ; pause(0.01) ;
            try PSNR_MFbA_HYBRID_SFW_APG(        trialCnt , SNRCnt ) = dlmread( 'PSNR_MFbA_HYBRID_SFW_APG' )         ; catch ; pause(1) ; PSNR_MFbA_HYBRID_SFW_APG(         trialCnt , SNRCnt ) = dlmread( 'PSNR_MFbA_HYBRID_SFW_APG' )         ; end ; pause(0.01) ;
            try TIMEUSE_MFbA_HYBRID_SFW_APG(     trialCnt , SNRCnt ) = dlmread( 'TIME_MFbA_HYBRID_SFW_APG' )         ; catch ; pause(1) ; TIMEUSE_MFbA_HYBRID_SFW_APG(      trialCnt , SNRCnt ) = dlmread( 'TIME_MFbA_HYBRID_SFW_APG' )         ; end ; pause(0.01) ;
            try ITUSE_MFbA_HYBRID_SFW_APG(       trialCnt , SNRCnt ) = dlmread( 'IT_used_MFbA_HYBRID_SFW_APG' )      ; catch ; pause(1) ; ITUSE_MFbA_HYBRID_SFW_APG(        trialCnt , SNRCnt ) = dlmread( 'IT_used_MFbA_HYBRID_SFW_APG' )      ; end ; pause(0.01) ;

            try RSNR_MFbA_HYBRID_SFW_AFISTA(     trialCnt , SNRCnt ) = dlmread( 'RSNR_MFbA_HYBRID_SFW_AFISTA' )      ; catch ; pause(1) ; RSNR_MFbA_HYBRID_SFW_AFISTA(      trialCnt , SNRCnt ) = dlmread( 'RSNR_MFbA_HYBRID_SFW_AFISTA' )      ; end ; pause(0.01) ;
            try RMSE_MFbA_HYBRID_SFW_AFISTA(     trialCnt , SNRCnt ) = dlmread( 'RMSE_MFbA_HYBRID_SFW_AFISTA' )      ; catch ; pause(1) ; RMSE_MFbA_HYBRID_SFW_AFISTA(      trialCnt , SNRCnt ) = dlmread( 'RMSE_MFbA_HYBRID_SFW_AFISTA' )      ; end ; pause(0.01) ;
            try SAM_MFbA_HYBRID_SFW_AFISTA(      trialCnt , SNRCnt ) = dlmread( 'SAM_MFbA_HYBRID_SFW_AFISTA' )       ; catch ; pause(1) ; SAM_MFbA_HYBRID_SFW_AFISTA(       trialCnt , SNRCnt ) = dlmread( 'SAM_MFbA_HYBRID_SFW_AFISTA' )       ; end ; pause(0.01) ;
            try PSNR_MFbA_HYBRID_SFW_AFISTA(     trialCnt , SNRCnt ) = dlmread( 'PSNR_MFbA_HYBRID_SFW_AFISTA' )      ; catch ; pause(1) ; PSNR_MFbA_HYBRID_SFW_AFISTA(      trialCnt , SNRCnt ) = dlmread( 'PSNR_MFbA_HYBRID_SFW_AFISTA' )      ; end ; pause(0.01) ;
            try TIMEUSE_MFbA_HYBRID_SFW_AFISTA(  trialCnt , SNRCnt ) = dlmread( 'TIME_MFbA_HYBRID_SFW_AFISTA' )      ; catch ; pause(1) ; TIMEUSE_MFbA_HYBRID_SFW_AFISTA(   trialCnt , SNRCnt ) = dlmread( 'TIME_MFbA_HYBRID_SFW_AFISTA' )      ; end ; pause(0.01) ;
            try ITUSE_MFbA_HYBRID_SFW_AFISTA(    trialCnt , SNRCnt ) = dlmread( 'IT_used_MFbA_HYBRID_SFW_AFISTA' )   ; catch ; pause(1) ; ITUSE_MFbA_HYBRID_SFW_AFISTA(     trialCnt , SNRCnt ) = dlmread( 'IT_used_MFbA_HYBRID_SFW_AFISTA' )   ; end ; pause(0.01) ;

            try RSNR_MFbA_HYBRID_SLFW_APG(       trialCnt , SNRCnt ) = dlmread( 'RSNR_MFbA_HYBRID_SLFW_APG' )        ; catch ; pause(1) ; RSNR_MFbA_HYBRID_SLFW_APG(        trialCnt , SNRCnt ) = dlmread( 'RSNR_MFbA_HYBRID_SLFW_APG' )        ; end ; pause(0.01) ;
            try RMSE_MFbA_HYBRID_SLFW_APG(       trialCnt , SNRCnt ) = dlmread( 'RMSE_MFbA_HYBRID_SLFW_APG' )        ; catch ; pause(1) ; RMSE_MFbA_HYBRID_SLFW_APG(        trialCnt , SNRCnt ) = dlmread( 'RMSE_MFbA_HYBRID_SLFW_APG' )        ; end ; pause(0.01) ;
            try SAM_MFbA_HYBRID_SLFW_APG(        trialCnt , SNRCnt ) = dlmread( 'SAM_MFbA_HYBRID_SLFW_APG' )         ; catch ; pause(1) ; SAM_MFbA_HYBRID_SLFW_APG(         trialCnt , SNRCnt ) = dlmread( 'SAM_MFbA_HYBRID_SLFW_APG' )         ; end ; pause(0.01) ;
            try PSNR_MFbA_HYBRID_SLFW_APG(       trialCnt , SNRCnt ) = dlmread( 'PSNR_MFbA_HYBRID_SLFW_APG' )        ; catch ; pause(1) ; PSNR_MFbA_HYBRID_SLFW_APG(        trialCnt , SNRCnt ) = dlmread( 'PSNR_MFbA_HYBRID_SLFW_APG' )        ; end ; pause(0.01) ;
            try TIMEUSE_MFbA_HYBRID_SLFW_APG(    trialCnt , SNRCnt ) = dlmread( 'TIME_MFbA_HYBRID_SLFW_APG' )        ; catch ; pause(1) ; TIMEUSE_MFbA_HYBRID_SLFW_APG(     trialCnt , SNRCnt ) = dlmread( 'TIME_MFbA_HYBRID_SLFW_APG' )        ; end ; pause(0.01) ;
            try ITUSE_MFbA_HYBRID_SLFW_APG(      trialCnt , SNRCnt ) = dlmread( 'IT_used_MFbA_HYBRID_SLFW_APG' )     ; catch ; pause(1) ; ITUSE_MFbA_HYBRID_SLFW_APG(       trialCnt , SNRCnt ) = dlmread( 'IT_used_MFbA_HYBRID_SLFW_APG' )     ; end ; pause(0.01) ;

            try RSNR_MFbA_HYBRID_SLFW_AFISTA(    trialCnt , SNRCnt ) = dlmread( 'RSNR_MFbA_HYBRID_SLFW_AFISTA' )     ; catch ; pause(1) ; RSNR_MFbA_HYBRID_SLFW_AFISTA(     trialCnt , SNRCnt ) = dlmread( 'RSNR_MFbA_HYBRID_SLFW_AFISTA' )     ; end ; pause(0.01) ;
            try RMSE_MFbA_HYBRID_SLFW_AFISTA(    trialCnt , SNRCnt ) = dlmread( 'RMSE_MFbA_HYBRID_SLFW_AFISTA' )     ; catch ; pause(1) ; RMSE_MFbA_HYBRID_SLFW_AFISTA(     trialCnt , SNRCnt ) = dlmread( 'RMSE_MFbA_HYBRID_SLFW_AFISTA' )     ; end ; pause(0.01) ;
            try SAM_MFbA_HYBRID_SLFW_AFISTA(     trialCnt , SNRCnt ) = dlmread( 'SAM_MFbA_HYBRID_SLFW_AFISTA' )      ; catch ; pause(1) ; SAM_MFbA_HYBRID_SLFW_AFISTA(      trialCnt , SNRCnt ) = dlmread( 'SAM_MFbA_HYBRID_SLFW_AFISTA' )      ; end ; pause(0.01) ;
            try PSNR_MFbA_HYBRID_SLFW_AFISTA(    trialCnt , SNRCnt ) = dlmread( 'PSNR_MFbA_HYBRID_SLFW_AFISTA' )     ; catch ; pause(1) ; PSNR_MFbA_HYBRID_SLFW_AFISTA(     trialCnt , SNRCnt ) = dlmread( 'PSNR_MFbA_HYBRID_SLFW_AFISTA' )     ; end ; pause(0.01) ;
            try TIMEUSE_MFbA_HYBRID_SLFW_AFISTA( trialCnt , SNRCnt ) = dlmread( 'TIME_MFbA_HYBRID_SLFW_AFISTA' )     ; catch ; pause(1) ; TIMEUSE_MFbA_HYBRID_SLFW_AFISTA(  trialCnt , SNRCnt ) = dlmread( 'TIME_MFbA_HYBRID_SLFW_AFISTA' )     ; end ; pause(0.01) ;
            try ITUSE_MFbA_HYBRID_SLFW_AFISTA(   trialCnt , SNRCnt ) = dlmread( 'IT_used_MFbA_HYBRID_SLFW_AFISTA' )  ; catch ; pause(1) ; ITUSE_MFbA_HYBRID_SLFW_AFISTA(    trialCnt , SNRCnt ) = dlmread( 'IT_used_MFbA_HYBRID_SLFW_AFISTA' )  ; end ; pause(0.01) ;

            try RSNR_HYSURE(                     trialCnt , SNRCnt ) = dlmread( 'RSNR_HySure' )                      ; catch ; pause(1) ; RSNR_HYSURE(                      trialCnt , SNRCnt ) = dlmread( 'RSNR_HySure' )                      ; end ; pause(0.01) ;
            try RMSE_HYSURE(                     trialCnt , SNRCnt ) = dlmread( 'RMSE_HySure' )                      ; catch ; pause(1) ; RMSE_HYSURE(                      trialCnt , SNRCnt ) = dlmread( 'RMSE_HySure' )                      ; end ; pause(0.01) ;
            try SAM_HYSURE(                      trialCnt , SNRCnt ) = dlmread( 'SAM_HySure' )                       ; catch ; pause(1) ; SAM_HYSURE(                       trialCnt , SNRCnt ) = dlmread( 'SAM_HySure' )                       ; end ; pause(0.01) ;
            try PSNR_HYSURE(                     trialCnt , SNRCnt ) = dlmread( 'PSNR_HySure' )                      ; catch ; pause(1) ; PSNR_HYSURE(                      trialCnt , SNRCnt ) = dlmread( 'PSNR_HySure' )                      ; end ; pause(0.01) ;
            try TIMEUSE_HYSURE(                  trialCnt , SNRCnt ) = dlmread( 'TIME_HySure' )                      ; catch ; pause(1) ; TIMEUSE_HYSURE(                   trialCnt , SNRCnt ) = dlmread( 'TIME_HySure' )                      ; end ; pause(0.01) ;
            try ITUSE_HYSURE(                    trialCnt , SNRCnt ) = dlmread( 'IT_used_HySure' )                   ; catch ; pause(1) ; ITUSE_HYSURE(                     trialCnt , SNRCnt ) = dlmread( 'IT_used_HySure' )                   ; end ; pause(0.01) ;
            
            catch
            disp(pwd);
            end
        cd( oriDir ) ;
    end
end
save( 'TEMP.mat' ) ;
diary off
else
load TEMP.mat
end
if( exist( 'results.txt' , 'file' ) )
    delete results.txt
end
diary( 'results.txt' ) ;
unix( 'date' ) ;
unix( 'pwd' ) ;
fprintf( 'model order: 16\n' ) ;
fprintf( 'number of trials: %d\n' , trialNum ) ;
hline  = '----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n' ;
empCel = '    -    ' ;
fprintf( hline ) ;
fprintf( '|%-5s|%-20s|%-16s|%-16s|%-16s|%-16s|%-16s|%-16s|\n'                                                        ,  'SNR'                   ,  'Method'             ,  'RSNR(HSI)'                                                                                                                                   ,  'RMSE(HSI)'                                                                                                                                   ,  'SAM(HSI)'                                                                                                                                  ,  'PSNR(HSI)'                                                                                                                                   ,  'time'                                                                                                                                              ,  'outer loop iter'                                                                                                                               ) ;
fprintf( '|%-5s|%-20s|%-16s|%-16s|%-16s|%-16s|%-16s|%-16s|\n'                                                        ,  '(dB)'                  ,  ''                   ,  '(dB)'                                                                                                                                        ,  '(dB)'                                                                                                                                        ,  '(deg)'                                                                                                                                     ,  '(dB)'                                                                                                                                        ,  '(sec)'                                                                                                                                             ,  ''                                                                                                                                              ) ;
fprintf( hline ) ;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
for SNRCnt = 1:length(SNRArr)
fprintf( '|%-5s|%-20s|%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |\n'  , num2str(SNRArr(SNRCnt))  ,  'FUMI'               , num2str(round(mean(RSNR_DRFUMI(:,SNRCnt)                  ),2)) ,  char(177)  , num2str(round(std(RSNR_DRFUMI(:,SNRCnt)                  ),2)) , num2str(round(mean(RMSE_DRFUMI(:,SNRCnt)                  ),2)) ,  char(177)  , num2str(round(std(RMSE_DRFUMI(:,SNRCnt)                  ),2)) , num2str(round(mean(SAM_DRFUMI(:,SNRCnt)                  ),2)) ,  char(177)  , num2str(round(std(SAM_DRFUMI(:,SNRCnt)                  ),2)) , num2str(round(mean(PSNR_DRFUMI(:,SNRCnt)                  ),2)) ,  char(177)  , num2str(round(std(PSNR_DRFUMI(:,SNRCnt)                  ),2)) , num2str(round(mean(TIMEUSE_DRFUMI(:,SNRCnt)                  ),2)) ,  char(177)  , num2str(round(std(TIMEUSE_DRFUMI(:,SNRCnt)                  ),2)) , num2str(round(mean(ITUSE_DRFUMI(:,SNRCnt)                  ),2)) ,  char(177)  , num2str(round(std(ITUSE_DRFUMI(:,SNRCnt)                  ),2)) ) ;
fprintf( '|%-5s|%-20s|%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |\n'  , num2str(SNRArr(SNRCnt))  ,  'CNMF'               , num2str(round(mean(RSNR_CNMF(:,SNRCnt)                    ),2)) ,  char(177)  , num2str(round(std(RSNR_CNMF(:,SNRCnt)                    ),2)) , num2str(round(mean(RMSE_CNMF(:,SNRCnt)                    ),2)) ,  char(177)  , num2str(round(std(RMSE_CNMF(:,SNRCnt)                    ),2)) , num2str(round(mean(SAM_CNMF(:,SNRCnt)                    ),2)) ,  char(177)  , num2str(round(std(SAM_CNMF(:,SNRCnt)                    ),2)) , num2str(round(mean(PSNR_CNMF(:,SNRCnt)                    ),2)) ,  char(177)  , num2str(round(std(PSNR_CNMF(:,SNRCnt)                    ),2)) , num2str(round(mean(TIMEUSE_CNMF(:,SNRCnt)                    ),2)) ,  char(177)  , num2str(round(std(TIMEUSE_CNMF(:,SNRCnt)                    ),2)) , num2str(round(mean(ITUSE_CNMF(:,SNRCnt)                    ),2)) ,  char(177)  , num2str(round(std(ITUSE_CNMF(:,SNRCnt)                    ),2)) ) ;
fprintf( '|%-5s|%-20s|%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |\n'  , num2str(SNRArr(SNRCnt))  ,  'HySure'             , num2str(round(mean(RSNR_HYSURE(:,SNRCnt)                  ),2)) ,  char(177)  , num2str(round(std(RSNR_HYSURE(:,SNRCnt)                  ),2)) , num2str(round(mean(RMSE_HYSURE(:,SNRCnt)                  ),2)) ,  char(177)  , num2str(round(std(RMSE_HYSURE(:,SNRCnt)                  ),2)) , num2str(round(mean(SAM_HYSURE(:,SNRCnt)                  ),2)) ,  char(177)  , num2str(round(std(SAM_HYSURE(:,SNRCnt)                  ),2)) , num2str(round(mean(PSNR_HYSURE(:,SNRCnt)                  ),2)) ,  char(177)  , num2str(round(std(PSNR_HYSURE(:,SNRCnt)                  ),2)) , num2str(round(mean(TIMEUSE_HYSURE(:,SNRCnt)                  ),2)) ,  char(177)  , num2str(round(std(TIMEUSE_HYSURE(:,SNRCnt)                  ),2)) , num2str(round(mean(ITUSE_HYSURE(:,SNRCnt)                  ),2)) ,  char(177)  , num2str(round(std(ITUSE_HYSURE(:,SNRCnt)                  ),2)) ) ;
fprintf( '|%-5s|%-20s|%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |\n'  , num2str(SNRArr(SNRCnt))  ,  'Ex.FISTA'           , num2str(round(mean(RSNR_MFbA_ExFISTA(:,SNRCnt)            ),2)) ,  char(177)  , num2str(round(std(RSNR_MFbA_ExFISTA(:,SNRCnt)            ),2)) , num2str(round(mean(RMSE_MFbA_ExFISTA(:,SNRCnt)            ),2)) ,  char(177)  , num2str(round(std(RMSE_MFbA_ExFISTA(:,SNRCnt)            ),2)) , num2str(round(mean(SAM_MFbA_ExFISTA(:,SNRCnt)            ),2)) ,  char(177)  , num2str(round(std(SAM_MFbA_ExFISTA(:,SNRCnt)            ),2)) , num2str(round(mean(PSNR_MFbA_ExFISTA(:,SNRCnt)            ),2)) ,  char(177)  , num2str(round(std(PSNR_MFbA_ExFISTA(:,SNRCnt)            ),2)) , num2str(round(mean(TIMEUSE_MFbA_ExFISTA(:,SNRCnt)            ),2)) ,  char(177)  , num2str(round(std(TIMEUSE_MFbA_ExFISTA(:,SNRCnt)            ),2)) , num2str(round(mean(ITUSE_MFbA_ExFISTA(:,SNRCnt)            ),2)) ,  char(177)  , num2str(round(std(ITUSE_MFbA_ExFISTA(:,SNRCnt)            ),2)) ) ;
fprintf( '|%-5s|%-20s|%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |\n'  , num2str(SNRArr(SNRCnt))  ,  'MFbA FISTA'         , num2str(round(mean(RSNR_MFbA_FISTA(:,SNRCnt)              ),2)) ,  char(177)  , num2str(round(std(RSNR_MFbA_FISTA(:,SNRCnt)              ),2)) , num2str(round(mean(RMSE_MFbA_FISTA(:,SNRCnt)              ),2)) ,  char(177)  , num2str(round(std(RMSE_MFbA_FISTA(:,SNRCnt)              ),2)) , num2str(round(mean(SAM_MFbA_FISTA(:,SNRCnt)              ),2)) ,  char(177)  , num2str(round(std(SAM_MFbA_FISTA(:,SNRCnt)              ),2)) , num2str(round(mean(PSNR_MFbA_FISTA(:,SNRCnt)              ),2)) ,  char(177)  , num2str(round(std(PSNR_MFbA_FISTA(:,SNRCnt)              ),2)) , num2str(round(mean(TIMEUSE_MFbA_FISTA(:,SNRCnt)              ),2)) ,  char(177)  , num2str(round(std(TIMEUSE_MFbA_FISTA(:,SNRCnt)              ),2)) , num2str(round(mean(ITUSE_MFbA_FISTA(:,SNRCnt)              ),2)) ,  char(177)  , num2str(round(std(ITUSE_MFbA_FISTA(:,SNRCnt)              ),2)) ) ;
%fprintf( '|%-5s|%-20s|%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |\n'  , num2str(SNRArr(SNRCnt))  ,  'MFbA Hybrid FW PG'  , num2str(round(mean(RSNR_MFbA_HYBRID_SFW_APG(:,SNRCnt)     ),2)) ,  char(177)  , num2str(round(std(RSNR_MFbA_HYBRID_SFW_APG(:,SNRCnt)     ),2)) , num2str(round(mean(RMSE_MFbA_HYBRID_SFW_APG(:,SNRCnt)     ),2)) ,  char(177)  , num2str(round(std(RMSE_MFbA_HYBRID_SFW_APG(:,SNRCnt)     ),2)) , num2str(round(mean(SAM_MFbA_HYBRID_SFW_APG(:,SNRCnt)     ),2)) ,  char(177)  , num2str(round(std(SAM_MFbA_HYBRID_SFW_APG(:,SNRCnt)     ),2)) , num2str(round(mean(PSNR_MFbA_HYBRID_SFW_APG(:,SNRCnt)     ),2)) ,  char(177)  , num2str(round(std(PSNR_MFbA_HYBRID_SFW_APG(:,SNRCnt)     ),2)) , num2str(round(mean(TIMEUSE_MFbA_HYBRID_SFW_APG(:,SNRCnt)     ),2)) ,  char(177)  , num2str(round(std(TIMEUSE_MFbA_HYBRID_SFW_APG(:,SNRCnt)     ),2)) , num2str(round(mean(ITUSE_MFbA_HYBRID_SFW_APG(:,SNRCnt)     ),2)) ,  char(177)  , num2str(round(std(ITUSE_MFbA_HYBRID_SFW_APG(:,SNRCnt)     ),2)) ) ;
fprintf( '|%-5s|%-20s|%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |\n'  , num2str(SNRArr(SNRCnt))  ,  'MFbA Hybrid FW FPG' , num2str(round(mean(RSNR_MFbA_HYBRID_SFW_AFISTA(:,SNRCnt)  ),2)) ,  char(177)  , num2str(round(std(RSNR_MFbA_HYBRID_SFW_AFISTA(:,SNRCnt)  ),2)) , num2str(round(mean(RMSE_MFbA_HYBRID_SFW_AFISTA(:,SNRCnt)  ),2)) ,  char(177)  , num2str(round(std(RMSE_MFbA_HYBRID_SFW_AFISTA(:,SNRCnt)  ),2)) , num2str(round(mean(SAM_MFbA_HYBRID_SFW_AFISTA(:,SNRCnt)  ),2)) ,  char(177)  , num2str(round(std(SAM_MFbA_HYBRID_SFW_AFISTA(:,SNRCnt)  ),2)) , num2str(round(mean(PSNR_MFbA_HYBRID_SFW_AFISTA(:,SNRCnt)  ),2)) ,  char(177)  , num2str(round(std(PSNR_MFbA_HYBRID_SFW_AFISTA(:,SNRCnt)  ),2)) , num2str(round(mean(TIMEUSE_MFbA_HYBRID_SFW_AFISTA(:,SNRCnt)  ),2)) ,  char(177)  , num2str(round(std(TIMEUSE_MFbA_HYBRID_SFW_AFISTA(:,SNRCnt)  ),2)) , num2str(round(mean(ITUSE_MFbA_HYBRID_SFW_AFISTA(:,SNRCnt)  ),2)) ,  char(177)  , num2str(round(std(ITUSE_MFbA_HYBRID_SFW_AFISTA(:,SNRCnt)  ),2)) ) ;
%fprintf( '|%-5s|%-20s|%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |\n'  , num2str(SNRArr(SNRCnt))  ,  'MFbA Hybrid LFW PG' , num2str(round(mean(RSNR_MFbA_HYBRID_SLFW_APG(:,SNRCnt)    ),2)) ,  char(177)  , num2str(round(std(RSNR_MFbA_HYBRID_SLFW_APG(:,SNRCnt)    ),2)) , num2str(round(mean(RMSE_MFbA_HYBRID_SLFW_APG(:,SNRCnt)    ),2)) ,  char(177)  , num2str(round(std(RMSE_MFbA_HYBRID_SLFW_APG(:,SNRCnt)    ),2)) , num2str(round(mean(SAM_MFbA_HYBRID_SLFW_APG(:,SNRCnt)    ),2)) ,  char(177)  , num2str(round(std(SAM_MFbA_HYBRID_SLFW_APG(:,SNRCnt)    ),2)) , num2str(round(mean(PSNR_MFbA_HYBRID_SLFW_APG(:,SNRCnt)    ),2)) ,  char(177)  , num2str(round(std(PSNR_MFbA_HYBRID_SLFW_APG(:,SNRCnt)    ),2)) , num2str(round(mean(TIMEUSE_MFbA_HYBRID_SLFW_APG(:,SNRCnt)    ),2)) ,  char(177)  , num2str(round(std(TIMEUSE_MFbA_HYBRID_SLFW_APG(:,SNRCnt)    ),2)) , num2str(round(mean(ITUSE_MFbA_HYBRID_SLFW_APG(:,SNRCnt)    ),2)) ,  char(177)  , num2str(round(std(ITUSE_MFbA_HYBRID_SLFW_APG(:,SNRCnt)    ),2)) ) ;
%fprintf( '|%-5s|%-20s|%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |\n'  , num2str(SNRArr(SNRCnt))  ,  'MFbA Hybrid LFW FPG', num2str(round(mean(RSNR_MFbA_HYBRID_SLFW_AFISTA(:,SNRCnt) ),2)) ,  char(177)  , num2str(round(std(RSNR_MFbA_HYBRID_SLFW_AFISTA(:,SNRCnt) ),2)) , num2str(round(mean(RMSE_MFbA_HYBRID_SLFW_AFISTA(:,SNRCnt) ),2)) ,  char(177)  , num2str(round(std(RMSE_MFbA_HYBRID_SLFW_AFISTA(:,SNRCnt) ),2)) , num2str(round(mean(SAM_MFbA_HYBRID_SLFW_AFISTA(:,SNRCnt) ),2)) ,  char(177)  , num2str(round(std(SAM_MFbA_HYBRID_SLFW_AFISTA(:,SNRCnt) ),2)) , num2str(round(mean(PSNR_MFbA_HYBRID_SLFW_AFISTA(:,SNRCnt) ),2)) ,  char(177)  , num2str(round(std(PSNR_MFbA_HYBRID_SLFW_AFISTA(:,SNRCnt) ),2)) , num2str(round(mean(TIMEUSE_MFbA_HYBRID_SLFW_AFISTA(:,SNRCnt) ),2)) ,  char(177)  , num2str(round(std(TIMEUSE_MFbA_HYBRID_SLFW_AFISTA(:,SNRCnt) ),2)) , num2str(round(mean(ITUSE_MFbA_HYBRID_SLFW_AFISTA(:,SNRCnt) ),2)) ,  char(177)  , num2str(round(std(ITUSE_MFbA_HYBRID_SLFW_AFISTA(:,SNRCnt) ),2)) ) ;
%fprintf( '|%-5s|%-20s|%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |\n'  , num2str(SNRArr(SNRCnt))  ,  'Ryan Hybrid FW PG'  , num2str(round(mean(RSNR_hybrid_ryan_SLFW_APG(:,SNRCnt)    ),2)) ,  char(177)  , num2str(round(std(RSNR_hybrid_ryan_SLFW_APG(:,SNRCnt)    ),2)) , num2str(round(mean(RMSE_hybrid_ryan_SLFW_APG(:,SNRCnt)    ),2)) ,  char(177)  , num2str(round(std(RMSE_hybrid_ryan_SLFW_APG(:,SNRCnt)    ),2)) , num2str(round(mean(SAM_hybrid_ryan_SLFW_APG(:,SNRCnt)    ),2)) ,  char(177)  , num2str(round(std(SAM_hybrid_ryan_SLFW_APG(:,SNRCnt)    ),2)) , num2str(round(mean(PSNR_hybrid_ryan_SLFW_APG(:,SNRCnt)    ),2)) ,  char(177)  , num2str(round(std(PSNR_hybrid_ryan_SLFW_APG(:,SNRCnt)    ),2)) , num2str(round(mean(TIMEUSE_hybrid_ryan_SLFW_APG(:,SNRCnt)    ),2)) ,  char(177)  , num2str(round(std(TIMEUSE_hybrid_ryan_SLFW_APG(:,SNRCnt)    ),2)) , num2str(round(mean(ITUSE_hybrid_ryan_SLFW_APG(:,SNRCnt)    ),2)) ,  char(177)  , num2str(round(std(ITUSE_hybrid_ryan_SLFW_APG(:,SNRCnt)    ),2)) ) ;
%fprintf( '|%-5s|%-20s|%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |%-9s%-2s%2.5s |\n'  , num2str(SNRArr(SNRCnt))  ,  'Ryan Hybrid FW FPG' , num2str(round(mean(RSNR_hybrid_ryan_SLFW_AFISTA(:,SNRCnt) ),2)) ,  char(177)  , num2str(round(std(RSNR_hybrid_ryan_SLFW_AFISTA(:,SNRCnt) ),2)) , num2str(round(mean(RMSE_hybrid_ryan_SLFW_AFISTA(:,SNRCnt) ),2)) ,  char(177)  , num2str(round(std(RMSE_hybrid_ryan_SLFW_AFISTA(:,SNRCnt) ),2)) , num2str(round(mean(SAM_hybrid_ryan_SLFW_AFISTA(:,SNRCnt) ),2)) ,  char(177)  , num2str(round(std(SAM_hybrid_ryan_SLFW_AFISTA(:,SNRCnt) ),2)) , num2str(round(mean(PSNR_hybrid_ryan_SLFW_AFISTA(:,SNRCnt) ),2)) ,  char(177)  , num2str(round(std(PSNR_hybrid_ryan_SLFW_AFISTA(:,SNRCnt) ),2)) , num2str(round(mean(TIMEUSE_hybrid_ryan_SLFW_AFISTA(:,SNRCnt) ),2)) ,  char(177)  , num2str(round(std(TIMEUSE_hybrid_ryan_SLFW_AFISTA(:,SNRCnt) ),2)) , num2str(round(mean(ITUSE_hybrid_ryan_SLFW_AFISTA(:,SNRCnt) ),2)) ,  char(177)  , num2str(round(std(ITUSE_hybrid_ryan_SLFW_AFISTA(:,SNRCnt) ),2)) ) ;
fprintf( hline ) ;
end
diary off
