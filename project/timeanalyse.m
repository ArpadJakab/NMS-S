% skrpit to analyze the data of arpads setup

clear all;

%load files
[filename Diri]=uigetfile('Z:\jan\','Select results of first Measurement');
%Diri=[strtok(Diri,'\')];
load([Diri filename]);


%analyse the first measurement
NoOfParticles=0;
WB=waitbar(0,'calcuation first measurements');
for i=1:size(results.job,1);
    waitbar(i/size(results.job,1),WB);
    if (size(results.job{i},1)>0)
        for j=1:size(results.job{i}.graph,1);
            S(NoOfParticles+j,1,:)=results.job{i}.graph{j}.normalized;
            P(NoOfParticles+j,1)=i;
            P(NoOfParticles+j,2)=results.job{i}.graph{j}.roi_particle.y;
            P(NoOfParticles+j,3)=results.job{i}.graph{1}.roi_particle.wy;
        end; 
        NoOfParticles=NoOfParticles+size(results.job{i}.graph,1);
    end;
end;
%generell constants
x_start=results.job{P(1)}.graph{1}.offset_x_px;
x_broad=size(results.job{P(1)}.graph{1}.particle,2);
lambda=results.job{P(1)}.graph{1}.axis.x;
white=results.white_light;
close(WB);

%find particles to close to the border of the CCD
sortout=find(P(:,2)+floor(1.5*P(:,3))>=401);
for i=size(sortout):-1:1;
    S(sortout(i),:,:)=[];
    P(sortout(i),:)=[];
end;
sortout=find(P(:,2)-round(0.5*P(:,3))<1); 
for i=size(sortout):-1:1;
    S(sortout(i),:,:)=[];
    P(sortout(i),:)=[];
end;
NoOfParticles=size(S,1);
clear sortout;

%calculate Max und FWHM
WB=waitbar(0,'calcuation Maximum and FWHM');
for i=1:NoOfParticles;
    waitbar(i/NoOfParticles,WB);
    [E_res(i,1) FWHM(i,1) MaxInt(i,1)]=timeDataAnalysis(S(i,1,:),lambda);
end;
close(WB);
clear i j;

%No of measurements
prompts={'How many measurements have you performed?'};
NoOfMeasurements=1;
defaults={num2str(NoOfMeasurements)};
NoOfMeasurements=getnumbers('',prompts,defaults);
clear defaults prompts;

%analyze next measurements
for k=2:NoOfMeasurements;
    directory_name = uigetdir(Diri,['Choose the directory of measurement No: ' num2str(k)]);
    WB=waitbar(0,'calcuation next measurements');
    for i=1:NoOfParticles;
        waitbar(i/NoOfParticles,WB);
        file=[directory_name '\Scan_' num2str(P(i,1)-1) '.000.mat'];
        load(file);
        %calculate and correct all spectra
        test_result=timeCalcSpec(camera_image,x_start,x_broad,P(i,2),P(i,3),white);  
        S(i,k,:)= test_result;
        %seach for particles without any intensity
        if (max(S(i,k,:))<=0)
            E_res(i,k)=NaN;
            FWHM(i,k)=NaN;
            MaxInt(i,k)=NaN;
        else
        %calcluate the maxima and FWHM
            [E_res(i,k) FWHM(i,k) MaxInt(i,k)]=timeDataAnalysis(S(i,k,:),lambda);
        end;
    end;
    close(WB);
end;
clear WB file i k;

%plot subfigures
refIndex=[1.33 1.38 1.43 1.48];
choice_sub=menu('Do you want to plot subplots?','yes','no');
counter=0;
if choice_sub==1
    for i=1:NoOfParticles;
        subplot(2,1,1);
        plot(refIndex,1240./E_res(i,:));
        xlabel('Refractive Index');
        ylabel('Wavelength [nm]');
        subplot(2,1,2);
        plot(lambda,permute(S(i,:,:),[3 2 1]));
        xlabel('Wavelength [nm]');
        ylabel('Intensity [arb. u.]');
        choice_sub=menu('You want to take thisone?','yes','no','abort all');
        if choice_sub==1;
            clf;
            counter=counter+1;
            intPart(counter)=i;
            intPartSpec(counter,:,:)=S(i,:,:);
            intPartMax(counter,:)=E_res(i,:);
            intPartFWHM(counter,:)=FWHM(i,:);
        end;
        if choice_sub==2;
            clf;
        end;
        if choice_sub==3;
            break;
        end;
    end;
end;
clear counter choice_sub i;

choice=menu('Do you want to save data as Matlab','yes','no');
if choice==1;
    save([Diri '\Auswertung.mat'], 'E_res','FWHM','MaxInt','P','S','lambda','refIndex','intPart','intPartSpec','intPartMax','intPartFWHM');
end;
