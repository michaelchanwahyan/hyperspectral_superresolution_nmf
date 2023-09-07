function [ ARGOUT ] = DSP_LOG( actionString , arg1 , arg2 , arg3 , arg4 , arg5 , arg6 )
ARGOUT = 0 ;
oriDirectory = cd ;
if( strcmp( actionString , 'log fig and img' ) == 1 )
    % arg1 = filePointer ;
    % arg2 = folderName ; 
    % arg3 = objectName ;
    % arg4 = objectExtension;
        % ============================================
        % check arg4 for fig , or png , or fig and png
        % ============================================
    if( ~exist( arg2 , 'dir' ) )
        mkdir( arg2 )
    end
    cd(arg2) ;
        if ( strcmp(arg4,'fig and png') )
            saveas( arg1 , [ arg3 , '.fig' ] , 'fig' );
            saveas( arg1 , [ arg3 , '.png' ] , 'png' );
        elseif( strcmp(arg4,'fig') )
            saveas( arg1 , [ arg3 , '.' , arg4 ] , arg4 );
        elseif( strcmp(arg4,'png') )
            saveas( arg1 , [ arg3 , '.' , arg4 ] , arg4 );
        elseif( strcmp(arg4,'eps') )
            saveas( arg1 , [ arg3 , '.' , arg4 ] , 'epsc2' );
        else % else means it is to log both fig and bmp
            saveas( arg1 , [ arg3 , '.' , arg4 ] , arg4 );
        end
    if( ~strcmp( arg2 , '.' ) )
        cd(oriDirectory);
    end
end
if( strcmp( actionString , 'log matrix to txt' ) )
    %dlmwrite(filename, M)
    %dlmwrite(filename, M, 'D')
    %dlmwrite(filename, M, 'D', R, C)
    % arg1 = folderName
    % arg2 = txtFileName
    % arg3 = matrix
    % arg4 = delims
    % arg5 = start from which row | first row is notated by 0
    % arg6 = start from which column | first column is notated by 0
    if( ~exist( arg1 , 'dir' ) )
        mkdir( arg1 )
    end
    cd(arg1);
            dlmwrite( arg2 , arg3 , arg4 );
    if( ~strcmp( arg1 , '.' ) )
        cd(oriDirectory);
    end
end
if( strcmp( actionString , 'log plot' ) )
	% arg1 = filePointer
	% arg2 = folderName
	% arg3 = objectName
	% arg4 = objectExtension
            % ============================================
            % check arg4 for fig , or png , or fig and png
            % ============================================
            if ( strcmp( arg4 , 'fig and png' ) )
                logBothFlag = 1;
            else
                logBothFlag = 0;
            end
	if( ~exist( arg2 , 'dir' ) )
        mkdir( arg2 )
    end
	cd(arg2);
            if ( logBothFlag == 0 )
                saveas( arg1 , arg3 , arg4 );
            else % else means it is to log both fig and bmp
                saveas( arg1 , arg3 , 'fig' );
                saveas( arg1 , arg3 , 'png' );
            end
	if( ~strcmp( arg2 , '.' ) )
        cd(oriDirectory);
    end
end
if( strcmp( actionString , 'log statement' ) == 1 )
    % arg1 = log_statementStr
	% arg2 = log_fileDirectory // absolute path is prefered
	% arg3 = log_fileNameStr
    if( ~exist( arg2 , 'dir' ) )
        error(['Error : @ DSP_LOG() : path: ',arg2,' does not exist !!!']);
    else
        oriDir = cd ;
        cd( arg2 )
			currTime = clock ;
			logTimeSerial = [ num2str(currTime(1)) , '-' ] ;
			if( currTime(2) < 10 )        ; logTimeSerial = [ logTimeSerial , '0' ] ; end
			logTimeSerial = [ logTimeSerial , num2str(currTime(2)) , '-' ] ;
			if( currTime(3) < 10 )        ; logTimeSerial = [ logTimeSerial , '0' ] ; end
			logTimeSerial = [ logTimeSerial , num2str(currTime(3)) , ' ' ] ;
			if( currTime(4) < 10 )        ; logTimeSerial = [ logTimeSerial , '0' ] ; end
			logTimeSerial = [ logTimeSerial , num2str(currTime(4)) , ':' ] ;
			if( currTime(5) < 10 )        ; logTimeSerial = [ logTimeSerial , '0' ] ; end
			logTimeSerial = [ logTimeSerial , num2str(currTime(5)) , ':' ] ;
			if( floor(currTime(6)) < 10 ) ; logTimeSerial = [ logTimeSerial , '0' ] ; end
			logTimeSerial = [ logTimeSerial , num2str(floor(currTime(6))) ] ;
            system(['echo ','[ ',logTimeSerial,' ]',arg1,' >> ',arg3]);
        cd(oriDir)
    end
end
if( strcmp( actionString , 'gen log file dir and name' ) == 1 )
    % ~-=~-=~-=~-=~- %
    % init diary log %
    % ~-=~-=~-=~-=~- %
        diary_LogDir = '~/Temp/MATLABLOG/' ;
        currTime = clock ;
        matlabLogFileSerial = num2str(currTime(1)) ;
        if( currTime(2) < 10 )
            matlabLogFileSerial = [ matlabLogFileSerial , '0' ] ;
        end
        matlabLogFileSerial = [ matlabLogFileSerial , num2str(currTime(2)) ] ;
        if( currTime(3) < 10 )
            matlabLogFileSerial = [ matlabLogFileSerial , '0' ] ;
        end
        matlabLogFileSerial = [ matlabLogFileSerial , num2str(currTime(3)) ] ;
        if( currTime(4) < 10 )
            matlabLogFileSerial = [ matlabLogFileSerial , '0' ] ;
        end
        matlabLogFileSerial = [ matlabLogFileSerial , num2str(currTime(4)) ] ;
        if( currTime(5) < 10 )
            matlabLogFileSerial = [ matlabLogFileSerial , '0' ] ;
        end
        matlabLogFileSerial = [ matlabLogFileSerial , num2str(currTime(5)) ] ;
        if( floor(currTime(6)) < 10 )
            matlabLogFileSerial = [ matlabLogFileSerial , '0' ] ;
        end
        matlabLogFileSerial = [ matlabLogFileSerial , num2str(floor(currTime(6))) ] ;
        diary_LogFileName   = [ 'matlab_',matlabLogFileSerial,'.log'] ; 
        ARGOUT              = cell( 2 , 1 ) ;
        ARGOUT{ 1 }         = diary_LogDir ;
        ARGOUT{ 2 }         = diary_LogFileName ;
end