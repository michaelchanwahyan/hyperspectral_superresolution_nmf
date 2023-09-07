function [ HSI_MF , A , S , IT_used_MF , TIME_MFbA , returnInfo ] = HIS_MFbA_gpExLnSrch( HS , MS , MFbA_opt )
returnInfo.status = 'null' ;
% ============== %
% basic var info %
% ============== %
[ HS_imgSizeM , HS_imgSizeN , HS_bandNum ] = size( HS ) ;
[ MS_imgSizeM , MS_imgSizeN , MS_bandNum ] = size( MS ) ;
  HS_pixelNum = HS_imgSizeM * HS_imgSizeN ;
  MS_pixelNum = MS_imgSizeM * MS_imgSizeN ;
  Y_M = reshape( permute( MS , [ 3 , 1 , 2 ] ) , MS_bandNum , MS_pixelNum ) ;
  Y_H = reshape( permute( HS , [ 3 , 1 , 2 ] ) , HS_bandNum , HS_pixelNum ) ;
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
% ======================== %
% algorithm initialization %
% ======================== %
S       = S_init ;
S_curr  = S      ;
A       = A_init ;
A_curr  = A      ;
objCurr = 0.5 * ( sum(sum((Y_H-A*S*G).^2)) ...
                + sum(sum((Y_M-F*A*S).^2)) ) ;
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
    % ============ %
    % S-subproblem %
    % ============ %
    for sstep = 1 : SStep
        Scurr_G        = SG                                     ;
        AScurrGminY_H  = A*Scurr_G - Y_H                        ;
        FAScurrminY_M  = FA*S_curr - Y_M                        ;
        GRADS          = ( A' * AScurrGminY_H ) * G'          ...
                           + FA' * FAScurrminY_M                ;
        ZS             = SimplexProj( (S_curr - GRADS)' )'      ;
        ZSminScurr     = ZS - S_curr                            ;
        A_ZSminScurr_G = A * ( ZSminScurr * G )                 ;
        FA_ZSminScurr  = FA * ZSminScurr                        ;
        tau            = ( - sum(sum( AScurrGminY_H .* A_ZSminScurr_G )) ...
                           - sum(sum( FAScurrminY_M .* FA_ZSminScurr  )) ) ...
                         / (   sum(sum( A_ZSminScurr_G.^2 ))  ...
                             + sum(sum( FA_ZSminScurr.^2 )) )   ;
        tau            = min( max( tau , 0 ) , 1 )              ;
        S_curr         = ( 1-tau ) * S_curr + tau * ZS          ;
        SG             = S_curr * G                             ;
    end
    S = S_curr ;
    % ============ %
    % A-subproblem %
    % ============ %
    for astep = 1 : AStep
        F_Acurr        = FA                                    ;
        AcurrSGminY_H  = A_curr*SG - Y_H                       ;
        FAcurrSminY_M  = F_Acurr * S - Y_M                     ;
        GRADA          = AcurrSGminY_H * SG'                 ...
                         + F' * ( FAcurrSminY_M * S' )         ;
        ZA             = min( max( A_curr - GRADA , 0 ) , 1 )  ;
        ZAminAcurr     = ZA - A_curr                           ;
        ZAminAcurr_SG  = ZAminAcurr * SG                       ;
        F_ZAminAcurr_S = ( F * ZAminAcurr ) * S                ;
        tau            = ( - sum(sum( AcurrSGminY_H .* ZAminAcurr_SG  )) ...
                           - sum(sum( FAcurrSminY_M .* F_ZAminAcurr_S )) ) ...
                         / (   sum(sum( ZAminAcurr_SG.^2 ))  ...
                             + sum(sum( F_ZAminAcurr_S.^2 )) ) ;
        tau            = min( max( tau , 0 ) , 1 )             ;
        A_curr         = ( 1-tau ) * A_curr + tau * ZA         ;
        FA             = F * A_curr                            ;
    end
    A = A_curr ;
    % ================= %
    % check convergence %
    % ================= %
    objPrev      = objCurr                                         ;
    objCurr      = 0.5 * ( sum(sum((Y_H-A_curr*SG).^2))          ...
                         + sum(sum((Y_M-FA*S_curr).^2)) )          ;
    obj_chng     = abs( objPrev - objCurr ) / objCurr              ;
    time_it(k+1) = toc                                             ;
    obj_it(k+1)  = objCurr                                         ;
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




function X = SimplexProj(Y)
% Projection to a simplex; the codes are from the reference [41]
% W. Wang and M. A. Carreira-Perpin?n, ?Projection onto the probability
% arXiv preprint arXiv:1309.1541v1, 2013.
[N,D] = size(Y);
X = sort(Y,2,'descend');
Xtmp = (cumsum(X,2)-1)*diag(sparse(1./(1:D)));
X = max(bsxfun(@minus,Y,Xtmp(sub2ind([N,D],(1:N)',sum(X>Xtmp,2)))),0);
end
