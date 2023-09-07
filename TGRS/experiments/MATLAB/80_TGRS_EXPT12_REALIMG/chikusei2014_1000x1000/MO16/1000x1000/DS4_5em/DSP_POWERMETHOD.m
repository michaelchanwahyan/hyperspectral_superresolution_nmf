function maxEig = DSP_POWERMETHOD( M , iteraNum )
n = size(M,1) ; x = rand(n,1) - 0.5 ; x = x ./ abs(x) ;
fprintf( 'iteration : %d \\     ' , iteraNum ) ;
for k = 1 : iteraNum ; fprintf( '\b\b\b\b%4i' , k ) ; x = M * x ; end
fprintf( '\n' ) ;
maxEig = ( x' * M * x ) / ( x' * x ) ;
end