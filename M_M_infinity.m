% Configuration
clear; % Clear all variables from the workspace
clc; % Clear the command window
close all; % Close all open figure windows
rng(11); % Random generator seed for reproducibility

% Parameters
lambda = 10; % Arrival rate (lambda calls per unit time)
mu = 2; % Service rate (mu calls per unit time)
total_time = 100; % Total time for the simulation (total unit time)

% Storage
inter_arrival_times_storage = []; % All inter-arrival times
service_times_storage = []; % All service times
time_in_system = []; % Unit time at specific event (index is event)
calls_in_system = []; % Number of calls at specific event (index is event)

% Initialization
current_time = 0; % Current system time
num_calls = 0; % Current number of calls in system
next_arrival_time = NaN; % Next arrival time
scheduled_departure_times = []; % Scheduled departures (not in order)

% Simulation
while current_time < total_time

    % Set the arrival time for the first call
    if (isnan(next_arrival_time))
        inter_arrival_time = exprnd(1 / lambda);
        next_arrival_time = current_time + inter_arrival_time;
        
        % Store inter arrival times
        inter_arrival_times_storage(end + 1) = inter_arrival_time;

        % Log event
        time_in_system(end + 1) = current_time;
        calls_in_system(end + 1) = num_calls;
        continue;
    end

    % Determine if the next event is an arrival or a departure
    if isempty(scheduled_departure_times) || next_arrival_time <= min(scheduled_departure_times)

        % Arrival event
        current_time = next_arrival_time;
        next_arrival_time = NaN; % Remove processed arrival
        num_calls = num_calls + 1;

        % Schedule the departure time for this call
        service_time = exprnd(1 / mu);
        scheduled_departure_times(end + 1) = current_time + service_time;

        % Set the arrival time for the next call
        inter_arrival_time = exprnd(1 / lambda);
        next_arrival_time = current_time + inter_arrival_time;

        % Store inter arrival and service times
        inter_arrival_times_storage(end + 1) = inter_arrival_time;
        service_times_storage(end + 1) = service_time;

    else

        % Departure event
        [departure_time, departure_index] = min(scheduled_departure_times);
        current_time = departure_time;
        scheduled_departure_times(departure_index) = []; % Remove processed departure
        num_calls = num_calls - 1;
    end

    % Log event
    time_in_system(end + 1) = current_time;
    calls_in_system(end + 1) = num_calls;
end


% Weighted average number of calls in the system
sum_calls = 0;
for i = 1:length(time_in_system)-1
    % Duration of the current event interval
    interval_duration = time_in_system(i+1) - time_in_system(i);
    
    % Weighted sum
    sum_calls = sum_calls + calls_in_system(i) * interval_duration;
end
average_calls = sum_calls / total_time;

% For probability distribution of number of calls in the system
[n, edges] = histcounts(calls_in_system, 'Normalization', 'probability');

% For probability distribution of tnter-arrival times
[m, medges] = histcounts(inter_arrival_times_storage, 'Normalization', 'probability');

% For probability distribution of service times
[k, kedges] = histcounts(service_times_storage, 'Normalization', 'probability');

% Screen size for positioning
screen_size = get(0, 'ScreenSize');
figure_width = screen_size(3) / 3;
figure_height = screen_size(4) / 2;


% Visualization: number of calls in the system over time
figure(1);
set(gcf, 'Color', [0.15, 0.15, 0.15], 'Position', [0, screen_size(4)-figure_height-200, figure_width, figure_height]);

stairs(time_in_system, calls_in_system, 'LineWidth', 1, 'Color', [0.9, 0.6, 0.2]);
hold on;

yline(average_calls, 'r--', 'LineWidth', 1);

title('Number of Calls in M/M/∞ System over Time', 'Color', 'w', 'FontSize', 14);
xlabel('Time', 'Color', 'w', 'FontSize', 12);
ylabel('Number of Calls', 'Color', 'w', 'FontSize', 12);

grid on;
set(gca, 'GridColor', 'w', 'GridAlpha', 0.7, 'Color', [0.05, 0.05, 0.05], 'XColor', 'w', 'YColor', 'w');

legend({'Calls in System', ['Average = ' num2str(average_calls, '%.2f')]}, 'Location', 'Best', 'TextColor', 'w');

axis equal;


% Visualization: probability distribution of calls in the system
figure(2);
set(gcf, 'Color', [0.15, 0.15, 0.15], 'Position', [2 * figure_width, screen_size(4)-figure_height-200, figure_width, figure_height]);

bar(edges(1:end-1) + diff(edges)/2, n, 'FaceColor', [0.9, 0.6, 0.2], 'EdgeColor', 'none', 'FaceAlpha', 0.8);
hold on;

title('Probability Distribution of Calls in M/M/∞ System', 'Color', 'w', 'FontSize', 14);
xlabel('Number of Calls', 'Color', 'w', 'FontSize', 12);
ylabel('Probability', 'Color', 'w', 'FontSize', 12);

grid on;
set(gca, 'GridColor', 'w', 'GridAlpha', 0.7, 'Color', [0.05, 0.05, 0.05], 'XColor', 'w', 'YColor', 'w');

legend({'Calls Distribution'}, 'Location', 'Best', 'TextColor', 'w');

axis padded;


% Visualization: probability distribution of inter-arrival and service times
figure(3);
set(gcf, 'Color', [0.15, 0.15, 0.15], 'Position', [figure_width, screen_size(4)-figure_height-200, figure_width, figure_height]);

% Inter-arrival times distribution
subplot(2, 1, 1);
bar(medges(1:end-1) + diff(medges)/2, m, 'FaceColor', [0.2, 0.7, 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.8);
hold on;

title('Probability Distribution of Inter-Arrival Times', 'Color', 'w');
xlabel('Inter-Arrival Time', 'Color', 'w');
ylabel('Probability', 'Color', 'w');

grid on;
set(gca, 'GridColor', 'w', 'GridAlpha', 0.7, 'Color', [0.05, 0.05, 0.05], 'XColor', 'w', 'YColor', 'w');

legend({'Inter-Arrival Times Distribution'}, 'Location', 'Best', 'TextColor', 'w');

axis padded;

% Service times distribution
subplot(2, 1, 2);
bar(kedges(1:end-1) + diff(kedges)/2, k, 'FaceColor', [0.9, 0.6, 0.2], 'EdgeColor', 'none', 'FaceAlpha', 0.8);

title('Probability Distribution of Service Times', 'Color', 'w');
xlabel('Service Time', 'Color', 'w');
ylabel('Probability', 'Color', 'w');

grid on;
set(gca, 'GridColor', 'w', 'GridAlpha', 0.7, 'Color', [0.05, 0.05, 0.05], 'XColor', 'w', 'YColor', 'w');

legend({'Service Times Distribution'}, 'Location', 'Best', 'TextColor', 'w');

axis padded;