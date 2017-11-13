clc;
clear;
close all;

%% Set the size
r = 10;
c = 10;
n = r*c;

animation = true;

%% Create the object
obj = ExpansionSim(r, c);

%% Simulate dynamics
nSteps = 250;
obj.Update(nSteps);

%% Plot results
close all;
subplot(1, 2, 1);
obj.Plot();
subplot(1, 2, 2);
obj.PlotHistoric();

%% Generate animation
if animation
    figure;
    F = obj.Animate();
    
    AnimationSave(F, 'animation.gif');
end

%% Auxiliary functions
function AnimationSave(F, filename)
%ANIMATIONSAVE Saves array of frames as gif file
%
% As seen here: https://nl.mathworks.com/matlabcentral/answers/94495-how-can-i-create-animated-gif-images-in-matlab
N = numel(F);
for j = 1:N
    % Extract frame
    im = frame2im(F(j));
    [imind, cm] = rgb2ind(im, 256);
    
    % Write to the GIF File
    if j == 1
        imwrite(imind, cm, filename, 'gif', 'Loopcount', inf);
    else
        imwrite(imind, cm, filename, 'gif', 'WriteMode', 'append');
    end
end

end