% GET THE STANDARD 3D TRAJECTORY DATA.figureProperties [ UPDATED ]
function [currentFigure,figureHandle] = GetFigure_estimate_errors(SIM,objectIndex,DATA,currentFigure)

% CONFIGURE THE PLOT ATTRIBUTES
figurePath = strcat(SIM.outputPath,'isometric');
figureHandle = figure('Name','OpenMAS isometric view');
set(figureHandle,'Position',DATA.figureProperties.windowSettings);         % [x y width height]
set(figureHandle,'Color',DATA.figureProperties.figureColor);               % Background colour 
% setappdata(figureHandle, 'SubplotDefaultAxesLocation', [0.08, 0.08, 0.90, 0.88]); % MAXIMISE GRAPH SIZE IN WINDOW
ax = axes(figureHandle);
legendCounter = 1; legendEntries = cell(DATA.totalObjects,1);

hold on; grid on; box on; grid minor;
for ID1 = 1:DATA.totalObjects    
    % GET OBJECT OVERVIEW DATA
    legendString = sprintf('[ID-%s] %s',num2str(SIM.OBJECTS(ID1).objectID),SIM.OBJECTS(ID1).name);
    legendEntries(legendCounter) = {legendString};
    % THE ASSOCIATED LOGIC
    objectID1 = objectIndex{SIM.globalIDvector == SIM.OBJECTS(ID1).objectID};
    % EXTRACT FINAL POSITION DATA FROM THE TRAJECTORY MATRIX
    [finalStates] = OMAS_getTrajectoryData(DATA.globalTrajectories,SIM.globalIDvector,SIM.OBJECTS(ID1).objectID,SIM.TIME.endStep);
    finalPosition = finalStates(1:3,:);
    
    % LOCAL FIXED TO GLOBAL ROTATED
    R_final = OMAS_geometry.quaternionToRotationMatrix(finalStates(7:10));
    
    % DISPLAY THE OBJECT
    if numel(objectID1.GEOMETRY.vertices) > 0
        patch(ax,'Vertices',objectID1.GEOMETRY.vertices*R_final + finalPosition',...
            'Faces',objectID1.GEOMETRY.faces,...
            'FaceColor',SIM.OBJECTS(ID1).colour,...
            'EdgeColor',DATA.figureProperties.edgeColor,...
            'EdgeAlpha',DATA.figureProperties.edgeAlpha,...  
            'FaceLighting',DATA.figureProperties.faceLighting,...
            'FaceAlpha',DATA.figureProperties.faceAlpha,...
            'LineWidth',DATA.figureProperties.patchLineWidth);             % Patch properties            % Patch properties
    else
        % PLOT THE TERMINAL POSITIONS
        plot3(ax,finalPosition(1),finalPosition(2),finalPosition(3),...
              'Marker',SIM.OBJECTS(ID1).symbol,...
              'MarkerSize',DATA.figureProperties.markerSize,...
              'MarkerFaceColor',SIM.OBJECTS(ID1).colour,...
              'MarkerEdgeColor',DATA.figureProperties.markerEdgeColor,...
              'LineWidth',DATA.figureProperties.lineWidth,...
              'LineStyle',DATA.figureProperties.lineStyle,...
              'Color',SIM.OBJECTS(ID1).colour); 
    end  
    legendCounter = legendCounter + 1;
end
legend('off')
hold on;

% DATA.ids(index, :, META.TIME.currentStep) = IDs';
% DATA.estimates(index, ID, :, META.TIME.currentStep) = X_relative;

for ID1 = 1:DATA.totalAgents 
    idleFlag = NaN('double');
    [objectStates] = OMAS_getTrajectoryData(DATA.globalTrajectories,SIM.globalIDvector,SIM.OBJECTS(ID1).objectID,idleFlag);
    agent_pos = objectStates(1:3,:);
    for ID2 = 1:DATA.totalObjects
        positions = squeeze(DATA.estimate_errors(ID1, ID2, 1:3, :));
        % EXTRACT STATE TIME-SERIES DATA UPTO THE IDLE POINT
        plot3(positions(1,:),positions(2,:),positions(3,:),...
              'LineStyle',DATA.figureProperties.lineStyle,...
              'LineWidth',DATA.figureProperties.lineWidth,...
              'Color',SIM.OBJECTS(ID1).colour);
    end
end

% Title
title(ax,...
    sprintf('Object trajectories over a period of %ss',num2str(SIM.TIME.endTime)),...
    'interpreter',DATA.figureProperties.interpreter,...
    'fontname',DATA.figureProperties.fontName,...
    'fontweight',DATA.figureProperties.fontWeight,...
    'fontsize',DATA.figureProperties.titleFontSize,...
    'fontsmoothing','on');
% X-Label
xlabel(ax,'x (m)',...
    'Interpreter',DATA.figureProperties.interpreter,...
    'fontname',DATA.figureProperties.fontName,...
    'Fontweight',DATA.figureProperties.fontWeight,...
    'FontSize',DATA.figureProperties.axisFontSize,...
    'FontSmoothing','on');
% Y-Label
ylabel(ax,'y (m)',...
    'Interpreter',DATA.figureProperties.interpreter,...
    'fontname',DATA.figureProperties.fontName,...
    'Fontweight',DATA.figureProperties.fontWeight,...
    'FontSize',DATA.figureProperties.axisFontSize,...
    'FontSmoothing','on');
% Z-Label
zlabel(ax,'z (m)',...
    'Interpreter',DATA.figureProperties.interpreter,...
    'fontname',DATA.figureProperties.fontName,...
    'Fontweight',DATA.figureProperties.fontWeight,...
    'FontSize',DATA.figureProperties.axisFontSize,...
    'FontSmoothing','on');
% Axes
set(ax,...
    'TickLabelInterpreter',DATA.figureProperties.interpreter,...
    'fontname',DATA.figureProperties.fontName,...
    'Fontweight',DATA.figureProperties.fontWeight,...
    'FontSize',DATA.figureProperties.axisFontSize,...
    'FontSmoothing','on',...
    'Color',DATA.figureProperties.axesColor,...
    'GridLineStyle','--',...
    'GridAlpha',0.25,...
    'GridColor','k');
% Legend
legend(legendEntries,...
    'location','northeastoutside',...
    'fontname',DATA.figureProperties.fontName,...
    'interpreter',DATA.figureProperties.interpreter);

% xlim(ax,[-DATA.figureProperties.maxAbsPosition,DATA.figureProperties.maxAbsPosition]);
% ylim(ax,[-DATA.figureProperties.maxAbsPosition,DATA.figureProperties.maxAbsPosition]);
%zlim(ax,[-DATA.figureProperties.maxAbsPosition,DATA.figureProperties.maxAbsPosition]);
%xlim(ax,[DATA.figureProperties.axisMinimums(1)-0.1,DATA.figureProperties.axisMaximums(1)+0.1]);
%ylim(ax,[DATA.figureProperties.axisMinimums(2)-0.1,DATA.figureProperties.axisMaximums(2)+0.1]);
% zlim(ax,[DATA.figureProperties.axisMinimums(3),DATA.figureProperties.axisMaximums(3)]);

axis vis3d equal;     
view([-24 36]);
set(ax,'outerposition',[0.05 0.15 1 0.68]);                               % Set the axes offset position in the figure window
grid on; grid minor;
hold off;

% SAVE THE OUTPUT FIGURE
savefig(figureHandle,figurePath); 

% Publish as .pdf if requested
if DATA.figureProperties.publish
	GetFigurePDF(figureHandle,figurePath);   
end

% FIGURE COMPLETE
currentFigure = currentFigure + 1;
% CLEAN UP
clearvars -except currentFigure figureHandle
end
