clear
clc
if( ~exist( 'TEMP_SAM.mat' , 'file' ) )
modelOrderArr = 3 : 3 : 48 ;
trialNum      = 100       ;
sam_FISTA  = -ones( trialNum , length(modelOrderArr) ) ;
sam_FW     = -ones( trialNum , length(modelOrderArr) ) ;
%sam_HYBRID = -ones( trialNum , length(modelOrderArr) ) ;
for n = 1 : length(modelOrderArr)
    N = modelOrderArr(n) ;
    cd( ['MO',int2str(N)] ) ;
        for trialCnt = 1 : trialNum
            trialFolderName = sprintf('trial%04d',trialCnt) ;
            cd( trialFolderName ) ;
                cd ;
                fileName = 'SAM_MFbA_fista_subprobIt_1'                 ; if( exist( fileName , 'file' ) ) ; sam_FISTA(  trialCnt , n ) = dlmread( fileName ) ; end ;
                fileName = 'SAM_MFbA_FW_subprobIt_1'                    ; if( exist( fileName , 'file' ) ) ; sam_FW(     trialCnt , n ) = dlmread( fileName ) ; end ;
                %fileName = 'SAM_MFbA_HYBRID_S_FW1_A_FISTA1_subprobIt_1' ; if( exist( fileName , 'file' ) ) ; sam_HYBRID( trialCnt , n ) = dlmread( fileName ) ; end ;
            cd ..
        end
    cd ..
end
save TEMP_SAM
else
load TEMP_SAM
end
intvl = 10 ;
for n = 1 : length(modelOrderArr)
S = sam_FISTA(:,n) ; nolarge_idx      = S < mean(S) + intvl*std(S)    ; nosmall_idx      = S > mean(S) - intvl*std(S)    ; suitable_idx     = nolarge_idx & nosmall_idx ; S(~suitable_idx) = mean(S(suitable_idx))     ; sam_FISTA(:,n) = S ;
S = sam_FW(:,n)    ; nolarge_idx      = S < mean(S) + intvl*std(S)    ; nosmall_idx      = S > mean(S) - intvl*std(S)    ; suitable_idx     = nolarge_idx & nosmall_idx ; S(~suitable_idx) = mean(S(suitable_idx))     ; sam_FW(:,n)    = S ;
%S = sam_HYBRID(:,n); nolarge_idx      = S < mean(S) + intvl*std(S)    ; nosmall_idx      = S > mean(S) - intvl*std(S)    ; suitable_idx     = nolarge_idx & nosmall_idx ; S(~suitable_idx) = mean(S(suitable_idx))     ; sam_HYBRID(:,n)= S ;
end
disp( mean( sam_FISTA ) ) ;
disp( mean( sam_FW ) ) ;
%disp( mean( sam_HYBRID ) ) ;
figure ; hold on ;
plot( modelOrderArr , mean( sam_FISTA  ) , 'b-x' ) ;
plot( modelOrderArr , mean( sam_FW     ) , 'r-^' ) ;
%plot( modelOrderArr , mean( sam_HYBRID ) , 'm-s' ) ;
xlabel( 'N' ) ;
ylabel( 'Avg. SAM (deg.)' ) ;
legend( 'FISTA' , 'FW' , 'Location' , 'best' ) ;
grid on ;