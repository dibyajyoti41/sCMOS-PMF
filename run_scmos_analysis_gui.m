% GUI for Selecting File and Inputting Parameters
function run_scmos_analysis_gui()
    % Create GUI figure
    fig = uifigure('Name', 'sCMOS Analysis GUI', 'Position', [100, 100, 400, 400]);

    % File selection
    lblFile = uilabel(fig, 'Position', [20 350 100 22], 'Text', 'Input TIFF File:');
    btnFile = uibutton(fig, 'push', 'Position', [130 350 150 22], 'Text', 'Select File', ...
        'ButtonPushedFcn', @(btn,event) selectFile(fig));

    % Parameter inputs
    fields = {'gain', 'adFactor', 'countOffset', 'shapeParameter', 'roNoise', 'alphaStar', 'pixelsize'};
    defaults = [0.8103, 1, 100.113, 0.051, 1.36, 0.01, 160];
    labels = {'Gain:', 'AD Factor:', 'Count Offset:', 'Shape Parameter:', 'Readout Noise:', 'Alpha*:', 'Pixel Size:'};
    for i = 1:length(fields)
        uilabel(fig, 'Position', [20 300-30*i 100 22], 'Text', labels{i});
        uieditfield(fig, 'numeric', 'Position', [130 300-30*i 100 22], 'Tag', fields{i}, 'Value', defaults(i));
    end

    % Run button
    btnRun = uibutton(fig, 'push', 'Position', [150 50 100 30], 'Text', 'Run Analysis', ...
        'ButtonPushedFcn', @(btn,event) runAnalysis(fig));

end

function selectFile(fig)
    [file, path] = uigetfile('*.tif', 'Select TIFF File');
    if file ~= 0
        fullpath = fullfile(path, file);
        fig.UserData.filename = fullpath;
        uialert(fig, ['Selected file: ', file], 'File Selected', 'Icon', 'success');

        % ✅ Enable the Run button and parameter fields
        for c = 1:numel(fig.Children)
            if isa(fig.Children(c), 'matlab.ui.control.NumericEditField')
                fig.Children(c).Editable = 'on';
                fig.Children(c).Enable = 'on';
            elseif strcmp(fig.Children(c).Text, 'Run Analysis')
                fig.Children(c).Enable = 'on';
            end
        end
    end
end


function runAnalysis(fig)
    % Get filename
    if ~isfield(fig.UserData, 'filename')
        uialert(fig, 'No file selected.', 'Error');
        return;
    end
    filename = fig.UserData.filename;

    % Get parameters from GUI
    chipParsSpec = struct();
    fields = {'gain', 'adFactor', 'countOffset', 'shapeParameter', 'roNoise', 'alphaStar', 'pixelsize'};
    for i = 1:length(fields)
        chipParsSpec.(fields{i}) = fig.Children(strcmp({fig.Children.Tag}, fields{i})).Value;
    end
    alphaStar = chipParsSpec.alphaStar;
    
    % Load image
    chipPars.inputImage = filename;
    image = Core.load_image(filename);
    T = 64;
    matrixBlocks = reshape(permute(reshape(double(image.imAverage), T, size(image.imAverage,1)/T, T, []), [1,3,2,4]), T, T, []);

    % Process each tile
    N = size(matrixBlocks,3);
    scores = nan(1,N);
    lambdaPars = nan(1,N);
    intthreshPars = nan(1,N);
    statsAll = cell(1,N);
    for idx = 1:N
        image2.imAverage = matrixBlocks(:,:,idx);
        [lambdaBg, intThreshBg, stats] = scmospmf_estimation(chipParsSpec, image2, alphaStar, 0);
        scores(idx) = min(stats.chi2Score);
        lambdaPars(idx) = lambdaBg;
        intthreshPars(idx) = intThreshBg;
        statsAll{idx} = stats;
    end
    
    % Save or visualize output as needed
    uialert(fig, 'Analysis completed.', 'Done');
idx1=101;

figure
    tiledlayout(1,2,'TileSpacing','compact','Padding','compact')
    nexttile
    pixelsize = 160;

    sampIm = mat2gray(image.imAverage);
    minInt = min(sampIm(:));
    medInt = median(sampIm(:));
    maxInt = max(sampIm(:));
    J = imadjust(sampIm,[minInt min(1,4*medInt)]);
    matrixBlocksJ = reshape(permute(reshape( double(J),T,size( J,1)/T,T,[]),[1,3,2,4]),T,T,[]);
 
    IM3 = padarray(matrixBlocksJ,[2 2],nan,'both');
    out = imtile(pagetranspose(IM3),'thumbnailsize',[64 64],'BorderSize', 2, 'BackgroundColor', 'cyan');
%     figure,imshow(out')

    imshow(pagetranspose(out),'InitialMagnification','fit');
    colormap winter
    %imshow(images.imAverage/max(images.imAverage(:)))
    hold on    
    % scale bar (ten microns in number of pixels)
    nPixels = 1e4/pixelsize;
    x = [5, 5 + nPixels ];
    y = [0.9*size(sampIm,1) , 0.9*size(sampIm,1)];
    plot(x,y,'Linewidth',8,'Color',[1 1 1])
    text(0,0.05,'10 microns','Fontsize',10,'Color',[1 1 1],'Units','normalized')
    title('(a)','Interpreter','latex')

structRes = statsAll{idx1};

intThreshBg =   intthreshPars(idx1);
lambdaBg=lambdaPars(idx1);
histAll = statsAll{idx1}.histAll;
stats = statsAll{idx1}.stats;
    nexttile    
binPos = 1:structRes.LU(2) + 0.5;
[minVal , idx] = min(abs(binPos - intThreshBg));
h1 = bar(binPos(1:idx),histAll(1:idx),1); 
set(h1,'FaceColor',[0.4 0.6 0.9])
set(h1,'EdgeColor','none')
hold on
h2 = bar(binPos(idx+1:end),histAll(idx+1:end-1),1); 
set(h2,'FaceColor',[1 0.5 0.3])
set(h2,'EdgeColor','none')
hold on
binCountsFit = stats.nBg.*structRes.pdf;
% binPos = binEdges(1:end-1) + diff(binEdges)/2;
plot(binCountsFit,'--','Color','black','LineWidth',2)

% Set figure labels, etc
xlabel('Image counts','Interpreter','latex')
ylabel('Histogram counts','Interpreter','latex')
% set(gca,'Fontsize',15)
% axis([30 80 0 46000])
[a,b] = ind2sub([16 16],idx1);
title(['(b) Fit for tile \{',num2str(a),',',num2str(b) , '\}'],'Interpreter','latex')

pbaspect([1 0.8 0.8])
legendEntry = strcat(['Fit, $\lambda_{bg} =  ' num2str(lambdaBg,2) ', N_{icr}^{bg}=' num2str(intThreshBg) '$']);
lgnd = legend('Image counts, true background','Image counts, not true background',legendEntry,'Interpreter','latex');
lgnd.Layout.Tile = 'south';

end


