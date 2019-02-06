function timeFormatted = format_time( str )
    % FORMAT_TIME converts string containing timestamp into date and time
    %
    % Parameters:
    %     str = string containing timestamp
    %
    % Return Values:
    %     format_time = date time 
    try
        timeFormatted = datetime(str,'InputFormat','uuuu-MM-dd''T''HH:mm:ss.SSSZ','TimeZone','America/Toronto');
    catch
        timeFormatted = str/86400000 + datetime(1970,1,1,'TimeZone','America/Toronto') - hours(5);
    end
end
