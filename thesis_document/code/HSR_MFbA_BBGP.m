function [ HSI_MF , F , G , A , S , IT_used_MF , TIME_MFbA , returnInfo ] = HIS_MFbA_BB_betaMax1( HS , MS , MFbA_opt )
returnInfo.status = 'null' ;
% ============== %
% basic var info %
% ============== %
[ HS_imgSizeM , HS_imgSizeN , HS_bandNum ] = size( HS ) ;
[ MS_imgSizeM , MS_imgSizeN , MS_bandNum ] = size( MS ) ;
  HS_pixelNum = HS_imgSizeM * HS_imgSizeN ;
  MS_pixelNum = MS_imgSizeM * MS_imgSizeN ;
  Y_M         = reshape( permute( MS , [ 3 , 1 , 2 ] ) , MS_bandNum , MS_pixelNum ) ;
  Y_H         = reshape( permute( HS , [ 3 , 1 , 2 ] ) , HS_bandNum , HS_pixelNum ) ;
% ============ %
% read options %
% ============ %
if( isfield( MFbA_opt , 'maxIteraNum' ) ) ; maxIteraNum = MFbA_opt.maxIteraNum ; else maxIteraNum = 100                                             ; end ;
if( isfield( MFbA_opt , 'F'           ) ) ; F           = MFbA_opt.F           ; else error( 'ERROR : Down-Sampling matrix F is not provided !!!' ) ; end ;
if( isfield( MFbA_opt , 'G'           ) ) ; G           = MFbA_opt.G           ; else error( 'ERROR : Down-Sampling matrix G is not provided !!!' ) ; end ;
if( isfield( MFbA_opt , 'A_init'      ) ) ; A_init      = MFbA_opt.A_init      ; else error( 'ERROR : A_init is not provided !!!' )                 ; end ;
if( isfield( MFbA_opt , 'S_init'      ) ) ; S_init      = MFbA_opt.S_init      ; else error( 'ERROR : S_init is not provided !!!' )                 ; end ;
if( isfield( MFbA_opt , 'AStep'       ) ) ; AStep       = MFbA_opt.AStep       ; else AStep       = 1                                               ; end ;
if( isfield( MFbA_opt , 'SStep'       ) ) ; SStep       = MFbA_opt.SStep       ; else SStep       = 1                                               ; end ;
if( isfield( MFbA_opt , 'convthresh'  ) ) ; convthresh  = MFbA_opt.convthresh  ; else convthresh  = 1e-7                                            ; end ;
% algorithm initialization %
S       = S_init ; S_curr  = S      ;
A       = A_init ; A_curr  = A      ;
objCurr = 0.5 * ( sum(sum((Y_H-A*(S*G)).^2)) + sum(sum((Y_M-(F*A)*S).^2)) ) ;
% the algorithm %
obj_it    = zeros(maxIteraNum+1,1) ; time_it   = zeros(maxIteraNum+1,1) ;
obj_it(1) = objCurr                ;
alphaS    = 1 ; % max( eig( gamma*(A'*A) + (F*A)'*(F*A) ) ) ;
alphaA    = 1 ; % max( eig( (S*G)*(S*G)' + theta * (S*S') ) ) ;
tic ;
SG = S_curr * G ;
FA = F * A_curr ;
for k = 1 : maxIteraNum
    % S-subproblem %
    for sstep = 1 : SStep
        ScurrG        = SG                                                  ;
        AScurrGminY_H = A * ScurrG - Y_H                                    ;
        FAScurrminY_M = FA * S_curr - Y_M                                   ;
        GRADS         = ( A' * AScurrGminY_H ) * G'                       ...
                        + FA' * FAScurrminY_M                               ;
        DELTS         = SimplexProj( (S_curr - alphaS*GRADS)' )' - S_curr   ;
        ADELTSG       = A * ( DELTS * G )                                   ;
        FADELTS       = FA * DELTS                                          ;
        tau           = ( - sum(sum( AScurrGminY_H .* (ADELTSG) ))        ...
                          - sum(sum( FAScurrminY_M .* FADELTS )) )        ...
                        / ( sum(sum((ADELTSG).^2)) + sum(sum(FADELTS.^2)) ) ;
        tau           = min( max( tau , 0 ) , 1 )                           ;
        S_curr        = S_curr + tau * DELTS                                ;
        gamm          = sum(sum( (ADELTSG).^2 )) + sum(sum( FADELTS.^2 ))   ;
        if( gamm > 0 ) % take beta_max as 1 , not to use 1/LS
            alphaS = min( max( sum(sum(DELTS.^2)) / gamm , 0 ) , 1 )        ;
        else
            alphaS = 1                                                      ;
        end
        SG = S_curr * G ;
    end
    S = S_curr ;
    % A-subproblem %
    for astep = 1 : AStep
        FAcurr        = FA                                                   ;
        AcurrSGminY_H = A_curr * SG - Y_H                                    ;
        FAcurrSminY_M = FAcurr * S - Y_M                                     ;
        GRADA         = AcurrSGminY_H * SG'                                ...
                        + F' * ( FAcurrSminY_M * S' )                        ;
        DELTA         = min( max( A_curr - alphaA*GRADA , 0 ) , 1 ) - A_curr ;
        FDELTAS       = ( F * DELTA ) * S                                    ;
        DELTASG       = DELTA * SG                                           ;
        tau           = ( - sum(sum( AcurrSGminY_H .* DELTASG ))           ...
                          - sum(sum( FAcurrSminY_M .* FDELTAS )) )         ...
                        / ( sum(sum(DELTASG.^2)) + sum(sum(FDELTAS.^2)) )    ;
        tau           = min( max( tau , 0 ) , 1 )                            ;
        A_curr        = A_curr + tau * DELTA                                 ;
        gamm          = sum(sum( DELTASG.^2 )) + sum(sum( (FDELTAS).^2 ))    ;
        if( gamm > 0 ) % take beta_max as 1 , not to use 1/LA
            alphaA = min( max( sum(sum(DELTA.^2)) / gamm , 0 ) , 1 )         ;
        else
            alphaA = 1                                                       ;
        end
        FA = F * A_curr ;
    end
    A = A_curr ;
    % check convergence %
    objPrev      = objCurr                                         ;
    objCurr      = 0.5 * ( sum(sum((Y_H-A_curr*SG).^2))          ...
                         + sum(sum((Y_M-FA*S_curr).^2)) )          ;
    time_it(k+1) = toc                                             ;
    obj_it(k+1)  = objCurr                                         ;
    obj_chng     = abs( objPrev - objCurr ) / objPrev              ;
    if( obj_chng < convthresh )
        fprintf( 'objective value converges !\n' )                 ;
        fprintf( 'early break @ it: %d / %d\n' , k , maxIteraNum ) ;
        break                                                      ;
    end
end
TIME_MFbA = toc ; IT_used_MF = k ;
HSI_MF = reshape( S'*A' , MS_imgSizeM , MS_imgSizeN , HS_bandNum ) ;

returnInfo.obj_it  = obj_it ;
returnInfo.time_it = time_it ;
end




%%%%%%%%%%%%%%
%%%%%%%%%%%%%%




function X = SimplexProj(Y)
% Projection to a simplex; the codes are from the reference [41]
% W. Wang and M. A. Carreira-Perpin?n, ?Projection onto the probability
% arXiv preprint arXiv:1309.1541v1, 2013.
[N,D] = size(Y);
X = sort(Y,2,'descend');
Xtmp = (cumsum(X,2)-1)*diag(sparse(1./(1:D)));
X = max(bsxfun(@minus,Y,Xtmp(sub2ind([N,D],(1:N)',sum(X>Xtmp,2)))),0);
end
