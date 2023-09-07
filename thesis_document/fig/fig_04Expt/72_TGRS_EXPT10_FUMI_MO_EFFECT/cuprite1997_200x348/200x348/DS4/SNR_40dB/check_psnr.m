clear
clc
if( ~exist( 'TEMP_PSNR.mat' , 'file' ) )
modelOrderArr = 3 : 3 : 48 ;
trialNum      = 100       ;
psnr_FISTA  = -ones( trialNum , length(modelOrderArr) ) ;
psnr_FW     = -ones( trialNum , length(modelOrderArr) ) ;
%psnr_HYBRID = -ones( trialNum , length(modelOrderArr) ) ;
for n = 1 : length(modelOrderArr)
    N = modelOrderArr(n) ;
    cd( ['MO',int2str(N)] ) ;
        for trialCnt = 1 : trialNum
            trialFolderName = sprintf('trial%04d',trialCnt) ;
            cd( trialFolderName ) ;
                cd ;
                fileName = 'PSNR_MFbA_fista_subprobIt_1'                 ; if( exist( fileName , 'file' ) ) ; psnr_FISTA(  trialCnt , n ) = dlmread( fileName ) ; end ;
                fileName = 'PSNR_MFbA_FW_subprobIt_1'                    ; if( exist( fileName , 'file' ) ) ; psnr_FW(     trialCnt , n ) = dlmread( fileName ) ; end ;
                %fileName = 'PSNR_MFbA_HYBRID_S_FW1_A_FISTA1_subprobIt_1' ; if( exist( fileName , 'file' ) ) ; psnr_HYBRID( trialCnt , n ) = dlmread( fileName ) ; end ;
            cd ..
        end
    cd ..
end
save TEMP_PSNR
else
load TEMP_PSNR
end
intvl = 10 ;
for n = 1 : length(modelOrderArr)
S = psnr_FISTA(:,n) ; nolarge_idx      = S < mean(S) + intvl*std(S)    ; nosmall_idx      = S > mean(S) - intvl*std(S)    ; suitable_idx     = nolarge_idx & nosmall_idx ; S(~suitable_idx) = mean(S(suitable_idx))     ; psnr_FISTA(:,n) = S ;
S = psnr_FW(:,n)    ; nolarge_idx      = S < mean(S) + intvl*std(S)    ; nosmall_idx      = S > mean(S) - intvl*std(S)    ; suitable_idx     = nolarge_idx & nosmall_idx ; S(~suitable_idx) = mean(S(suitable_idx))     ; psnr_FW(:,n)    = S ;
%S = psnr_HYBRID(:,n); nolarge_idx      = S < mean(S) + intvl*std(S)    ; nosmall_idx      = S > mean(S) - intvl*std(S)    ; suitable_idx     = nolarge_idx & nosmall_idx ; S(~suitable_idx) = mean(S(suitable_idx))     ; psnr_HYBRID(:,n)= S ;
end
disp( mean( psnr_FISTA ) ) ;
disp( mean( psnr_FW ) ) ;
%disp( mean( psnr_HYBRID ) ) ;
figure ; hold on ;
plot( modelOrderArr , mean( psnr_FISTA  ) , 'b-x' ) ;
plot( modelOrderArr , mean( psnr_FW     ) , 'r-^' ) ;
%plot( modelOrderArr , mean( psnr_HYBRID ) , 'm-s' ) ;
xlabel( 'N' ) ;
ylabel( 'Avg. PSNR (dB)' ) ;
legend( 'FISTA' , 'FW' , 'Location' , 'best' ) ;
grid on ;