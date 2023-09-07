function [A,S,obj,t] = HIS_hybrid(Y_H,Y_M,Setting)
% ==========================================
F = Setting.F;
G = Setting.G;
A_init = Setting.A_init;
S_init = Setting.S_init;
convthresh = Setting.convthresh;
maxIteraNum = Setting.maxIteraNum;
% modelOrder = Setting.modelOrder;
% Setting.dimReduction = false;

% ============ %
% read options %
% ============ %

if( isfield( Setting , 'AfistaStep'  ) ) ; AfistaStep  = Setting.AfistaStep  ; else AfistaStep  = 1;                                                                     ; end ;
if( isfield( Setting , 'SfistaStep'  ) ) ; SfistaStep  = Setting.SfistaStep  ; else SfistaStep  = 30;                                                                     ; end ;
if( isfield( Setting , 'A_LIM'  ) ) ; A_LIM  = Setting.A_LIM  ; else A_LIM  = 1e-7                                                                  ; end ;
if( isfield( Setting , 'S_LIM'  ) ) ; S_LIM  = Setting.S_LIM  ; else S_LIM  = 1e-7                                                                  ; end ;

% =================== %
% frequently used var %
% =================== %
gamma = DSP_POWERMETHOD(G'*G,100);
theta = norm(F*F',2); 
% ======================== %
% algorithm initialization %
% ======================== %
S = S_init;
S_curr = S_init;
A = A_init;
A_curr = A_init;
A_prev = A_curr;
uk = 0; % Nesterov parameter on A-leastsquares
obj_recorder = inf;
stopping_count = 0;
% if Setting.dimReduction
%     [U,~,~]=svd(Y_H); 
%     U = U(:,1:modelOrder);
%     YH_dr = U'*Y_H;
%     F_dr = F*U;
% end
% ~ wrap up info ~ %
objCurr = 1/2*(sum(sum((Y_H-A*(S*G)).^2))+sum(sum((Y_M-(F*A)*S).^2)));
obj = objCurr ;
% ============= %
% the algorithm %
% ============= %
t = 0 ;
tic;
for k = 1 : maxIteraNum
    % ============ %
    % S-subproblem %
    % ============ %
    % ---------------------- %
    % solving by frank-wolfe %
    % ---------------------- %
    FA = F*A;
    AtA = A'*A;
    AtY_H = A'*Y_H;
    LS = max(eig(gamma*AtA+FA'*FA));
    for sfista = 1:SfistaStep
        S_prev = S_curr;
        GRADS = (AtA*(S_curr*G)-AtY_H)*G'+FA'*(FA*S_curr-Y_M);
        [~,columIndex] = min(GRADS);
        FW_upd = ind2vec(columIndex,size(S_curr,1));
        FW_upd_S_curr = FW_upd-S_curr;
        step = min(1, -(GRADS(:)'*FW_upd_S_curr(:)) / (LS* (FW_upd_S_curr(:)'*FW_upd_S_curr(:))) );
        S_curr = S_curr+step*FW_upd_S_curr;
        if sfista>1 && SfistaStep>20
            s_d         = S_curr(:) - S_prev(:) ;
            S_diff_norm = square((s_d'*s_d)/length(s_d));
            if(S_diff_norm<S_LIM)
                break ;
            end
        end
    end % end for sfista = 1 : SfistaStep
    S = S_curr;
    % ============ %
    % A-subproblem %
    % ============ %
    % ---------------------------- %
    % solving by proximal gradient %
    % ---------------------------- %
    SG = S*G ;
    if(AfistaStep>100)
        uk = 0;
    end
    LA = norm(SG*SG'+theta*(S*S'),2);
    for afista = 1:AfistaStep
        uk_next = (1+sqrt(4*uk^2+1))/2 ;    
        ZA = A_curr+(uk-1)/uk_next*(A_curr-A_prev);
%        ZA = A_curr;
        GRADA = (ZA*SG-Y_H)*SG'+F'*(((F*ZA)*S-Y_M)*S');    
        uk = uk_next;    
        A_prev = A_curr;
        A_curr = min(1,max(0,ZA-1/LA*GRADA));    
        if afista>1 && AfistaStep>20
            a_d         = A_curr(:) - A_prev(:) ;
            A_diff_norm = sqrt((a_d'*a_d)/length(a_d));    
            if A_diff_norm<A_LIM    
                break;    
            end    
        end    
    end
    A = A_curr;
    % ================= %
    % check convergence %
    % ================= %
%     objCurr = 0.5*(sum(sum((Y_H-A_curr*(S_curr*G)).^2))+sum(sum((Y_M-(F*A_curr)*S_curr).^2)));
%     if objCurr<=obj_recorder-1e-1
%         obj_recorder = objCurr;
%         A_best = A_curr;
%         S_best = S_curr;
%         stopping_count = 0;
%     else
%         stopping_count = stopping_count+1;
%     end
%     if stopping_count >= 10
%         break ;
%     end
    objPrev = objCurr;
    HS_residual  = Y_H-A*(S*G) ;
    MS_residual  = Y_M-(F*A)*S ;
    objCurr = 0.5*(HS_residual(:)'*HS_residual(:)+MS_residual(:)'*MS_residual(:));
    obj = [ obj , objCurr ] ;
    obj_chng = abs(objPrev-objCurr)/objPrev;
    if obj_chng<convthresh
        break ;
    end
    t = [ t , toc ] ;
end
runtime = toc;
end

