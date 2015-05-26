function optimizer2_newformat(datafile, datapath)
    
%we calculate the displacement of the SRL curve
%by averaging the last 100 points of the curve, rather than
%averaging the first 100 points after the peak time hits.  This was
%created to examine the affect of compliance in the system. 

%This file was modified to remove the user-interface request to select the
%path.  Sonia Bansal  modified this program to take the diameter and
%construct thickness from the accompanying files with the SRL data.


    
clc
%close all
fclose all;
format short g

% Get filenames, pathnames via user interface dialog
%[datafile datapath] = uigetfile({'*.txt'},'Select data file','MultiSelect','off');

copyfile('TEMPLATE_opt.feb',strcat(datapath,'TEMPLATE_opt.feb'))
copyfile('TEMPLATE1_srl.feb',strcat(datapath,'TEMPLATE1_srl.feb'))
copyfile('TEMPLATE2_srl.feb',strcat(datapath,'TEMPLATE2_srl.feb'))
copyfile('EquilibTensile.feb',strcat(datapath,'EquilibTensile.feb'))

datapath
datafile


%if user cancels ui dialog don't error
if datafile==0 return
end
addpath(datapath);
disp(datafile);

% Full datafile name: filenamel(ong)
filenamel = fullfile(datapath, datafile);

% These 4 variables are read from text files within datafile directory
samplediam = importdata([filenamel(1:(size(filenamel,2)-4)),'.samplediam.txt']);
sampleheight = importdata([filenamel(1:(size(filenamel,2)-4)),'.sampleheight.txt']);
creeptime = importdata([filenamel(1:(size(filenamel,2)-4)),'.creeptime.txt']);
dlstime = importdata([filenamel(1:(size(filenamel,2)-4)),'.dynloadstartime.txt']);

% Textscan input parameters
fid = fopen(fullfile(datapath, datafile));
block_size = 10000;
form = '%22c %f %f';

% First create empty rawdata array makes code run faster
rdat = [];

% Read raw data text file into rdat
while ~feof(fid)
   clear tmpdat
   celin = textscan(fid, form, block_size); 
   tmpdat = [celin{1,1}];
   tmpdat = datenum(tmpdat);
   tmpdat = horzcat(tmpdat, [celin{1,2}]); 
   tmpdat = horzcat(tmpdat, [celin{1,3}]);
   rdat = vertcat(rdat, tmpdat);
end
fclose(fid);

% Clear temporary variables to free up memory
clear celin tmpdat fid form

% Convert from absolute time to elapsed test time & convert to seconds
rdat(:,1) = (rdat(:,1) - rdat(1,1))*86400;

% Find time closest to given creep time, then crop away creep data
[y,mini] = min(abs(rdat(:,1) - creeptime));
rdat(:,1) = rdat(:,1) - rdat(mini,1);
clear y mini

% Crop away creep data by deleting any rows where there is negative time value
rdat(any(rdat(:,1)<0,2),:)=[];

% Tare displacement, convert from um to mm
rdat(:,2) = -1/1000*(rdat(:,2) - rdat(1,2));% Note: disp must be <0 for FEBio model

% Tare, convert load from lb/g to N, 
%Uncomment for 250g load cell
rdat(:,3) = (rdat(:,3) - rdat(1,3))*0.00980665002864;

%Uncomment for 10lb load cell
% rdat(:,3) = (rdat(:,3) - rdat(1,3))*4.4482;

% Separate rawdata (rdat) into srldat and dyndat
if ~dlstime
    srldat = rdat;
    dyndat = [];
else
    rdat(:,4) = rdat(:,1) - dlstime; % make a temporary 4th col
    srldat = rdat;
    dyndat = rdat;
    
    srldat(any(srldat(:,4)>0,2),:) = [];
    dyndat(any(dyndat(:,4)<0,2),:) = [];
    rdat(:,4) = [];
    srldat(:,4) = [];
    dyndat(:,4) = [];
end

% Output equilibrium srl disp and srl load

Load_f=mean(srldat(length(srldat)-30:length(srldat),3))
disp_f=mean(srldat(length(srldat)-30:length(srldat),2));
disp('SRL eq load (N)'); disp('SRL eq disp (mm)')
disp(Load_f); disp(disp_f)

Time = srldat(:,1);  
a = dlstime-creeptime
ind_dynload = find((min(abs(Time-a))==sqrt((Time-a).*(Time-a)))==1)

    
ind_dynload = ind_dynload(1);

% Make figures
figure
subplot(2,1,1), plot(srldat(1:ind_dynload,1),-1*srldat(1:ind_dynload,2));

title([datafile]);
xlabel('time [s]');
ylabel('disp [mm]');
subplot(2,1,2), plot(srldat(1:ind_dynload,1),-1*srldat(1:ind_dynload,3));
hold on
xlabel('time [s]');
ylabel('load [N]');
set(gcf, 'Position', [560 90 660 860])
    
    
    smoothed = filter(ones(1,5)/5,1,srldat(:,3)) ;
    peakind = find(smoothed==min(smoothed));
    %peakind = find(fid.srl(:,3)==max(fid.srl(:,3)));
    peaktime = srldat(peakind,1);
    
    
    
    % Calculate the Resulting SRL Load Curve (assumes 3 degree
    % axial slice in model)

    
    TaredLoad = srldat(:,3)/120;

    v = [];
    feb = fopen(strcat(datapath,'TEMPLATE_opt.feb'),'r');
    datapath
    tline = fgetl(feb);
    while ischar(tline)
        tline = strcat(tline);
        tline = strrep(tline,'PATHPATHPATH',datapath);
        v = strvcat(v,tline);
        tline = fgetl(feb);
    end
    feb = fopen(strcat(datapath,'TEMPLATE_opt.feb'),'w');
    for i=1:17
        fprintf(feb,'%s \n',v(i,:));
    end
    
    % Compile and Save Data
    feb = fopen(strcat(datapath,'TEMPLATE_opt.feb'),'a');
    
    
    for i = 1:ind_dynload
        fprintf(feb,['\n<point>',num2str(Time(i)),',', ...
                    num2str(TaredLoad(i)),'</point>']);
    end
    
    fprintf(feb,['\n     </loadcurve>\n   </LoadData>\n</febio_optimize>']);
    fclose(feb)

    
    
    
    
    
    %% Part two_________________________________________
        
    
        
    format long
    


    %Ask user for Geometry
    
    
    srldisp = -1*disp_f;
    diameter = samplediam;
    thickness = sampleheight;
    
    Rad = diameter/2;
    
    %Upload positions (currently uses a function calling the generic
    %corrdinates for a 4 mm diam, 2.34 mm thick construct and
    %scales these positions - here there are 20 elements in the
    %radial direction and 1 element in the height (z)). These will
    %then be scaled according user defined parameters.
    xnode_orig = [0.0000000
0.3120967
0.3116690
0.5773789
0.5765877
0.8028688
0.8017685
0.9945352
0.9931722
1.1574517
1.1558654
1.2959306
1.2941546
1.4136378
1.4117004
1.5136888
1.5116144
1.5987322
1.5965412
1.6710191
1.6687290
1.7324630
1.7300887
1.7846902
1.7822444
1.8290834
1.8265767
1.8668176
1.8642592
1.8988917
1.8962893
1.9261547
1.9235150
1.9493282
1.9466567
1.9690257
1.9663272
1.9857686
1.9830471
2.0000000
1.9972591
0.0000000
0.3120967
0.3116690
0.5773789
0.5765877
0.8028688
0.8017685
0.9945352
0.9931722
1.1574517
1.1558654
1.2959306
1.2941546
1.4136378
1.4117004
1.5136888
1.5116144
1.5987322
1.5965412
1.6710191
1.6687290
1.7324630
1.7300887
1.7846902
1.7822444
1.8290834
1.8265767
1.8668176
1.8642592
1.8988917
1.8962893
1.9261547
1.9235150
1.9493282
1.9466567
1.9690257
1.9663272
1.9857686
1.9830471
2.0000000
1.9972591
-2.5000000
-2.5000000
2.5000000
2.5000000
-2.4965738
-2.4965738
2.4965738
2.4965738];
    
    ynode_orig = [0.0000000
0.0000000
0.0163339
0.0000000
0.0302177
0.0000000
0.0420189
0.0000000
0.0520500
0.0000000
0.0605763
0.0000000
0.0678238
0.0000000
0.0739841
0.0000000
0.0792204
0.0000000
0.0836712
0.0000000
0.0874544
0.0000000
0.0906701
0.0000000
0.0934035
0.0000000
0.0957268
0.0000000
0.0977017
0.0000000
0.0993803
0.0000000
0.1008072
0.0000000
0.1020200
0.0000000
0.1030508
0.0000000
0.1039271
0.0000000
0.1046719
0.0000000
0.0000000
0.0163339
0.0000000
0.0302177
0.0000000
0.0420189
0.0000000
0.0520500
0.0000000
0.0605763
0.0000000
0.0678238
0.0000000
0.0739841
0.0000000
0.0792204
0.0000000
0.0836712
0.0000000
0.0874544
0.0000000
0.0906701
0.0000000
0.0934035
0.0000000
0.0957268
0.0000000
0.0977017
0.0000000
0.0993803
0.0000000
0.1008072
0.0000000
0.1020200
0.0000000
0.1030508
0.0000000
0.1039271
0.0000000
0.1046719
0.2500000
-0.2500000
0.2500000
-0.2500000
-0.1308400
-0.1308398
0.1308398
0.1308400];
    
    znode_orig = [0.0000000
0.0000000
0.0000000
0.0000000
0.0000000
0.0000000
0.0000000
0.0000000
0.0000000
0.0000000
0.0000000
0.0000000
0.0000000
0.0000000
0.0000000
0.0000000
0.0000000
0.0000000
0.0000000
0.0000000
0.0000000
0.0000000
0.0000000
0.0000000
0.0000000
0.0000000
0.0000000
0.0000000
0.0000000
0.0000000
0.0000000
0.0000000
0.0000000
0.0000000
0.0000000
0.0000000
0.0000000
0.0000000
0.0000000
0.0000000
0.0000000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
2.3400000
-2.5000000
2.5000000
-2.5000000
2.5000000]; 

    xnode = xnode_orig;
    ynode = ynode_orig;
    znode = znode_orig;
    
    for i = 1:82;
        znode(i) = znode(i) * thickness / 2.34;
        
        if isequal(ynode(i), 0)
            xnode(i) = xnode(i) * Rad / 2;
            
        else
            h = sqrt(xnode(i) ^ 2 + ynode(i) ^2);
            xnode(i) = cosd(3) * h * (Rad / 2);
            ynode(i) = sind(3) * h * (Rad / 2);
            
        end
    end
    
    for i = 83:86;
        znode(i) = znode(i) * thickness / 2.34;
    end
    
    [xnode_orig,ynode_orig,znode_orig,xnode,ynode,znode];
    
    feb1 = fopen(strcat(datapath,'TEMPLATE1_srl.feb'),'a');
    feb2 = fopen(strcat(datapath,'TEMPLATE2_srl.feb'));

    
    for i = 1:length(xnode)
        fprintf(feb1,'\n %s',['<node id="',num2str(i),'"> ',num2str(xnode(i)),',',num2str(ynode(i)),', ',num2str(znode(i)),'</node>']);
    end
    
   
    tline = fgetl(feb2);
    
    platendisp = [num2str(peaktime),',',num2str(-1*srldisp)];
    
    while ischar(tline)
            tline = strcat(tline);
            fprintf(feb1,'\n %s',tline);
            tline = fgetl(feb2);
            
            %Replace XX with peak time, YY with 2*peaktime, and ZZ
            %with the platen displacement parameters
            tline = strrep(tline,'XX',num2str(peaktime));
            tline = strrep(tline,'YY',num2str(2*peaktime));
            
            tline = strrep(tline,'ZZ',platendisp);
        
    end
    
    

    fclose(feb1);

    fclose(feb2);
   


   
    
    
    
    
    

    
    
    
    