%Chih-Yuan Yang
%11/20/12
%Separate from PP9
%Draw edge prior
clear
clc
close all
folder_data = 'EdgePriors';
folder_save = 'EdgePriors2';
U22_makeifnotexist(folder_save);
fn_data = 'Statistics_Sc4_Si1.6.mat';
load(fullfile(folder_data,fn_data));
zooming = 4;
Gau_sigma = 1.6;
%     loaddata = load(fullfile(folder_data,fn_data));
%     DistLength = loaddata.DistLength;
%     BinNumber = loaddata.BinNumber;
%     Statistics = loaddata.Statistics;
    for i=1:DistLength
        hFig = figure;
        %need to control here, if d=0, plot is a better choice than mesh
        if i==1
            MeanValue = zeros(1,BinNumber);
            StdValue = zeros(1,BinNumber);
            for j=1:BinNumber
                MeanValue(j) = Statistics(i).EstimatedMag(j,j);
                StdValue(j) =  Statistics(i).StdRecord(j,j);
            end
            plot(BinCenter,MeanValue,'ro');
            hold on
            plot(BinCenter,MeanValue-StdValue,'bx');
            plot(BinCenter,MeanValue+StdValue,'bx');
            xlabel('$m_p$','interpreter','latex','FontSize',30);
            ylabel('$\bar{m}''_p$','interpreter','latex','FontSize',30);
            axis equal
        else
            mesh(BinCenter,BinCenter,Statistics(i).EstimatedMag);
            zlabel('$\bar{m}''_p$','interpreter','latex','FontSize',30);
            xlabel('$m_c$','interpreter','latex','FontSize',30,'Position',[0.2 -0.2 0]);
            ylabel('$m_p$','interpreter','latex','FontSize',30,'Position',[-0.1 0.3 0]);
            colorbar
            caxis([0 1.6]);
            zlim([0 1.6]);
            hAxes = gca;
            hAxesPosition = get(hAxes,'Position');
            set(hAxes,'Position',[hAxesPosition(1)+0.01 hAxesPosition(2) hAxesPosition(3) hAxesPosition(4)]);
        end
        dist = b(i);
        fn_save = sprintf('EdgePriors_Sc%d_Si%dp%d_dist%dp%d.png',...
            zooming,...
            floor(Gau_sigma),floor(10*(eps+Gau_sigma-floor(Gau_sigma))),...
            floor(dist)          ,floor(10*(eps+dist-floor(dist)))...
            );
        saveas(hFig,fullfile(folder_save,fn_save));
        close(hFig);
    end
