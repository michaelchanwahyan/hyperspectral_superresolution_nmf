function [M,Up,my,sing_values] = DSP_SISAL( Y , modelOrder , varargin )

%% [M,Up,my,sing_values] = sisal(Y,p,varargin)
%
% Simplex identification via split augmented Lagrangian (SISAL)
%
%% --------------- Description ---------------------------------------------
%
%  SISAL Estimates the vertices  M={m_1,...m_p} of the (p-1)-dimensional
%  simplex of minimum volume containing the vectors [y_1,...y_N], under the
%  assumption that y_i belongs to a (p-1)  dimensional affine set. Thus,
%  any vector y_i   belongs  to the convex hull of  the columns of M; i.e.,
%
%                   y_i = M*x_i
%
%  where x_i belongs to the probability (p-1)-simplex.
%
%  As described in the papers [1], [2], matrix M is  obtained by implementing
%  the following steps:
%
%   1-Project y onto a p-dimensional subspace containing the data set y
%
%            yp = Up'*y;      Up is an isometric matrix (Up'*Up=Ip)
%
%   2- solve the   optimization problem
%
%       Q^* = arg min_Q  -\log abs(det(Q)) + tau*|| Q*yp ||_h
%
%                 subject to:  ones(1,p)*Q=mq,
%
%      where mq = ones(1,N)*yp'inv(yp*yp) and ||x||_h is the "hinge"
%              induced norm (see [1])
%   3- Compute
%
%      M = Up*inv(Q^*);
%
%% -------------------- Line of Attack  -----------------------------------
%
% SISAL replaces the usual fractional abundance positivity constraints, 
% forcing the spectral vectors to belong to the convex hull of the 
% endmember signatures,  by soft  constraints. This new criterion brings
% robustnes to noise and outliers
%
% The obtained optimization problem is solved by a sequence of
% augmented Lagrangian optimizations involving quadractic and one-sided soft
% thresholding steps. The resulting algorithm is very fast and able so
% solve problems far beyond the reach of the current state-of-the art
% algorithms. As examples, in a standard PC, SISAL, approximatelly, the
% times:
%
%  p = 10, N = 1000 ==> time = 2 seconds
%
%  p = 20, N = 50000 ==> time = 3 minutes
%
%%  ===== Required inputs =============
%
% y - matrix with  L(channels) x N(pixels).
%     each pixel is a linear mixture of p endmembers
%     signatures y = M*x + noise,
%
%     SISAL assumes that y belongs to an affine space. It may happen,
%     however, that the data supplied by the user is not in an affine
%     set. For this reason, the first step this code implements
%     is the estimation of the affine set the best represent
%     (in the l2 sense) the data.
%
%  p - number of independent columns of M. Therefore, M spans a
%  (p-1)-dimensional affine set.
%
%
%%  ====================== Optional inputs =============================
%
%  'MM_ITERS' = double; Default 80;
%
%               Maximum number of constrained quadratic programs
%
%
%  'TAU' = double; Default; 1
%
%               Regularization parameter in the problem
%
%               Q^* = arg min_Q  -\log abs(det(Q)) + tau*|| Q*yp ||_h
%
%                 subject to:ones(1,p)*Q=mq,
%
%              where mq = ones(1,N)*yp'inv(yp*yp) and ||x||_h is the "hinge"
%              induced norm (see [1]).
%
%  'MU' = double; Default; 1
%
%              Augmented Lagrange regularization parameter
%
%  'spherize'  = {'yes', 'no'}; Default 'yes'
%
%              Applies a spherization step to data such that the spherized
%              data spans over the same range along any axis.
%
%  'TOLF'  = double; Default; 1e-2
%
%              Tolerance for the termination test (relative variation of f(Q))
%
%
%  'M0'  =  <[Lxp] double>; Given by the VCA algorithm
%
%            Initial M.
%
%
%  'verbose'   = {0,1,2,3}; Default 1
%
%                 0 - work silently
%                 1 - display simplex volume
%                 2 - display figures
%                 3 - display SISAL information 
%                 4 - display SISAL information and figures
%
%
%
%
%%  =========================== Outputs ==================================
%
% M  =  [Lxp] estimated mixing matrix
%
% Up =  [Lxp] isometric matrix spanning  the same subspace as M
%
% my =   mean value of y
%
% sing_values  = (p-1) eigenvalues of Cy = (y-my)*(y-my)/N. The dynamic range
%                 of these eigenvalues gives an idea of the  difficulty of the
%                 underlying problem
%
%
% NOTE: the identified affine set is given by
%
%              {z\in R^p : z=Up(:,1:p-1)*a+my, a\in R^(p-1)}
%
%% -------------------------------------------------------------------------
%
% Copyright (May, 2009):        Jos� Bioucas-Dias (bioucas@lx.it.pt)
%
% SISAL is distributed under the terms of
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
% ----------------------------------------------------------------------
%
% More details in:
%
% [1] Jos� M. Bioucas-Dias
%     "A variable splitting augmented lagrangian approach to linear spectral unmixing"
%      First IEEE GRSS Workshop on Hyperspectral Image and Signal
%      Processing - WHISPERS, 2009 (submitted). http://arxiv.org/abs/0904.4635v1
%
%
%
% -------------------------------------------------------------------------
%


%--------------------------------------------------------------
% test for number of required parametres
%--------------------------------------------------------------
if( nargin - length(varargin) ) ~= 2
    error( 'Wrong number of required parameters' ) ;
end
% data set size
[ L , N ] = size( Y ) ;
if( L < modelOrder )
    error( 'Insufficient number of columns in y' ) ;
end

%--------------------------------------------------------------
% Set the defaults for the optional parameters
%--------------------------------------------------------------
MMiters           = 80   ; % maximum number of quadratic QPs
spherize          = 'yes';
verbose           = 1    ; % display only volume evolution
tau               = 1    ; % soft constraint regularization parameter
mu = modelOrder * 1000/N ; % Augmented Lagrangian regularization parameter
M                 = 0    ; % no initial simplex
tol_f             = 1e-2 ; % tolerance for the termination test

%--------------------------------------------------------------
% Local variables
%--------------------------------------------------------------
slack             = 1e-3 ; % maximum violation of inequalities
energy_decreasing = 0    ; % flag energy decreasing
f_val_back        = inf  ; % used in the termination test
lam_sphe          = 1e-8 ; % spherization regularization parameter
lam_quad          = 1e-6 ; % quadractic regularization parameter for the Hesssian
AL_iters          = 4    ; % minimum number of AL iterations per quadratic problem
flaged            = 0    ; % flag

%--------------------------------------------------------------
% Read the optional parameters
%--------------------------------------------------------------
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'MM_ITERS'
                MMiters  = varargin{i+1};
            case 'SPHERIZE'
                spherize = varargin{i+1};
            case 'MU'
                mu       = varargin{i+1};
            case 'TAU'
                tau      = varargin{i+1};
            case 'TOLF'
                tol_f    = varargin{i+1};
            case 'M0'
                M        = varargin{i+1};
            case 'VERBOSE'
                verbose  = varargin{i+1};
            otherwise
                % Hmmm, something wrong with the parameter string
                error(['Unrecognized option: ''' varargin{i} '''']);
        end
    end
end

%%
%--------------------------------------------------------------
% set display mode
%--------------------------------------------------------------
if (verbose == 3) | (verbose == 4)
    warning('off','all');
else
    warning('on','all');
end

%%
%--------------------------------------------------------------
% identify the affine space that best represent the data set y
%--------------------------------------------------------------
my          = mean( Y , 2 )                            ;
Y           = Y - repmat( my , 1 , N )                 ;
[ Up , D ]  = svds( Y * Y' / N , modelOrder-1 )        ;
Y           = Up * Up' * Y                             ; % represent y in the subspace R^(p-1)
Y           = Y + repmat( my , 1 , N )                 ; % lift y
my_ortho    = my - Up * Up' * my                       ; % compute the orthogonal component of my
Up          = [ Up my_ortho/sqrt( sum(my_ortho.^2) ) ] ; % define another orthonormal direction
sing_values = diag(D)                                  ;
Y           = Up' * Y                                  ; % get coordinates in R^p


%------------------------------------------
% spherize if requested
%------------------------------------------
if strcmp(spherize,'yes')
    Y  = Up * Y ;
    Y  = Y - repmat( my , 1 , N )      ;
    C  = diag( 1 ./ sqrt( diag( D + lam_sphe * eye(modelOrder-1) ) ) ) ;
    IC = inv(C)                        ;
    Y  = C * Up(:,1:modelOrder-1)' * Y ;
    Y(modelOrder,:) = 1                ; % lift
    Y  = Y / sqrt(modelOrder)          ; % normalize to unit norm
end

%%
% ---------------------------------------------
%            Initialization
%---------------------------------------------
if M == 0
    % Initialize with VCA
    Mvca = DSP_VCA(Y,'Endmembers',modelOrder,'verbose','off');
    M    = Mvca      ;
    Ym   = mean(M,2) ; % expand Q
    Ym   = repmat( Ym , 1 , modelOrder ) ;
    dQ   = M - Ym    ;
    % fraction: multiply by p is to make sure Q0 starts with a feasible
    % initial value.
    M    = M + modelOrder * dQ ;
else
    % Ensure that M is in the affine set defined by the data
    M    = M - repmat( my , 1 , modelOrder ) ;
    M    = Up(:,1:modelOrder-1) * Up(:,1:modelOrder-1)' * M ;
    M    = M +  repmat( my , 1 , modelOrder ) ;
    M    = Up' * M ; % represent in the data subspace
    % is sherization is set
    if strcmp(spherize,'yes')
        M = Up * M - repmat( my , 1 , modelOrder ) ;
        M = C * Up( : , 1 : modelOrder-1 )' * M ;
        M(modelOrder,:) = 1 ; % lift
        M = M / sqrt(modelOrder) ; % normalize to unit norm
    end
    
end
Q0 = inv(M) ;
Q  = Q0     ;


% plot  initial matrix M
if verbose == 2 | verbose == 4
    set(0,'Units','pixels')

    %get figure 1 handler
    H_1             = figure ;
    pos1            = get(H_1,'Position') ;
    pos1(1)         = 50 ;
    pos1(2)         = 100+400 ;
    set(H_1,'Position', pos1)

    hold on
    M               = inv(Q);
    p_H(1)          = plot( Y(1,:) , Y(2,:) , '.'  ) ;
    p_H(2)          = plot( M(1,:) , M(2,:) , 'ok' ) ;

    leg_cell        = cell(1);
    leg_cell{1}     = 'data points';
    leg_cell{end+1} = 'M(0)';
    title('SISAL: Endmember Evolution')

end


% ---------------------------------------------
%            Build constant matrices
%---------------------------------------------

AAT    = kron( Y*Y' , eye(modelOrder) )               ; % size p^2xp^2
B      = kron( eye(modelOrder) , ones(1,modelOrder) ) ; % size pxp^2
qm     = sum( inv(Y*Y') * Y , 2 )                     ;


H      = lam_quad*eye(modelOrder^2)                   ;
F      = H + mu * AAT                                 ; % equation (11) of [1]
IF     = inv(F)                                       ;
G      = IF     * B' * inv( B * IF * B' )             ;
qm_aux = G      * qm                                  ;
G      = IF - G * B  * IF                             ; % auxiliar constant matrices


%%
% ---------------------------------------------------------------
%          Main body- sequence of quadratic-hinge subproblems
%----------------------------------------------------------------

% initializations
Z  = Q * Y ;
Bk = 0 * Z ;

for k = 1 : MMiters
    
    if( mod(k,50) == 0 )
        fprintf( '\nSISAL : %d / %d ' , k , MMiters ) ;
    end
    
    IQ =  inv(Q) ;
    g  = -IQ'    ;
    g  = g(:)    ;

    baux = H * Q(:) - g ;

    q0 = Q(:) ;
    Q0 = Q    ;
    
    % display the simplex volume
    if verbose == 1
        if strcmp(spherize,'yes')
            % unscale
            M = IQ * sqrt(modelOrder) ;
            %remove offset
            M = M(1:modelOrder-1,:) ;
            % unspherize
            M = Up(:,1:modelOrder-1) * IC * M ;
            % sum ym
            M = M + repmat(my,1,modelOrder) ;
            M = Up' * M ;
        else
            M = IQ ;
        end
        fprintf('\n iter = %d, simplex volume = %4f  \n', k, 1/abs(det(M)))
    end

    
    %Bk = 0*Z;
    if k == MMiters
        AL_iters = 100;
        %Z=Q*Y;
        %Bk = 0*Z;
    end
    
    % initial function values (true and quadratic)
    % f0_val = -log(abs(det(Q0)))+ tau*sum(sum(hinge(Q0*Y)));
    % f0_quad = f0_val; % (q-q0)'*g+1/2*(q-q0)'*H*(q-q0);
    
    %fprintf( '\tQuadratic Energy E0 : E =                    ' ) ;
    
    while 1 > 0
        q       = Q(:) ;
        % initial function values (true and quadratic)
        f0_val  = -log(abs(det(Q))) + tau * sum(sum(hinge(Q*Y))) ;
        f0_quad = (q-q0)' * g + 1/2 * (q-q0)' * H * (q-q0) + tau * sum(sum(hinge(Q*Y))) ;
        for i = 2 : AL_iters
            %-------------------------------------------
            % solve quadratic problem with constraints
            %-------------------------------------------
            dq_aux = Z + Bk                           ; % matrix form
            dtz_b  = dq_aux * Y'                      ;
            dtz_b  = dtz_b(:)                         ;
            b      = baux + mu * dtz_b                ; % (11) of [1]
            q      = G * b + qm_aux                   ; % (10) of [1]
            Q      = reshape(q,modelOrder,modelOrder) ;
            
            %-------------------------------------------
            % solve hinge
            %-------------------------------------------
            Z      = soft_neg( Q * Y - Bk , tau / mu ) ;
            
                 %norm(B*q-qm)
           
            %-------------------------------------------
            % update Bk
            %-------------------------------------------
            Bk     = Bk - ( Q * Y - Z )                ;
            if verbose == 3 ||  verbose == 4
                fprintf('\n ||Q*Y-Z|| = %4f \n',norm(Q*Y-Z,'fro'))
            end
            if verbose == 2 || verbose == 4
                M = inv(Q) ;
                plot( M(1,:) , M(2,:) , '.r' ) ;
                if ~flaged
                     p_H(3)          = plot( M(1,:) , M(2,:) , '.r' ) ;
                     leg_cell{end+1} = 'M(k)'                         ;
                     flaged          = 1                              ;
                end
            end
        end
        f_quad = (q-q0)' * g + 1/2 * (q-q0)' * H * (q-q0) + tau * sum(sum(hinge(Q*Y))) ;
        if verbose == 3 ||  verbose == 4
            fprintf('\n MMiter = %d, AL_iter, = % d,  f0 = %2.4f, f_quad = %2.4f,  \n',...
                k,i, f0_quad,f_quad)
        end
        f_val = -log(abs(det(Q))) + tau * sum(sum(hinge(Q*Y))) ;
        %fprintf( '\tQuadratic Energy E0 : E = %f : %f\n' , f0_quad , f_quad ) ;
        %fprintf( '\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b' ) ;
        %fprintf( '%8f : %8f' , f0_quad , f_quad ) ;
        if f0_quad >= f_quad    %quadratic energy decreased
            while( f0_val < f_val )
                if( verbose == 3 ||  verbose == 4 )
                    fprintf('\n line search, MMiter = %d, AL_iter, = % d,  f0 = %2.4f, f_val = %2.4f,  \n',...
                        k,i, f0_val,f_val)
                end
                % do line search
                Q = (Q+Q0) / 2 ;
                f_val = -log(abs(det(Q))) + tau * sum(sum(hinge(Q*Y))) ;
            end
            break
        end
    end    

end

if verbose == 2 || verbose == 4
    p_H(4) = plot(M(1,:), M(2,:),'*g') ;
    leg_cell{end+1} = 'M(final)' ;
    legend(p_H', leg_cell) ;
end


if strcmp(spherize,'yes')
    M = inv(Q);
    % refer to the initial affine set
    M = M * sqrt(modelOrder)              ; % unscale
    M = M( 1 : modelOrder-1 , : )         ; %remove offset
    M = Up(:,1:modelOrder-1) * IC * M     ; % unspherize
    M = M + repmat( my , 1 , modelOrder ) ; % sum ym
else
    M = Up * inv(Q) ;
end

end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

function [Ae, indice, Rp] = DSP_VCA(R,varargin)

% Vertex Component Analysis
%
% [Ae, indice, Rp ]= vca(R,'Endmembers',p,'SNR',r,'verbose',v)
%
% ------- Input variables -------------
%  R - matrix with dimensions L(channels) x N(pixels)
%      each pixel is a linear mixture of p endmembers
%      signatures R = M x s, where s = gamma x alfa
%      gamma is a illumination perturbation factor and
%      alfa are the abundance fractions of each endmember.
%      for a given R, we need to decide the M and s
% 'Endmembers'
%          p - positive integer number of endmembers in the scene
%
% ------- Output variables -----------
% A - estimated mixing matrix (endmembers signatures)
% indice - pixels that were chosen to be the most pure
% Rp - Data matrix R projected.   
%
% ------- Optional parameters---------
% 'SNR'
%          r - (double) signal to noise ratio (dB)
% 'verbose'
%          v - [{'on'} | 'off']
% ------------------------------------
%
% Authors: Jos?Nascimento (zen@isel.pt) 
%          Jos?Bioucas Dias (bioucas@lx.it.pt) 
% Copyright (c)
% version: 2.1 (7-May-2004)
%
% For any comment contact the authors
%
% more details on:
% Jos?M. P. Nascimento and Jos?M. B. Dias 
% "Vertex Component Analysis: A Fast Algorithm to Unmix Hyperspectral Data"
% submited to IEEE Trans. Geosci. Remote Sensing, vol. .., no. .., pp. .-., 2004
% 
% 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

         verbose = 'on'; % default
         snr_input = 0;  % default this flag is zero,
                         % which means we estimate the SNR
         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Looking for input parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

         dim_in_par = length(varargin);
         if (nargin - dim_in_par)~=1
            error('Wrong parameters');
         elseif rem(dim_in_par,2) == 1
            error('Optional parameters should always go by pairs');
         else
            for i = 1 : 2 : (dim_in_par-1)
                switch lower(varargin{i})
                  case 'verbose'
                       verbose = varargin{i+1};
                  case 'endmembers'     
                       p = varargin{i+1};
                  case 'snr'     
                       SNR = varargin{i+1};
                       snr_input = 1;       % flag meaning that user gives SNR 
                  otherwise
                       fprintf(1,'Unrecognized parameter:%s\n', varargin{i});
                end %switch
            end %for
         end %if

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initializations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         
         if isempty(R)
            error('there is no data');
         else
            [L N]=size(R);  % L number of bands (channels)
                            % N number of pixels (LxC) 
         end                   
               
         if (p<0 | p>L | rem(p,1)~=0),  
            error('ENDMEMBER parameter must be integer between 1 and L');
         end
        
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SNR Estimates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

         if snr_input==0,
            r_m = mean(R,2);      
            R_m = repmat(r_m,[1 N]); % mean of each band
            R_o = R - R_m;           % data with zero-mean 
            [Ud,Sd,Vd] = svds(R_o*R_o'/N,p);  % computes the p-projection matrix 
            x_p =  Ud' * R_o;                 % project the zero-mean data onto p-subspace
            
            SNR = estimate_snr(R,r_m,x_p);
            
            if strcmp (verbose, 'on'), fprintf(1,'SNR estimated = %g[dB]\n',SNR); end
         else   
            if strcmp (verbose, 'on'), fprintf(1,'input    SNR = %g[dB]\t',SNR); end
         end

         SNR_th = 15 + 10*log10(p);
         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Choosing Projective Projection or 
%          projection to p-1 subspace
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

         if SNR < SNR_th,   
                if strcmp (verbose, 'on'), fprintf(1,'... Select the projective proj.\n',SNR); end
                
                d = p-1;
                if snr_input==0, % it means that the projection is already computed
                     Ud= Ud(:,1:d);    
                else
                     r_m = mean(R,2);      
                     R_m = repmat(r_m,[1 N]); % mean of each band
                     R_o = R - R_m;           % data with zero-mean 
         
                     [Ud,Sd,Vd] = svds(R_o*R_o'/N,d);  % computes the p-projection matrix 

                     x_p =  Ud' * R_o;                 % project thezeros mean data onto p-subspace

                end
                
                Rp =  Ud * x_p(1:d,:) + repmat(r_m,[1 N]);      % again in dimension L
                
                x = x_p(1:d,:);             %  x_p =  Ud' * R_o; is on a p-dim subspace
                c = max(sum(x.^2,1))^0.5;
                y = [x ; c*ones(1,N)] ;
         else
                if strcmp (verbose, 'on'), fprintf(1,'... Select proj. to p-1\n',SNR); end
             
                d = p;
                [Ud,Sd,Vd] = svds(R*R'/N,d);         % computes the p-projection matrix 
                
                x_p = Ud'*R;
                Rp =  Ud * x_p(1:d,:);      % again in dimension L (note that x_p has no null mean)
                
                x =  Ud' * R;
                u = mean(x,2);        %equivalent to  u = Ud' * r_m
                y =  x./ repmat( sum( x .* repmat(u,[1 N]) ) ,[d 1]);

          end
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VCA algorithm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

indice = zeros(1,p);
A = zeros(p,p);
A(p,1) = 1;

for i=1:p
      w = rand(p,1);   
      f = w - A*pinv(A)*w;
      f = f / sqrt(sum(f.^2));
      
      v = f'*y;
      [v_max indice(i)] = max(abs(v));
      A(:,i) = y(:,indice(i));        % same as x(:,indice(i))
end
Ae = Rp(:,indice);

return;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of the vca function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Internal functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function snr_est = estimate_snr(R,r_m,x)

         [L N]=size(R);           % L number of bands (channels)
                                  % N number of pixels (Lines x Columns) 
         [p N]=size(x);           % p number of endmembers (reduced dimension)

         P_y = sum(R(:).^2)/N;
         P_x = sum(x(:).^2)/N + r_m'*r_m;
         snr_est = 10*log10( (P_x - p/L*P_y)/(P_y- P_x) );
return;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function z = hinge(y)
%  z = hinge(y)
%
%   hinge function)

z = max(-y,0);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function z = soft_neg(y,tau)
%  z = soft_neg(y,tau);
%
%  negative soft (proximal operator of the hinge function)

z = max(abs(y+tau/2) - tau/2, 0);
z = z./(z+tau/2) .* (y+tau/2);
end