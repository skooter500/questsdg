shader_type spatial;

uniform float alpha : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec4 albedo_tex = texture(TEXTURE, UV);
    ALBEDO = albedo_tex.rgb;
    ALPHA = albedo_tex.a * alpha;
}
