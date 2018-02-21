function [copyTime, trackTime, convertTime, totalFiles] = start_whisker_tracking(varargin)
  % START_WHISKER_TRACKING An improved version of the mp4 converter and Janelia farm whisker tracking script
  % START_WHISKER_TRACKING(STARTDIR, ENDDIR) specifies location of current files and where to send them, defaults to working directory
  % START_WHISKER_TRACKING(STARTDIR, ENDDIR, CONVERTVIDEO) CONVERTVIDEO = 1 will convert seq -> mp4, = 0 will skip conversion
  % START_WHISKER_TRACKING(STARTDIR, ENDDIR, CONVERTVIDEO, WHISKERNUM, PIXDEN) Adjust whisker number or pixel density as appropriate
  % START_WHISKER_TRACKING(STARTDIR, ENDDIR, CONVERTVIDEO, WHISKERNUM, PIXDEN, TRANSFERVIDEO) TRANSFERVIDEO = 1 copies files to end directory, =0 will not copy

  %% CHANGE LOG -----------------------------------------------------------

  %  Change                            Date            Editor
  % -----------------------------------------------------------------
  %  Initial Script                   2014-12-13      J. Sy
  %  Variation for Jon                2017-10-06      J. Cheung
  %  Added mp4 converter selector     2017-10-13      J. Sy
  %  Function name change             2017-12-13      J. Sy
  %  Added new parameters             2017-12-15      J. Sy


  %% SECTION 1: INPUT HANDLING -------------------------------------------
  %Default Settings:
  startDir = pwd;
  endDir = pwd;
  convertVideo = 1; %mp4 converter will run
  whiskerNum = 1; %Default number of whiskers is 1
  pixDen = 0.033; %This is the default pixel density
  faceSide = 'top';
  transferVideo = true; %Default to transfering to end directory
  reservedCores = 0; %Standard is to not reserve any cores for parallel
  errorCheck = false; %Default to not performin JK error check

  if nargin == 0
    fprintf('Function called empty, setting all parameters to default')
    fprintf('Everything will be processed in the current directory')
  else
    %Handle variable argument processing in subfunction so all the code people don't care about can be at the bottom
    [startDir, endDir, convertVideo, pixDen, whiskerNum, faceSide, reservedCores, errorCheck] = varInputHandler(varargin);
  end
  %If startDir and endDir are the same, don't transfer Video
  if strcmp(startDir, endDir)
    transferVideo = false;
  end
  numCores = feature('numcores'); %identify number of cores available for MATLAB to use
  numCores = numCores - reservedCores;
  
  cd(startDir)

  %% SECTION 2: CONVERT .SEQ TO .MP4 --------------------------------------
  mp4List = dir([startDir filesep '*mp4']);
  seqList = dir([startDir filesep '*seq']);
  if convertVideo == 1
      if isempty(seqList) 
          error('There are no SEQ files in the directory: %c', startDir)
      end
      %See if all the mp4s already exist
      if length(mp4List) == length(seqList)
          Q = input(['You appear to have already converted these .seq files to .mp4s. \n' ...
              'Enter 0 to skip conversion. Enter 1 to create different mp4s. Enter 2 to overwrite old .mp4s ']);
          switch Q
              case 0
                  convertVideoReally = 0;
              case 1
                  convertVideoReally = 1;
              case 2
                  Q2 = input('Are you absolutely sure you want to delete the old mp4s and replace them? [Y/N] ');
                  if strcmpi(Q2, 'y')
                      system(['rm' startDir filesep '*.mp4']);
                  else
                      convertVideoReally = 1;
                  end
              otherwise
                  fprintf('Input statement invalid, mp4 conversion will not occur \n')
          end
      else
          convertVideoReally = 1;
      end
      %See if any .mp4s exist
      if ~isempty(mp4List)
          warning('Some MP4 files already exist in this directory, this may cause issues in conversion later')
      end
      %Run converter
      if convertVideoReally == 1
          tic
          fprintf('STARTING MP4 CONVERSION OF %s \n', startDir)
          delete(gcp('nocreate'));
          parpool(numCores);
          parfor i = 1:length(seqList)
              currentSEQ = seqList(i).name;
              norpix_seq_reader_jsy(currentSEQ);
          end
          fprintf('FINISHED MP4 CONVERSION \n')
          convertTime = toc;
      end
  else
      fprintf('Skipping video conversion in %s \n', startDir)
  end

  %% SECTION 3: TRACK MP4 FILES WITH JANELIA TRACKER ----------------------
  mp4List = dir([startDir filesep '*mp4']);
  if isempty(mp4List)
    error('There are no MP4 files to track in the directory: %s', startDir)
  end
  tic;
  fprintf('STARTING WHISKER TRACKING OF %s \n', startDir)

  if exist([startDir filesep 'default.parameters'],'file') == 2
      whisker_tracker_true_parallel(pixDen, whiskerNum, faceSide, numCores, errorCheck) % Uses 'classify' for multiple whisker tracking.
  else
      try
          system('copy C:\Users\shires\Documents\GitHub\jkWhisker\default.parameters startDir');
      catch
          try
              system('copy Z:\default.parameters startDir');
              whisker_tracker_true_parallel(pixDen, whiskerNum, faceSide, numCores, errorCheck)
          catch
              warning('No default.parameters')
              proceedQ = input(['No default.parameters file found, do you want to have '...
                  'the tracker autogenerate one that might be incorrect [Y/N]']);
              if strcmpi(proceedQ, 'y')
                  whisker_tracker_true_parallel(pixDen, whiskerNum, faceSide, numCores, errorCheck)
              else
                  error('Cannot proceed, no default.parameters file')
              end
          end
      end
  end
  disp('FINISHED TRACKING \n')
  trackTime = toc;


  nf_mp4 = length(dir('*.mp4'));
  nf_whiskers = length(dir('*.whiskers'));
  nf_measurements = length(dir('*.measurements'));
  if nf_mp4 ~= nf_whiskers || nf_mp4 ~= nf_measurements
      error('Number of files do not match')
  end
  totalFiles = nf_whiskers;

  %% SECTION 4: COPY FILES ------------------------------------------------
  copyTime = 0;
  if transferVideo == 1
    tic;
    system(['copy ', startDir, '\*.mp4 ', endDir]);
    system(['copy ', startDir, '\*.whiskers ', endDir]);
    system(['copy ', startDir, '\*.measurements ', endDir]);
    system(['copy ', startDir, '\default.parameters ', endDir]);
    system(['copy ', startDir, '\*.detectorbank ', endDir]);
    copyTime = toc;
  end

end


%% ------------------------------------------------------------------------------
%And here is a subfunction to handle the varargin stuff because most people don't want to see this
function [startDir, endDir, convertVideo, whiskerNum, pixDen, faceSide, rCores, eCheck] = varInputHandler(vInputs)
  %Defaults
  inputN = length(vInputs);
  startDir = pwd;
  endDir = pwd;
  convertVideo = 1; %mp4 converter will run
  whiskerNum = 1; %Default number of whiskers is 1
  pixDen = 0.033; %This is the default pixel density
  rCores = 0; %Standard is to not reserve any cores for parallel
  eCheck = false; %Default to not performin JK error check
  faceSide = 'top'; %Default to top side

  %PARAMETER 1: Where to find files
  if inputN >= 1 %Change start directory
    %Empty call
    if strcmpi(vInputs{1},'')
      %Change NOTHING
    else
      %Check if actually a directory
      if ischar(vInputs{1})
        startDir = vInputs{1};
      else
        error('Directory name must be string')
      end
      %Check if exist
      if exist(vInputs{1},'dir') ~= 7
        error('Cannot find input directory %c', vInputs{1})
      end
    end
  end
  %PARAMETER 2: Where to transfer files
  if inputN >= 2 %Change end directory
    %Empty call
    if strcmp(vInputs{2},'')
      %Change NOTHING
    else
      %Check if actually a directory
      if ischar(vInputs{2})
        endDir = vInputs{2};
      else
        error('Directory name must be string')
      end
      %Check if exist
      if exist(vInputs{2},'dir') ~= 7
        error('Cannot find output directory %c', vInputs{2})
      end
    end
  end
  %PARAMETER 3: Do we need to convert SEQs?
  if inputN >= 3
    if vInputs{3} == 1 || strcmpi(vInputs{3},'true')
      convertVideo = 1;
    elseif vInputs{3} == 0 || strcmpi(vInputs{3},'false')
      convertVideo = 0;
    else
      fprintf('Improper entry for video parameter, defaulting to convertVideo = TRUE')
    end
  end
  %PARAMETER 4: Number of whiskers to track
  if inputN >= 4
    if vInputs{4} == 0 || strcmp(vInputs{4},'')
      %Do nothing
    else
      whiskerNum = vInputs{4};
    end
  end
  %PARAMETER 5: Pixel density
  if inputN >= 5
    if vInputs{5} == 0 || strcmp(vInputs{5},'')
      %Do nothing
    else
      pixDen = vInputs{5};
    end
  end
  %PARAMETER 6: Where is the face in the image?
  if inputN >= 6
    if ischar(vInputs{6})
      faceSide = vInputs{6};
    else
      warning('Invalid face side input, defaulting to "top"')
    end
  end
  %PARAMETER 7: Should we save any CPU cores for non-tracking?
  if inputN >= 7
    if isnumeric(vInputs{6})
      rCores = vInputs{6};
    end
  end
  %PARAMETER 8: Whether or not to perform Jinho's error check (the check will not be parallel)
  if inputN >= 8
    switch vInputs{8}
    case 1
      eCheck = true;
    case 0
      eCheck = false;
    otherwise
      warning('Invalid error check input, defaulting to false')
    end
  end
  %EXTRA PARAMETERS
  if inputN > 8
    fprintf('You called this function with too many variables, ignoring extras')
  end
end
