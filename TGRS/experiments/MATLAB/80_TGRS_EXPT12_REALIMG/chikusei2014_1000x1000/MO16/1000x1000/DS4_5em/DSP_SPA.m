function ENDMEM = DSP_SPA( HYPERSPEC , modelOrder )

Y       = HYPERSPEC ;
Y_sizeM = size(Y,1) ;
PROJ    = eye( Y_sizeM ) ;
ENDMEM = zeros( Y_sizeM , modelOrder ) ;
for k = 1 : modelOrder 
    Y           = PROJ * Y ;
    normArray   = sum( Y.^2 ) ;
    [ ~ , idx ] = max( normArray ) ;
    ENDMEM(:,k) = HYPERSPEC( : , idx ) ;
    Pe          = PROJ * ENDMEM(:,k) ;
    PROJ        = ( eye( Y_sizeM ) - Pe * Pe' / ( Pe'*Pe ) ) * PROJ ;
end ; clear k

