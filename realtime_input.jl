#=
realtime_input.jl
Julia adaptation of MATLAB code from:
https://github.com/pkash16/eecs351_vocal_harmonizer
=#

using Sound: findpeaks
using DSP: hanning, spectrogram
using TickTock
using PortAudio
using SampledSignals
using FFTW: fft, ifft
using WAV
using Plots; default(label="")

include("realtime_harmonize.jl")

function realtime_input(time::Real = 5, volume::Real = 1.0)
    # constants
    SAMPLE_RATE = 44100; # Hz
    WINDOW_SIZE = 6000; # larger window size -> more delay
    PROCESSED_SIZE = floor(Int, WINDOW_SIZE + WINDOW_SIZE/2);
    SPECTROGRAM_N = 4000;

    # create input/output device
    stream = PortAudioStream(1, 1; samplerate=Float64(SAMPLE_RATE));
    # stream = PortAudioStream("Elgato Wave:1", "MacBook Pro Speakers", 1, 1; samplerate=Float64(SAMPLE_RATE));

    # variables for current and previous signals
    total_processed_signal = Float32[];
    prev_signal = fill(0, WINDOW_SIZE);
    prev_processed_signal = fill(0, PROCESSED_SIZE);
    signal = read(stream, WINDOW_SIZE);
    processed_signal = fill(0, PROCESSED_SIZE);

    print("Start input... ");
    tick()
    while (peektimer() < time)
        # push back buffers
        prev_signal = signal;
        prev_processed_signal = processed_signal;

        # record the new buffer
        read!(stream, signal);

        # call pitch_shift: takes in audio and outputs harmonized signal
        start = floor(Int, length(prev_signal)/2) + 1;
        processed_signal = realtime_harmonize([prev_signal[start:end]; signal], WINDOW_SIZE, SAMPLE_RATE);

        # write the end of the prev signal and the beginning of the new signal to the output signal
        final_output = ([prev_processed_signal[WINDOW_SIZE+1:end]; fill(0, WINDOW_SIZE)] + processed_signal) .* 0.5;
        final_output = real(final_output[1:WINDOW_SIZE]) ./ volume;
        total_processed_signal = [total_processed_signal; final_output];

        write(stream, final_output);
    end
    tock();
    print("End input.\n");
    close(stream);

    final_spectrogram = spectrogram(total_processed_signal, SPECTROGRAM_N, SPECTROGRAM_N >> 2; fs=SAMPLE_RATE);
    return final_spectrogram
end
