function [ HSI_MF , A , S , IT_used_MF , TIME_MFbA , returnInfo ] = HIS_MFbA_fista( HS , MS , MFbA_opt )
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
% algorithm initialization %
S       = S_init ; S_curr  = S_init ; S_prev  = S_curr ;
A       = A_init ; A_curr  = A_init ; A_prev  = A_curr ;
tk      = 0      ; % Nesterov parameter on S-leastsquares
uk      = 0      ; % Nesterov parameter on A-leastsquares
%restart_tk = ( SStep > 100 ) ;
%restart_uk = ( AStep > 100 ) ;
objCurr = 0.5 * ( sum(sum((Y_H-A*S*G).^2)) + sum(sum((Y_M-F*A*S).^2)) ) ;
% the algorithm %
obj_it    = zeros(maxIteraNum+1,1) ; time_it   = zeros(maxIteraNum+1,1) ;
obj_it(1) = objCurr                ;
tic ;
FA = F * A ;
for k = 1 : maxIteraNum
    % S-subproblem %
    AtA = A'*A                             ;
    LS  = max( eig( gamma*AtA + FA'*FA ) ) ;
    %if( restart_tk ) ; tk  = 0 ; end ;
    for sstep = 1 : SStep
        tk_next = 0.5 + sqrt( 0.25 + tk^2 )                           ;
        ZS      = S_curr + ( (tk-1) / tk_next ) * ( S_curr - S_prev ) ;
        GRADS   = ( (AtA/LS) * ( ZS * G ) - (A'/LS) * Y_H ) * G'    ...
                  + (FA'/LS) * ( FA * ZS - Y_M )                      ;
        tk      = tk_next                                             ;
        S_prev  = S_curr                                              ;
        S_curr  = SimplexProj( (ZS - GRADS)' )'                       ;
    end
    S = S_curr ;
    % A-subproblem %
    SG = S*G                                   ;
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
    A = A_curr ;
    % check convergence %
    FA           = F * A                                           ;
    objPrev      = objCurr                                         ;
    objCurr      = 0.5 * ( sum(sum((Y_H-A_curr*SG).^2))          ...
                       + sum(sum((Y_M-FA*S_curr).^2)) )            ;
    time_it(k+1) = toc                                             ;
    obj_it(k+1)  = objCurr                                         ;
    obj_chng     = abs( objPrev - objCurr ) / objCurr              ;
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
