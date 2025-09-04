shader_type spatial;
render_mode cull_disabled;

uniform float time;
uniform float wave_strength = 0.1;
uniform float wave_speed = 1.0;
uniform float wave_freq = 2.0;
uniform sampler2D flag_texture;

void vertex() {
    float wave = sin(UV.x * wave_freq + time * wave_speed);
    
    // Weight the wave so it starts at 0 near UV.x = 0 (pinned side)
    float weight = UV.x;
    float offset = wave * wave_strength * weight;

    VERTEX.z += offset;
}

void fragment() {
    ALBEDO = texture(flag_texture, UV).rgb;
}