function [ HSI_MF , A , S , IT_used_MF , TIME_MFbA , returnInfo ] = HIS_MFbA_HYBRID( HS , MS , MFbA_opt )
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
if( isfield( MFbA_opt , 'gamma'       ) ) ; gamma       = MFbA_opt.gamma       ; else gamma       = powermethod(G'*G,100)                           ; end ;
if( isfield( MFbA_opt , 'theta'       ) ) ; theta       = MFbA_opt.theta       ; else theta       = max(eig(F*F'))                                  ; end ;
if( isfield( MFbA_opt , 'A_HYBRID'    ) ) ; A_HYBRID    = MFbA_opt.A_HYBRID    ; else A_HYBRID    = 'PROXGRAD'                                      ; end ;
if( isfield( MFbA_opt , 'S_HYBRID'    ) ) ; S_HYBRID    = MFbA_opt.S_HYBRID    ; else S_HYBRID    = 'FRANKWOLFE'                                    ; end ;
if( strcmp( AStep , 'randi' ) ) ; A_HYBRID_RANDI_STEP = true  ; A_HYBRID_RANDI_BASE = MFbA_opt.A_HYBRID_RANDI_BASE ; else A_HYBRID_RANDI_STEP = false ; end ;
if( strcmp( SStep , 'randi' ) ) ; S_HYBRID_RANDI_STEP = true  ; S_HYBRID_RANDI_BASE = MFbA_opt.S_HYBRID_RANDI_BASE ; else S_HYBRID_RANDI_STEP = false ; end ;

% ======================== %
% algorithm initialization %
% ======================== %
S          = S_init ;
S_curr     = S      ;
if( strcmp( S_HYBRID , 'FISTA' ) )
S_prev     = S_curr ;
tk      = 0      ; % Nesterov parameter on S-leastsquares
end
A          = A_init ;
A_curr     = A      ;
if( strcmp( A_HYBRID , 'FISTA' ) )
A_prev     = A_curr ;
uk      = 0      ; % Nesterov parameter on A-leastsquares
end
objCurr    = 0.5 * ( sum(sum((Y_H-A*S*G).^2)) ...
                   + sum(sum((Y_M-F*A*S).^2)) ) ;
modelOrder = size( A , 2 ) ;
zeros_N_L  = false( modelOrder , MS_pixelNum )       ; % boolean false matrix
FW_bases   = 0:modelOrder:modelOrder*(MS_pixelNum-1) ;
% ============= %
% the algorithm %
% ============= %
obj_it    = zeros(maxIteraNum+1,1) ;
time_it   = zeros(maxIteraNum+1,1) ;
obj_it(1) = objCurr                ;
tic ;
SG = S_curr * G ;
FA = F * A_curr ;
for k = 1 : maxIteraNum
    if( exist( 'stopHIS.txt' , 'file' ) )
        delete stopHIS.txt
        break ;
    end
    % ============ %
    % S-subproblem %
    % ============ %
    if( S_HYBRID_RANDI_STEP )
        SStep = randi(S_HYBRID_RANDI_BASE) ;
    else
        SStep = 1 ;
    end
    switch S_HYBRID
    case 'FW'
    for sstep = 1 : SStep
        Scurr_G        = SG                                      ;
        AScurrGminY_H  = A*Scurr_G - Y_H                         ;
        FAScurrminY_M  = FA*S_curr - Y_M                         ;
        GRADS          = ( A' * AScurrGminY_H ) * G'           ...
                         + FA' * ( FA * S_curr - Y_M )           ;
        [~,minIdx]     = min( GRADS )                            ;
        ZS             = zeros_N_L                               ;
        ZS( minIdx + FW_bases ) = 1                              ;
        ZSminScurr     = ZS - S_curr                             ;
        A_ZSminScurr_G = A * ( ZSminScurr * G )                  ;
        FA_ZSminScurr  = FA * ZSminScurr                         ;
        tau            = ( - (AScurrGminY_H(:)' * A_ZSminScurr_G(:))  ...
                           - (FAScurrminY_M(:)' * FA_ZSminScurr(:)) ) ...
                         / (  A_ZSminScurr_G(:)' * A_ZSminScurr_G(:)  ...
                            + FA_ZSminScurr(:)' * FA_ZSminScurr(:)    ...
                            + 1e-8 * (ZSminScurr(:)'*ZSminScurr(:)) ) ;
        tau            = min( max( tau , 0 ) , 1 )               ;
        S_curr         = S_curr + tau * ZSminScurr               ;
        SG             = S_curr * G                              ;
    end
    % end case 'FRANKWOLFE'
    end
    S = S_curr ;
    % ============ %
    % A-subproblem %
    % ============ %
    if( A_HYBRID_RANDI_STEP )
        AStep = randi(A_HYBRID_RANDI_BASE) ;
    else
        AStep = 1 ;
    end
    switch A_HYBRID
    case 'PG'
    LA = max( eig( SG*SG' + theta * (S*S') ) ) ;
    for astep = 1 : AStep
        GRADA  = ( A_curr * SG - Y_H ) * (SG'/LA)        ...
                 + F' * ( ( ( FA * S - Y_M ) * S' ) / LA ) ;
        A_curr = min( max( A_curr-GRADA , 0 ) , 1 )        ;
        FA     = F * A_curr                                ;
    end
    % end case 'PROXGRAD'
    case 'FISTA'
    LA = max( eig( SG*SG' + theta * (S*S') ) ) ;
    %if( restart_uk ) ; uk  = 0 ; end ;
    for astep = 1 : AStep
        uk_next = 0.5 + sqrt( 0.25 + uk^2 )                           ;
        ZA      = A_curr + ( (uk-1) / uk_next ) * ( A_curr - A_prev ) ;
        GRADA   = ( ( ZA * SG - Y_H ) * SG'                         ...
                  + F' * ( ( (F * ZA) * S - Y_M ) * S' ) ) / LA       ;
        uk      = uk_next                                             ;
        A_prev  = A_curr                                              ;
        A_curr  = min( max( ZA - GRADA , 0 ) , 1 )                    ;
    end
    FA = F * A_curr ;
    % end case 'FISTA'
    end
    A = A_curr ;
    % ================= %
    % check convergence %
    % ================= %
    objPrev      = objCurr                                         ;
    HS_residual  = Y_H-A_curr*SG                                   ;
    MS_residual  = Y_M-FA*S_curr                                   ;
    objCurr      = 0.5 * ( HS_residual(:)'*HS_residual(:)        ...
                         + MS_residual(:)'*MS_residual(:) )        ;
    time_it(k+1) = toc                                             ;
    obj_it(k+1)  = objCurr                                         ;
    obj_chng     = abs( objPrev - objCurr ) / objCurr              ;
    if( obj_chng < convthresh )
        fprintf( 'objective value converges !\n' )                 ;
        fprintf( 'early break @ it: %d / %d\n' , k , maxIteraNum ) ;
        break                                                      ;
    end
end
TIME_MFbA = toc ;
HSI_MF = reshape( S'*A' , MS_imgSizeM , MS_imgSizeN , HS_bandNum ) ;
IT_used_MF = k ;
returnInfo.obj_it  = obj_it ;
returnInfo.time_it = time_it ;
end




%%%%%%%%%%%%%%
%%%%%%%%%%%%%%




function maxEig = powermethod( M , iteraNum )
n = size(M,1) ; x = rand(n,1) - 0.5 ; x = x ./ abs(x) ;
fprintf( 'iteration : %d \\     ' , iteraNum ) ;
for k = 1 : iteraNum ; fprintf( '\b\b\b\b%4i' , k ) ; x = M * x ; end
fprintf( '\n' ) ;
maxEig = ( x' * M * x ) / ( x' * x ) ;
end




function X = SimplexProj(Y)
% Projection to a simplex; the codes are from the reference [41]
% W. Wang and M. A. Carreira-Perpin?n, ?Projection onto the probability
% arXiv preprint arXiv:1309.1541v1, 2013.
[N,D] = size(Y);
X = sort(Y,2,'descend');
Xtmp = (cumsum(X,2)-1)*diag(sparse(1./(1:D)));
X = max(bsxfun(@minus,Y,Xtmp(sub2ind([N,D],(1:N)',sum(X>Xtmp,2)))),0);
end
