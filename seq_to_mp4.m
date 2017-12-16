% SEQ_TO_MP4(FLOCATION,ITYPE) converts either a single seq or a directory to mp4
% This is a heavily modified version of Read_Seq_File.m by Sk Sahariyaz Zaman 

function seq_to_mp4(fLocation, iType, cores)
  switch iType
  case 'dir'
    %Running on directory
    convertList = dir([fLocation filesep '*.mp4']);
    numSEQ = length(convertList);
    %Run in single or parallel depending on cores
    if cores == 1
      for i =1:numSEQ
        read_the_seq([fLocation filesep convertList(i).name])
      end
    else
      delete(gcp('nocreate')); %turns off all other parallel pool processes
      pool = parpool(cores);
      parfor i =1:numSEQ
        read_the_seq([fLocation filesep convertList(i).name])
      end
    end

  case 'single'
    %Single file, running on file
    read_the_seq(fLocation)
  end
end

function read_the_seq(seqFullPath)
  %Extract out the seq's name and path 
  [seqPath,seqFile,~] = fileparts(seqFullPath);
  outputMP4 = [seqPath filesep seqFile '.mp4'];

  %Call MATLAB's videoWriter function, tell it to write to mp4
  mp4Writer = VideoWriter(outputMP4, 'MPEG-4');
  mp4Writer.Quality = 100; %Quality could perhaps be higher? More experimentation needed

  open(mp4Writer);
  frameWindow = 1; %Amount of frames to move by, should be 1 unless you want 
  %to intentionally skip frames

  % Changed from the original Zaman code to just read from 0:Inf, since
  % that's all our lab actually needs
  firstFrame=0;
  lastFrame=inf;

  %Calls seqIo to read the SEQ file. seqIo, and its dependencies,
  %seqReaderPlugin and seqWriterPlugin, are sourced from Piotr's toolbox,
  %found at https://github.com/pdollar/toolbox/tree/master/videos
  seqID = seqIo( input_seq_file, 'reader' );
  info=seqID.getinfo();
  lastFrame=min(lastFrame,info.numFrames-1);
  allFrames=firstFrame:frameWindow:lastFrame;


  for currentFrame=allFrames
    seqID.seek(currentFrame);
    [idx, ~] =seqID.getframe();
    shiftedIdx = idx(16:end,:);
    shiftedIdx = circshift(shiftedIdx, 272,2);

    writeVideo(mp4Writer, shiftedIdx);
  end

  seqID.close();
  close(mp4Writer);

end
