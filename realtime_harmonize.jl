#=
realtime_harmonize.jl

Julia adaptation of MATLAB code from:
https://github.com/pkash16/eecs351_vocal_harmonizer
=#

include("pitch_shift.jl")

function realtime_harmonize(input_signal, WINDOW_SIZE, SAMPLE_RATE)
    HALF_WINDOW = floor(Int, WINDOW_SIZE/2);

    # separate into 2 channels
    input_signal1 = input_signal[1:WINDOW_SIZE] .* hanning(WINDOW_SIZE);
    input_signal2 = input_signal[(HALF_WINDOW+1):end] .* hanning(WINDOW_SIZE);

    # run phase vocoder on the signals
    ultimate1 = pitch_shift(input_signal1, WINDOW_SIZE);
    ultimate2 = pitch_shift(input_signal2, WINDOW_SIZE);

    # ifft to return to time domain
    time_domain1 = ifft(ultimate1);
    time_domain2 = ifft(ultimate2);

    return [time_domain1; fill(0, HALF_WINDOW)] + [fill(0, HALF_WINDOW); time_domain2];
end
