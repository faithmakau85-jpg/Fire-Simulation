%% ================================================================
% CAPSTONE PROJECT 2: MODELING FOREST FIRE SPREAD
% Approach: Cellular Automata (CA)

%
% Cell states:
%   1 = Healthy (green)
%   2 = Burning (red)
%   3 = Burnt (dark grey)
%
% Fire rule:
%   A healthy cell with at least one burning cell in its Moore
%   neighbourhood has a 60% chance of catching fire.
%   Burning cells become burnt in the next time step.
%   Burnt cells remain burnt.
%% ================================================================

clear;
clc;
close all;
rng(1); % Makes the random simulation repeatable

%% STEP 1: Simulation parameters
gridSize = 50;
spreadProb = 0.6;
maxSteps = 100;

%% STEP 2: Define the three tree states
HEALTHY = 1;
BURNING = 2;
BURNT = 3;

%% STEP 3: Create the forest and set the initial fire source
forest = ones(gridSize, gridSize) * HEALTHY;
fireRow = round(gridSize / 2);
fireCol = round(gridSize / 2);
forest(fireRow, fireCol) = BURNING;

%% STEP 4: Define colours for the three states
% Rows correspond to HEALTHY, BURNING and BURNT, in that order.
myColors = [0.0 0.7 0.0; ...
            1.0 0.0 0.0; ...
            0.2 0.2 0.2];

%% STEP 5: Create a folder for figures
if ~exist('figures', 'dir')
    mkdir('figures');
end

%% STEP 6: Display and save the initial forest
figure('Name', 'Initial Forest');
imagesc(forest, [1 3]);
colormap(myColors);
caxis([1 3]);
axis image;
set(gca, 'YDir', 'normal');
colorbar('Ticks', [1 2 3], ...
         'TickLabels', {'Healthy', 'Burning', 'Burnt'});
xlabel('Column');
ylabel('Row');
title('Initial Forest - Time Step 0');
figDir = fullfile(pwd, 'figures');
if ~exist(figDir, 'dir')
    mkdir(figDir);
end
saveas(gcf, fullfile(figDir, 'initial_forest.png'));
saveas(gcf, fullfile('figures', 'initial_forest.png'));

%% STEP 7: Display the Moore neighbourhood around the fire source
r1 = max(fireRow - 1, 1);
r2 = min(fireRow + 1, gridSize);
c1 = max(fireCol - 1, 1);
c2 = min(fireCol + 1, gridSize);
neighborhood = forest(r1:r2, c1:c2);

disp('Moore neighbourhood around the initial fire source:');
disp(neighborhood);

%% STEP 8: Prepare arrays to record the number of each tree state
healthyCount = zeros(maxSteps + 1, 1);
burningCount = zeros(maxSteps + 1, 1);
burntCount = zeros(maxSteps + 1, 1);

healthyCount(1) = sum(forest(:) == HEALTHY);
burningCount(1) = sum(forest(:) == BURNING);
burntCount(1) = sum(forest(:) == BURNT);

%% STEP 9: Run the Cellular Automata simulation
fprintf('\nFOREST FIRE SIMULATION STARTED\n');

figure('Name', 'Forest Fire Animation');

for step = 1:maxSteps
    % Use a separate grid so all cells update simultaneously.
    newForest = forest;

    for row = 1:gridSize
        for col = 1:gridSize

            % Rule 1: A burning tree becomes burnt.
            if forest(row, col) == BURNING
                newForest(row, col) = BURNT;

            % Rule 2: A healthy tree may catch fire.
            elseif forest(row, col) == HEALTHY
                % Get the surrounding 3-by-3 area, including diagonals.
                rA = max(row - 1, 1);
                rB = min(row + 1, gridSize);
                cA = max(col - 1, 1);
                cB = min(col + 1, gridSize);
                block = forest(rA:rB, cA:cB);

                % Count burning cells in the Moore neighbourhood.
                burningNeighbors = sum(block(:) == BURNING);

                % At least one burning neighbour gives a 60% chance.
                if burningNeighbors > 0 && rand < spreadProb
                    newForest(row, col) = BURNING;
                end
            end

            % Rule 3: Burnt trees remain burnt (no action needed).
        end
    end

    % Apply all changes together at the end of the time step.
    forest = newForest;

    %% STEP 10: Record the number of each state
    healthyCount(step + 1) = sum(forest(:) == HEALTHY);
    burningCount(step + 1) = sum(forest(:) == BURNING);
    burntCount(step + 1) = sum(forest(:) == BURNT);

    %% STEP 11: Update the animation
    imagesc(forest, [1 3]);
    colormap(myColors);
    caxis([1 3]);
    axis image;
    set(gca, 'YDir', 'normal');
    colorbar('Ticks', [1 2 3], ...
             'TickLabels', {'Healthy', 'Burning', 'Burnt'});
    xlabel('Column');
    ylabel('Row');
    title(['Forest Fire Simulation - Time Step ', num2str(step)]);
    drawnow;
    pause(0.1);

    %% STEP 12: Print the counts for this time step
    fprintf('Step %d: Healthy = %d, Burning = %d, Burnt = %d\n', ...
        step, healthyCount(step + 1), ...
        burningCount(step + 1), burntCount(step + 1));

    %% STEP 13: Stop if there are no burning trees left
    if burningCount(step + 1) == 0
        fprintf('\nFire stopped spreading at step %d.\n', step);
        break;
    end
end

%% STEP 14: Calculate the final counts and percentages
finalHealthy = sum(forest(:) == HEALTHY);
finalBurning = sum(forest(:) == BURNING);
finalBurnt = sum(forest(:) == BURNT);
totalCells = numel(forest);

percentHealthy = 100 * finalHealthy / totalCells;
percentBurning = 100 * finalBurning / totalCells;
percentBurnt = 100 * finalBurnt / totalCells;

%% STEP 15: Display and save the final forest
figure('Name', 'Final Forest');
imagesc(forest, [1 3]);
colormap(myColors);
caxis([1 3]);
axis image;
set(gca, 'YDir', 'normal');
colorbar('Ticks', [1 2 3], ...
         'TickLabels', {'Healthy', 'Burning', 'Burnt'});
xlabel('Column');
ylabel('Row');
title('Final Forest Distribution');
saveas(gcf, fullfile('figures', 'final_forest.png'));

%% STEP 16: Plot and save the changes in tree populations
timeSteps = 0:step;
figure('Name', 'Forest Fire Statistics');
plot(timeSteps, healthyCount(1:step + 1), 'g-', 'LineWidth', 2);
hold on;
plot(timeSteps, burningCount(1:step + 1), 'r-', 'LineWidth', 2);
plot(timeSteps, burntCount(1:step + 1), 'k-', 'LineWidth', 2);
xlabel('Time Steps');
ylabel('Number of Trees');
title('Changes in Tree States During the Fire');
legend('Healthy Trees', 'Burning Trees', 'Burnt Trees', ...
       'Location', 'best');
grid on;
hold off;
saveas(gcf, fullfile('figures', 'tree_state_over_time.png'));

%% STEP 17: Compare the final number of trees in each state
figure('Name', 'Final Tree Counts');
bar([finalHealthy, finalBurning, finalBurnt]);
set(gca, 'XTick', 1:3, ...
         'XTickLabel', {'Healthy', 'Burning', 'Burnt'});
ylabel('Number of Cells');
title('Final Number of Trees in Each State');
grid on;
saveas(gcf, fullfile('figures', 'final_tree_counts.png'));

%% STEP 18: Print the final results
fprintf('\n========================================\n');
fprintf('          FINAL SIMULATION RESULTS\n');
fprintf('========================================\n');
fprintf('Total forest cells: %d\n', totalCells);
fprintf('Healthy trees: %d (%.2f%%)\n', finalHealthy, percentHealthy);
fprintf('Burning trees: %d (%.2f%%)\n', finalBurning, percentBurning);
fprintf('Burnt trees: %d (%.2f%%)\n', finalBurnt, percentBurnt);
fprintf('Number of time steps: %d\n', step);
fprintf('Figures saved in the figures folder.\n');
fprintf('SIMULATION COMPLETED SUCCESSFULLY.\n');
