% TRACKING_QUE_WITH_STATS- queues up different directories for tracking assignments
% The spiritual sucessor to whiskerQueue

% =========================================================================
% ADJUSTABLE SETTINGS
% =========================================================================
% TRACKING PARAMETERS -----------------------------------------------------
NUMBER_OF_WHISKERS = 1;
PIXEL_DENSITY = 0.033;
FACE_LOCATION = 'top';
DISPLAY_STATISTICS = true;
CONVERT_ALL_VIDEOS = true;
NUMBER_OF_RESERVED_CORES = 2;
USE_ERROR_CHECK = false;

% DIRECTORY LIST ----------------------------------------------------------
%Directory to find files to convert or track >>>
startDirList = {...
'Z:\Users\Jonathan_Sy\testSeq';...
};
%Directory to send tracked files >>>
endDirList = {...
'Z:\Users\Jonathan_Sy\testSeq';...

};
% VIDEO CONVERSION LIST ---------------------------------------------------
%If you want to selective convert, fill this out in same order as directories:
%Make sure to set CONVERT_ALL_VIDEOS to false to use this function >>>
convertVid = [...
false;...
false;...
];

% =========================================================================
% Queue settings should only be changed above this line
% =========================================================================


%TRACKING STARTS HERE!
allFileClock = tic;
sumFiles = 0;
sumTrackTime = 0;
sumConversionTime = 0;
sumCopyTime = 0;
for i = 1:length(startDirList)
  if CONVERT_ALL_VIDEOS == true
    [copyTime, trackTime, convertTime, totalFiles] = start_whisker_tracking(...
    startDirList{i}, endDirList{i}, 1, PIXEL_DENSITY, NUMBER_OF_WHISKERS, ...
    FACE_LOCATION, NUMBER_OF_RESERVED_CORES, USE_ERROR_CHECK);
  else
    [copyTime, trackTime, convertTime, totalFiles] = start_whisker_tracking(...
    startDirList{i}, endDirList{i}, convertVid(i), PIXEL_DENSITY, NUMBER_OF_WHISKERS, ...
    FACE_LOCATION, NUMBER_OF_RESERVED_CORES, USE_ERROR_CHECK);
  end
  sumFiles = sumFiles + totalFiles;
  sumTrackTime = sumTrackTime + trackTime;
  sumConversionTime = sumConversionTime + convertTime;
  sumCopyTime = sumCopyTime + copyTime;
end

% =========================================================================
% TRACKING STATISTICS
% =========================================================================
if DISPLAY_STATISTICS == true
  allFileTime = toc(allFileClock);
  totalHours = floor(allFileTime/3600);
  extraMinutes = floor(rem(allFileTime,3600)/60);
  extraSeconds = rem(rem(allFileTime,3600),60);
  %Some more math
  convPct = 100*(sumConversionTime/allFileTime);
  trackPct = 100*(sumTrackTime/allFileTime);
  timePerFile = allFileTime/sumFiles;
  %Display stats
  fprintf('Tracking statistics: \n')
  fprintf('Total time: %.00f hours %.00f minutes %.02f seconds \n', ...
  totalHours, extraMinutes, extraSeconds)
  fprintf('Of this time: \n')
  fprintf('Video conversion took %.02f seconds or %.02f percent of the total time \n', sumConversionTime, convPct)
  fprintf('Whisker tracking took %.02f seconds or %.02f percent of the total time \n', sumTrackTime, trackPct)
  fprintf('You tracked a total of %.00f files with an average time of %.02f seconds per file \n', sumFiles, timePerFile)
  fprintf('Aaaaaaaaaaaaand we''re done! \n')

end
