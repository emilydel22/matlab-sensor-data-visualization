%% DelgadoGonzalez_Emily_BME4503C_Assignment_Temp.m
% Author: Emily D. Delgado Gonzalez
% Course: BME4503C
% Assignment: Temperature Sensor with Arduino Leonardo
%
% Purpose:
%   Control inputs/outputs of an Arduino Leonardo board in MATLAB.
%   Read analog signals from an LM335 temperature sensor and activate
%   an LED and buzzer when the measured temperature crosses a threshold.
%
% Tasks:
%   - Continuously record temperature for ~30 seconds
%   - Show a real-time temperature plot
%   - Trigger LED + buzzer when threshold is reached
%   - Plot rate of temperature change and compare estimated vs actual time

clear; close all; clc;

%% --- Pin Setup and Arduino Connection ---
% Connect to Arduino Leonardo (update port if needed)
a = arduino('/dev/cu.usbmodem1101','Leonardo');  

tempPin  = 'A0';   % LM335 temperature sensor on analog pin A0
ledPin   = 'D9';   % LED on digital pin 9
buzzPin  = 'D10';  % Buzzer on digital pin 10

% Set outputs low to start
writeDigitalPin(a, ledPin, 0);
writeDigitalPin(a, buzzPin, 0);

%% --- Experiment Parameters ---
Fs        = 10;        % sample rate (Hz)
tMax      = 32;        % record for ~32 seconds
N         = Fs * tMax; % total samples
threshC   = 32;        % threshold in Celsius
time      = zeros(N,1);
tempC     = zeros(N,1);

fprintf('Recording for %d seconds...\n', tMax);

%% --- Real-time Acquisition and Plotting ---
figure('Color','w');
hLine = animatedline('Color','b', ...
                     'Marker','o', ...
                     'LineWidth',1.6, ...
                     'MarkerSize',4);
xlabel('Time (s)'); ylabel('Temperature (°C)');
title('Real-Time Temperature Reading (LM335)');
grid on;
yline(threshC,'--r','Threshold');

alerted = false;
tic;
for k = 1:N
    % Read LM335 voltage
    v = readVoltage(a, tempPin);      % in Volts
    T_K = v / 0.010;                  % LM335 gives 10 mV per Kelvin
    T_C = T_K - 273.15;               % convert to Celsius
    
    % Log values
    time(k)  = toc;
    tempC(k) = T_C;
    
    % Update plot
    addpoints(hLine, time(k), tempC(k));
    xlim([0 max(5,time(k))]);
    drawnow limitrate;
    
    % Trigger LED and buzzer if threshold crossed
    if ~alerted && T_C >= threshC
        writeDigitalPin(a, ledPin, 1);
        writeDigitalPin(a, buzzPin, 1);
        alerted = true;
        fprintf('Threshold reached at %.2f s (%.2f °C)\n', time(k), T_C);
    end
    
    pause(1/Fs);
end   
