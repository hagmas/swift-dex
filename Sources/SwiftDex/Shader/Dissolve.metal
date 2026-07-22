#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

static float random(float2 p) {
    return fract(sin(dot(p, float2(127.1, 311.7))) * 43758.5453123);
}

/// Dissolves a layer in or out using cell-based value noise.
///
/// - progress: 0 = fully dissolved (invisible), 1 = fully visible.
/// - cellSize: The size of the dissolve grain, in points.
[[ stitchable ]] half4 dissolve(float2 position, SwiftUI::Layer layer, float progress, float cellSize) {
    half4 color = layer.sample(position);
    float noise = random(floor(position / max(cellSize, 1.0)));

    // Slightly overshoot the threshold so every cell (noise in [0, 1)) is
    // fully visible at progress == 1, with a soft edge while animating.
    float threshold = progress * 1.05;
    float visibility = smoothstep(noise, noise + 0.05, threshold);

    return color * half(visibility);
}
