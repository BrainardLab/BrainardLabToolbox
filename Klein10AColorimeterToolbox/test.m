function test

    luminanceRange = 'Automatic';
    luminanceRange = 'LockedInRange_1';
    
    streamingTime = [0:1:256*10-1]/256;
    streamingTimeLowRes = streamingTime(1:32:end);
    streamingLuminance = 20000 + 15000*sin(streamingTime*0.5*2.0*pi);
    correctedXdata8HzStream = 10 + 8*sin(streamingTimeLowRes*0.5*2.0*pi);
    correctedYdata8HzStream = 10 - 8*sin(streamingTimeLowRes*0.5*2.0*pi);
    correctedZdata8HzStream = 10 - 0*sin(streamingTimeLowRes*0.5*2.0*pi);
    filename ='/Users/nicolas/Desktop/test.txt';
    FID = fopen(filename, 'w'); 
    fprintf(FID,'%20s\r\n', datestr(clock));
    fprintf(FID,'%20s\r\n', luminanceRange);
    fprintf(FID,'%d\r\n', length(streamingLuminance));
    fprintf(FID,'%6s  %12s\r\n','Time(s)','YLum (D/A)');
    fprintf(FID,'%6.5f %10.0f\r\n',[streamingTime;streamingLuminance]);
    fprintf(FID,'%d\r\n', length(correctedXdata8HzStream));
    fprintf(FID,'%6s  %6s   %6s   %6s\r\n','Time(s)', 'X','Y', 'Z');
    fprintf(FID,'%06.5f   %06.5f  %06.5f  %06.5f\r\n', [streamingTimeLowRes; correctedXdata8HzStream; correctedYdata8HzStream; correctedZdata8HzStream]);  
    fclose(FID);
    fprintf('test data exported to file %s\n', filename);
end