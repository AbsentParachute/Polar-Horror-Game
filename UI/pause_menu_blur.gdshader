shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;

uniform float blur_lod  : hint_range(0.0, 6.0, 0.01) = 2.0;  // higher = blurrier
uniform float darkness  : hint_range(0.0, 1.0, 0.01) = 0.35; // 0..1
uniform float alpha     : hint_range(0.0, 1.0, 0.01) = 1.0;

void fragment() {
    vec3 c = textureLod(screen_texture, SCREEN_UV, blur_lod).rgb;
    c = mix(c, vec3(0.0), darkness);
    COLOR = vec4(c, alpha);
}
