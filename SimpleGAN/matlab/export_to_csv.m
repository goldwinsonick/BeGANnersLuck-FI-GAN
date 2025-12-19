%% === EXTRACTION SCRIPT ===
% Exports weights, inputs, and outputs to CSV
% Format: Q8.8 Integer (Float * 256)

% Q8.8 conversion
to_q88 = @(x) round(x * 256);

%% 1. EXPORT PARAMETERS (weights.csv)
weights_list = [];

% Generator Layer 1 (9 params)
for i = 1:size(Wg2,1)
    weights_list = [weights_list; Wg2(i,:)'; bg2(i)]; 
end

% Generator Layer 2 (36 params)
for i = 1:size(Wg3,1)
    weights_list = [weights_list; Wg3(i,:)'; bg3(i)]; 
end

% Discriminator Layer 1 (30 params)
for i = 1:size(Wd2,1)
    weights_list = [weights_list; Wd2(i,:)'; bd2(i)]; 
end

% Discriminator Layer 2 (4 params)
weights_list = [weights_list; Wd3'; bd3]; 

writematrix(to_q88(weights_list), 'weights.csv');
fprintf('Success: Exported weights.csv\n');

%% 2. EXPORT INPUT TEST VECTOR (inputs.csv)
% Uses the last 'ng' (noise) from training as the test case
writematrix(to_q88(ng), 'inputs.csv');
fprintf('Success: Exported inputs.csv\n');

%% 3. EXPORT EXPECTED OUTPUT (outputs_matlab.csv)
% Contains 9 Pixel values followed by 1 Discriminator Score
output_data = [x_fake; y_fake];
writematrix(to_q88(output_data), 'outputs_matlab.csv');
fprintf('Success: Exported outputs_matlab.csv\n');