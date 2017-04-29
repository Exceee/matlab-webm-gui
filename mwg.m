function mwg
% mwg

FFMPEG_PATH = 'D:\Soft\ffmpeg\bin\ffmpeg.exe';
PLAYER_PATH = 'D:\Soft\MPC-HC\mpc-hc.exe';
CURRENT_PATH = cd;

% Create and then hide the GUI as it is being constructed
f = figure('Visible', 'off', 'Position', [360, 505, 450, 315], 'MenuBar', ...
    'None', 'Name', 'ffmpeg webm helper', 'NumberTitle', 'off');

% Some variables for gui
InputFileName = 'Not selected';
OutputFileName = 'Not selected';
InputFilePath = '';
OutputFilePath = '';
SubtitlesOn = true;
SaveBatOn = true;
OpenFileOn = true;
SameLengthOn = true;

% Construct gui components
hSelectInputFile = uicontrol('Style','pushbutton',...
    'String','Select Input File',...
    'Position',[20,285,100,25], 'Callback',@SelectInputFile_Callback);
hTextInputFile = uicontrol('Style','text','String',InputFileName,...
    'Position',[120,280,300,25]);
hSelectOutputFile = uicontrol('Style','pushbutton',...
    'String','Select Output File',...
    'Position',[20,255,100,25], 'Callback',@SelectOutputFile_Callback);
hTextOutputFile = uicontrol('Style','text','String',OutputFileName,...
    'Position',[120,250,300,25]);
hTextStartTime = uicontrol('Style','text','String','Start Time:',...
    'Position',[20,225,60,15]);
hStartTime = uicontrol('Style','edit','String','',...
    'Position',[100,225,60,15]);
hTextEndTime = uicontrol('Style','text','String','End Time:',...
    'Position',[180,225,60,15]);
hEndTime = uicontrol('Style','edit','String','',...
    'Position',[260,225,60,15]);
hTextCRF = uicontrol('Style','text','String','CRF:',...
    'Position',[20,195,60,15]);
hCRF = uicontrol('Style','edit','String','',...
    'Position',[100,195,60,15]);
hTextBitrate = uicontrol('Style','text','String','Bitrate:',...
    'Position',[180,195,60,15]);
hBitrate = uicontrol('Style','edit','String','0',...
    'Position',[260,195,60,15]);
hTextHeight = uicontrol('Style','text','String','Height:',...
    'Position',[20,165,60,15]);
hHeight = uicontrol('Style','edit','String','540',...
    'Position',[100,165,60,15]);
hTextAudioQuality = uicontrol('Style','text','String','Audio:',...
    'Position',[180,165,60,15]);
hAudioQuality = uicontrol('Style','edit','String','5',...
    'Position',[260,165,60,15]);
hTextMetadata = uicontrol('Style','text','String','Metadata:',...
    'Position',[20,135,60,15]);
hMetadata = uicontrol('Style','edit','String','',...
    'Position',[100,135,220,15]);
hSubtitles = uicontrol('Style','checkbox','String','Subtitles',...
    'Position',[20,100,100,30],'Callback',@Subtitles_Callback);
hSaveBat = uicontrol('Style','checkbox',...
    'String','Save *.bat',...
    'Position',[20,70,100,30], 'Callback',@SaveBat_Callback);
hOpenFile = uicontrol('Style','checkbox',...
    'String','Open file',...
    'Position',[20,40,100,30], 'Callback',@OpenFile_Callback);
hConvert = uicontrol('Style','pushbutton',...
    'String','GO',...
    'Position',[20,10,70,25], 'Callback',@Convert_Callback);

align([hTextInputFile, hTextOutputFile],'Left', 'None');

f.Visible = 'on';

    function SelectInputFile_Callback(source, eventdata)
        [InputFileName, InputFilePath] = uigetfile('*.*');
        if InputFileName ~= 0
            hTextInputFile = uicontrol('Style', 'text', 'String', InputFileName,...
                'Position', [120,280,300,25], 'Callback', @SelectInputFile_Callback);
        end
    end

    function SelectOutputFile_Callback(source, eventdata)
        [OutputFileName,OutputFilePath] = uiputfile('*.webm');
        if OutputFileName ~= 0
            hTextOutputFile = uicontrol('Style', 'text', 'String', OutputFileName,...
                'Position', [120,250,300,25]);
        end
    end

    function Subtitles_Callback(hSubtitles, eventdata, handles)
        if (get(hSubtitles,'Value') == get(hSubtitles,'Max'))
            SubtitlesOn = true;
        else
            SubtitlesOn = false;
        end
    end

    function SaveBat_Callback(hSaveBat, eventdata, handles)
        if (get(hSaveBat, 'Value') == get(hSaveBat, 'Max'))
            SaveBatOn = true;
        else
            SaveBatOn = false;
        end
    end

    function OpenFile_Callback(hOpenFile, eventdata, handles)
        if (get(hOpenFile, 'Value') == get(hOpenFile, 'Max'))
            OpenFileOn = true;
        else
            OpenFileOn = false;
        end
    end

    function Convert_Callback(source, eventdata)
        if strcmp(InputFileName,'Not selected')
            hError = msgbox ('Input file was not selected','Error');
            return;
        end
        if strcmp(OutputFileName, 'Not selected')
            hError = msgbox ('Output file was not selected','Error');
            return;
        end
        if strcmp(hCRF.String, '')
            hError = msgbox ('Enter CRF','Error');
            return;
        end
        if strcmp(hBitrate.String, '')
            hError = msgbox ('Enter Bitrate','Error');
            return;
        end

        cd (InputFilePath);

        if strcmp(hStartTime.String,'') && strcmp(hEndTime.String,'')
            startTimeParameter = '';
            startTime = '';
            durationParameter = '';
            duration = '';
        else
            startTimeParameter = '-ss';
            durationParameter = '-t';
            startTime = hStartTime.String;

            t1 = startTime;
            if isempty(strfind(startTime,':')) == 0
                t1 = strsplit(t1, ':');
                t1m = str2double(t1(1));
                t1s = str2double(t1(2));
                t1 = t1m * 60 + t1s;
            else
                t1 = str2double(t1);
            end

            temp = hEndTime.String;

            if isempty(strfind(temp,':')) == 0
                t2 = strsplit(temp, ':');
                t2m = str2double(t2(1));
                t2s = str2double(t2(2));
                t2 = t2m * 60 + t2s;
            else
                t2 = str2double(temp);
            end
            dt = t2 - t1;
            duration = num2str(dt);
        end

        InputFileFullPath = ['"', InputFilePath, InputFileName, '"'];
        OutputFileFullPath = ['"', OutputFilePath, OutputFileName, '"'];

        if SubtitlesOn
            C1 = {(['"' FFMPEG_PATH '"']), startTimeParameter, startTime, '-i', ...
                InputFileFullPath, durationParameter, duration, '-map', '0:v:0', ...
                '-map', '0:a:0',  '-c:v libvpx-vp9 -pix_fmt yuv420p',...
                (['-metadata title="', ([hMetadata.String '"'])]), '-vf', ...
                (['scale=-1:' hHeight.String]), '-crf', hCRF.String, '-b:v', ...
                hBitrate.String, '-threads', '4', '-slices', '1', '-ac', '2', ...
                '-c:a', 'libvorbis', '-q:a', hAudioQuality.String, '-pass', '1',...
                '-f', 'null', '-y', 'NUL'};
            C2 = {(['"' FFMPEG_PATH '"']), startTimeParameter, startTime, '-i', ...
                InputFileFullPath, durationParameter, duration, '-map', '0:v:0', ...
                '-map', '0:a:0',  '-c:v libvpx-vp9 -pix_fmt yuv420p', ...
                (['-metadata title="', ([hMetadata.String '"'])]), '-vf', ...
                (['scale=-1:' hHeight.String]), '-crf', hCRF.String, '-b:v', ...
                hBitrate.String, '-threads', '4', '-slices', '1', '-ac', '2', ...
                '-c:a', 'libvorbis', '-q:a', hAudioQuality.String, '-pass', '2',...
                '-f', 'webm', '-y', OutputFileFullPath};
        else
            C1 = {(['"' FFMPEG_PATH '"']), '-i', InputFileFullPath, ...
                startTimeParameter, startTime, durationParameter, duration, ...
                '-map', '0:v:0', '-map', '0:a:0', ...
                '-c:v libvpx-vp9 -pix_fmt yuv420p', (['-metadata title="', ...
                ([hMetadata.String '"'])]), '-vf',...
                (['"scale=-1:' hHeight.String ',subtitles=''' InputFileName '''"']), ...
                '-crf', hCRF.String, '-b:v', hBitrate.String, ...
                '-threads', '4', '-slices', '1', '-ac', '2', '-c:a', 'libvorbis', ...
                '-q:a', hAudioQuality.String, '-pass', '1', '-f', 'null', '-y', 'NUL'};
            C2 = {(['"' FFMPEG_PATH '"']), '-i', InputFileFullPath, startTimeParameter, ...
                startTime, durationParameter, duration, '-map', '0:v:0', '-map', '0:a:0', ...
                '-c:v libvpx-vp9 -pix_fmt yuv420p', (['-metadata title="', ...
                ([hMetadata.String '"'])]), '-vf', ...
                (['"scale=-1:' hHeight.String ',subtitles=''' InputFileName '''"']), ...
                '-crf', hCRF.String, '-b:v', hBitrate.String, '-threads', '4', ...
                '-slices', '1', '-ac', '2', '-c:a', 'libvorbis', '-q:a', ...
                hAudioQuality.String, '-pass', '2', '-f', 'webm', '-y', OutputFileFullPath};
        end

        args1 = strjoin(C1);
        args2 = strjoin(C2);

        if SaveBatOn
            args1_bat = regexprep(args1,'\','\\\');
            args2_bat = regexprep(args2,'\','\\\');
            PLAYER_PATH_bat = regexprep(PLAYER_PATH,'\','\\\');
            OutputFileFullPath_bat = regexprep(OutputFileFullPath,'\','\\\');
            OutputBatFullPath = ([OutputFilePath, OutputFileName, '.bat']);
            fid = fopen(OutputBatFullPath, 'w');
            fprintf (fid, args1_bat);
            fprintf (fid, '\n\n');
            fprintf (fid, args2_bat);
            fprintf (fid, '\n\n');
            fprintf (fid, 'DEL ffmpeg2pass-0.log');
            fprintf (fid, '\n\npause');
            if OpenFileOn
                fprintf (fid, (['\n\n"' PLAYER_PATH_bat '" ']));
                fprintf (fid, OutputFileFullPath_bat);
            end
            fclose (fid);
        end

        % Calculating convert time
        time1 = clock;
        dos(args1);
        dos(args2);
        time3 = clock;
        dtime = etime(time3,time1);
        disp(['Convert time = ' num2str(dtime) ' s']);

        % Delete temporary file from 1st pass
        delete([cd '\ffmpeg2pass-0.log']);

        if OpenFileOn
            dos(['"' PLAYER_PATH '"' ' ' OutputFileFullPath]);
        end
        cd (CURRENT_PATH);
    end
end
