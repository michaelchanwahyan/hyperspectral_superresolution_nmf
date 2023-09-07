clear
clc
if( ~exist( 'TEMP_TIME.mat' , 'file' ) )
modelOrderArr = 3 : 3 : 48 ;
trialNum      = 100         ;
time_FISTA  = -ones( trialNum , length(modelOrderArr) ) ;
time_FW     = -ones( trialNum , length(modelOrderArr) ) ;
%time_HYBRID = -ones( trialNum , length(modelOrderArr) ) ;
for n = 1 : length(modelOrderArr)
    N = modelOrderArr(n) ;
    cd( ['MO',int2str(N)] ) ;
        for trialCnt = 1 : trialNum
            trialFolderName = sprintf('trial%04d',trialCnt) ;
            cd( trialFolderName ) ;
                cd ;
                fileName = 'TIME_MFbA_fista_subprobIt_1'                 ; if( exist( fileName , 'file' ) ) ; time_FISTA(  trialCnt , n ) = dlmread( fileName ) ; end ;
                fileName = 'TIME_MFbA_FW_subprobIt_1'                    ; if( exist( fileName , 'file' ) ) ; time_FW(     trialCnt , n ) = dlmread( fileName ) ; end ;
                %fileName = 'TIME_MFbA_HYBRID_S_FW1_A_FISTA1_subprobIt_1' ; if( exist( fileName , 'file' ) ) ; time_HYBRID( trialCnt , n ) = dlmread( fileName ) ; end ;
            cd ..
        end
    cd ..
end
save TEMP_TIME
else
load TEMP_TIME
end
%intvl = 0.2 ;
%for n = 1 : length(modelOrderArr)
%S = time_FISTA(:,n) ; nolarge_idx      = S < mean(S) + intvl*std(S)    ; nosmall_idx      = S > mean(S) - intvl*std(S)    ; suitable_idx     = nolarge_idx & nosmall_idx ; S(~suitable_idx) = mean(S(suitable_idx))     ; time_FISTA(:,n) = S ;
%S = time_FW(:,n)    ; nolarge_idx      = S < mean(S) + intvl*std(S)    ; nosmall_idx      = S > mean(S) - intvl*std(S)    ; suitable_idx     = nolarge_idx & nosmall_idx ; S(~suitable_idx) = mean(S(suitable_idx))     ; time_FW(:,n)    = S ;
%S = time_HYBRID(:,n); nolarge_idx      = S < mean(S) + intvl*std(S)    ; nosmall_idx      = S > mean(S) - intvl*std(S)    ; suitable_idx     = nolarge_idx & nosmall_idx ; S(~suitable_idx) = mean(S(suitable_idx))     ; time_HYBRID(:,n)= S ;
%end
disp( mean( time_FISTA ) ) ;
disp( mean( time_FW ) ) ;
%disp( mean( time_HYBRID ) ) ;
figure ; hold on ;
plot( modelOrderArr , mean( time_FISTA  ) , 'b-x' ) ;
plot( modelOrderArr , mean( time_FW     ) , 'r-^' ) ;
%plot( modelOrderArr , mean( time_HYBRID ) , 'm-s' ) ;
xlabel( 'N' ) ;
ylabel( 'Avg. Runtime (sec.)' ) ;
legend( 'FISTA' , 'FW' , 'Location' , 'best' ) ;
grid on ;