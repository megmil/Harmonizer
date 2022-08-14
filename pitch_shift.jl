using Plots; default(label="")

#=
pitch_shift.jl
Julia adaptation of MATLAB code from:
https://github.com/pkash16/eecs351_vocal_harmonizer
=#

include("peak_shift.jl")

function pitch_shift(y, window_size)
    # constants
    eps_peak = 0.2; # findpeaks threshold
    max_peak = 6; # max number of peaks
    mask_width = 10; # larger mask width -> less clean up
    half_window = floor(Int, window_size/2);

    # vectors
    clean_signal = fill(0, window_size);
    final_signal = fill(0, window_size);

    # harmonic ratios
    major_third = 1.25;
    perfect_fifth = 1.5;

    # take fft
    freq_signal = fft(y);
    half_freq = freq_signal[1:half_window];

    # find the best peaks
    peak_locs = []
    if (length(half_freq) > 3)
        peak_locs = findpeaks(abs.(half_freq), max_peak, eps_peak);
    end
    num_peaks = length(peak_locs);

    if num_peaks == 0
        final_signal = half_freq;
    else
        peaks = [];
        if num_peaks == 1
            peaks = peak_locs[1];
        else
            peaks = peak_locs[1:num_peaks];
        end
        mask_window = fill(0, half_window);
        for peak in 1:num_peaks
            w = floor(Int, mask_width);
            mask_window[max(peaks[peak]-w, 1):min(peaks[peak]+w, half_window)] .= 1;
        end
        clean_signal = half_freq .* mask_window;
        shift1 = peak_shift(clean_signal, major_third, window_size, peaks, num_peaks, mask_width);
        shift2 = peak_shift(clean_signal, perfect_fifth, window_size, peaks, num_peaks, mask_width);
        final_signal = half_freq .+ shift1 .+ shift2;
    end
    return [final_signal; reverse(final_signal)];
end
