close all
clear
clc
%            FUMI  DRFUMI  CNMF , FISTA   FW     Hybrid   HySure
colorArr = { 'k' , 'k'   , 'm'  , 'r'   , 'b'  , 'b'    , 'm' } ;
lnstyArr = { '-' , '--'  , '-'  , '-'   , '-'  , '--'   , '--'} ;
lineWidthVal = 1 ;
cd SNR_40dB
    load HSI_chikusei2014_1000x1000
    HS_bandNum  = 128       ;
    MS_pixelNum = 1000 * 1000 ;
    Y   = reshape(permute(HSI,[3,1,2]),HS_bandNum,MS_pixelNum) ;
    cd trial0001
        % ---------------------- %
        % plot the SAM histogram %
        % ---------------------- %
        load( 'LOG_FUMI_subprobVar_-2' , 'A_FUMI' , 'S_FUMI' ) ;
        fprintf( 'FUMI\n' ) ;
        HSI_FUMI = cat( 1 , cat( 2 , reshape(( A_FUMI{ 1,1}*S_FUMI{ 1,1} )',100,100,128) , reshape(( A_FUMI{ 1,2}*S_FUMI{ 1,2} )',100,100,128) , reshape(( A_FUMI{ 1,3}*S_FUMI{ 1,3} )',100,100,128) , reshape(( A_FUMI{ 1,4}*S_FUMI{ 1,4} )',100,100,128) , reshape(( A_FUMI{ 1,5}*S_FUMI{ 1,5} )',100,100,128) , reshape(( A_FUMI{ 1,6}*S_FUMI{ 1,6} )',100,100,128) , reshape(( A_FUMI{ 1,7}*S_FUMI{ 1,7} )',100,100,128) , reshape(( A_FUMI{ 1,8}*S_FUMI{ 1,8} )',100,100,128) , reshape(( A_FUMI{ 1,9}*S_FUMI{ 1,9} )',100,100,128) , reshape(( A_FUMI{ 1,10}*S_FUMI{ 1,10} )',100,100,128)  ) , ...
                            cat( 2 , reshape(( A_FUMI{ 2,1}*S_FUMI{ 2,1} )',100,100,128) , reshape(( A_FUMI{ 2,2}*S_FUMI{ 2,2} )',100,100,128) , reshape(( A_FUMI{ 2,3}*S_FUMI{ 2,3} )',100,100,128) , reshape(( A_FUMI{ 2,4}*S_FUMI{ 2,4} )',100,100,128) , reshape(( A_FUMI{ 2,5}*S_FUMI{ 2,5} )',100,100,128) , reshape(( A_FUMI{ 2,6}*S_FUMI{ 2,6} )',100,100,128) , reshape(( A_FUMI{ 2,7}*S_FUMI{ 2,7} )',100,100,128) , reshape(( A_FUMI{ 2,8}*S_FUMI{ 2,8} )',100,100,128) , reshape(( A_FUMI{ 2,9}*S_FUMI{ 2,9} )',100,100,128) , reshape(( A_FUMI{ 2,10}*S_FUMI{ 2,10} )',100,100,128)  ) , ...
                            cat( 2 , reshape(( A_FUMI{ 3,1}*S_FUMI{ 3,1} )',100,100,128) , reshape(( A_FUMI{ 3,2}*S_FUMI{ 3,2} )',100,100,128) , reshape(( A_FUMI{ 3,3}*S_FUMI{ 3,3} )',100,100,128) , reshape(( A_FUMI{ 3,4}*S_FUMI{ 3,4} )',100,100,128) , reshape(( A_FUMI{ 3,5}*S_FUMI{ 3,5} )',100,100,128) , reshape(( A_FUMI{ 3,6}*S_FUMI{ 3,6} )',100,100,128) , reshape(( A_FUMI{ 3,7}*S_FUMI{ 3,7} )',100,100,128) , reshape(( A_FUMI{ 3,8}*S_FUMI{ 3,8} )',100,100,128) , reshape(( A_FUMI{ 3,9}*S_FUMI{ 3,9} )',100,100,128) , reshape(( A_FUMI{ 3,10}*S_FUMI{ 3,10} )',100,100,128)  ) , ...
                            cat( 2 , reshape(( A_FUMI{ 4,1}*S_FUMI{ 4,1} )',100,100,128) , reshape(( A_FUMI{ 4,2}*S_FUMI{ 4,2} )',100,100,128) , reshape(( A_FUMI{ 4,3}*S_FUMI{ 4,3} )',100,100,128) , reshape(( A_FUMI{ 4,4}*S_FUMI{ 4,4} )',100,100,128) , reshape(( A_FUMI{ 4,5}*S_FUMI{ 4,5} )',100,100,128) , reshape(( A_FUMI{ 4,6}*S_FUMI{ 4,6} )',100,100,128) , reshape(( A_FUMI{ 4,7}*S_FUMI{ 4,7} )',100,100,128) , reshape(( A_FUMI{ 4,8}*S_FUMI{ 4,8} )',100,100,128) , reshape(( A_FUMI{ 4,9}*S_FUMI{ 4,9} )',100,100,128) , reshape(( A_FUMI{ 4,10}*S_FUMI{ 4,10} )',100,100,128)  ) , ...
                            cat( 2 , reshape(( A_FUMI{ 5,1}*S_FUMI{ 5,1} )',100,100,128) , reshape(( A_FUMI{ 5,2}*S_FUMI{ 5,2} )',100,100,128) , reshape(( A_FUMI{ 5,3}*S_FUMI{ 5,3} )',100,100,128) , reshape(( A_FUMI{ 5,4}*S_FUMI{ 5,4} )',100,100,128) , reshape(( A_FUMI{ 5,5}*S_FUMI{ 5,5} )',100,100,128) , reshape(( A_FUMI{ 5,6}*S_FUMI{ 5,6} )',100,100,128) , reshape(( A_FUMI{ 5,7}*S_FUMI{ 5,7} )',100,100,128) , reshape(( A_FUMI{ 5,8}*S_FUMI{ 5,8} )',100,100,128) , reshape(( A_FUMI{ 5,9}*S_FUMI{ 5,9} )',100,100,128) , reshape(( A_FUMI{ 5,10}*S_FUMI{ 5,10} )',100,100,128)  ) , ...
                            cat( 2 , reshape(( A_FUMI{ 6,1}*S_FUMI{ 6,1} )',100,100,128) , reshape(( A_FUMI{ 6,2}*S_FUMI{ 6,2} )',100,100,128) , reshape(( A_FUMI{ 6,3}*S_FUMI{ 6,3} )',100,100,128) , reshape(( A_FUMI{ 6,4}*S_FUMI{ 6,4} )',100,100,128) , reshape(( A_FUMI{ 6,5}*S_FUMI{ 6,5} )',100,100,128) , reshape(( A_FUMI{ 6,6}*S_FUMI{ 6,6} )',100,100,128) , reshape(( A_FUMI{ 6,7}*S_FUMI{ 6,7} )',100,100,128) , reshape(( A_FUMI{ 6,8}*S_FUMI{ 6,8} )',100,100,128) , reshape(( A_FUMI{ 6,9}*S_FUMI{ 6,9} )',100,100,128) , reshape(( A_FUMI{ 6,10}*S_FUMI{ 6,10} )',100,100,128)  ) , ...
                            cat( 2 , reshape(( A_FUMI{ 7,1}*S_FUMI{ 7,1} )',100,100,128) , reshape(( A_FUMI{ 7,2}*S_FUMI{ 7,2} )',100,100,128) , reshape(( A_FUMI{ 7,3}*S_FUMI{ 7,3} )',100,100,128) , reshape(( A_FUMI{ 7,4}*S_FUMI{ 7,4} )',100,100,128) , reshape(( A_FUMI{ 7,5}*S_FUMI{ 7,5} )',100,100,128) , reshape(( A_FUMI{ 7,6}*S_FUMI{ 7,6} )',100,100,128) , reshape(( A_FUMI{ 7,7}*S_FUMI{ 7,7} )',100,100,128) , reshape(( A_FUMI{ 7,8}*S_FUMI{ 7,8} )',100,100,128) , reshape(( A_FUMI{ 7,9}*S_FUMI{ 7,9} )',100,100,128) , reshape(( A_FUMI{ 7,10}*S_FUMI{ 7,10} )',100,100,128)  ) , ...
                            cat( 2 , reshape(( A_FUMI{ 8,1}*S_FUMI{ 8,1} )',100,100,128) , reshape(( A_FUMI{ 8,2}*S_FUMI{ 8,2} )',100,100,128) , reshape(( A_FUMI{ 8,3}*S_FUMI{ 8,3} )',100,100,128) , reshape(( A_FUMI{ 8,4}*S_FUMI{ 8,4} )',100,100,128) , reshape(( A_FUMI{ 8,5}*S_FUMI{ 8,5} )',100,100,128) , reshape(( A_FUMI{ 8,6}*S_FUMI{ 8,6} )',100,100,128) , reshape(( A_FUMI{ 8,7}*S_FUMI{ 8,7} )',100,100,128) , reshape(( A_FUMI{ 8,8}*S_FUMI{ 8,8} )',100,100,128) , reshape(( A_FUMI{ 8,9}*S_FUMI{ 8,9} )',100,100,128) , reshape(( A_FUMI{ 8,10}*S_FUMI{ 8,10} )',100,100,128)  ) , ...
                            cat( 2 , reshape(( A_FUMI{ 9,1}*S_FUMI{ 9,1} )',100,100,128) , reshape(( A_FUMI{ 9,2}*S_FUMI{ 9,2} )',100,100,128) , reshape(( A_FUMI{ 9,3}*S_FUMI{ 9,3} )',100,100,128) , reshape(( A_FUMI{ 9,4}*S_FUMI{ 9,4} )',100,100,128) , reshape(( A_FUMI{ 9,5}*S_FUMI{ 9,5} )',100,100,128) , reshape(( A_FUMI{ 9,6}*S_FUMI{ 9,6} )',100,100,128) , reshape(( A_FUMI{ 9,7}*S_FUMI{ 9,7} )',100,100,128) , reshape(( A_FUMI{ 9,8}*S_FUMI{ 9,8} )',100,100,128) , reshape(( A_FUMI{ 9,9}*S_FUMI{ 9,9} )',100,100,128) , reshape(( A_FUMI{ 9,10}*S_FUMI{ 9,10} )',100,100,128)  ) , ...
                            cat( 2 , reshape(( A_FUMI{10,1}*S_FUMI{10,1} )',100,100,128) , reshape(( A_FUMI{10,2}*S_FUMI{10,2} )',100,100,128) , reshape(( A_FUMI{10,3}*S_FUMI{10,3} )',100,100,128) , reshape(( A_FUMI{10,4}*S_FUMI{10,4} )',100,100,128) , reshape(( A_FUMI{10,5}*S_FUMI{10,5} )',100,100,128) , reshape(( A_FUMI{10,6}*S_FUMI{10,6} )',100,100,128) , reshape(( A_FUMI{10,7}*S_FUMI{10,7} )',100,100,128) , reshape(( A_FUMI{10,8}*S_FUMI{10,8} )',100,100,128) , reshape(( A_FUMI{10,9}*S_FUMI{10,9} )',100,100,128) , reshape(( A_FUMI{10,10}*S_FUMI{10,10} )',100,100,128)  ) ) ;
        fprintf( 'DRFUMI\n' ) ;
        load( 'LOG_DRFUMI_subprobVar_-2' , 'A_DRFUMI' , 'S_DRFUMI' ) ;
        HSI_DRFUMI = cat( 1 , cat( 2 , reshape(( A_DRFUMI{ 1,1}*S_DRFUMI{ 1,1} )',100,100,128) , reshape(( A_DRFUMI{ 1,2}*S_DRFUMI{ 1,2} )',100,100,128) , reshape(( A_DRFUMI{ 1,3}*S_DRFUMI{ 1,3} )',100,100,128) , reshape(( A_DRFUMI{ 1,4}*S_DRFUMI{ 1,4} )',100,100,128) , reshape(( A_DRFUMI{ 1,5}*S_DRFUMI{ 1,5} )',100,100,128) , reshape(( A_DRFUMI{ 1,6}*S_DRFUMI{ 1,6} )',100,100,128) , reshape(( A_DRFUMI{ 1,7}*S_DRFUMI{ 1,7} )',100,100,128) , reshape(( A_DRFUMI{ 1,8}*S_DRFUMI{ 1,8} )',100,100,128) , reshape(( A_DRFUMI{ 1,9}*S_DRFUMI{ 1,9} )',100,100,128) , reshape(( A_DRFUMI{ 1,10}*S_DRFUMI{ 1,10} )',100,100,128)  ) , ...
                              cat( 2 , reshape(( A_DRFUMI{ 2,1}*S_DRFUMI{ 2,1} )',100,100,128) , reshape(( A_DRFUMI{ 2,2}*S_DRFUMI{ 2,2} )',100,100,128) , reshape(( A_DRFUMI{ 2,3}*S_DRFUMI{ 2,3} )',100,100,128) , reshape(( A_DRFUMI{ 2,4}*S_DRFUMI{ 2,4} )',100,100,128) , reshape(( A_DRFUMI{ 2,5}*S_DRFUMI{ 2,5} )',100,100,128) , reshape(( A_DRFUMI{ 2,6}*S_DRFUMI{ 2,6} )',100,100,128) , reshape(( A_DRFUMI{ 2,7}*S_DRFUMI{ 2,7} )',100,100,128) , reshape(( A_DRFUMI{ 2,8}*S_DRFUMI{ 2,8} )',100,100,128) , reshape(( A_DRFUMI{ 2,9}*S_DRFUMI{ 2,9} )',100,100,128) , reshape(( A_DRFUMI{ 2,10}*S_DRFUMI{ 2,10} )',100,100,128)  ) , ...
                              cat( 2 , reshape(( A_DRFUMI{ 3,1}*S_DRFUMI{ 3,1} )',100,100,128) , reshape(( A_DRFUMI{ 3,2}*S_DRFUMI{ 3,2} )',100,100,128) , reshape(( A_DRFUMI{ 3,3}*S_DRFUMI{ 3,3} )',100,100,128) , reshape(( A_DRFUMI{ 3,4}*S_DRFUMI{ 3,4} )',100,100,128) , reshape(( A_DRFUMI{ 3,5}*S_DRFUMI{ 3,5} )',100,100,128) , reshape(( A_DRFUMI{ 3,6}*S_DRFUMI{ 3,6} )',100,100,128) , reshape(( A_DRFUMI{ 3,7}*S_DRFUMI{ 3,7} )',100,100,128) , reshape(( A_DRFUMI{ 3,8}*S_DRFUMI{ 3,8} )',100,100,128) , reshape(( A_DRFUMI{ 3,9}*S_DRFUMI{ 3,9} )',100,100,128) , reshape(( A_DRFUMI{ 3,10}*S_DRFUMI{ 3,10} )',100,100,128)  ) , ...
                              cat( 2 , reshape(( A_DRFUMI{ 4,1}*S_DRFUMI{ 4,1} )',100,100,128) , reshape(( A_DRFUMI{ 4,2}*S_DRFUMI{ 4,2} )',100,100,128) , reshape(( A_DRFUMI{ 4,3}*S_DRFUMI{ 4,3} )',100,100,128) , reshape(( A_DRFUMI{ 4,4}*S_DRFUMI{ 4,4} )',100,100,128) , reshape(( A_DRFUMI{ 4,5}*S_DRFUMI{ 4,5} )',100,100,128) , reshape(( A_DRFUMI{ 4,6}*S_DRFUMI{ 4,6} )',100,100,128) , reshape(( A_DRFUMI{ 4,7}*S_DRFUMI{ 4,7} )',100,100,128) , reshape(( A_DRFUMI{ 4,8}*S_DRFUMI{ 4,8} )',100,100,128) , reshape(( A_DRFUMI{ 4,9}*S_DRFUMI{ 4,9} )',100,100,128) , reshape(( A_DRFUMI{ 4,10}*S_DRFUMI{ 4,10} )',100,100,128)  ) , ...
                              cat( 2 , reshape(( A_DRFUMI{ 5,1}*S_DRFUMI{ 5,1} )',100,100,128) , reshape(( A_DRFUMI{ 5,2}*S_DRFUMI{ 5,2} )',100,100,128) , reshape(( A_DRFUMI{ 5,3}*S_DRFUMI{ 5,3} )',100,100,128) , reshape(( A_DRFUMI{ 5,4}*S_DRFUMI{ 5,4} )',100,100,128) , reshape(( A_DRFUMI{ 5,5}*S_DRFUMI{ 5,5} )',100,100,128) , reshape(( A_DRFUMI{ 5,6}*S_DRFUMI{ 5,6} )',100,100,128) , reshape(( A_DRFUMI{ 5,7}*S_DRFUMI{ 5,7} )',100,100,128) , reshape(( A_DRFUMI{ 5,8}*S_DRFUMI{ 5,8} )',100,100,128) , reshape(( A_DRFUMI{ 5,9}*S_DRFUMI{ 5,9} )',100,100,128) , reshape(( A_DRFUMI{ 5,10}*S_DRFUMI{ 5,10} )',100,100,128)  ) , ...
                              cat( 2 , reshape(( A_DRFUMI{ 6,1}*S_DRFUMI{ 6,1} )',100,100,128) , reshape(( A_DRFUMI{ 6,2}*S_DRFUMI{ 6,2} )',100,100,128) , reshape(( A_DRFUMI{ 6,3}*S_DRFUMI{ 6,3} )',100,100,128) , reshape(( A_DRFUMI{ 6,4}*S_DRFUMI{ 6,4} )',100,100,128) , reshape(( A_DRFUMI{ 6,5}*S_DRFUMI{ 6,5} )',100,100,128) , reshape(( A_DRFUMI{ 6,6}*S_DRFUMI{ 6,6} )',100,100,128) , reshape(( A_DRFUMI{ 6,7}*S_DRFUMI{ 6,7} )',100,100,128) , reshape(( A_DRFUMI{ 6,8}*S_DRFUMI{ 6,8} )',100,100,128) , reshape(( A_DRFUMI{ 6,9}*S_DRFUMI{ 6,9} )',100,100,128) , reshape(( A_DRFUMI{ 6,10}*S_DRFUMI{ 6,10} )',100,100,128)  ) , ...
                              cat( 2 , reshape(( A_DRFUMI{ 7,1}*S_DRFUMI{ 7,1} )',100,100,128) , reshape(( A_DRFUMI{ 7,2}*S_DRFUMI{ 7,2} )',100,100,128) , reshape(( A_DRFUMI{ 7,3}*S_DRFUMI{ 7,3} )',100,100,128) , reshape(( A_DRFUMI{ 7,4}*S_DRFUMI{ 7,4} )',100,100,128) , reshape(( A_DRFUMI{ 7,5}*S_DRFUMI{ 7,5} )',100,100,128) , reshape(( A_DRFUMI{ 7,6}*S_DRFUMI{ 7,6} )',100,100,128) , reshape(( A_DRFUMI{ 7,7}*S_DRFUMI{ 7,7} )',100,100,128) , reshape(( A_DRFUMI{ 7,8}*S_DRFUMI{ 7,8} )',100,100,128) , reshape(( A_DRFUMI{ 7,9}*S_DRFUMI{ 7,9} )',100,100,128) , reshape(( A_DRFUMI{ 7,10}*S_DRFUMI{ 7,10} )',100,100,128)  ) , ...
                              cat( 2 , reshape(( A_DRFUMI{ 8,1}*S_DRFUMI{ 8,1} )',100,100,128) , reshape(( A_DRFUMI{ 8,2}*S_DRFUMI{ 8,2} )',100,100,128) , reshape(( A_DRFUMI{ 8,3}*S_DRFUMI{ 8,3} )',100,100,128) , reshape(( A_DRFUMI{ 8,4}*S_DRFUMI{ 8,4} )',100,100,128) , reshape(( A_DRFUMI{ 8,5}*S_DRFUMI{ 8,5} )',100,100,128) , reshape(( A_DRFUMI{ 8,6}*S_DRFUMI{ 8,6} )',100,100,128) , reshape(( A_DRFUMI{ 8,7}*S_DRFUMI{ 8,7} )',100,100,128) , reshape(( A_DRFUMI{ 8,8}*S_DRFUMI{ 8,8} )',100,100,128) , reshape(( A_DRFUMI{ 8,9}*S_DRFUMI{ 8,9} )',100,100,128) , reshape(( A_DRFUMI{ 8,10}*S_DRFUMI{ 8,10} )',100,100,128)  ) , ...
                              cat( 2 , reshape(( A_DRFUMI{ 9,1}*S_DRFUMI{ 9,1} )',100,100,128) , reshape(( A_DRFUMI{ 9,2}*S_DRFUMI{ 9,2} )',100,100,128) , reshape(( A_DRFUMI{ 9,3}*S_DRFUMI{ 9,3} )',100,100,128) , reshape(( A_DRFUMI{ 9,4}*S_DRFUMI{ 9,4} )',100,100,128) , reshape(( A_DRFUMI{ 9,5}*S_DRFUMI{ 9,5} )',100,100,128) , reshape(( A_DRFUMI{ 9,6}*S_DRFUMI{ 9,6} )',100,100,128) , reshape(( A_DRFUMI{ 9,7}*S_DRFUMI{ 9,7} )',100,100,128) , reshape(( A_DRFUMI{ 9,8}*S_DRFUMI{ 9,8} )',100,100,128) , reshape(( A_DRFUMI{ 9,9}*S_DRFUMI{ 9,9} )',100,100,128) , reshape(( A_DRFUMI{ 9,10}*S_DRFUMI{ 9,10} )',100,100,128)  ) , ...
                              cat( 2 , reshape(( A_DRFUMI{10,1}*S_DRFUMI{10,1} )',100,100,128) , reshape(( A_DRFUMI{10,2}*S_DRFUMI{10,2} )',100,100,128) , reshape(( A_DRFUMI{10,3}*S_DRFUMI{10,3} )',100,100,128) , reshape(( A_DRFUMI{10,4}*S_DRFUMI{10,4} )',100,100,128) , reshape(( A_DRFUMI{10,5}*S_DRFUMI{10,5} )',100,100,128) , reshape(( A_DRFUMI{10,6}*S_DRFUMI{10,6} )',100,100,128) , reshape(( A_DRFUMI{10,7}*S_DRFUMI{10,7} )',100,100,128) , reshape(( A_DRFUMI{10,8}*S_DRFUMI{10,8} )',100,100,128) , reshape(( A_DRFUMI{10,9}*S_DRFUMI{10,9} )',100,100,128) , reshape(( A_DRFUMI{10,10}*S_DRFUMI{10,10} )',100,100,128)  ) ) ;
        fprintf( 'CNMF\n' ) ;
        load( 'LOG_CNMF_subprobIt_100_convth_1em2.mat'         , 'A_CNMF' , 'S_CNMF' ) ; HSI_CNMF        = reshape( S_CNMF'*A_CNMF' , 1000 , 1000 , [] ) ; ;
        fprintf( 'FISTA\n' ) ;
        load( 'LOG_MFbA_fista_subprobIt_1.mat'                 , 'A_MF'   , 'S_MF'   ) ; HSI_MFbA_FISTA  = reshape( S_MF'*A_MF' , 1000 , 1000 , [] );
        fprintf( 'FW\n' ) ;
        load( 'LOG_MFbA_FW_subprobIt_1.mat'                    , 'A_MF'   , 'S_MF'   ) ; HSI_MFbA_FW     = reshape( S_MF'*A_MF' , 1000 , 1000 , [] );
        fprintf( 'Hybrid\n' ) ;
        load( 'LOG_MFbA_HYBRID_S_FW1_A_FISTA1_subprobIt_1.mat' , 'A_MF'   , 'S_MF'   ) ; HSI_MFbA_HYBRID = reshape( S_MF'*A_MF' , 1000 , 1000 , [] );
        fprintf( 'HySure\n' ) ;
        load( 'LOG_HySure.mat'                                 ,'A_HySure','S_HySure') ; HSI_HySure      = reshape( S_MF'*A_MF' , 1000 , 1000 , [] );
    cd ..
cd ..
% -------------------- %
% 815nm Map (89th band)%
% -------------------- %
bandIdx = 89 ;
%for bandIdx = 100 ;
colormapChoice = 'jet' ;%'hot' ; % 'cool' ; % 'hsv' ; % 'jet' ;
fid2 = figure ;
IMG_FUMI_815        = HSI_FUMI(:,:,bandIdx)        / 0.5 ;
IMG_DRFUMI_815      = HSI_DRFUMI(:,:,bandIdx)      / 0.5 ;
IMG_CNMF_815        = HSI_CNMF(:,:,bandIdx)        / 0.5 ;
IMG_MFbA_FISTA_815  = HSI_MFbA_FISTA(:,:,bandIdx)  / 0.5 ;
IMG_MFbA_FW_815     = HSI_MFbA_FW(:,:,bandIdx)     / 0.5 ;
IMG_MFbA_HYBRID_815 = HSI_MFbA_HYBRID(:,:,bandIdx) / 0.5 ;
IMG_HySure_815      = HSI_HySure(:,:,bandIdx)      / 0.5 ;
IMG_TRUE_815        = HSI(:,:,bandIdx)             / 0.5 ;

IM_CNMF_815         = imgray2pcolor( IMG_CNMF_815        , 'hot' , 255 ) ;
IM_DRFUMI_815       = imgray2pcolor( IMG_DRFUMI_815      , 'hot' , 255 ) ;
IM_FUMI_815         = imgray2pcolor( IMG_FUMI_815        , 'hot' , 255 ) ;
IM_HySure_815       = imgray2pcolor( IMG_HySure_815      , 'hot' , 255 ) ;
IM_MFbA_FISTA_815   = imgray2pcolor( IMG_MFbA_FISTA_815  , 'hot' , 255 ) ;
IM_MFbA_FW_815      = imgray2pcolor( IMG_MFbA_FW_815     , 'hot' , 255 ) ;
IM_MFbA_HYBRID_815  = imgray2pcolor( IMG_MFbA_HYBRID_815 , 'hot' , 255 ) ;
IM_TRUE_815         = imgray2pcolor( IMG_TRUE_815        , 'hot' , 255 ) ;

IMG = cat( 1 , cat( 2 , IMG_CNMF_815       , IMG_FUMI_815    , IMG_HySure_815      ) , ...
               cat( 2 , IMG_MFbA_FISTA_815 , IMG_MFbA_FW_815 , IMG_MFbA_HYBRID_815 ) ) ;
IM = imgray2pcolor( IMG , 'hot' , 255 ) ;

figure ; imshow( IM_CNMF_815        ) ; title( sprintf( 'CNMF , b %d' , bandIdx ) ) ; pause(0.2) ;
figure ; imshow( IM_DRFUMI_815      ) ; title( sprintf( 'DRFUMI , b %d' , bandIdx ) ) ; pause(0.2) ;
figure ; imshow( IM_FUMI_815        ) ; title( sprintf( 'FUMI , b %d' , bandIdx ) ) ; pause(0.2) ;
figure ; imshow( IM_HySure_815      ) ; title( sprintf( 'HySure , b %d' , bandIdx ) ) ; pause(0.2) ;
figure ; imshow( IM_MFbA_FISTA_815  ) ; title( sprintf( 'FISTA , b %d' , bandIdx ) ) ; pause(0.2) ;
figure ; imshow( IM_MFbA_FW_815     ) ; title( sprintf( 'FW , b %d' , bandIdx ) ) ; pause(0.2) ;
figure ; imshow( IM_MFbA_HYBRID_815 ) ; title( sprintf( 'HYBRID , b %d' , bandIdx ) ) ; pause(0.2) ;
figure ; imshow( IM                 ) ; title( sprintf( 'IM , b %d' , bandIdx ) ) ; pause(0.2) ;
figure ; imshow( IM_TRUE_815        ) ; title( sprintf( 'TRUE , b%d' , bandIdx ) ) ; pause(0.2) ;
imwrite( IM_CNMF_815 , 'IM_CNMF_815.png' ) ;
imwrite( IM_FUMI_815 , 'IM_FUMI_815.png' ) ;
imwrite( IM_HySure_815 , 'IM_HySure_815.png' ) ;
imwrite( IM_MFbA_FISTA_815 , 'IM_MFbA_FISTA_815.png' ) ;
imwrite( IM_MFbA_FW_815 , 'IM_MFbA_FW_815.png' ) ;
imwrite( IM_MFbA_HYBRID_815 , 'IM_MFbA_HYBRID_815.png' ) ;
imwrite( IM_TRUE_815 , 'IM_TRUE_815.png' ) ;
%end

figure ; p = pcolor( IMG_TRUE_815 ) ;
colormap hot ;
axis equal ;
set( p , 'EdgeColor' , 'none' ) ;
c = colorbar('horizontal') ;
set( c , 'XTick' , [0:0.2:1] ) ;
set( c , 'XTickLabel' , {'0','0.2','0.4','0.6','0.8','1'} ) ;