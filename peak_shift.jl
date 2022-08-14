#=
peak_shift.jl

Julia adaptation of MATLAB code from:
https://github.com/pkash16/eecs351_vocal_harmonizer
=#

function peak_shift(clean_signal, ratio, window_size, peaks, num_peaks, mask_width)
    half_window = floor(Int, window_size/2);
    shifted_signal = complex(fill(0.0, half_window));
    for index in 1:num_peaks
        signal_index = peaks[index];
        scaled_index = floor(Int, signal_index * ratio);

        signal_left_span = signal_index - max(signal_index - mask_width, 1);
        signal_right_span = min(signal_index + mask_width, half_window) - signal_index;

        scaled_left_span = scaled_index - max(scaled_index - mask_width, 1);
        scaled_right_span = min(scaled_index + mask_width, half_window) - scaled_index;

        left_span = min(scaled_left_span, signal_left_span);
        right_span = min(scaled_right_span, signal_right_span);

        freq_shift = (scaled_index - signal_index) * 2 * pi / window_size;
        scaled_range = (scaled_index - left_span):(scaled_index + right_span);
        signal_range = (signal_index - left_span):(signal_index + right_span);

        shifted_signal[scaled_range] .= (clean_signal[signal_range] .* exp(1im * freq_shift * half_window));
    end
    
    return shifted_signal;
end
