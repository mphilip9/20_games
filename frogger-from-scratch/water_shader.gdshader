shader_type canvas_item;

// River flow parameters
uniform vec2 flow_direction = vec2(1.0, 0.0); // Direction of river flow
uniform float flow_speed : hint_range(0.0, 2.0, 0.1) = 0.3;
uniform float tile_size = 16.0; // Size of your tile in pixels

// Simple wave effects that work well with tiles
uniform float wave_amplitude : hint_range(0.0, 0.3, 0.01) = 0.1; // Keep small for tiles!
uniform float wave_frequency : hint_range(0.5, 5.0, 0.1) = 2.0; // Lower frequency for tiles
uniform float wave_speed : hint_range(0.0, 3.0, 0.1) = 1.0;

// Subtle shimmer effect
uniform float shimmer_amount : hint_range(0.0, 0.3, 0.01) = 0.1;
uniform float shimmer_frequency : hint_range(1.0, 10.0, 0.1) = 3.0;

// Optional color adjustments
uniform float brightness_variation : hint_range(0.0, 0.2, 0.01) = 0.05;
uniform vec4 water_tint : source_color = vec4(0.8, 0.9, 1.0, 1.0);
uniform float tint_strength : hint_range(0.0, 0.5, 0.01) = 0.1;

// Vertex displacement for wave effect
uniform float vertex_wave_amplitude : hint_range(0.0, 5.0, 0.1) = 2.0;

varying vec2 world_pos;

void vertex() {
    // In canvas_item shaders, we can use the vertex position directly
    // which gives us position in the tile's local space
    world_pos = VERTEX;

    // For TileMaps, we need to use a different approach
    // We'll create waves based on the vertex position
    float time = TIME * wave_speed;
    vec2 flow_dir = normalize(flow_direction);

    // Create wave based on position
    float wave_offset = dot(VERTEX / tile_size, flow_dir);
    float wave = sin((wave_offset * wave_frequency) - time) * vertex_wave_amplitude;

    // Apply perpendicular displacement for water flow look
    vec2 perp_dir = vec2(-flow_dir.y, flow_dir.x);
    VERTEX += perp_dir * wave;
}

void fragment() {
    // Use FRAGCOORD for world-space continuous effects
    // This gives us screen position which is continuous across tiles
    vec2 screen_uv = FRAGCOORD.xy / tile_size;

    // Simple UV distortion (very subtle for tiles)
    vec2 uv = UV;
    float time = TIME;

    // Small ripple effect based on screen position
    float ripple = sin(screen_uv.y * shimmer_frequency + time * flow_speed) * 0.02;
    uv.x += ripple;

    // Add a flowing distortion
    vec2 flow_dir = normalize(flow_direction);
    float flow_offset = dot(screen_uv, flow_dir);
    uv += flow_dir * sin(flow_offset * wave_frequency - time * wave_speed) * wave_amplitude * 0.1;

    // Get the base color
    vec4 base_color = texture(TEXTURE, uv);
    vec4 final_color = base_color;

    // Apply subtle tint
    if (tint_strength > 0.0) {
        final_color.rgb = mix(final_color.rgb, final_color.rgb * water_tint.rgb, tint_strength);
    }

    // Add shimmer based on screen position (continuous across tiles)
    if (shimmer_amount > 0.0) {
        float shimmer_offset = dot(screen_uv, flow_dir);
        float shimmer = sin((shimmer_offset * shimmer_frequency * 10.0) - time * flow_speed * 3.0) * 0.5 + 0.5;
        shimmer = pow(shimmer, 3.0); // Make highlights sharper
        final_color.rgb += shimmer * shimmer_amount;
    }

    // Subtle brightness variation
    if (brightness_variation > 0.0) {
        float brightness_wave = sin(screen_uv.x * 5.0 + screen_uv.y * 3.0 + time) * brightness_variation;
        final_color.rgb *= (1.0 + brightness_wave);
    }

    // Preserve alpha
    final_color.a = base_color.a;

    // Clamp
    final_color.rgb = clamp(final_color.rgb, 0.0, 1.0);

    COLOR = final_color;
}