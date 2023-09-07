function [ yn , n ] = DSP_AWGN( y , SNR_dB )

[ y_sizeM , y_sizeN ] = size( y ) ;

% =================== %
% detect signal power %
% =================== %

if( min( y_sizeM , y_sizeN ) == 1 )
    y_is_matrix = false ;
    yPower = norm( y , 2 )^2 / numel(y) ;
else
    y_is_matrix = true ;
    y      = y(:)    ;
    yPower = y' * y  / numel(y) ;
end


y_normalize    = y / yPower ;
yn_normalize   = awgn( y_normalize , SNR_dB ) ;
yn             = yn_normalize * yPower ;
n              = yn - y ;
SNR_dB_curr    = 10 * log10( norm( y , 2 )^2 / norm( n , 2 )^2 ) ;
%SNR_dB_curr    = 10 * log10( norm( y , 2 )^2 / ( y_sizeM * y_sizeN * norm( n , 2 )^2 ) ) ; % FUMI's SNR definition
SNR_dB_diff    = SNR_dB_curr - SNR_dB ;

if( abs( SNR_dB_diff ) > 0.00001 )
    noiseScale = sqrt( 10 ^ ( 0.1 * SNR_dB_diff ) ) ;
    n          = noiseScale * n ;
    yn         = y + n ;
end

if( y_is_matrix )
    yn         = reshape( yn , [ y_sizeM , y_sizeN ] ) ;
    n          = reshape( n  , [ y_sizeM , y_sizeN ] ) ;
end

end
