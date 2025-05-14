using Logomaker
using Colors  # For defining custom colors

# Define the letters
letters = ['T', 'a', 'r', 'g', 'e', 't', 'T', 'r', 'i', 'a', 'l', 'E', 'm', 'u', 'l', 'a', 't', 'i', 'o', 'n']

# Define weights for each position (a single column matrix with equal weights)
weights = ones(length(letters), 1)  # Each letter gets the same score of 1.0

# Define custom color scheme for the Julia colors
color_scheme = Dict(
    'T' => "purple",
    'a' => "purple",
    'r' => "purple",
    'g' => "purple",
    'e' => "purple",
    't' => "purple",
    'T' => "cyan",
    'r' => "cyan",
    'i' => "cyan",
    'a' => "cyan",
    'l' => "cyan",
    'E' => "yellow",
    'm' => "yellow",
    'u' => "yellow",
    'l' => "yellow",
    'a' => "yellow",
    't' => "yellow",
    'i' => "yellow",
    'o' => "yellow",
    'n' => "yellow"
)

# Create the logo
logo = Logomaker.Logo(weights, letters; color_scheme=color_scheme)

# Customize the axes
logo.ax.set_ylim(0, 1.5)  # Adjust the height of the bars
logo.ax.set_xlabel("TargetTrialEmulation.jl")
logo.ax.set_ylabel("Score")

# Display the logo
logo.fig
