using Gtk
using DSP
using Plots; default(label="")
using FFTW: fft

include("realtime_input.jl")

# GtkButtonBox - container for arranging buttons
# GtkGrid - place widgets in rows and columns
# GtkImage - displays an image
# GtkLabel
# GtkFrame
# GtkWindow

# globals
duration = 5;
volume = 1;
instrument = 0; # 0 = vocal, 1 = oboe, 2 = guitar

# widgets
img = GtkImage("images/title.png");
plot = GtkImage("images/default_plot.png");
dur = GtkComboBoxText();
acc = GtkComboBoxText();
start = GtkButton("Start");
vol_up = GtkButton("Volume up");
vol_down = GtkButton("Volume down");

# setup start callback
signal_connect(start, "clicked") do widget, others...
    spec = realtime_input(duration, volume);
    map = heatmap(spec.time, spec.freq, spec.power, xguide="Time [s]", yguide="Frequency [Hz]", ylims=(0,1000));
    savefig(map, "images/heatmap.png");
    set_gtk_property!(plot, :file, "images/heatmap.png");
end

# setup duration dropdown
times = ["5 seconds", "10 seconds", "15 seconds", "20 seconds", "25 seconds", "30 seconds"];
for time in times
    push!(dur, time);
end
set_gtk_property!(dur, :active, 0);
signal_connect(dur, "changed") do widget, others...
    active_index = get_gtk_property(dur, "active", Int);
    global duration = (active_index + 1) * 5;
    print("Duration: "); print((active_index + 1) * 5); print(" seconds\n");
end

# setup accompaniment dropdown
accompaniments = ["Voice", "Guitar", "Distorted guitar", "Oboe", "Saxophone", "Flute", "Trumpet"];
for accompaniment in accompaniments
    push!(acc, accompaniment);
end
set_gtk_property!(acc, :active, 0);
signal_connect(acc, "changed") do widget, others...
    active_index = get_gtk_property(acc, "active", Int);
    global instrument = active_index;
    print("Instrument: "); print(active_index); print("\n");
end

# setup volume
signal_connect(vol_up, "clicked") do widget, others...
    global volume = volume + 1.0;
    if volume > 5.0
        global volume = 5.0;
    end
    print("Volume: "); print(volume); print("\n");
end
signal_connect(vol_down, "clicked") do widget, others...
    global volume = volume - 1.0;
    if volume < 1.0
        global volume = 1.0;
    end
    print("Volume: "); print(volume); print("\n");
end

# fill grid with widgets
g = GtkGrid();
set_gtk_property!(g, :row_spacing, 2);
set_gtk_property!(g, :column_spacing, 2);

g[1:4,1] = img;
g[1,2] = vol_up;
g[2,2] = vol_down;
g[3:4,2] = start;
g[1:2,3] = dur;
g[3:4,3] = acc;
g[1:4,4] = plot;

win = GtkWindow("Live Vocal Harmonizer", 700);
push!(win, g);
showall(win);
