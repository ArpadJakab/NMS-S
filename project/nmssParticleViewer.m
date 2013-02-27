function nmssParticleViewer( particle )
%UNTITLED1 Summary of this function goes here
%  Detailed explanation goes here

    mycolor = ['r','b','g','k'];
    fig = figure();
    for i=1:length(particle)
        title(['Particle #', num2str(i)]);
        hold on;
        for k=1:4
            if (~isempty(particle{i}.pdata{k}))
                plot(particle{i}.pdata{k}.graph{1}.axis.x, particle{i}.pdata{k}.graph{1}.normalized, mycolor(k));
            end
        end
        
        answer = menu('Continue?','Yes','No');
        if (answer == 2)
            break;
        end
        cla;
        
    end