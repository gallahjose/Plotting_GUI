function [ U,S,V,diagS ] = f_SVD( data, time, wave, varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%% Sets Options
opt.fig = 2;
opt.NumS = 15;
opt.NumPlotted = 5;
opt.showPlots = 1;
opt.inverse = 0; %can be a vector

% user input (after autodetection to allow user options)
[opt] = f_OptSet(opt, varargin);

[U,S,V] = svd(data);
diagS = diag(S);

if opt.inverse
    invert_vectorU = ones(length(U),1);
    invert_vectorV = ones(length(V),1);
    invert_vectorU(1:length(opt.inverse)) = opt.inverse;
    U = bsxfun(@times, U, invert_vectorU');
        invert_vectorV(1:length(opt.inverse)) = opt.inverse;
    V = bsxfun(@times, V, invert_vectorV');
   
end

%% Analysis Plots
if opt.showPlots
    
    diagSScalled = diagS(1:opt.NumPlotted,1);
    
    figure(opt.fig); scatter(1:opt.NumS,diagS(1:opt.NumS), 'MarkerEdgeColor','b',...
              'MarkerFaceColor','b',...
              'LineWidth',1);
    if ishandle(opt.fig+1)
    close(opt.fig+1)
    end
    [ h ] = f_MultiLinLogAxes( opt.NumPlotted, opt.fig+1);
    
    
    UScalled = U(:,1:opt.NumPlotted); %kinetics
    VScalled = V(:,1:opt.NumPlotted); %spectra
    UMax = max(abs(UScalled));
    UScalled = bsxfun(@rdivide,UScalled,UMax);
    VScalled = bsxfun(@times,VScalled,UMax.*diagSScalled');
    UMax = max(max(UScalled));
    UMin = min(min(UScalled));
    
    %Plots each components contributions
    for n = 1 : opt.NumPlotted
        f_PlotTraces(VScalled(:,n), wave, h(n), 'title',[], 'Ylabel', []);
    end

    for n = 1 : opt.NumPlotted
        hIndex = n*2-1 + opt.NumPlotted;
        f_PlotTraces(UScalled(:,n), time, [h(hIndex);h(hIndex+1)], 'title',[],'Ylabel', [], 'YLimits', [UMin UMax]);
    end
    for n = 1 : opt.NumPlotted
        hIndex = n*2-1 + 3*opt.NumPlotted;
        dataPred = VScalled(:,n)*UScalled(:,n)';
        
        f_PlotSurf(dataPred, time, wave, [h(hIndex);h(hIndex+1)],[]);
        axes(h(hIndex+1));
        colorbar('off');
    end
    f_JetBar('allAxes', h(1 + 3*opt.NumPlotted:end));
    
    %Plots surface and residuals from combininh multiple components
    [ h ] = f_MultiLinLogAxes( opt.NumPlotted, opt.fig+2, 'rowStyles', [{'LinLog'}], 'yPadding', 0.3);
    [ j ] = f_MultiLinLogAxes( opt.NumPlotted, opt.fig+3, 'rowStyles', [{'LinLog'}], 'yPadding', 0.3);
    for n = 1 : opt.NumPlotted
        hIndex = n*2-1;
        dataPred = U(:,1:n)*S(1:n,1:n)*V(:,1:n)';
        f_PlotSurf(dataPred, time, wave, [h(hIndex);h(hIndex+1)],[]);
        axes(h(hIndex+1));
        colorbar('off');
        f_PlotSurf(data-dataPred, time, wave, [j(hIndex);j(hIndex+1)],[]);
        axes(j(hIndex+1));
        colorbar('off');
    end
    f_JetBar('allAxes', h(1:end));
    %f_JetBar('allAxes', j(1:end), 'cMin',-0.25,'cMax',0.25);
    f_JetBar('allAxes', j(1:end), 'squeezecolorbar', 8);
end

    set(0,'Units','pixels')
    scnsize = get(0,'ScreenSize');
    fig7 = figure(7);
    
    position = get(fig7,'Position');
    outerpos = get(fig7,'OuterPosition');
    borders = outerpos - position;
    edge = -borders(1)/2;
    
    pos7 = [scnsize(3)/2 + edge, scnsize(4) * (1/2), scnsize(3)/2 - edge, scnsize(4)/2];
    pos8 = [edge, pos7(2), scnsize(3)/2 - edge, pos7(4)];
    pos9 = [edge, pos7(2)/2, scnsize(3)/2 - edge, scnsize(4)/4];
    pos10 = [edge, pos7(2) - scnsize(4) * (1/2), scnsize(3)/2 - edge, scnsize(4)/4];
    
    t7 = suptitle('SVD - Component number and relative weighting');
    set(t7,'FontSize',10,'FontWeight','bold')
    xlabel('Component', 'FontWeight','bold')
    ylabel('Weighting','FontWeight','bold')
    
    fig8 = figure(8);
    t8 = suptitle('SVD - Individial Components and weightings');
    set(t8,'FontSize',10,'FontWeight','bold')
    fig9 = figure(9);
    t9 = suptitle('SVD - Sum of Components');
    set(t9,'FontSize',10,'FontWeight','bold')
    fig10 = figure(10);
    t10 = suptitle('SVD - Residual of sum of components');
    set(t10,'FontSize',10,'FontWeight','bold')
    
    set(fig7,'OuterPosition',pos7, 'color',[1,1,1], 'Name', 'SVD - Number of component' )
    set(fig8,'OuterPosition',pos8, 'color',[1,1,1], 'Name', 'SVD - Indvividial Components')
    set(fig9,'OuterPosition',pos9, 'color',[1,1,1], 'Name','SVD - Summing Components')
    set(fig10,'OuterPosition',pos10, 'color',[1,1,1], 'Name', 'SVD Residual of Sum of Components')
