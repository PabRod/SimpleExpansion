classdef ExpansionSim < handle
    %EXPANSIONSIM Simulates a very simplified model of a free expansion
    %   Detailed explanation goes here
    
    properties(GetAccess = public, SetAccess = private)
        % Boolean matrix storing the available/occupied states at the left
        % compartment. Due to mass conservation, the right compartment can
        % be read as the complementary matrix
        occupationMatrix;
        
        % Array of boolean matrices storing the previous occupation
        % matrices
        historicMatrix = [];
    end
    
    methods(Access = public)
        %% Constructor
        function obj = ExpansionSim(r, c)
            % Creates an ExpansionSim object with r rows and c columns
            obj.occupationMatrix = ones(r, c);
            obj.LogToHistoric();
        end
        
        %% Dynamics        
        function Update(this, varargin)
            % Perform a series of nSteps unique updates (see private method UpdateOnce)
            switch nargin % Set the number of steps to simulate
                case 1
                    nSteps = 1;
                case 2
                    nSteps = varargin{1};
                otherwise
                    error('Wrong nargin');
            end
            
            % Simulate each step
            for i = 1:nSteps
                UpdateOnce(this);
            end
        end
        
        %% Extract information
        function [n, r, c] = Size(this)
            % Returns some measures of the occupation matrix
            r = size(this.occupationMatrix, 1); % Rows
            c = size(this.occupationMatrix, 2); % Columns
            n = numel(this.occupationMatrix(:)); % Number of elements
        end
        
        function N = NumberOfStates(this)
           % Returns the possible number of states
           [n, ~, ~] = Size(this);
           N = 2.^n; % Notice that our problem is isomorphic with binary numbers
        end
        
        function N = NumberOfCompatibleStates(this, nl)
            % Returns the number of possible states compatible with an
            % occupation number
            [n, ~, ~] = Size(this);
            N = nchoosek(n, nl);
        end
        
        function [Ml, Mr] = OccupationMatrices(this, varargin)
            % Returns the occupation matrices of the left and right
            % compartment
            switch nargin
                case 1
                    Ml = this.occupationMatrix;
                    Mr = ~this.occupationMatrix;
                case 2
                    t = varargin{1};
                    if iscell(t) % TODO: try to avoid this
                        t = cell2num(t);
                    end
                    Ml = this.historicMatrix{t};
                    Mr = ~this.historicMatrix{t};
                otherwise
                    error('Wrong nargin');
            end
        end
        
        function [nl, nr] = Occupation(this, varargin)
            % Returns the occupation number in each compartment
            switch nargin
                case 1
                    [Ml, Mr] = OccupationMatrices(this);
                case 2
                    [Ml, Mr] = OccupationMatrices(this, varargin);
                otherwise
                    error('Wrong nargin');
            end                
            nl = sum(Ml(:));
            nr = sum(Mr(:));
        end
        
        %% Graphical representation
        function Plot(this, varargin)
            % Plots the occupation diagram
            switch nargin
                case 1 % Extract current matrix
                    [Ml, Mr] = OccupationMatrices(this);
                case 2 % Extract nth matrix
                    [Ml, Mr] = OccupationMatrices(this, varargin);
                otherwise
                    error('Wrong nargin');
            end
            
            % Paste both matrices
            Mboth = [Ml, Mr];
            
            % Plot them
            imagesc(Mboth);
            hold on;
            
            % Plot the border
            [~, r, c] = Size(this);
            plot([c + 0.5, c + 0.5], [0,  r + 1], 'LineWidth', 7, 'Color', 'k');
            
            % Set aesthetics
            axis equal;
            set(gca,'xtick',[]); set(gca,'ytick',[]);
            title('Occupation diagram');
            hold off;
        end
        
        function PlotBar(this, varargin)
            % Bar plot of the occupation numbers
            switch nargin
                case 1
                    index = numel(this.historicMatrix);
                case 2
                    index = varargin{1};
                otherwise
                    error('Wrong nargin');
            end
                        
            [nl, nr] = this.Occupation(index);
            [n, ~, ~] = this.Size();
            b = bar([nl, n-nl; nr, n-nr], 'stacked');
            b(1).FaceColor = [248, 250, 13]./255; % Yellow
            b(2).FaceColor = [53, 42, 134]./255; % Dark blue
            set(gca, 'xticklabel', {'Left', 'Right'});
        end
        
        function PlotHistoric(this)
            % Plots the occupation numbers vs time
            tMax = numel(this.historicMatrix);
            nl = NaN(1, tMax); 
            nr = NaN(1, tMax);
            for j = 1:tMax % Extract occupation numbers at each time
                [nl(j), nr(j)] = this.Occupation(j);
            end
            
            % Plot it
            plot(nl);
            hold on;
            plot(nr);
            
            % Set aesthetics
            xlabel('Time steps'); ylabel('Occupation');
            title('Occupation vs. time');
            legend('Left compartment', 'Right compartment');
        end
        
        function F = Animate(this)
            % Generates an animation of the occupation states
            ax = gca;
            ax.NextPlot = 'replaceChildren';
            tMax = numel(this.historicMatrix);
            F(tMax) = struct('cdata',[],'colormap',[]);
            Nl = NaN(1, tMax);
            Nr = NaN(1, tMax);
            for j = 1:tMax
                [Nl(j), Nr(j)] = this.Occupation(j);
                subplot(1, 2, 1);
                this.Plot(j);
                subplot(1, 2, 2);
                this.PlotBar(j);
                titleStr = sprintf('Left: %d . Right: %d', Nl(j), Nr(j));
                title(titleStr);
                F(j) = getframe(gcf);
            end
        end
        
    end
    
    
    methods(Access = private)
        %% Dynamics
        function UpdateOnce(this)
            % Change the occupation state of a randomly chosen element
            n = this.Size();
            randIndex = randi(n); % Random number from 1 to n (inclusive)
            this.occupationMatrix(randIndex) = ~this.occupationMatrix(randIndex); % Switch state
            this.LogToHistoric();
        end
        
        %% Other functions
        function LogToHistoric(this)
            % Appends the current information to the historical log
            currentTimeIndex = numel(this.historicMatrix);
            this.historicMatrix{currentTimeIndex + 1} = this.occupationMatrix;
        end
        
    end
end

