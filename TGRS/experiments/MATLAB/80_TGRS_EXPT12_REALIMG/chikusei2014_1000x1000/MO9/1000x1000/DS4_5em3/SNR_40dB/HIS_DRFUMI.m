function [ HSI_DRFUMI , A , S , IT_used , TIME_DRFUMI , returnInfo ] = HIS_DRFUMI( HS , MS , DRFUMI_opt )
returnInfo.status = 'null' ;

addpath('~/Documents/Michael/HYPERSPEC/FUMI');

HS_bandNum  = DRFUMI_opt.HS_bandNum ;
HS_imgSizeM = DRFUMI_opt.HS_imgSizeM ;
HS_imgSizeN = DRFUMI_opt.HS_imgSizeN ;
HS_pixelNum = HS_imgSizeM * HS_imgSizeN ;
MS_bandNum  = DRFUMI_opt.MS_bandNum ;
MS_imgSizeM = DRFUMI_opt.MS_imgSizeM ;
MS_imgSizeN = DRFUMI_opt.MS_imgSizeN ;
MS_pixelNum = MS_imgSizeM * MS_imgSizeN ;
dsRatio     = DRFUMI_opt.dsRatio ;
F           = DRFUMI_opt.F ;
sig         = DRFUMI_opt.G_sigma ;
kerSiz      = DRFUMI_opt.G_kerSiz ;
modelOrder  = DRFUMI_opt.modelOrder ;
convthresh  = DRFUMI_opt.convthresh ;
maxIteraNum = DRFUMI_opt.maxIteraNum;

Y_H              = reshape( permute(HS,[3,1,2]) , HS_bandNum , HS_pixelNum ) ;
Y_M              = reshape( permute(MS,[3,1,2]) , MS_bandNum , MS_pixelNum ) ;
ChInv            = eye(HS_bandNum);
CmInv            = eye(MS_bandNum);
psfY.ds_r        = dsRatio ;
    mask         = zeros( MS_imgSizeM , MS_imgSizeN ) ;
    mask( 1 : dsRatio : end , 1 : dsRatio : end ) = 1 ;
psfY.dsp         = mask ;
    KerBlu       = fspecial('gaussian',[kerSiz,kerSiz],sig);
psfY.B=KernelToMatrix(KerBlu,MS_imgSizeM,MS_imgSizeN);
psfZ             = F ;
sizeIM           = [ MS_imgSizeM , MS_imgSizeN , modelOrder ] ;

para_opt_in.SpaDeg=1; %%  If the degradation B and S are known, SpaDeg=1; otherwise, SpaDeg=0
para_opt_in.N_it=maxIteraNum;% The number of iterations for BCD updates
para_opt_in.thre_BCD=convthresh;
if( ~isfield( DRFUMI_opt , 'A_init' ) )
    error( 'ERROR : A_init is not provided !!!' ) ;
else
    A_init = DRFUMI_opt.A_init ;
end
para_opt_in.E_ini=A_init;
para_opt_in.It_ADMM_ABUN = DRFUMI_opt.It_ADMM_ABUN ;
para_opt_in.It_ADMM_EEA  = DRFUMI_opt.It_ADMM_EEA ;
para_opt_in.Th_ADMM_ABUN = DRFUMI_opt.Th_ADMM_ABUN ;
para_opt_in.Th_ADMM_EEA  = DRFUMI_opt.Th_ADMM_EEA ;

[Out,para_opt] = JointFusionUnmix(Y_H,Y_M,ChInv,CmInv,psfY,psfZ,sizeIM,para_opt_in) ;
A                  = Out.E_hyper ;
S                  = Out.A_multi ;
HSI_DRFUMI           = reshape( S' * A' , MS_imgSizeM , MS_imgSizeN , HS_bandNum ) ;
IT_used            = Out.IT_used ;
TIME_DRFUMI          = Out.TIME_DRFUMI ;
returnInfo.obj_it  = para_opt.obj_it ;
returnInfo.time_it = para_opt.time_it ;
end

function [Out,para_opt]= JointFusionUnmix(Y_H,Y_M,LAMB_H,LAMB_M,psfY,F,ABUND_SIZE,para_opt_in)
%% This function implements the joint fusion and unmixing of Hyperspectral and Multispectral images
%If you use this code, please cite the following paper:
% [1] Q. Wei, J. M. Bioucas-Dias, N. Dobigeon and J-Y. Tourneret,
%Multi-Band Image Fusion Based on Spectral Unmixing, in preparation.
%% -------------------------------------------------------------------------
% Copyright (March, 2015):        Qi WEI (qi.wei@n7.fr)
%
% FastAuxMat is distributed under the terms of
% the GNU General Public License 2.0.
%
% Permission to use, copy, modify, and distribute this software for
% any purpose without fee is hereby granted, provided that this entire
% notice is included in all copies of any software which is or includes
% a copy or modification of this software and in all copies of the
% supporting documentation for such software.
% This software is being provided "as is", without any express or
% implied warranty.  In particular, the authors do not make any
% representation or warranty of any kind concerning the merchantability
% of this software or its fitness for any particular purpose."
dsRatio     = psfY.ds_r            ;
N_it        = para_opt_in.N_it     ;
SpaDeg      = para_opt_in.SpaDeg   ;
thre_BCD    = para_opt_in.thre_BCD ;
A           = para_opt_in.E_ini    ;
MS_imgSizeM = ABUND_SIZE(1)        ;
MS_imgSizeN = ABUND_SIZE(2)        ;
modelOrder  = ABUND_SIZE(3)        ;
St_size     = [MS_imgSizeM*MS_imgSizeN modelOrder] ;
HS_imgSizeM = MS_imgSizeM/dsRatio  ;
HS_imgSizeN = MS_imgSizeN/dsRatio  ;
HS_bandNum  = size(Y_H,1)          ;

It_ADMM_ABUN = para_opt_in.It_ADMM_ABUN ;
It_ADMM_EEA  = para_opt_in.It_ADMM_EEA  ;
Th_ADMM_ABUN = para_opt_in.Th_ADMM_ABUN ;
Th_ADMM_EEA  = para_opt_in.Th_ADMM_EEA  ;

sStepUsed = zeros(N_it,1) ;
aStepUsed = zeros(N_it,1) ;

%[H,~,~] = svd(Y_H) ;
%H       = H(:,1:modelOrder) ;
[eVec,~] = eig(Y_H*Y_H') ;
eVec     = fliplr(eVec)  ;
H        = eVec(:,1:modelOrder) ;

if SpaDeg==1
    FBm         = fft2(psfY.B);
    FBmC        = conj(FBm);
    FBs         = repmat(FBm,[1 1 modelOrder]);
    FBCs        = repmat(FBmC,[1 1 modelOrder]);
    FBCNs       = repmat(FBmC./(abs(FBmC).^2),[1 1 modelOrder]);
    B2Sum       = PPlus(abs(FBs).^2./(dsRatio^2),HS_imgSizeM,HS_imgSizeN);

    XH_int      = zeros(MS_imgSizeM,MS_imgSizeN,HS_bandNum);
    XH_int(1:dsRatio:end,1:dsRatio:end,:) = reshape(Y_H',[HS_imgSizeM HS_imgSizeN HS_bandNum]);
    Y_init      = reshape(XH_int,[MS_imgSizeM*MS_imgSizeN HS_bandNum])';  %% interpolated HS image with zeros

    % Normalized HS and MS data
    Y_HGt       = LAMB_H*Y_init;
    LAMB_M_Y_M  = LAMB_M*Y_M;

    rou         = min(mean(diag(LAMB_M)),mean(diag(LAMB_H)))*1e0;
    %rou=1e5; % The ADMM regularization parameter
    meanVIm     = zeros([modelOrder MS_imgSizeM*MS_imgSizeN]);  % The Gaussian prior mean: initialized with zeros
    W           = zeros([modelOrder MS_imgSizeM*MS_imgSizeN]);      % Dual Variable: intialized with zeros
    N_admm      = It_ADMM_ABUN ;                % The maximum numbre of ADMM steps
    %thre_ADMM=1/sqrt(rou);            % The threshold of primal dual to stop in ADMM 1/sqrt(rou)
    thre_ADMM   = Th_ADMM_ABUN;
    thre_ADMM_dual = Th_ADMM_ABUN;
    res_dual    = inf;
end
cost_BCD = zeros(N_it+1,1);        % Initialization
time_it = zeros(N_it+1,1) ;
cost_BCD(1) = 0.5 * norm( sqrt(LAMB_H) * (Y_H-A*ones(St_size(2),HS_imgSizeM*HS_imgSizeN)/St_size(2)) , 'fro' )^2 + ...
              0.5 * norm( sqrt(LAMB_M) * (Y_M-(F*A)*ones(St_size(2),St_size(1))/St_size(2)) , 'fro' )^2 ;
tic ;
for t=1:N_it
    if( exist( 'stopHIS.txt' , 'file' ) )
        delete stopHIS.txt
        break ;
    end
    !date
    fprintf( 'FUMI it: %d / %d\n' , t , N_it ) ;
    FA = F*A;
    if SpaDeg==0
        %% Update the HS Abundances: SUDAP or SUNSAL
        [SG,~] = fcls_dpcs_v1(A,Y_H,'POSITIVITY','yes','VERBOSE','no','ADDONE', 'yes', ...
                                  'ITERS',100,'FACTORIZATION', 'orth', 'TOL', 1e-200,'X_SOL',0,'CONV_THRE',0);
        %% Update the MS Abundances: SUDAP or SUNSAL
        [S,~]  = fcls_dpcs_v1(FA,Y_M,'POSITIVITY','yes','VERBOSE','no','ADDONE', 'yes', ...
                                  'ITERS',100,'FACTORIZATION', 'orth', 'TOL', 1e-200,'X_SOL',0,'CONV_THRE',0); %% SUDAP
    elseif SpaDeg==1
        %% Unmixing based on Sylvester equation embedded in ADMM
        AtY_HGt = A'*Y_HGt;
        AtFtY_M = FA'*LAMB_M_Y_M;
        AtA     = A'*LAMB_H*A;
        AtFtFA  = FA'*LAMB_M*FA;
        %% Update the High-resolution Abundance Maps: ADMM scheme
        [Q,Cc,InvDI,InvLbd,C2Cons]=FasterAuxMat(AtY_HGt,AtFtY_M,FBs,FBCs,ABUND_SIZE,HS_imgSizeM,HS_imgSizeN,rou*eye(modelOrder),AtA,AtFtFA,B2Sum);
        for n_admm=1:N_admm
            %% Update A: Using An explicit Sylvester Solver
            S_FFT = FasterFusion(meanVIm,Q,Cc,InvDI,InvLbd,C2Cons,FBs,FBCs,St_size,ABUND_SIZE,HS_imgSizeM,HS_imgSizeN,dsRatio);
            S = reshape(real(ifft2(reshape(S_FFT',ABUND_SIZE))),St_size)';
            %% Update V: Using the Projection onto the Simplex
            V=SimplexProj((S-W)')'; %  V=A_multi-W; Without projection to the simplex
            %% Update the residual
            res_pri=S-V;  % The primal residual: the difference between A and V
            W=W-res_pri;        % The dual variable
            if n_admm>1
               res_dual=rou*(V-V_old);
            end
            V_old=V;
            %res_AVG = S-V-W ;
            meanVIm = reshape(fft2(reshape((V+W)',ABUND_SIZE)),St_size)';%VXd_dec VXHd_int VX_real Maybe problem here
            if norm(res_pri,'fro')/sqrt(numel(res_pri))<thre_ADMM  && norm(res_dual,'fro')/sqrt(numel(res_dual))<thre_ADMM_dual %&& norm(res_AVG,'fro')/sqrt(numel(res_AVG))<thre_ADMM
                break; %% Stop when the primal dual is smaller than a threshold
            end
            %rou_set(n_admm)=rou;
        end
        ImAh_temp = reshape(S',ABUND_SIZE);
        ImAh_temp = func_blurringY(ImAh_temp,psfY); % blurring and downsampling
        ImAh_temp = ImAh_temp(1:dsRatio:end,1:dsRatio:end,:);
        SG        = reshape(ImAh_temp,[HS_imgSizeM*HS_imgSizeN modelOrder])';
    end
    %% Update the Endmembers
    [A,i]       = EEA(A,SG,S,Y_H,Y_M,F,LAMB_H,LAMB_M,Th_ADMM_EEA,It_ADMM_EEA,H); % HS+MS
    %% objective function to minimize
    time_it(t+1)  = toc ;
    cost_BCD(t+1) = 0.5 * norm( sqrt(LAMB_H) * (Y_H-A*SG) , 'fro' )^2 + 0.5 * norm( sqrt(LAMB_M) * (Y_M-FA*S) , 'fro' )^2 ;
    if t>2
        fprintf( 'obj chg ratio: %f\n' , abs((cost_BCD(t)-cost_BCD(t-1))/cost_BCD(t-1)) ) ;
    end
    if t>2 && abs((cost_BCD(t)-cost_BCD(t-1))/cost_BCD(t-1))<thre_BCD
        break;
    end
end
TIME_DRFUMI = toc ;
disp(['BCD converges at the ' num2str(t) 'th iteration']);
Out.E_hyper=A;
Out.A_hyper=SG;
Out.E_multi=FA;
Out.A_multi=S;
Out.IT_used=t;
Out.TIME_DRFUMI=TIME_DRFUMI;

para_opt.obj_it = cost_BCD ;
para_opt.time_it = time_it ;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Internal functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [B]=KernelToMatrix(KerBlu,nr,nc)
% flip the kernel
KerBlu=rot90(KerBlu,2);
mid_col=round((nc+1)/2);
mid_row=round((nr+1)/2);
% the size of the kernel
[len_hor,len_ver]=size(KerBlu);
lx = (len_hor-1)/2;
ly = (len_ver-1)/2;
B=zeros(nr,nc);
% range of the pixels
B(mid_row-lx:mid_row+lx,mid_col-ly:mid_col+ly)=KerBlu;
B=circshift(B,[-mid_row+1,-mid_col+1]);
end

function X = SimplexProj(Y)
%% This function prjected each row of Y into the canonical simplex
[N,D] = size(Y);
X = sort(Y,2,'descend');
Xtmp = (cumsum(X,2)-1).*repmat(1./(1:D),[N 1]);
X = max(bsxfun(@minus,Y,Xtmp(sub2ind([N,D],(1:N)',sum(X>Xtmp,2)))),0);

end

function Y = func_blurringY(X,psf,varargin)

FBm  = fft2(psf.B);
FBmC = conj(FBm);
% build convolution filters
FZ = zeros(size(X));
FZC = zeros(size(X));
for i=1:size(X,3)
    FZ(:,:,i) = FBm;
    FZC(:,:,i) = FBmC;
end
ConvCBD = @(X,FK) real(ifft2(fft2(X).*FK));

if nargin==2
    Y=ConvCBD(X,FZ);
elseif nargin==3
    dsp_op=repmat(psf.dsp,[1 1 size(X,3)]);
    X = X.*dsp_op;
    Y=ConvCBD(X,FZC);
end

end

%function [A] = EEA(A,SG,S,Y_H,Y_M,F,LAMB_H,LAMB_M,U)
function [A,i] = EEA(A,SG,S,Y_H,Y_M,F,LAMB_H,LAMB_M,Th_ADMM_EEA,It_ADMM_EEA,U)
%% Initialization
mu           = size(Y_H,2);
Th_ADMM      = Th_ADMM_EEA ; %% Threshold to stop
Th_ADMM_dual = Th_ADMM_EEA ;
res_Dual     = inf  ;
N_max        = It_ADMM_EEA  ;
subspace=1;
subspace     = 0    ;
V = 1 * sqrt(LAMB_H) * A ;
G = V * 0 ;
%% Loop
[HS_bandNum,modelOrder] =size(A) ;
inv_SSt = eye(modelOrder)/(S*S') ;
DisM    = modelOrder/(modelOrder-1)*eye(modelOrder)-1/(modelOrder-1)*ones(modelOrder,modelOrder);
lambda  = 0e-4*mean(diag(LAMB_H))*size(Y_H,2); % if lambda==0, there is no minimum volume constraint
MatB    = (SG*SG'+mu*eye(modelOrder))*inv_SSt;
MatD    = lambda*(DisM*DisM')*inv_SSt;
if subspace==0
    MatE     = inv(LAMB_H);
    MatA     = LAMB_H\F'*LAMB_M*F;
    temp1    = LAMB_H\F'*LAMB_M*Y_M*S'+Y_H*SG';
    Mat_temp = kron(eye(modelOrder),MatA)+kron(MatB',eye(HS_bandNum))+kron(MatD',MatE);
    temp     = Mat_temp\eye(HS_bandNum*modelOrder);
elseif subspace==1
    % Subspace
    RH       = F*U;
    MatE     = (U'*LAMB_H*U)\eye(modelOrder);
    MatA     = MatE*((RH)'*LAMB_M*RH);
    temp1    = MatE*U'*(LAMB_H*Y_H*SG'+F'*LAMB_M*Y_M*S');
    temp2    = mu*MatE*U'*sqrt(LAMB_H);
    Mat_temp = kron(eye(modelOrder),MatA)+kron(MatB',eye(modelOrder))+kron(MatD',MatE);
    temp     = Mat_temp\eye(modelOrder*modelOrder);
end

upper_V=repmat(diag(sqrt(LAMB_H)),[1 modelOrder]);

%% Define the regularzier
for i=1:N_max
    %% Sylvester equation
    if subspace==0
        MatC = (temp1+mu*(sqrt(LAMB_H)\(V+G)))*inv_SSt;
        A    = reshape(temp*MatC(:),[HS_bandNum modelOrder]);
    else
        MatC = (temp1+temp2*(V+G))*inv_SSt;
        A    = U*reshape(temp*MatC(:),[modelOrder modelOrder]);
    end
    nu    = sqrt(LAMB_H)*A-G;
    V_old = V ;
    V     = min(max(nu,0),upper_V);
    G     = V-nu ;
    %% Stop the ADMM if the residual is small enough: sqrt(ChInv)*E-V
    res_Pri = sqrt(LAMB_H)*A-V;
    res_Dual= mu*(V-V_old);
    %res_AVG = A-V-G ;
    if norm(res_Pri,'fro')/sqrt(numel(res_Pri))< Th_ADMM && norm(res_Dual,'fro')/sqrt(numel(res_Dual))< Th_ADMM_dual %&& norm(res_AVG,'fro')/sqrt(numel(res_AVG))< Th_ADMM %(abs((cost-cost_old))/cost_old < Th || i == N_max) %&& i>2
        break;
    end
end
end
